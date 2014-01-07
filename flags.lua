module (..., package.seeall)

local current = {}
local flash = {}

function set(name, val, time)
  if val == nil then
    clear(name)
    return
  end

  current[name] = val
  dbg = "Flag '" .. name .. "' raised for '" .. tostring(val) .. "'"

  if not time then
    dbg = dbg .. " (timeout = prompt)"
    flash[name] = true
  elseif time ~= 0 then
    dbg = dbg .. " (timeout = " .. tostring(time) .. ")"

    local timer_name = name .. "_flag__"
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
    group="Flags" >
  <send>flags.clear("]] .. name .. [[")</send>
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
  end

  display.Debug(dbg, "flags")

  scan.update = true
end

function get(name)
  return current[name]
end

function clear(name)
  if type(name) == "table" then
    for _,n in ipairs(name) do
      clear(n)
    end
    return
  end

  if current[name] == nil then
    return
  end

  display.Debug("Flag '" .. name .. "' taken down", "flags")
  current[name] = nil

  local timer_name = name .. "_flag__"
  DeleteTimer(timer_name)

  scan.update = true
end

function unscan(cmd)
  local cf = {}
  for n,v in pairs(current) do
    if string.find(n, "^scanned_") and string.find(v, cmd) then
      table.insert(cf, n)
    end
  end
  if #cf > 0 then
    clear(cf)
  end
end

function reset()
  for n in pairs(current) do
    local timer_name = n .. "_flag__"
    DeleteTimer(timer_name)
  end

  current = {}
  flash = {}

  display.Debug("Flags cleared", "flags")
end


function OnPrompt()
  for n in pairs(flash) do
    clear(n)
  end
  flash = {}
end


local function damaged(name, count)
  local c = flags.get("damaged_" .. name) or 0
  c = c + count
  if c <= 0 then
    flags.clear("damaged_" .. name)
  else
    flags.set("damaged_" .. name, c)
  end
end

function damaged_health()
  damaged("health", 1)
end

function blocked_health()
  damaged("health", -1)
end

function damaged_mana()
  damaged("mana", 1)
end

function damaged_ego()
  damaged("ego", 1)
end

function damaged_power()
  damaged("power", 1)
end


function clear_elixir(name)
  local elixir = get("elixir") or {}
  local matches = {}
  for i,e in ipairs(elixir) do
    if string.find(name, e) then
      table.insert(matches, i)
    end
  end
  for n in ipairs(matches) do
    table.remove(elixir, n)
  end
  if #elixir > 0 then
    set("elixir", elixir, 2)
  else
    clear("elixir")
  end
end

function clear_scan(name)
  local rem = {}
  for n in pairs(current) do
    if string.match(n, "^scanned%_" .. name) then
      table.insert(rem, n)
    end
  end
  if #rem > 0 then
    clear(rem)
  end
end

function clear_slow(name)
  if get("slow_going") == name or not name then
    clear{"slow_sent", "slow_going"}
    scan.update = true
  end
end

function clear_stun()
  local rem = {}
  for n in pairs(current) do
    if string.match(n, "%_try$") or
       string.match(n, "^scanned%_") then
      table.insert(rem, n)
    end
  end
  if #rem > 0 then
    clear(rem)
  end
end


function show()
  display.Info("Flags Report:")

  local i = 0
  for name,val in pairs(current) do
    i = i + 1
    local timer_name = name .. "_flag__"

    display.Prefix()
    Tell("  ")
    timeout = ""
    if flash[name] then
      timeout = " [delete on prompt]"
    elseif IsTimer(timer_name) == 0 and GetTimerInfo(timer_name, 6) then
      timeout = string.format(" [%.3f seconds]", GetTimerInfo(timer_name, 13))
    end
    ColourNote("silver", "black", name, "dimgray", "", " = ",
      "cornflowerblue", "", tostring(val), "slategray", "", timeout)
  end
  if i == 0 then
    display.Prefix()
    ColourNote("dimgray", "black", "  No flags raised.")
  end

  if IsConnected() then
    Send("")
  end
end
