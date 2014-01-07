module (..., package.seeall)

local active = {}
local params = {}
local nonfiring = {}
local qc = {}

items_stored = {}
items_unworn = {}

fn = {}
ck = {}

local function set(name, time, nofire)
  if not time then
    activate(name)
  else
    display.Debug("Failsafe '" .. name .. "' [" .. time .. "s]", "failsafes")

    local timer_name = string.gsub(name, "[ :]", "_") .. "_failsafe__"
    if IsTimer(timer_name) ~= 0 then
      local minutes = math.floor(time / 60)
      local seconds = time % 60
      ImportXML([[<timers>
  <timer
    name="]] .. timer_name .. [["
    minute="]] .. minutes .. [["
    second="]] .. seconds .. [["
    offset_second="0.00"
    active_closed="y"
    one_shot="y"
    temporary="y"
    send_to="12"
    group="Failsafes" >
  <send>failsafe.activate("]] .. name .. [[")</send>
  </timer>
  </timers>]])
    else
      -- Synchronize timer to desired value
      local minutes = math.floor(time / 60)
      local seconds = time % 60
      SetTimerOption(timer_name, "minute", minutes)
      SetTimerOption(timer_name, "second", seconds)
    end
    EnableTimer(timer_name, true)
    ResetTimer(timer_name)

    nonfiring[name] = nofire
  end
end

function activate(name)
  if not active[name] then
    return
  end

  display.Debug("Failsafe executing: " .. name, "failsafes")
  active[name](params[name])
  disable(name)
end

function q(f, time, args, nofire)
  if not f then
    display.Error("Tried to queue a nil function as a failsafe")
    return
  end

  local key = tostring(f)
  active[key] = f
  params[key] = args
  set(key, time, nofire)
end

function exec(name, time, nofire)
  if not name or not failsafe.fn[name] then
    display.Error("Missing failsafe method '" .. tostring(name) .. "'")
    return
  end

  active[name] = failsafe.fn[name]
  set(name, time, nofire)
end

function disable(name)
  local timer_name = string.gsub(name, "[ :]", "_") .. "_failsafe__"
  if GetTimerInfo(timer_name, 6) then
    DeleteTimer(timer_name)
    display.Debug("Disabled '" .. name .. "' failsafe", "failsafes")
  end

  active[name] = nil
  params[name] = nil
  nonfiring[name] = nil
end


function fire()
  for n in pairs(active or {}) do
    if not nonfiring[n] then
      activate(n)
    end
  end
end


function forced_command(name, line, wildcards, styles)
  flags.set("forced_command", true)
end

function forced_inventory(name, line, wildcards, styles)
  local stuff = json.decode(wildcards[1])
  local id = string.match(stuff.location, "^rep(%d+)$")
  if flags.get("forced_command") and id then
    items_stored[stuff.item.id] = id
    display.Debug("Forced to store '" .. stuff.item.name .. "' (" .. id .. ")", "failsafes")
  elseif items_stored[stuff.item.id] and stuff.location == "inv" then
    items_stored[stuff.item.id] = nil
  end
end

function forced_unwear(name, line, wildcards, styles)
  local stuff = json.decode(wildcards[1])
  local id = stuff.item.id
  local attr = stuff.item.attrib or ""
  local worn = gear.inventory[id] and string.find(gear.inventory[id].attrib, "w")
  if worn and not string.find(attr, "w") and
     (flags.get("forced_command") or affs.has("vestiphobia")) then
    items_unworn[id] = true
    display.Debug("Forced to remove '" .. stuff.item.name .. "' (" .. id .. ")", "failsafes")
  elseif not worn and string.find(attr, "w") then
    items_unworn[id] = nil
  end
end


function show()
  display.Info("Active Failsafes Report:")
  local i = 0
  for n in pairs(active or {}) do
    i = i + 1
    display.Prefix()
    local timer_name = string.gsub(n, "[ :]", "_") .. "_failsafe__"
    timeout = ""
    if IsTimer(timer_name) == 0 and GetTimerInfo(timer_name, 6) then
      timeout = string.format(" [%.3f seconds]", GetTimerInfo(timer_name, 13))
    end
    ColourNote("silver", "", string.format("  %20s ", n), "dimgray", "", "-->", "slategray", "", timeout)
  end

  for n,fn in pairs(qc or {}) do
    i = i + 1
    display.Prefix()
    ColourTell("dodgerblue", "", string.format("  %20s ", n))
    if fn and type(fn) == "function" then
      ColourNote("dimgray", "", "[", "slategray", "", tostring(fn), "dimgray", "", "]")
    else
      Note("")
    end
  end

  if i <= 0 then
    display.Prefix()
    ColourNote("dimgray", "", "  Nothing doing.")
  end
  if IsConnected() then
    Send("")
  end
end


function OnPrompt()
  if affs.slow() or not able.generic() then
    return
  end
  for n,fn in pairs(qc) do
    display.Debug("Executing '" .. n .. "' failsafe check", "failsafes")
    ck[n](fn)
  end
  qc = {}
end


function check(n, aff, fn)
  if aff and affs.has(aff) then
    return
  end
  if not n or not ck[n] then
    display.Error("Invalid failsafe check invoked: " .. tostring(n))
    return
  end
  if flags.get("check_" .. n) or qc[n] then
    return
  end

  qc[n] = fn or true
  display.Debug("Queued check for '" .. n .. "' [" .. tostring(qc[n]) .. "]", "failsafes")
end

function uncheck(n)
  qc[n] = nil
  display.Debug("Cleared check for '" .. n .. "'", "failsafes")
end


function reset()
  qc = {}
  active = {}
  params = {}
  nonfiring = {}
end


function ck.bleeding()
  flags.set("check_bleeding", true, 1.5)
  prompt.illqueue(function ()
    EnableTrigger("checking_bleeding_amount__", true)
  end, "chkbleed")
  SendNoEcho("show bleeding")
end

function handle_bleeding_amount(name, line, wildcards, styles)
  affs.bleed(tonumber(wildcards[1]) - (affs.has("bleeding") or 0))
  EnableTrigger("checking_bleeding_amount__", false)
  flags.clear("check_bleeding")
end


function ck.eating(fn)
  flags.set("check_eating", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_eating_anorexia__", true)
    EnableTrigger("checking_eating_slit_throat__", true)
    EnableTrigger("checking_eating_throatlock__", true)
    EnableTrigger("checking_eating_windpipe__", true)
    EnableTrigger("checking_eating_fine__", true)
  end, "chkeat")
  SendNoEcho("quaff water")
end

function handle_eating_anorexia(name, line, wildcards, styles)
  affs.no_eating_allowed("anorexia")
  prompt.gag = true
end

function handle_eating_slit_throat(name, line, wildcards, styles)
  affs.no_eating_allowed("slit_throat")
  prompt.gag = true
end

function handle_eating_throatlock(name, line, wildcards, styles)
  affs.no_eating_allowed("throat_locked")
  prompt.gag = true
end

function handle_eating_windpipe(name, line, wildcards, styles)
  affs.no_eating_allowed("crushed_windpipe")
  prompt.gag = true
end

function handle_eating_fine(name, line, wildcards, styles)
  local fn = flags.get("check_eating")
  if fn and type(fn) == "function" then
    fn()
  end
  flags.clear("check_eating")
  EnableTrigger("checking_eating_anorexia__", false)
  EnableTrigger("checking_eating_slit_throat__", false)
  EnableTrigger("checking_eating_throatlock__", false)
  EnableTrigger("checking_eating_windpipe__", false)
  EnableTrigger("checking_eating_fine__", false)
  prompt.gag = true
end


function ck.asthma(fn)
  flags.set("check_asthma", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_asthma1__", true)
    EnableTrigger("checking_asthma2__", true)
  end, "chkasthma")
  SendNoEcho("smoke")
end

function handle_asthma_true(name, line, wildcards, styles)
  affs.no_smoking_allowed()
  prompt.gag = true
end

function handle_asthma_false(name, line, wildcards, styles)
  local fn = flags.get("check_asthma")
  if fn and type(fn) == "function" then
    fn()
  end
  flags.clear("check_asthma")
  EnableTrigger("checking_asthma1__", false)
  EnableTrigger("checking_asthma2__", false)
  prompt.gag = true
end


function ck.blind(fn)
  flags.set("check_blind", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_blindness__", true)
  end, "chkblind")
  SendNoEcho("read pipe")
end

function handle_blind(name, line, wildcards, styles)
  if string.find(line, "noteworthy") then
    local fn = flags.get("check_blind")
    if fn and type(fn) == "function" then
      fn()
    end
  else
    affs.blinded()
  end

  flags.clear("check_blind")
  EnableTrigger("checking_blindness__", false)
  prompt.gag = true
end


function ck.dementia(fn)
  flags.set("check_dementia", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_dementia__", true)
  end, "chkdement")
  SendNoEcho("ih gfedcba")
end

function handle_demented(name, line, wildcards, styles)
  if string.find(line, "delusions") then
    affs.add_queue("dementia")
    affs.unhidden("dementia")
  else
    local fn = flags.get("check_dementia")
    if fn and type(fn) == "function" then
      fn()
    end
  end

  flags.clear("check_dementia")
  EnableTrigger("checking_dementia__", false)
  prompt.gag = true
end


function ck.impatience(fn)
  if not affs.slow() and
     able.generic() then
    flags.set("check_impatience", fn or true, 1)
    prompt.illqueue(function ()
      EnableTrigger("checking_impatience__", true)
      EnableTrigger("checking_impatience_true__", true)
    end, "chkimpat")
    SendNoEcho("med")    
  end
end

function handle_impatient(name, line, wildcards, styles)
  local fn = flags.get("check_impatience")
  if fn and type(fn) == "function" then
    fn()
  end

  flags.clear("check_impatience")
  EnableTrigger("checking_impatience__", false)
  EnableTrigger("checking_impatience_true__", false)
  prompt.gag = true
end

function handle_impatient_true(name, line, wildcards, styles)
  affs.add_queue("impatience")
  if flags.get("focus_try") then
    failsafe.exec("focus")
  end

  flags.clear("check_impatience")
  EnableTrigger("checking_impatience__", false)
  EnableTrigger("checking_impatience_true__", false)
  prompt.gag = true
end


function ck.paranoia(fn)
  flags.set("check_paranoia", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_paranoia__", true)
  end, "chkparan")
  SendNoEcho("unenemy galt")
end

function handle_paranoid(name, line, wildcards, styles)
  local fn = flags.get("check_paranoia")
  if fn and type(fn) == "function" then
    fn()
  end

  flags.clear("check_paranoia")
  EnableTrigger("checking_paranoia__", false)
  prompt.gag = true
end


function ck.paralysis(fn)
  flags.set("check_paralysis", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_paralysis1__", true)
    EnableTrigger("checking_paralysis2__", true)
  end, "chkpara")
  SendNoEcho("g paralysis")
end

function handle_paralysis_true(name, line, wildcards, styles)
  affs.no_picking_up()
  prompt.gag = true
end

function handle_paralysis_false(name, line, wildcards, styles)
  local fn = flags.get("check_paralysis")
  if fn and type(fn) == "function" then
    fn()
  end
  flags.clear("check_paralysis")
  EnableTrigger("checking_paralysis1__", false)
  EnableTrigger("checking_paralysis2__", false)
  prompt.gag = true
end


function ck.standing(fn)
  flags.set("check_standing", fn or true, 1)
  prompt.illqueue(function ()
    EnableTrigger("checking_standing_hemiplegy__", true)
    EnableTrigger("checking_standing_leglock__", true)
    EnableTrigger("checking_standing_roped__", true)
    EnableTrigger("checking_standing_shackled__", true)
    EnableTrigger("checking_standing_fine__", true)
  end, "chkstanding")
  SendNoEcho("stand")
end

function handle_standing_hemiplegy(name, line, wildcards, styles)
  local count = (affs.has("hemiplegy") or 0) + 1
  affs.no_standing_allowed("hemiplegy", math.min(count, 2))
  prompt.gag = true
end

function handle_standing_leglock(name, line, wildcards, styles)
  affs.no_standing_allowed("leg_locked")
  prompt.gag = true
end

function handle_standing_shackled(name, line, wildcards, styles)
  affs.no_standing_allowed("shackled")
  prompt.gag = true
end

function handle_standing_roped(name, line, wildcards, styles)
  affs.no_standing_allowed("roped")
  prompt.gag = true
end

function handle_standing_fine(name, line, wildcards, styles)
  local fn = flags.get("check_standing")
  if fn and type(fn) == "function" then
    fn()
  end
  flags.clear("check_standing")
  EnableTrigger("checking_standing_hemiplegy__", false)
  EnableTrigger("checking_standing_leglock__", false)
  EnableTrigger("checking_standing_roped__", false)
  EnableTrigger("checking_standing_shackled__", false)
  EnableTrigger("checking_standing_fine__", false)
  prompt.gag = true
end


function ck.aeon()
  if flags.get("checking_aeon") or
     flags.get("check_aeon") or
     affs.slow() or not
     able.generic() then
    return
  end

  flags.set("checking_aeon", true, 1)
  EnableTrigger("checking_aeon1__", true)
  SendNoEcho("show age")
  SendNoEcho("show age")
end

function handle_aeon_false(name, line, wildcards, styles)
  flags.clear{"checking_aeon", "check_aeon"}
  if flags.get("aeon_twice") then
    EnableTrigger("checking_aeon1__", false)
  else
    flags.set("aeon_twice", true, 2)
  end
  prompt.gag = true
end


function ck.severed_arms()
  if not affs.slow() and
     able.generic() then
    flags.set("check_severed_arms", true, 1)
    prompt.illqueue(function ()
      EnableTrigger("checking_severed_arms1__", true)
      EnableTrigger("checking_severed_arms2__", true)
    end, "chkarms")
    SendNoEcho("quaff water")
--  else
--    affs.limb_queue("left", "arm", "severed")
--    affs.limb_queue("right", "arm", "severed")
  end
end

function handle_severed_arms_true(name, line, wildcards, styles)
  affs.limb_queue("left", "arm", "severed")
  affs.limb_queue("right", "arm", "severed")

  flags.clear("check_severed_arms")
  EnableTrigger("checking_severed_arms1__", false)
  EnableTrigger("checking_severed_arms2__", false)
  prompt.gag = true
end

function handle_severed_arms_false(name, line, wildcards, styles)
  if affs.limb("left", "arm") == "severed" then
    affs.limb_queue("left", "arm", "healthy")
  end
  if affs.limb("right", "arm") == "severed" then
    affs.limb_queue("right", "arm", "healthy")
  end

  flags.clear("check_severed_arms")
  EnableTrigger("checking_severed_arms1__", false)
  EnableTrigger("checking_severed_arms2__", false)
  prompt.gag = true
end


DeleteTrigger("checking_anorexia1__")
DeleteTrigger("checking_anorexia2__")
DeleteTrigger("checking_leglock1__")
DeleteTrigger("checking_leglock2__")
