module (..., package.seeall)

local copytable = require "copytable"
local json = require "json"

local qexec = {}
local qill = {}
local qpre = {}
local qpreill = {}
local time_power = 0
local time_prev = false
local last_cure = false
local recent_blackout = false

gag = false

cloaked = false
stats = {
  essence = tonumber(GetVariable("sg1_essence") or ""),
  nl = tonumber(GetVariable("sg1_xp") or ""),

  prone = false,
  deaf = false,
  blind = false,
  kafe = false,

  eq = true,
  bal = true,
  head = true,
  rarm = true,
  larm = true,
  id = true,
  sub = true,
  super = true,
}
stats_prev = {
  essence = stats.essence,
  nl = stats.nl,
}
gstats = {}
local stats_xlate = {
  health = "hp",
  mana = "mp",
  power = "pow",
  endurance = "ep",
  willpower = "wp",
  aetherwillpower = "awp",

  max_health = "maxhp",
  max_mana = "maxmp",
  max_ego = "maxego",
  max_power = "maxpow",
  max_endurance = "maxep",
  max_willpower = "maxwp",
  max_aetherwillpower = "maxawp",

  momentum = "mo",
  xp = "nl",

  equilibrium = "eq",
  balance = "bal",
  right_arm = "rarm",
  left_arm = "larm",
  psi_id = "id",
  psi_sub = "sub",
  psi_super = "super",
}
local stats_flags = {
  prone = false,
  deaf = false,
  blind = false,
  kafe = false,

  eq = true,
  bal = true,
  head = true,
  rarm = true,
  larm = true,
  id = true,
  sub = true,
  super = true,
}


function stat_raw(name)
  local name = string.lower(name)
  return stats[stats_xlate[name] or name]
end

function stat(name)
  local name = string.lower(name)
  name = stats_xlate[name] or name

  if name == "maxhp" then
    local hm = stat_raw("maxhp") or 0
    if affs.has("illusory_wounds") then
      hm = hm * 2 / 3
      if stat_raw("hp") > hm then
        affs.del("illusory_wounds", true)
      end
    end
    return hm
  elseif name == "hp" and affs.has("blackout") then
    return gstats[name] or 0
  elseif name == "mp" and affs.has("blackout") then
    return gstats[name] or 0
  elseif name == "ego" and affs.has("blackout") then
    return gstats[name] or 0
  elseif name == "pow" and affs.has("blackout") then
    return gstats[name] or 0
  elseif stats_flags[name] ~= nil then
    return stat_raw(name) or stats_flags[name]
  end

  return stat_raw(name) or 0
end


function prequeue(item, name)
  qpre[name or tostring(item)] = item
end

function preillqueue(item, name)
  qpreill[name or tostring(item)] = item
end

function queue(item, name)
  qexec[name or tostring(item)] = item
end

function illqueue(item, name)
  qill[name or tostring(item)] = item
end

function clear_queue()
  qill = {}
  qpreill = {}
end

function unqueue(name)
  if not name or #name < 1 then
    display.Error("Invalid name passed to prompt.unqueue")
    return false
  end

  local ret = qpre[name] or qpreill[name] or qexec[name] or qill[name] or false
  qpre[name] = nil
  qpreill[name] = nil
  qexec[name] = nil
  qill[name] = nil
  return ret
end

function exec(pre)
  if pre then
    local qp = copytable.shallow(qpre)
    local qpi = copytable.shallow(qpreill)
    qpre = {}
    qpreill = {}
    for _,i in pairs(qp) do
      if type(i) == "function" then
        i()
      else
        Execute(i)
      end
    end
    for _,i in pairs(qpi) do
      if type(i) == "function" then
        i()
      else
        Execute(i)
      end
    end
  else
    local qe = copytable.shallow(qexec)
    local qi = copytable.shallow(qill)
    qexec = {}
    qill = {}
    for _,i in pairs(qe) do
      if type(i) == "function" then
        i()
      else
        Execute(i)
      end
    end
    for _,i in pairs(qi) do
      if type(i) == "function" then
        i()
      else
        Execute(i)
      end
    end
  end
end


function alerts()
  if flags.get("speedwalk_done") then
    ColourTell("red", "", " (Done.)")
    flags.clear("speedwalk_done")
  elseif map.autowalk > 0 and map.rooms[map.current_room].pathing then
    ColourTell("red", "", " (", "red", "", map.rooms[map.current_room].pathing .. ")")
  end

  if main.is_paused() then
    Tell(" ")
    ColourTell("gold", "", "[", "peru", "", "PAUSED", "gold", "", "]")
  elseif affs.has("inquisition") then
    Tell(" ")
    ColourTell("coral", "saddlebrown", "[", "yellow", "saddlebrown", "INQUISITION", "coral", "saddlebrown", "]")
  elseif affs.has("bubble") then
    Tell(" ")
    ColourTell("dodgerblue", "navy", "[", "white", "navy", "BUBBLE", "dodgerblue", "navy", "]")
  elseif affs.has("statue") then
    Tell(" ")
    ColourTell("black", "firebrick", "[", "silver", "firebrick", "STATUE", "black", "firebrick", "]")
  elseif affs.has("asleep") then
    Tell(" ")
    ColourTell("darkcyan", "darkslateblue", "[", "cyan", "darkslateblue", "ASLEEP", "darkcyan", "darkslateblue", "]")
  elseif affs.has("blackout") then
    Tell(" ")
    ColourTell("black", "antiquewhite", "[", "purple", "antiquewhite", "BLACKOUT", "black", "antiquewhite", "]")
  elseif map.elevation() == "pit" then
    Tell(" ")
    ColourTell("lightsteelblue", "dimgray", "[", "aqua", "dimgray", "IN PIT", "lightsteelblue", "dimgray", "]")
  elseif affs.has("recklessness") then
    Tell(" ")
    ColourTell("slateblue", "greenyellow", "[", "navy", "greenyellow", "RECKLESS", "slateblue", "greenyellow", "]")
  elseif affs.has("stunned") then
    Tell(" ")
    ColourTell("dodgerblue", "", "[", "cyan", "", "STUNNED", "dodgerblue", "", "]")
  elseif affs.has("jinx") then
    Tell(" ")
    ColourTell("orange", "", "[", "yellow", "", "JINXED", "orange", "", "]")
  elseif affs.has("crucified") then
    Tell(" ")
    ColourTell("maroon", "", "[", "orangered", "", "CRUCIFIED", "maroon", "", "]")
  elseif affs.limb("left", "arm") == "severed" and
         affs.limb("right", "arm") == "severed" then
    Tell(" ")
    ColourTell("gold", "crimson", "[", "white", "crimson", "NO ARMS", "gold", "crimson", "]")
  elseif affs.has("slickness") and
        (affs.has("slit_throat") or affs.has("crushed_windpipe") or
         (affs.has("anorexia") and affs.has("asthma"))) then
    if affs.has("prone") or
       affs.has("paralysis") or
       affs.has("severed_spine") then
      if affs.limb("left", "leg") ~= "healthy" or
         affs.limb("right", "leg") ~= "healthy" or
         affs.limb("left", "arm") ~= "healthy" or
         affs.limb("right", "arm") ~= "healthy" or
         affs.has("tendon_left") or
         affs.has("tendon_right") then
        Tell(" ")
        ColourTell("gold", "crimson", "[", "white", "crimson", "FULL LOCK", "gold", "crimson", "]")
      else
        Tell(" ")
        ColourTell("darkgoldenrod", "maroon", "[", "khaki", "maroon", "LEVEL 2 LOCK", "darkgoldenrod", "maroon", "]")
      end
    else
      Tell(" ")
      ColourTell("yellowgreen", "dimgray", "[", "gold", "dimgray", "LEVEL 1 LOCK", "yellowgreen", "dimgray", "]")
    end
  elseif affs.has("pinned_left") or affs.has("pinned_right") then
    Tell(" ")
    ColourTell("crimson", "", "[", "mediumslateblue", "", "PINNED", "crimson", "", "]")
  end

  if affs.has("sap") then
    Tell(" ")
    ColourTell("lightblue", "darkmagenta", "[", "white", "darkmagenta", "SAPPED", "lightblue", "darkmagenta", "]")
--  elseif affs.has("choke") then
--    Tell(" ")
--    ColourTell("lightblue", "darkmagenta", "[", "white", "darkmagenta", "CHOKE", "lightblue", "darkmagenta", "]")
  elseif affs.has("aeon") then
    Tell(" ")
    ColourTell("lightblue", "darkmagenta", "[", "white", "darkmagenta", "AEON", "lightblue", "darkmagenta", "]")
  end
end

local diff = {health = 0, mana = 0, ego = 0, xp = stats.nl, essence = stats.essence}
local diff_prev = {health = 0, mana = 0, ego = 0, xp = stats.nl, essence = stats.essence}
local diff_suff = {health = "H", mana = "M", ego = "E", xp = "% XP", essence = " Essence"}

function diffs(dc)
  for k in pairs(diff) do
    diff_prev[k] = diff[k] or 0
    diff[k] = dc[k] or diff_prev[k]

    local di = diff[k] - diff_prev[k]
    display.diff(di, diff_suff[k])
  end
end


local function check_equilibrium(on)
  if on then
    affs.del("disrupted", true)
  end
  if on and not bals.get("eq") then
    bals.gain("eq")
    flags.clear{"eq_time", "defs_bal", "scanned_defup_bal"}
  elseif not on and bals.get("eq") then
    bals.lose("eq")
    flags.set("eq_time", os.clock(), 0)
    flags.clear{"doing", "scanned_todo"}

    if flags.get("shivering") then
      affs.add{"shivering", "disrupted"}
      defs.del("fire")
    elseif flags.get("vomiting_blood") then
      affs.add("vomiting_blood")
    end
  elseif not on and not bals.get("eq") then
    local ct = os.clock()
    if ct - (flags.get("eq_time") or ct) > 12 then
      affs.add("disrupted")
    end
  end
end

local function check_balance(on)
  if on and flags.get("check_arm") 
     and not (main.has_skill("bonecrusher") or main.has_skill("blademaster") or main.has_skill("kata")) then
    affs.limb(flags.get("check_arm"), "arm", "broken")
    flags.clear{"check_arm", "checking_arm"}
  end
  if on and not bals.get("bal") then
    bals.gain("bal")
    flags.clear{"bal_time", "defs_bal", "scanned_defup_bal"}
  elseif not on and bals.get("bal") then
    bals.lose("bal")
    flags.set("bal_time", os.clock(), 0)
    flags.clear{"doing", "scanned_todo"}
  end
end

local function check_arm(side, on)
  local arm = string.sub(side, 1, 1) .. "arm"
  if on and flags.get("check_arm") == side and
     not (side == "right" and affs.grappled()["rightarm"]) and
     (main.has_skill("bonecrusher") or main.has_skill("blademaster") or main.has_skill("kata")) then
    affs.limb(side, "arm", "broken")
    flags.clear{"check_arm", "checking_arm"}
  end
  if on and not bals.get(arm) then
    bals.gain(arm)
    flags.clear(arm .. "_time")
  elseif not on and bals.get(arm) then
    bals.lose(arm)
    flags.set(arm .. "_time", os.clock(), 0)
  end
end

local function check_psionics(sub, super, id)
  if not main.has_skill("psionics") then
    return
  end

  if sub and not bals.get("sub") then
    bals.gain("sub")
    flags.clear("sub_time")
  elseif not sub and bals.get("sub") then
    bals.lose("sub")
    flags.set("sub_time", os.clock(), 0)
  end

  if super and not bals.get("super") then
    bals.gain("super")
    flags.clear("super_time")
  elseif not super and bals.get("super") then
    bals.lose("super")
    flags.set("super_time", os.clock(), 0)
  end

  if id and not bals.get("id") then
    bals.gain("id")
    flags.clear("id_time")
  elseif not id and bals.get("id") then
    bals.lose("id")
    flags.set("id_time", os.clock(), 0)
  end
end

local function check_kafe(on)
  if on then
    defs.add("kafe")
  else
    defs.del("kafe")
  end
end

local function check_blind(on)
  if on then
    if last_cure == "eat myrtle" then
      affs.del("blindness", true)
      defs.add("sixthsense")
    else
      if not defs.has("sixthsense") and
         not (affs.has("losteye_left") and affs.has("losteye_right")) then
        affs.add("blindness")
      else
        affs.del("blindness", true)
      end
    end
  else
    if affs.has("blindness") then
      Execute("gmcp on quiet")
    end
    affs.del("blindness", true)
    defs.del("sixthsense")
  end
end

local function check_deaf(on)
  if on then
    if last_cure == "eat myrtle" then
      affs.del("deafness", true)
      defs.add("truehearing")
    else
      if not defs.has("truehearing") then
        affs.add("deafness")
      else
        affs.del("deafness", true)
      end
    end
    affs.del("deathsong", true)
  else
    affs.del("deafness", true)
    defs.del("truehearing")
  end
end

local function check_prone(on)
  local paralyzed = false
  if on then
    local pc = flags.get("prone_check") or {}
    for _,a in ipairs(pc) do
      if type(a) == "function" then
        a()
      else
        if a == "paralysis" then
          paralyzed = true
          local charyb = (flags.get("charybdon") or 1) - 1
          if charyb <= 0 then
            flags.clear("charyb")
          else
            flags.set("charybdon", charyb, 0)
          end
        elseif a == "frozen" then
          local charyb = (flags.get("charybdon") or 1) - 1
          if charyb <= 0 then
            flags.clear("charyb")
          else
            flags.set("charybdon", charyb, 0)
          end
        end
        affs.add(a)
      end
    end
    flags.clear("prone_check")
    bals.prone = true
  else
    affs.del({"asleep", "entangled", "frozen", "kneeling", "paralysis", "prone",
      "roped", "severed_spine", "shackled", "stunned"}, true)
    failsafe.disable("stun")
    bals.prone = false
  end
  return paralyzed
end

function check_reckless()
  --display.Debug("Previous Power: " .. tostring(stats_prev.pow) .. ", Power: " .. tostring(stats.pow) .. ", Power Time: " .. time_power, "affs")
  if stats_prev.pow and stats.pow then
    if stats.pow < stats_prev.pow then
      time_power = os.clock()
    elseif stats.pow > stats_prev.pow and stats.pow == 10 and
      not flags.get("refresh_power") and ((stats.pow - stats_prev.pow) / (os.clock() - time_power)) > 0.15 then
      --display.Debug("Power reckless", "scan")
      return true
    elseif flags.get("methrenton") then
      flags.clear("methrenton")
      affs.add("sensitivity")
    end
  end

  if flags.get("damaged_health") and stat("hp") == stat("maxhp") then
    --display.Debug("Health reckless", "scan")
    return true
  end
  if flags.get("damaged_mana") and stat("mp") == stat("maxmp") then
    --display.Debug("Mana reckless", "scan")
    return true
  end
  if flags.get("damaged_ego") and stat("ego") == stat("maxego") then
    --display.Debug("Ego reckless", "scan")
    return true
  end

  return false
end

function check_stats()
  if not affs.has("blackout") then
    if not recent_blackout then
      stats_prev = copytable.shallow(stats)
    end
  else
    if flags.get("damaged_health") then
      gstats.hp = (gstats.hp or 0) - 1
    end
    if flags.get("damaged_mana") then
      gstats.mp = (gstats.mp or 0) - 1
    end
    if flags.get("damaged_ego") then
      gstats.ego = (gstats.ego or 0) - 1
    end
  end
  stats = copytable.shallow(gstats)

  check_equilibrium(stats.eq)
  check_balance(stats.bal)
  check_arm("right", stats.rarm)
  check_arm("left", stats.larm)
  check_psionics(stats.sub, stats.super, stats.id)

  check_kafe(stats.kafe)
  check_blind(stats.blind)
  check_deaf(stats.deaf)

  local paralyzed = check_prone(stats.prone or affs.has("blackout"))
  if paralyzed then
    affs.add("paralysis")
  end
end


function gmcp(name, line, wildcards, styles)
  display.q = true

  local pvars = json.decode(wildcards[1] or "{}")

  if pvars.essence then
    local essence = tonumber(GetVariable("sg1_essence") or "0")
    if essence ~= tonumber(pvars.essence) or stat("essence") == 0 then
      gstats.essence = tonumber(pvars.essence)
      stats.essence = gstats.essence
      SetVariable("sg1_essence", pvars.essence)
      main.info("essence")
    end
  elseif pvars.nl and pvars.nl ~= "n/a" then
    local tnl = tonumber(GetVariable("sg1_xp") or "0")
    if tnl ~= tonumber(pvars.nl) or stat("xp") == 0 then
      gstats.nl = tonumber(pvars.nl)
--      if gstats.nl < stat("xp") then
--        gstats.nl = gstats.nl + 100
--      end
      stats.nl = gstats.nl
      SetVariable("sg1_xp", pvars.nl)
      main.info("xp")
    end
  end

  if tonumber(pvars.esteem or "0") >= tonumber(GetVariable("sg1_imbue_threshold") or "1") and not flags.get("imbue_try") then
    local imbue = main.auto("imbue")
    if imbue then
      if imbue == true then
        imbue = "figurine"
      end
      flags.set("imbue_try", true, 2)
      queue("imbue " .. imbue .. " with " .. pvars.esteem .. " esteem")
    end
  end

  gstats.hp = tonumber(pvars.hp)
  gstats.mp = tonumber(pvars.mp)
  gstats.ego = tonumber(pvars.ego)
  gstats.pow = tonumber(pvars.pow)
  gstats.ep = tonumber(pvars.ep)
  gstats.wp = tonumber(pvars.wp)
  gstats.awp = tonumber(pvars.awp)

  local zero_count = 0
  local nonzero_count = 0
  for _,v in ipairs{"hp", "mp", "ego", "pow", "ep", "wp", "awp"} do
    gstats["max" .. v] = tonumber(pvars["max" .. v] or "0")
    if gstats[v] then
      if gstats[v] < 1 then
        zero_count = zero_count + 1
      else
        nonzero_count = nonzero_count + 1
      end
    end
  end

  recent_blackout = false
  if zero_count > 1 then
    if not affs.has("blackout") then
      affs.blackout()
    end
  elseif affs.has("blackout") and nonzero_count > 0 then
    recent_blackout = true
    affs.unblackout()
    last_cure = false
  elseif ((gstats.hp and gstats.hp == 0) or flags.get("vitaed")) and
     not affs.has("blackout") and
     not main.is_paused() then
    if flags.get("am_i_dead") then
      defs.reset_death()
      bashing.reset()
      wounds.reset()
      affs.reset()
      flags.reset()
      bals.reset()
      main.pause()
    else
      flags.set("am_i_dead", true, 0.5)
    end
  end

  gstats.prone = pvars.prone == "1"
  gstats.deaf = pvars.deaf == "1"
  gstats.blind = pvars.blind == "1"
  gstats.kafe = pvars.kafe == "1"

  gstats.eq = pvars.equilibrium == "1"
  gstats.bal = pvars.balance == "1"
  gstats.head = pvars.head == "1"
  gstats.rarm = pvars.right_arm == "1"
  gstats.larm = pvars.left_arm == "1"
  gstats.id = pvars.psiid == "1"
  gstats.sub = pvars.psisub == "1"
  gstats.super = pvars.psisuper == "1"

  if pvars.mount == "nothing" then
    if beast.locate() == "mounted" then
      beast.locate("lost")
    end
  elseif pvars.mount then
    SetVariable("sg1_beast_desc", pvars.mount)
    if beast.locate() ~= "inventory" then
      beast.locate("mounted")
    end
  end

  gstats.mo = tonumber(pvars.momentum or "0")
  gstats.esteem = tonumber(pvars.esteem or "0")
  gstats.karma = tonumber(pvars.karma or "0")

  display.q = false
end


function match(name, line, wildcards, styles)
  display.OnPrompt()

  if flags.get("maybe_ate") then
    flags.clear{"last_cure", "maybe_ate"}
    affs.clear_queue()
  end

  wounds.OnPrompt()
  affs.OnPrompt()
  defs.OnPrompt()

  exec(true)

  failsafe.OnPrompt()

  last_cure = flags.get("last_cure") or false

  check_stats()

  affs.last_cure(last_cure)

  local reckless = check_reckless()
  if reckless then
    affs.add("recklessness")
  end

  if map.autowalk == 2 then
    map.go_next(gag)
  end

  if gag then
    gag = false
  else
    display.timestamp(GetVariable("sg1_option_timestamp") == "prefix" or not GetVariable("sg1_option_timestamp"))

    if GetVariable("sg1_option_elevation") == "1" then
      display.elevation()
    end

    if not affs.has("blackout") then
      for _,v in ipairs(styles) do
        if v.text ~= wildcards[8] and (not wildcards[7] or v.text ~= " " .. wildcards[7] .. "mo" .. wildcards[8]) then
          ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), v.text)
        end
      end

      if stat("mo") > 0 then
        ColourTell("silver", "", " " .. stat("mo") .. "mo")
      end

      if wildcards[8] then
        if string.find(wildcards[8], "<>") then
          cloaked = true
        else
          cloaked = false
        end
      end
    end

    local pflags = bals.pflags()

    if bals.can_act() then
      ColourTell(GetVariable("sg1_prompt_onbal") or "goldenrod", "", " " .. pflags)
    else
      ColourTell(GetVariable("sg1_prompt_offbal") or "gray", "", " " .. pflags)
    end

    if defs.wanted() > 0 then
      display.defs_wanted(defs.wanted())
    end

    display.timestamp(GetVariable("sg1_option_timestamp") == "suffix")

    alerts()
    diffs{health = tonumber(wildcards[1]),
          mana = tonumber(wildcards[2]),
          ego = tonumber(wildcards[3]),
          xp = stats.nl,
          essence = stats.essence}
    if GetVariable("sg1_option_afflist") == "1" then
      display.afflist()
    end
    Note("")
  end

  if scan.update and stat("maxhp") > 0 then
    scan.process()
  end

  flags.OnPrompt()
  exec(false)
end


function time_diff(name, line, wildcards, styles)
  if time_prev then
    display.Info("Time Difference: " .. string.format("%0.3f", math.abs(tonumber(wildcards[1]) - time_prev)) .. " seconds")
    time_prev = false
    SetStatus("Ready")
    EnableTimer("expire_timestamp__", false)
  else
    time_prev = tonumber(wildcards[1])
    SetStatus(os.date("%m/%d/%Y %H:%M:%S", tonumber(wildcards[2])))
    EnableTimer("expire_timestamp__", true)
  end
  ResetTimer("expire_timestamp__")
end

function time_expire(name, line, wildcards, styles)
  time_prev = false
  SetStatus("Ready")
  EnableTimer("expire_timestamp__", false)
  ResetTimer("expire_timestamp__")
end

function gagger(name, line, wildcards, styles)
  gag = true
end
