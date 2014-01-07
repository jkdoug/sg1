module (..., package.seeall)

local valid = {}
local targets = {}
local room_inv = {}


function init(v)
  if v and type(v) == "table" then
    valid = {}
    local pcount = 0
    for k,t in pairs(v) do
      local prio = t.priority
      if not prio then
        prio = 1000 + pcount
        pcount = pcount + 1
      end
      valid[k] = { priority = prio, target = t.target or "notarget" }
    end
  end
end

function reset()
  targets = {}
  EnableGroup("Bashable", false)
end

function count()
  return #targets
end


local function destruction(targ)
  local attack = "manifest destruction at"

  if enemy.is_shielded(GetVariable("target_name") or targ) then
    if main.auto("raze") then
      if main.has_skill("lowmagic") then
        attack = "invoke nullify"
      elseif main.has_skill("highmagic") then
        attack = "evoke void"
      end
    elseif able.generic_beast("aggressive") and main.auto("braze") then
      Execute("beast order attack " .. targ)
    else
      return
    end
  elseif able.to("beast order attack") and main.auto("bbash") then
    Execute("beast order attack " .. targ)
  end

  if bals.can_act() and not flags.get("bashing1") then
    Execute(attack .. " " .. targ)
    flags.set("bashing1", true, 0.3)
    flags.set("bashing2", true, 0.3)
  end
end

local function warrior_2(targ)
  local attacks = { "jab", "swing" }
  attacks = { attacks[math.random(2)], attacks[math.random(2)] }

  local raze = 0
  if enemy.is_shielded(GetVariable("target_name") or targ) then
    raze = raze + 1
  end
  if enemy.has_aura(targ) then
    raze = raze + 1
  end

  if main.auto("raze") then
    if raze > 0 then
      attacks[1] = "raze"
    end
    if raze > 1 then
      attacks[2] = "raze"
    end
  end

  if able.to("beast order attack") then
    if (main.auto("bbash") and raze < 1) or
       (main.auto("braze") and beast.has_ability("aggressive") and raze > 0) then
      Execute("beast order attack " .. targ)
    end
  end

  if (bals.get("larm") or bals.get("rarm")) and
     not flags.get("bashing1") then
    Execute(attacks[1] .. " " .. targ)
    flags.set("bashing1", true, 0.3)
  end
  if bals.get("larm") and bals.get("rarm") and
     not flags.get("bashing2") then
    Execute(attacks[2] .. " " .. targ)
    flags.set("bashing2", true, 0.3)
  end
end

local function warrior_1(targ)
  local attacks = { "jab", "swing" }
  local attack = attacks[math.random(2)]

  local raze = 0
  if enemy.is_shielded(GetVariable("target_name") or targ) then
    raze = raze + 1
  end
  if enemy.has_aura(targ) then
    raze = raze + 1
  end

  if main.auto("raze") and
     (main.has_ability("axelord", "cleave") or
      main.has_ability("pureblade", "cleave") or
      main.has_ability("cavalier", "cleave")) and
     raze > 0 then
    attack = "cleave"
  elseif able.to("beast order attack") then
    if (main.auto("bbash") and raze < 1) or
       (main.auto("braze") and beast.has_ability("aggressive") and raze > 0) then
      Execute("beast order attack " .. targ)
    end
  end

  if bals.can_act() and
     not flags.get("bashing1") then
    Execute(attack .. " " .. targ)
    flags.set("bashing1", true, 0.3)
    flags.set("bashing2", true, 0.3)
  end
end

local function bard(targ)
  local attack = "play minorsecond"
  if enemy.is_shielded(GetVariable("target_name") or targ) then
    if main.auto("raze") then
      attack = "play blanknote"
    elseif able.to("beast order attack") and
       beast.has_ability("aggressive") and
       main.auto("braze") then
      Execute("beast order attack " .. targ)
    else
      return
    end
  elseif able.to("beast order attack") and main.auto("bbash") then
    Execute("beast order attack " .. targ)
  end

  if bals.can_act() and not flags.get("bashing1") then
    Execute(attack .. " " .. targ)
    flags.set("bashing1", true, 0.3)
    flags.set("bashing2", true, 0.3)
  end
end

local function wiccan(targ)
  local attack = "nature curse"
  if defs.has("drawdown") then
    if GetVariable("sg1_option_bash_attack") == "moonfire" then
      attack = "moonfire"
    else
      attack = "moonburst"
    end
  end

  if enemy.is_shielded(GetVariable("target_name") or targ) then
    if main.auto("raze") then
      if main.has_skill("lowmagic") then
        attack = "invoke nullify"
      elseif main.has_skill("highmagic") then
        attack = "evoke void"
      end
    elseif able.to("beast order attack") and
       beast.has_ability("aggressive") and
       main.auto("braze") then
      Execute("beast order attack " .. targ)
    else
      return
    end
  elseif able.to("beast order attack") and main.auto("bbash") then
    Execute("beast order attack " .. targ)
  end

  if bals.can_act() and not flags.get("bashing1") then
    Execute(attack .. " " .. targ)
    flags.set("bashing1", true, 0.3)
    flags.set("bashing2", true, 0.3)
  end
end

local function druid(targ)
  local attack = "point cudgel"

  if enemy.is_shielded(GetVariable("target_name") or targ) then
    if main.auto("raze") then
      if main.has_skill("lowmagic") then
        attack = "invoke nullify"
      elseif main.has_skill("highmagic") then
        attack = "evoke void"
      end
    elseif able.generic_beast("aggressive") and main.auto("braze") then
      Execute("beast order attack " .. targ)
    else
      return
    end
  elseif able.to("beast order attack") and main.auto("bbash") then
    Execute("beast order attack " .. targ)
  end

  if bals.can_act() and not flags.get("bashing1") then
    if attack == "point cudgel" and main.has_ability("druidry", "lightningbugs") then
      Execute(attack .. " " .. targ .. " lightningbugs")
    else
      Execute(attack .. " " .. targ)
    end
    flags.set("bashing1", true, 0.3)
    flags.set("bashing2", true, 0.3)
  end
end

local function is_present(thing)
  local id = tonumber(thing)
  if id then
    for _,item in ipairs(room_inv) do
      if id == item.id and not string.find(item.name, "^the corpse of ") then
        return true
      end
    end
  else
    for _,item in ipairs(room_inv) do
      if string.find(item.name, thing) and not string.find(item.name, "^the corpse of ") then
        return true
      end
    end
  end
  return false
end

function attack()
  if main.auto("bash") and #targets > 0 then
    prompt.queue(function () bashing.attack() end, "autobash")
  else
    EnableGroup("Bashable", false)
    return
  end

  if not able.to("bash") then
    return
  end

  local targ = GetVariable("target") or ""
  if not is_present(targ) then
    if bals.can_act() then
      table.sort(targets, function (a,b) return a.priority < b.priority end)
      targ = targets[1].id or targets[1].name
      Execute("t " .. targ)
    else
      return
    end
  end

  if GetVariable("sg1_option_bash_destruction") == "1" then
    destruction(targ)
  elseif main.has_skill("bonecrusher") or
     main.has_skill("blademaster") then
    warrior_2(targ)
  elseif main.has_skill("knighthood") then
    warrior_1(targ)
  elseif main.has_skill("music") then
    bard(targ)
  elseif main.has_skill("druidry") then
    druid(targ)
  elseif main.has_skill("nature") then
    wiccan(targ)
  else
    display.Error("Bashing is currently not available for your skills. Sorry.")
    Execute("reset bashing")
    if IsConnected() then
      Send("")
    end
  end
end


function handle_target(name, line, wildcards, styles)
  local id = tonumber(wildcards[1])
  local tname = wildcards[1]
  if id then
    for _,item in ipairs(room_inv) do
      if id == item.id then
        tname = (valid[item.name] and valid[item.name].target) or item.name
      end
    end
  end

  SetVariable("target", wildcards[1])
  SetVariable("target_name", tname)
  display.Info("Targeting: " .. GetVariable("target"))
  main.info("target")
  if IsConnected() then
    Send("")
  end
end

function handle_kill(name, line, wildcards, styles)
  local targ = wildcards[1]
  if not targ or #targ == 0 then
    targ = GetVariable("target")
  end
  if valid[string.lower(targ)] then
    targ = valid[string.lower(targ)].target
  end

  table.insert(targets, {name = targ, id = false, priority = 1000})
  display.Debug("Added '" .. targ .. "' to bashing queue", "bash")

  if not main.auto("bash") then
    Execute("auto bash on")
  end

  EnableGroup("Bashable", true)

  attack()
end

function handle_pkill(name, line, wildcards, styles)
  if #targets > 0 then
    display.Error("Target queue not empty; force a reset first, if desired.")
    if IsConnected() then
      Send("")
    end
    return
  end

  if not main.auto("bash") then
    Execute("auto bash on")
  end

  EnableGroup("Bashable", true)

  targets = {}
  for _,item in ipairs(room_inv) do
    if valid[item.name] then
      table.insert(targets, {name = item.name, id = item.id, priority = valid[item.name].priority})
    end
  end

  if #targets == 0 then
    display.Info("No valid targets found at your present location.")
    if IsConnected() then
      Send("")
    end
    return
  end

  table.sort(targets, function (a,b) return a.priority < b.priority end)

  attack()
end

function handle_notarget(name, line, wildcards, styles)
  if affs.has("blindness") then
    display.Debug("No bashable target because of blindness", "bash")
    return
  end

  if #targets < 1 then
    display.Debug("No bashable targets to remove", "bash")
    return
  end

  local targ = GetVariable("target") or ""
  local id = tonumber(targ)
  display.Debug("Looking to remove '" .. targ .. "' from queue", "bash")
  if id then
    for i = #targets,1,-1 do
      if (targets[i].id and id == targets[i].id) or (not targets[i].id and targets[i].name == targ) then
        display.Debug("Removed target '" .. targets[i].name .. "' at position " .. i, "bash")
        table.remove(targets, i)
      end
    end
  else
    for i = #targets,1,-1 do
      if string.find(targets[i].name, targ) then
        display.Debug("Removed target '" .. targets[i].name .. "' at position " .. i, "bash")
        table.remove(targets, i)
      end
    end
  end

  if #targets == 0 then
    EnableGroup("Bashable", false)
  end
  --flags.clear{"bashing1", "bashing2"}
end

local bash_affs = {
  ["bashing_ablaze__"] = function () affs.add_queue("ablaze") affs.burning() end,
  ["bashing_ablaze_blackout__"] = function () affs.add_queue("ablaze") affs.burning()  end,
  ["bashing_ablaze_paralysis__"] = function () affs.add_queue("ablaze") affs.burning() affs.prone("paralysis") end,
  ["bashing_aeon__"] = function () affs.aeon() end,
  ["bashing_arms__"] = function () affs.add_queue("mending_arms") end,
  ["bashing_blacklung__"] = function () affs.add_queue("black_lung") end,
  ["bashing_blackout__"] = function () end,
  ["bashing_blackout_aeon__"] = function () affs.aeon() end,
  ["bashing_blackout_legs__"] = function () affs.add_queue("mending_legs") end,
  ["bashing_blackout_paralysis__"] = function () affs.add_queue("paralysis") end,
  ["bashing_blackout_prone__"] = function () affs.add_queue("prone") end,
  ["bashing_blackout_stupidity__"] = function () affs.add_queue("stupidity") end,
  ["bashing_blinded__"] = function () affs.blinded() end,
  ["bashing_blinded_entangled__"] = function () affs.prone("entangled") affs.blinded() end,
  ["bashing_blinded_paralysis__"] = function () affs.prone("paralysis") affs.blinded() end,
  ["bashing_charybdon__"] = function () main.charybdon() end,
  ["bashing_charybdon_paralysis__"] = function () main.charybdon() affs.prone("paralysis") flags.damaged_health() end,
  ["bashing_cold__"] = function () affs.cold() end,
  ["bashing_cold2__"] = function () affs.cold() end,
  ["bashing_cold_arm__"] = function () affs.cold() EnableTrigger("bashing_cold_arm2__", true) prompt.queue(function () EnableTrigger("bashing_cold_arm2__", false) end) end,
  ["bashing_cold_arm2__"] = function () affs.add_queue("mending_arms") end,
  ["bashing_cold_paralysis__"] = function () affs.prone("paralysis") end,
  ["bashing_damaged__"] = function () flags.damaged_health() end,
  ["bashing_deafened__"] = function () affs.deafened() end,
  ["bashing_entangled__"] = function () affs.prone("entangled") end,
  ["bashing_entangled_arms__"] = function () affs.prone{"entangled", "mending_arms"} end,
  ["bashing_entangled_stupidity__"] = function () affs.prone{"entangled", "stupidity"} end,
  ["bashing_fear__"] = function () affs.add_queue("fear") end,
  ["bashing_fear_stupidity__"] = function () affs.add_queue{"fear", "stupidity"} end,
  ["bashing_legs__"] = function () affs.add_queue("mending_legs") end,
  ["bashing_limb_mend__"] = function (wc) affs.add_queue("mending_" .. wc[1] .. "s") end,
  ["bashing_paralysis__"] = function () affs.prone("paralysis") end,
  ["bashing_paralysis_cold__"] = function () affs.prone("paralysis") affs.cold() end,
  ["bashing_paralysis_poisoned__"] = function () affs.prone("paralysis") main.poisons_on() end,
  ["bashing_paralysis_stupidity__"] = function () affs.prone{"paralysis", "stupidity"} end,
  ["bashing_paranoia__"] = function () affs.add_queue("paranoia") end,
  ["bashing_poisoned__"] = function () main.poisons_on() end,
  ["bashing_poisoned_bleed__"] = function () main.poisons_on() affs.bleed(200) end,
  ["bashing_prone__"] = function () affs.prone() end,
  ["bashing_prone2__"] = function () affs.prone() end,
  ["bashing_prone_deaf__"] = function () affs.prone() affs.deafened() end,
  ["bashing_prone_entangled__"] = function () affs.prone{"prone", "entangled"} end,
  ["bashing_prone_leg__"] = function (wc) affs.prone() affs.limb_queue(wc[1], "leg", "broken") end,
  ["bashing_prone_legs__"] = function () affs.prone{"prone", "mending_legs"} end,
  ["bashing_prone_poisoned__"] = function () affs.prone() main.poisons_on() end,
  ["bashing_prone_stupidity__"] = function () affs.prone{"prone", "stupidity"} end,
  ["bashing_sensitivity_2__"] = function () affs.add_queue("sensitivity") end,
  ["bashing_stupidity__"] = function () affs.add_queue("stupidity") end,
  ["bashing_stupidity_damaged__"] = function () affs.add_queue("stupidity") flags.damaged_health() end,
  ["bashing_unshield__"] = function () defs.del_queue("shield") end,
}

function aff(name, line, wildcards, styles)
  local fn = bash_affs[name]
  if not fn then
    display.Error("No bashing affs function defined for " .. name)
    return
  end
  if type(fn) == "function" then
    fn(wildcards)
  else
    affs.add_queue(fn)
  end
end

function bleed(name, line, wildcards, styles)
--  local amt = tonumber(string.match(name, "^bashing_bleed_(%d+)__$"))
--  if not amt then
--    return
--  end
--  affs.bleed(amt)
  failsafe.check("bleeding")
end


function items_list(name, line, wildcards, styles)
  display.q = true
  local wc = string.gsub(wildcards[1] or "", "bearing the name \"(%w+)\"", "bearing the name '%%1'")
  local stuff = json.decode(wc)
  if stuff.location == "room" then
    room_inv = {}
    for _,item in ipairs(stuff.items) do
      display.Debug("Bashing noticed: " .. string.format("%d, ", tonumber(item.id)) .. item.name, "bash")
      table.insert(room_inv, {name = item.name, id = tonumber(item.id)})
    end
  end

  display.q = false
end

function items_add(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "room" then
    local id = tonumber(stuff.item.id)
    for i,item in ipairs(room_inv) do
      if id == item.id then
        id = false
        break
      end
    end
    if id then
      table.insert(room_inv, {name = stuff.item.name, id = id})
      display.Debug("Bashing noticed: " .. string.format("%d, ", id) .. stuff.item.name, "bash")
      if main.auto("target") and #targets > 0 and valid[stuff.item.name] then
        table.insert(targets, {name = stuff.item.name, id = id, priority = valid[stuff.item.name].priority})
        display.Debug("Bashing added: " .. string.format("%d, ", id) .. stuff.item.name .. " [" .. targets[#targets].priority .. "]", "bash")
      end
    end
  end
  display.q = false
end

function items_remove(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "room" then
    local id = tonumber(stuff.item)
    for i = #room_inv,1,-1 do
      if id == room_inv[i].id then
        display.Debug("Bashing unnoticed: " .. string.format("%d, ", id) .. room_inv[i].name, "bash")
        table.remove(room_inv, i)
        break
      end
    end
    for i = #targets,1,-1 do
      if id == targets[i].id then
        display.Debug("Bashing removed: " .. string.format("%d, ", id) .. targets[i].name, "bash")
        table.remove(targets, i)
        break
      end
    end
  end
  display.q = false
end

function items_update(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "room" and string.find(stuff.item.name, "^the corpse of ") then
    local id = tonumber(stuff.item.id)
    for i = #room_inv,1,-1 do
      if id == room_inv[i].id then
        room_inv[i].name = stuff.item.name
        display.Debug("Bashing unnoticed: " .. string.format("%d, ", id) .. stuff.item.name, "bash")
        break
      end
    end
    for i = #targets,1,-1 do
      if (targets[i].id and id == targets[i].id) or (not targets[i].id and string.find(stuff.item.name, targets[i].name)) then
        display.Debug("Bashing removed: " .. string.format("%d, ", id) .. targets[i].name, "bash")
        table.remove(targets, i)
        break
      end
    end
  end
  display.q = false
end


function show_queue()
  display.Info("Bashing Report:")
  local active = false
  for i,item in ipairs(targets) do
    active = true
    display.Prefix()
    ColourNote("dimgray", "", string.format("  %2d ", i), "saddlebrown", "", string.format(" %6d ", item.id or 0),
               "darkorange", "", string.format(" %-40s ", string.sub(item.name, 1, 40)))
  end
  if not active then
    display.Prefix()
    ColourNote("dimgray", "", "  Nothing on the agenda.")
  end
  if IsConnected() then
    Send("")
  end
end


DeleteAlias("bashing_iht__")
DeleteTrigger("bashing_iht_add__")
DeleteTrigger("bashing_iht_done__")
DeleteTrigger("bashing_target_dead__")
DeleteTrigger("bashing_target_slain__")
DeleteTrigger("bashing_entangled_stupidity__")
