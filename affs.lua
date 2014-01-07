module (..., package.seeall)

require "flags"
require "php"

local current = {}
local limbs = {
  left_arm = "healthy",
  left_leg = "healthy",
  right_arm = "healthy",
  right_leg = "healthy",
}
local qadd = {}
local qdel = {}
local qlimb = {}
local unknowns = 0
local grapples = {}
local ninshi = {}
local ootangk = {}
local ignores = {}

local hideys =
{
  addiction = {"hidden_mental", "telepathy", "ancestralcurse"},
  agoraphobia = {"hidden_mental", "telepathy", "reality", "hidden_oracle"},
  anorexia = {"hidden_mental", "crone"},
  claustrophobia = {"telepathy", "reality", "hidden_oracle"},
  clumsiness = {"ancestralcurse", "violetvibrato", "hidden_kombu"},
  confusion = {"hidden_mental", "reality", "spores", "moon_tarot", "sidiak_ray", "time_echo", "hidden_heretic", "dark", "crone", "baalphegar", "crowcaw", "avengingangel", "ancientcurse", "purplehaze", "disoriented", "southwind"},
  daydreaming = {"mote"},
  deadening = {"violetvibrato", "hidden_kombu"},
  dementia = {"hidden_mental", "telepathy", "reality", "spores", "moon_ray", "time_echo", "dark", "baalphegar", "purplehaze", "southwind"},
  dizziness = {"reality", "southwind", "moon_ray", "hidden_heretic", "violetvibrato", "disoriented", "hidden_kombu"},
  epilepsy = {"telepathy", "focus_mote", "sidiak_ray", "time_echo", "hidden_heretic", "baalphegar", "plague", "violetvibrato", "hidden_kombu"},
  fear = {"hidden_mental"},
  frozen = {"crone"},
  gluttony = {"hidden_mental"},
  hallucinations = {"hidden_mental", "telepathy", "spores", "moon_ray", "time_echo", "hidden_heretic", "japhiel", "justchorale", "purplehaze", "southwind"},
  hemiplegy_left = {"hemiplegy"},
  hemiplegy_right = {"hemiplegy"},
  hypersomnia = {"moon_tarot"},
  hypochondria = {"hidden_mental", "telepathy", "ancestralcurse", "vestiphobia"},
  impatience = {"hidden_mental", "southwind", "ancestralcurse"},
  loneliness = {"hidden_mental", "crone"},
  lovers = {"eroee_ray"},
  masochism = {"hidden_mental", "crone"},
  narcolepsy = {"mote"},
  omniphobia = {"violetvibrato", "hidden_kombu"},
  pacifism = {"hidden_mental", "telepathy", "focus_mote", "justchorale"},
  paralysis = {"telepathy", "justchorale"},
  paranoia = {"hidden_mental", "ancestralcurse", "hidden_oracle", "dark", "baalphegar", "justchorale", "purplehaze", "southwind"},
  peace = {"eroee_ray"},
  pox = {"plague"},
  recklessness = {"telepathy", "ancestralcurse", "crone", "justchorale"},
  relapsing = {"hidden_heretic"},
  rigormortis = {"plague"},
  scabies = {"eroee_ray", "plague"},
  sensitivity = {"eroee_ray", "starlight", "hidden_sensitivity"},
  shivering = {"crone"},
  shyness = {"hidden_mental", "southwind"},
  slickness = {"crone"},
  stupidity = {"hidden_mental", "telepathy", "moon_tarot", "sidiak_ray", "time_echo", "hidden_heretic", "dark", "japhiel", "baalphegar", "crowcaw", "avengingangel", "southwind"},
  sun_allergy = {"starlight"},
  vapors = {"hidden_kombu"},
  vertigo = {"reality", "hidden_heretic"},
  vestiphobia = {"hidden_mental", "telepathy", "reality", "hidden_oracle"},
  vomiting = {"hidden_heretic", "starlight"},
  worms = {"plague"},
}


tr = {}

insane = {
  slight = 1,
  moderate = 15,
  major = 30,
  massive = 50,
}

timewarped = {
  minorly = 1,
  moderately = 15,
  majorly = 30,
  massively = 50,  
}

allergic = {
  mild = 1,
  strong = 4,
  severe = 8,
  incapacitating = 12,
}

local drunk_levels = php.Table()
drunk_levels["suicidally intoxicated"] = 250
drunk_levels["totally plastered"] = 221
drunk_levels["entirely inebriated"] = 151
drunk_levels["decidedly sloshed"] = 126
drunk_levels["feeling no pain"] = 101
drunk_levels["feeling decidedly mellow"] = 76
drunk_levels["feeling a bit tipsy"] = 51
drunk_levels["slightly flushed"] = 31
drunk_levels["sober and in control"] = 0

local drunk = 0


function add(name, val)
  if type(name) == "table" then
    for _,a in ipairs(name) do
      add(a, val)
    end
    return
  end

  flags.clear("last_hidden")

  local val = val or true
  if not current[name] then
    display.Debug("Affliction added - '" .. name .. "' (" .. tostring(val) .. ")", "affs")
  elseif val ~= current[name] then
    display.Debug("Affliction updated - '" .. name .. "' (" .. tostring(val) .. ")", "affs")
  else
    return
  end
  flags.clear("last_cure")
  flags.clear_scan(name)
  scan.update = true
  current[name] = val
end

function del(name, quietly)
  if type(name) == "table" then
    for _,a in ipairs(name) do
      del(a, quietly)
    end
    return
  end

  if not quietly then
    flags.clear{"last_cure", "slow_going"}
    flags.clear_scan(name)

    scan.update = true
    if has(name) then
      display.Debug("Affliction removed - '" .. name .. "'", "affs")
    else
      unhidden(name)
    end
  end
  current[name] = nil
end


function mine()
  return current
end

function ignoring()
  -- TODO
  return false
end


function limb(side, limb, condition)
  local side = string.lower(side)
  local limb = string.lower(limb)

  if condition then
    local state = limbs[side .. "_" .. limb]
    local previous_state = string.find("healthy broken mangled severed", state)
    local current_state = string.find("healthy broken mangled severed", condition)
    if current_state < previous_state then
      flags.clear("last_cure")
    end

    local other_side
    if side == "left" then
      other_side = limbs["right_" .. limb]
    else
      other_side = limbs["left_" .. limb]
    end

    local unaff = {}
    if condition == "healthy" and other_side == "healthy" then
      unaff = {"broken_" .. limb, "mangled_" .. limb, "severed_" .. limb}
    end
    if condition == "broken" or other_side == "broken" then
      add("broken_" .. limb)
    else
      table.insert(unaff, "broken_" .. limb)
    end
    if condition == "mangled" or other_side == "mangled" then
      add("mangled_" .. limb)
    else
      table.insert(unaff, "mangled_" .. limb)
    end
    if condition == "severed" or other_side == "severed" then
      add("severed_" .. limb)
    else
      table.insert(unaff, "severed_" .. limb)
    end

    if #unaff > 0 then
      del(unaff)
    end

    limbs[side .. "_" .. limb] = condition
  end

  return limbs[side .. "_" .. limb]
end

function cracked(side, limb)
  if limb == "leg" then
    if has("kneecap_" .. side) then
      prone()
    end

    add_queue("kneecap_" .. side)
    defs.del_queue("stance")

    EnableTrigger("aff_kneecap_again__", true)
    prompt.queue(function () EnableTrigger("aff_kneecap_again__", false) end, "cracktwo")
  else
    if not has("elbow_" .. side) then
      add_queue("elbow_" .. side)
    else
      limb_queue(side, limb, "broken")
    end
  end
end

function has(name)
  return current[name] or false
end

function coming(name)
  local pc = flags.get("prone_check") or {}
  for _,a in ipairs(pc) do
    if a == name then
      return true
    end
  end
  return qadd[name] or false
end

function going(name)
  return qdel[name] or false
end

function slow()
  return has("aeon") or has("sap")
end

function blood_clots()
  local c = 0
  for _,a in ipairs{"clot_leftarm", "clot_leftleg", "clot_rightarm", "clot_rightleg", "clot_unknown"} do
    if has(a) then
      c = c + 1
    end
  end
  return math.min(c, 4)
end

function grappled()
  return grapples
end

function is_grappled(part)
  if part then
    return grapples[part] or false
  end
  return next(grapples) or false
end

function is_prone()
  if has("prone") or
     has("entangled") or
     has("paralysis") or
     has("severed_spine") or
     has("stunned") or
     has("frozen") or
     has("roped") or
     has("impale_gut") or
     has("impale_antlers") or
     has("crucified") or
     has("shackled") or
     has("kneeling") or
     has("sitting") then
    return true
  end

  return false
end

function is_drunk()
  local dl = "sober and in control"
  for n,d in drunk_levels:pairs() do
    if drunk >= d then
      dl = n
      break
    end
  end
  return dl
end

function is_impaled()
  if has("impale_gut") or
     has("crucified") or
     has("impale_antlers") or
     has("pinned_left") or
     has("pinned_right") then
    return true
  end

  return false
end

function is_mental()
  if has("addiction") or
     has("anorexia") or
     has("baalphegar") or
     has("confusion") or
     has("crowcaw") or
     has("dementia") or
     has("epilepsy") or
     has("gluttony") or
     has("hallucinations") or
     has("hidden_mental") or
     has("hidden_oracle") or
     has("hypersomnia") or
     has("impatience") or
     has("japhiel") or
     has("loneliness") or
     has("lovers") or
     has("masochism") or
     has("paranoia") or
     has("purplehaze") or
     has("reality") or
     has("scrambled") or
     has("shyness") or
     has("stupidity") or
     has("telepathy") or
     has("void") then
    return true
  end

  return false
end

function is_ninshi(part)
  return ninshi[part] or false
end

function is_ootangk(part)
  return ootangk[part] or false
end

function is_stupid()
  if has("stupidity") or
     has("moon_tarot") or
     has("dark") or
     has("crowcaw") or
     has("purplehaze") or
     has("baalphegar") or
     has("japhiel") or
     has("concussion") or
     has("jinx") then
    return true
  end

  return false
end


function add_queue(name, val)
  if type(name) == "table" then
    for _,a in ipairs(name) do
      add_queue(a)
    end
    return
  end

  flags.clear("last_hidden")

  local val = val or true
  if has(name) == val or qadd[name] == val then
    return
  end

  display.Debug("Queued affliction '" .. name .. "' (" .. tostring(val) .. ")", "affs")
  qadd[name] = val
  qdel[name] = nil
end

function del_queue(name)
  if type(name) == "table" then
    for _,a in ipairs(name) do
      del_queue(a)
    end
    return
  end

  if not qdel[name] then
    display.Debug("Queued affliction removal '" .. name .. "'", "affs")
    qdel[name] = true
  end
  qadd[name] = nil
end

function limb_queue(side, limb, condition)
  local current = string.find("healthy broken mangled severed", condition)
  for n,l in ipairs(qlimb) do
    if l.side == side and l.limb == limb then
      local prio = string.find("healthy broken mangled severed", l.condition)
      if current > prio then
        qlimb[n].condition = condition
        display.Debug("Updated queued limb state '" .. side .. " " .. limb .. "' (" .. condition .. ")", "affs")
      end
      display.Debug("Ignored new limb state '" .. side .. " " .. limb .. "' (" .. condition .. ")", "affs")
      return
    end
  end
  table.insert(qlimb, {side = side, limb = limb, condition = condition})
  display.Debug("Queued limb state '" .. side .. " " .. limb .. "' (" .. condition .. ")", "affs")
end

function clear_queue()
  qadd = {}
  qdel = {}
  qlimb = {}
  flags.clear{"last_cure", "prone_check", "blackout"}
  display.Debug("Affliction queues cleared", "affs")
end


local bedevils = {
  ["eat myrtle"] = function () add_queue("hypochondria") end,
  ["cure me senses"] = function () add_queue("hypochondria") end,
  ["eat yarrow"] = function () add_queue("impatience") end,
  ["cure me blood"] = function () add_queue("impatience") end,
  ["eat horehound"] = function () add_queue("recklessness") end,
  ["cure me curses"] = function () add_queue("recklessness") end,
  ["eat reishi"] = function () add_queue("broken_nose") end,
  ["smoke coltsfoot"] = function () add_queue("hemophilia") end,
  ["cure me neurosis"] = function () add_queue("hemophilia") end,
  ["eat galingale"] = function () add_queue("slickness") end,
  ["cure me depression"] = function () add_queue("slickness") end,
  ["eat pennyroyal"] = function () add_queue("confusion") end,
  ["cure me mania"] = function () add_queue("confusion") end,
  ["eat marjoram"] = function () limb_queue("left", "leg", "broken") end,
  ["cure me muscles"] = function () limb_queue("left", "leg", "broken") end,
  ["eat wormwood"] = function () add_queue("sensitivity") end,
  ["cure me phobias"] = function () add_queue("sensitivity") end,
  ["eat calamus"] = function () add_queue("clumsiness") end,
  ["cure me glandular"] = function () add_queue("clumsiness") end,
  ["apply liniment to skin"] = function () add_queue("stupidity") end,
  ["cure me skin"] = function () add_queue("stupidity") end,
  ["cure me fractures"] = function () add_queue("powersink") end,
  ["cure me breaks"] = function () add_queue("weakness") end,
}

function last_cure(lc)
  if flags.get("bedevil") and bedevils[flags.get("bedevil")] then
    bedevils[flags.get("bedevil")]()
  elseif lc then
    cures.clear(lc)
  end

  flags.clear("last_cure")
end


function no_eating_allowed(aff)
  if flags.get("health_try") then
    failsafe.exec("health")
  elseif flags.get("herb_try") then
    failsafe.exec("herb")
  elseif flags.get("purgative_try") then
    failsafe.exec("purgative")
  elseif flags.get("sparkle_try") then
    failsafe.exec("sparkle")
  elseif flags.get("allheale_try") then
    failsafe.exec("allheale")
  elseif flags.get("speed_try") then
    flags.clear{"speed_try", "elixir"}
  elseif flags.get("check_eating") then
    flags.clear("check_eating")
    EnableTrigger("checking_eating_anorexia__", false)
    EnableTrigger("checking_eating_slit_throat__", false)
    EnableTrigger("checking_eating_throatlock__", false)
    EnableTrigger("checking_eating_windpipe__", false)
    EnableTrigger("checking_eating_fine__", false)
  else
    return
  end
  local aff = aff or "anorexia"
  add_queue(aff)
  unhidden(aff)
  flags.clear{"slow_sent", "slow_going"}
end

function no_smoking_allowed(aff)
  if flags.get("smoking") then
    if flags.get("smoking") ~= "faeleaf" or
       has("coils") then
      failsafe.exec("herb")
    end
  elseif flags.get("check_asthma") then
    flags.clear("check_asthma")
    EnableTrigger("checking_asthma1__", false)
    EnableTrigger("checking_asthma2__", false)
  else
    return
  end
  local aff = aff or "asthma"
  add_queue(aff)
  unhidden(aff)
  flags.clear{"slow_sent", "slow_going"}
end

function no_picking_up(aff)
  if flags.get("check_paralysis") then
    flags.clear("check_paralysis")
    EnableTrigger("checking_paralysis1__", false)
    EnableTrigger("checking_paralysis2__", false)
  else
    return
  end
  local aff = aff or "paralysis"
  add_queue(aff)
  unhidden(aff)
end

function no_standing_allowed(aff, val)
  if flags.get("check_standing") then
    flags.clear("check_standing")
    EnableTrigger("checking_standing_hemiplegy__", false)
    EnableTrigger("checking_standing_leglock__", false)
    EnableTrigger("checking_standing_roped__", false)
    EnableTrigger("checking_standing_shackled__", false)
    EnableTrigger("checking_standing_fine__", false)
  elseif flags.get("check_paralysis") then
    flags.clear("check_paralysis")
    EnableTrigger("checking_paralysis1__", false)
    EnableTrigger("checking_paralysis2__", false)
    if not aff then
      aff = "paralysis"
    end
  else
    return
  end

  local aff = aff or "leg_locked"
  add_queue(aff, val or true)
  unhidden(aff)
  flags.clear{"slow_sent", "slow_going"}
end


function blackout()
  add("blackout")
  local fn = flags.get("blackout")
  if fn then
    fn()
    flags.clear("blackout")
  end
  if flags.get("hex") or flags.get("onyx") then
    flags.set("check_speed", true, 5)
  end
  prompt.queue(function ()
    EnableGroup("Blackout", true)
    EnableGroup("Cures", true)
    EnableGroup("Poisons", true)
    EnableGroup("Sipping", true)
    EnableGroup("SongEffects", true)
    EnableTrigger("sparkleberry_healing__", true)
  end, "blackedout")
end

function unblackout()
  del("blackout")
  if flags.get("check_speed") then
    defs.del("speed")
  end
  defs.del("held_breath")
  flags.clear{"blackout", "check_speed"}
  prompt.queue(function ()
    EnableGroup("Blackout", false)
    EnableGroup("Cures", false)
    EnableGroup("Poisons", false)
    EnableGroup("Sipping", false)
    EnableGroup("SongEffects", false)
    EnableTrigger("sparkleberry_healing__", false)
    main.diag()
  end, "blackedin")
end


function blinded()
  if defs.has("sixthsense") then
    defs.del_queue("sixthsense")
  end
end

function deafened()
  if defs.has("truehearing") then
    defs.del_queue("truehearing")
  end
end


function deathmark(amt)
  local marks = 0
  if type(amt) == "string" then
    if amt == "slightly" then
      marks = 1
    elseif amt == "greatly" then
      marks = 2
    elseif amt == "brilliantly" then
      marks = 3
    else
      if not flags.get("deathmarked") then
        flags.set("deathmarked", true, 300)
      end

      if amt == "small stain" then
        add_queue("deathmarks", 1)
      elseif amt == "murky blotch" then
        add_queue("deathmarks", 4)
      elseif amt == "dark mark" then
        add_queue("deathmarks", 8)
      elseif amt == "jagged scar" then
        add_queue("deathmarks", 12)
      elseif amt == "black miasma" then
        add_queue("deathmarks", 15)
      end
      return
    end
  else
    marks = amt
  end

  local count = has("deathmarks") or 0
  marks = math.max(math.min(15, count + marks), 1)
  if flags.get("deathmarked") then
    add_queue("deathmarks", marks)
  end
end


function prone(aff)
  if type(aff) == "table" then
    for _,a in ipairs(aff) do
      prone(a)
    end
    return
  end

  if has(aff) then
    return
  end

  local pc = flags.get("prone_check") or {}
  table.insert(pc, aff or "prone")
  flags.set("prone_check", pc)
  flags.clear("hex")
end


function aeoned()
  EnableTrigger("aff_aeon1__", true)
  EnableTrigger("aff_aeon2__", true)
  prompt.queue(function ()
    EnableTrigger("aff_aeon1__", false)
    EnableTrigger("aff_aeon2__", false)
  end, "unaeon")
end

function aeon()
  if defs.has("speed") then
    flags.clear{"speed_try", "waiting_for_speed"}
    defs.del("speed")
  else
    add_queue("aeon")
    flags.set("aeon_time", os.clock(), 0)
  end

  EnableTrigger("cure_jinx__", true)
  prompt.queue(function () EnableTrigger("cure_jinx__", false) end, "unjinx")
end

function unaeon()
  if flags.get("last_cure") == "sip phlegmatic" or
     flags.get("last_cure") == "eat reishi" or
     flags.get("last_cure") == "sip allheale" or
     flags.get("last_cure") == "moondance full" or
     flags.get("last_cure") == "invoke green" or
     flags.get("last_cure") == "evoke gedulah" or
     flags.get("speed_try") or
     (os.clock() - (flags.get("aeon_time") or 0)) < 20 or
     has("blackout") then
    del_queue("aeon")
    flags.clear{"aeon_time", "slow_sent", "slow_going"}
  end
end

function allergy(amt)
  local curr = has("allergies") or flags.get("allergies") or 0
  
  if type(amt) == "string" then
    local lo = allergic[amt] or 0
    local hi = 0
    if amt == "mild" then
      hi = allergic.strong
    elseif amt == "strong" then
      hi = allergic.severe
    elseif amt == "severe" then
      hi = allergic.incapacitating
    else
      hi = 40
    end
    if curr >= lo and curr < hi then
      add("allergies", curr)
      return
    end

    amt = hi - 1
    curr = 0
  end

  local new = curr + amt

  if new <= 0 then
    del_queue("allergies")
    return
  end

  add_queue("allergies", new)
end


function bleed(amt, immed)
  if not amt then
    amt = 100
  end

  local curr = has("bleeding") or 0
  if amt + curr <= 20 then
    del("bleeding")
  elseif immed then
    add("bleeding", curr + amt)
  else
    add_queue("bleeding", curr + amt)
  end
end

function burned(level)
  if not level or #level == 0 then
    del_queue("burns_first")
    return
  end

  local aff = "burns_" .. level
  if has(aff) then
    return
  end

  for _,a in ipairs{"burns_first", "burns_second", "burns_third", "burns_fourth"} do
    del(a, true)
  end
  add_queue(aff)
end

function burning()
  EnableTrigger("aff_burnlevel__", true)
  prompt.queue(function () EnableTrigger("aff_burnlevel__", false) end, "burnlevel")
end

function burst(count, abs)
  local b = has("burst_vessels") or 0
  if not count then
    b = b + 1
  elseif abs then
    b = count
  else
    b = b + count
  end

  if b > 0 then
    add_queue("burst_vessels", b)
  else
    del_queue("burst_vessels")
  end    
end


function check_arm(name, line, wildcards, styles)
  local side = wildcards[1]
  if name == "symp_arm_off_balance__" then
    if side == "left" then
      side = "right"
    else
      side = "left"
    end
  end

  if not flags.get("checking_arm") and not aethercraft.is_locked() then
    if not has("hemiplegy_" .. side) and
       not has("hemiplegy") and
       not has("clamped_" .. side) and
       not has("pierced_" .. side .. "arm") then
      flags.set("check_arm", side)
    end
    flags.set("checking_arm", true, 1)
  end
end

function check_leg(name, line, wildcards, styles)
  if limb("left", "leg") == "healthy" and
     limb("right", "leg") == "healthy" and
     not has("pierced_leftleg") and
     not has("pierced_rightleg") then
    add_queue("mending_legs")
  end
end

function check_limbs(name, line, wildcards, styles)
  if not main.auto("diagnose") then
    return
  end
end

function cold()
  if defs.has("fire") and not defs.going("fire") then
    defs.del_queue("fire")
    flags.clear("last_cure")
  elseif has("shivering") or coming("shivering") then
    prone("frozen")
  else
    add_queue("shivering")
  end
end


function displaced()
  if not has("displacement") then
    add("displacement")
    failsafe.fire()
  end
end

failsafe.fn.displaced = function ()
  EnableTrigger("aeonics_displaced__", false)
end

function drunken(amt)
  if type(amt) == "string" then
    drunk = drunk_levels[amt] or 0
  else
    drunk = drunk + amt
  end
  -- TODO: timer to wear off drunkenness?
end


function glamour(text, max)
  local colors = {
    ["incandescent blue striations"] = function () add_queue("recklessness") end,
    ["vibrant orange hues"] = function () add_queue("stupidity") end,
    ["scarlet red light"] = function () prone("paralysis") end,
    ["bright yellow flashes"] = function () add_queue("dementia") end,
    ["deep indigo whorls"] = function () flags.damaged_health() end,
    ["emerald green iridescence"] = function () add_queue("epilepsy") end,
    ["lustrous violet swirls"] = function () add_queue("dizziness") end,
  }
  local max = max or 2
  local cnt = 0
  local qf = {}
  for c,a in pairs(colors) do
    if string.find(text, c) then
      table.insert(qf, a)
      cnt = cnt + 1
    end
  end
  if cnt > max then
    return
  end
  for _,a in ipairs(qf) do
    a()
  end
end

function grapple(part, person, special)
  if not person then
    if part then
      grapples[part] = nil
      ninshi[part] = nil
      ootangk[part] = nil
    else
      grapples = {}
      ninshi = {}
      ootangk = {}
    end
    flags.clear("writhing")
  elseif not part then
    for _,p in ipairs{"body", "chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
      if grapples[p] == person or grapples[p] == "Someone" then
        grapple(p)
      end
    end
  else
    grapples[part] = person
    if special == "ninshi" then
      ninshi[part] = true
    elseif special == "ootangk" then
      ootangk[part] = true
    end
  end

  if grapples.chest or
     grapples.gut or
     grapples.head or
     grapples.leftarm or
     grapples.leftleg or
     grapples.rightarm or
     grapples.rightleg or
     grapples.body then
    add_queue("grappled")
  else
    ninshi = {}
    ootangk = {}
    del_queue("grappled")
  end
end


function hexed()
  failsafe.check("asthma", "asthma")
  failsafe.check("eating", "anorexia")
  failsafe.check("dementia", "dementia")
  failsafe.check("paralysis", "paralysis")
  defs.del("insomnia")
  scan.process()
end

function hypochondria()
  if has("hypochondria") or flags.get("skip_hypochondria") then
    return
  end

  local c = flags.get("hypochondriac") or 0
  c = c + 1
  if c > 2 then
    add_queue("hypochondria")
    flags.clear("hypochondriac")
  else
    flags.set("hypochondriac", c, 1.5)
  end
end


function insanity(amt, val)
  local curr = has("insanity") or 0
  
  if type(amt) == "string" then
    if curr >= (insane[amt] or 0) then
      return
    end
    if amt == "slight" then
      amt = (insane.moderate - insane.slight) / 2 + insane.slight
    elseif amt == "moderate" then
      amt = (insane.major - insane.moderate) / 2 + insane.moderate
    elseif amt == "major" then
      amt = (insane.massive - insane.major) / 2 + insane.major
    else
      amt = 60
    end
  end

  if amt < 0 then
    flags.clear("last_cure")
  end

  local new = curr + amt

  if val and amt < 0 and insane[val] > new then
    new = insane[val]
  end

  if new <= 0 or val == "none" then
    del_queue("insanity")
    return
  end

  add_queue("insanity", new)
end


function numb(part, iter)
  if not part then
    return
  end

  local iter = iter or 0

  add("numb_" .. part)
  if iter < 2 then
    if string.find(part, "arm") or string.find(part, "head") then
      numb("chest", iter + 1)
    elseif string.find(part, "leg") then
      numb("gut", iter + 1)
    elseif part == "chest" then
      numb("head", iter + 1)
      numb("gut", iter + 1)
      numb("leftarm", iter + 1)
      numb("rightarm", iter + 1)
    elseif part == "gut" then
      numb("chest", iter + 1)
      numb("rightleg", iter + 1)
      numb("leftleg", iter + 1)
    end
  end
end


function poison(aff)
  add_queue(aff)
  flags.set("skip_hypochondria", true)
  flags.clear{"charybdon", "last_cure"}

  if flags.get("hex") then
    flags.clear("hex")
    prompt.unqueue("mehexed")
  end
end


local function repel(name)
  local pc = flags.get("prone_check") or {}
  for i,v in ipairs(pc) do
    if v == name then
      table.remove(pc, i)
    end
  end
  if #pc > 0 then
    flags.set("prone_check", pc)
  else
    flags.clear("prone_check")
  end
  flags.set("repel_" .. name, true)
  flags.set("repelled", name)
  qadd[name] = nil
  local charyb = (flags.get("charybdon") or 1)   - 1
  if charyb <= 0 then
    flags.clear("charybdon")
  else
    flags.set("charybdon", charyb, 0)
  end
  if flags.get("last_hidden") then
    for _,a in ipairs(hideys[name] or {}) do
      if a == flags.get("last_hidden") then
        local count = (has(a) or 0) - 1
        if count < 1 then
          current[a] = nil
          display.Debug("Hidden affliction removed - '" .. a .. "'", "affs")
        else
          current[a] = count
          display.Debug("Hidden affliction updated - '" .. a .. "' (" .. count .. ")", "affs")
        end
        break
      end
    end
    flags.clear("last_hidden")
  end
end

function repel_amulet(name, line, wildcards, styles)
  local rune_affs = {
    ansuz = "hypochondria",
    beorc = "shyness",
    cen = "stupidity",
    daeg = "illuminated",
    eh = "recklessness",
    eoh = "confusion",
    eohl = "pacifism",
    feoh = "masochism",
    ger = "impatience",
    ing = "lovers",
    lagu = "dementia",
    manna = "repugnance",
    nyd = "sensitivity",
    peorth = "hallucinations",
    tiwaz = "justice",
    ur = "gluttony",
    wynn = "loneliness",
    gyfu = "paralysis",
    --othala = "random",
    --haegl = "manadrain",
    --sigil = "defstrip",
    --isa = "cold",
  }
  local rune = wildcards[1] or ""
  if rune_affs[rune] then
    repel(rune_affs[rune])
  end
end

function repel_fear(name, line, wildcards, styles)
  repel("fear")
end

function repel_tea(name, line, wildcards, styles)
  local tea_defs = {
    insight = "white",
    movement = "green",
    passion = "oolong",
    vivaciousness = "black",
  }
  if defs.has("tea") == tea_defs[wildcards[2]] then
    repel(wildcards[3])
    if #wildcards[1] == 0 then
      defs.del_queue("tea")
      bals.lose("brew")
      flags.set("brew_off", true, 65)
    end
  end
end

function repel_karma(name, line, wildcards, styles)
  repel(wildcards[1])
end

function repel_consciousness(name, line, wildcards, styles)
  defs.add_queue("consciousness")
  repel("unconscious")
end


local function runed(name)
  local rune_affs = {
    ansuz = "hypochondria",
    beorc = "shyness",
    cen = "stupidity",
    daeg = "illuminated",
    eh = "recklessness",
    eoh = "confusion",
    eohl = "pacifism",
    feoh = "masochism",
    ger = "impatience",
    ing = "lovers",
    lagu = "dementia",
    manna = "repugnance",
    nyd = "sensitivity",
    peorth = "hallucinations",
    tiwaz = "justice",
    ur = "gluttony",
    wynn = "loneliness",
    gyfu = function () prone("paralysis") end,
    othala = function () main.diag() end,
    haegl = function () flags.damaged_mana() end,
    sigil = function () prompt.preillqueue(function () display.Alert("Check DEF!") end) end,
    rad = function () prompt.preillqueue(function () display.Alert("Moved by Rad rune!") end, "summoned") end,
    isa = function () cold() end,
  }

  if not rune_affs[name] then
    return false
  end

  if type(rune_affs[name]) == "function" then
    rune_affs[name]()
  else
    add_queue(rune_affs[name])
  end

  return true
end

local function check_runes(person, ab)
  if person then
    if flags.get("antirunes_" .. person) then
      flags.clear("antirunes_" .. person)
      return false
    end
    flags.set("antirunes_" .. person, true, 1)
    if not main.attacked(person, "runes", ab or "sling") then
      return false
    end
  elseif not main.attacked(nil, "runes", ab or "sling") then
    return false
  end
  return true
end


function stunned()
  if not has("stunned") and not flags.get("stun_immunity") then
    prone(function ()
      affs.add("stunned")
      failsafe.fire()
      failsafe.exec("stun", 1.5, true)
      flags.clear_stun()
    end, "stunner")
  end
end

failsafe.fn.stun = function ()
  affs.del("stunned")
end


function telepathy()
  local pc = flags.get("prone_check")
  if pc and prompt.stat("prone") then
    return
  end

  if prompt.stat("hp") < prompt.stat("maxhp") * 0.95 then
    flags.damaged_health()
  elseif prompt.stat("mp") < prompt.stat("maxmp") * 0.95 then
    flags.damaged_mana()
  elseif prompt.stat("ego") < prompt.stat("maxego") * 0.95 then
    flags.damaged_ego()
  end

--  local count = has("telepathy") or 1
--  local plural = ""
--  if count > 1 then
--    plural = "s"
--  end
--  display.Alert("Hit by " .. count .. " telepathy affliction" .. plural)
end

function timewarp(amt, val)
  local curr = has("timewarp") or 0
  
  if type(amt) == "string" then
    if curr >= (timewarped[amt] or 0) then
      return
    end
    if amt == "minorly" then
      amt = (timewarped.moderately - timewarped.minorly) / 2 + timewarped.minorly
    elseif amt == "moderately" then
      amt = (timewarped.majorly - timewarped.moderately) / 2 + timewarped.moderately
    elseif amt == "majorly" then
      amt = (timewarped.massively - timewarped.majorly) / 2 + timewarped.majorly
    else
      amt = 60
    end
  end

  if amt < 0 then
    flags.clear("last_cure")
  end

  local new = curr + amt

  if val and amt < 0 and timewarped[val] > new then
    new = timewarped[val]
  end

  if new <= 0 or val == "none" then
    del_queue("timewarp")
    return
  end

  add_queue("timewarp", new)
end


function hidden(name, val, max)
  if type(name) == "table" then
    for _,a in ipairs(name) do
      hidden(a, val)
    end
    return
  end

  local val = math.min((val or current[name] or 0) + 1, max or 4)
  if not current[name] then
    display.Debug("Hidden affliction added - '" .. name .. "' (" .. tostring(val) .. ")", "affs")
  elseif val ~= current[name] then
    display.Debug("Hidden affliction updated - '" .. name .. "' (" .. tostring(val) .. ")", "affs")
  else
    return
  end
  flags.clear("last_cure")
  flags.clear_scan(name)
  scan.update = true
  current[name] = val
  flags.set("last_hidden", name)
end

function unhidden(aff)
  if not hideys[aff] then
    return
  end

  for _,a in ipairs(hideys[aff]) do
    local count = has(a)
    if count then
      count = count - 1
      if count < 1 then
        current[a] = nil
        display.Debug("Hidden affliction removed - '" .. a .. "'", "affs")
      else
        current[a] = count
        display.Debug("Hidden affliction updated - '" .. a .. "' (" .. count .. ")", "affs")
      end
    end
  end
end

failsafe.fn.unknown_affs = function ()
  affs.unknown(-1)
end

function unknown(count)
  if count then
    unknowns = unknowns + count
    if unknowns <= 0 then
      unknowns = 0
      failsafe.disable("unknown_affs")
    elseif unknowns == count then
      failsafe.exec("unknown_affs", tonumber(GetVariable("sg1_option_unknown_timeout") or "11"), true)
    end
    display.Debug("Unknown affs = " .. unknowns, "affs")
    if unknowns >= tonumber(GetVariable("sg1_option_unknown_diag") or "1") then
      main.diag()
    end
  end
  return unknowns
end


function reset(diag)
  if diag then
    if has("allergies") then
      flags.set("allergies", has("allergies"))
    end
  else
    grapples = {}
    ninshi = {}
    ootangk = {}
  end
  unknowns = 0
  failsafe.disable("unknown_affs")
  current = {}
  limbs = {
    left_arm = "healthy",
    left_leg = "healthy",
    right_arm = "healthy",
    right_leg = "healthy",
  }
  display.Debug("Afflictions cleared", "affs")
  clear_queue()
  scan.update = true
end


function OnPrompt()
  for a,v in pairs(qadd) do
    add(a, v)
  end
  for _,t in ipairs(qlimb) do
    limb(t.side, t.limb, t.condition)
  end
  for a in pairs(qdel) do
    del(a)
  end

  qadd = {}
  qdel = {}
  qlimb = {}
end


function show()
  display.Info("Affliction Status Report:")

  local i = 0
  for aff,val in pairs(mine()) do
    if i == 0 then
      display.Prefix()
      Tell("  ")
    end
    if i > 0 then
      ColourTell("silver", "black", ", ")
    end
    ColourTell("silver", "black", aff)
    if val ~= true then
      ColourTell("gray", "black", " (" .. tostring(val) .. ")")
    end
    i = i + 1
  end

  if i == 0 then
    display.Prefix()
    ColourNote("dimgray", "", "  All clear.")
  else
    Note("")
  end
  if IsConnected() then
    Send("")
  end
end


local function exec_handler(hfn, name, wc)
  if not hfn or not hfn[name] then
    display.Error("No affliction handler for '" .. name .. "'")
    return
  end
  hfn[name](wc)
end

tr.aff = {
  aeon1 = function ()
    defs.del("speed")
    flags.clear("waiting_for_speed")
  end,
  aeon2 = function ()
    if not flags.get("waiting_for_speed") then
      defs.del("speed")
    end
    aeon()
  end,
  ablaze = function ()
    add_queue("ablaze")
    burning()
    if flags.get("ignite_try") then
      magic.use_charge("ignite")
    end
    if flags.get("enchant_attacker") then
      prompt.queue(function() cures.clear("point ignite at me") end, "ignited")
      main.attacked(flags.get("enchant_attacker"), nil, "ignite")
    end
  end,
  asleep_fell = function ()
    prone{"asleep", "prone"}
    defs.del_queue("insomnia")
  end,
  asleep_poison = function ()
    prone()
    defs.del_queue("insomnia")
    poison("asleep")
    local charyb = (flags.get("charybdon") or 1) - 1
    if charyb <= 0 then
      flags.clear("charybdon")
    else
      flags.set("charybdon", charyb, 0)
    end
  end,
  asleep_tired = function ()
    prone{"prone", "asleep"}
  end,
  bleeding = function (wc)
    local b = tonumber(wc[1])
    if b < prompt.stat("maxhp") then
      add_queue("bleeding", b)
      flags.damaged_health()
    end
  end,
  burnlevel = function (wc)
    burned(wc[1])
  end,
  concussion = function ()
    if map.elevation() == "flying" then
      if not defs.has("levitation") then
        flags.damaged_health()
      end
      prompt.preillqueue(function ()
        if map.elevation() == "ground" then
          add{"concussion", "damaged_head2", "damaged_head"}
          bleed(50)
          defs.del("flying")
        end
      end, "plummeted")
    end
  end,
  dizziness = function ()
    add_queue("dizziness")
  end,
  drunk = function (wc)
    drunken(wc[1])
  end,
  enchantment = function (wc)
    flags.set("enchant_attacker", wc[1])
    EnableTrigger("aff_ablaze__", true)
    prompt.queue(function () EnableTrigger("aff_ablaze__", false) end, "blazing")
  end,
  entangled = function (wc)
    local ap = wc[1]
    local as = "cosmic"
    if #ap <= 1 then
      ap = flags.get("enchant_attacker")
      as = "enchantment"
    end
    if main.attacked(ap, as, "web") then
      prone("entangled")
    end
  end,
  fear_ascendant = function (wc)
    if main.attacked(wc[1], "ascendance", "fearaura") then
      add_queue("fear")
    end
  end,
  hyperventilating = function ()
    if defs.has("held_breath") then
      add_queue("hyperventilating")
    end
  end,
  kneecap_again = function (wc)
    limb_queue(wc[1], "leg", "broken")
  end,
  kneeling = function ()
    prone("kneeling")
  end,
  legs_notree = function (wc)
    limb_queue(wc[1], "leg", "broken")
  end,
  legs_tree = function ()
    limb_queue("left", "leg", "broken")
    limb_queue("right", "leg", "broken")
  end,
  orgpotion_gaudiguch = function (wc)
    if main.attacked(wc[1], "gaudiguch", "orgpotion") then
      add_queue("ablaze")
      flags.damaged_health()
    end
  end,
  orgpotion_glomdoring = function (wc)
    if main.attacked(wc[1], "glomdoring", "orgpotion") then
      bleed(150)
    end
  end,
  orgpotion_hallifax = function (wc)
    if main.attacked(wc[1], "hallifax", "orgpotion") then
      flags.set("slushy", true, 12)
    end
  end,
  orgpotion_hallifax_stun = function (wc)
    if flags.get("slushy") then
      stunned()
    end
  end,
  orgpotion_hallifax_end = function (wc)
    flags.clear("slushy")
  end,
  orgpotion_magnagora = function (wc)
    if main.attacked(wc[1], "magnagora", "orgpotion") then
      flags.damaged_health()
    end
  end,
  pacifism = function ()
    add_queue("pacifism")
  end,
  prone = function ()
    prone()
  end,
  resist_summon = function ()
    prompt.unqueue("summoned")
  end,
  rigormortis = function ()
    add_queue("rigormortis")
  end,
  scabies = function ()
    add_queue("scabies")
  end,
  shieldstun = function (wc)
    if main.attacked(wc[1], "combat", "shieldstun") then
      stunned()
    end
  end,
  totem_statue = function ()
    local bolts = (flags.get("totem_statue") or 0) + 1
    if bolts == 6 then
      flags.clear("totem_statue")
      if not flags.get("repel_paralysis") then
        prone("paralysis")
      end
      for _,a in ipairs{"loneliness", "masochism", "hallucinations", "stupidity", "impatience"} do
        if not flags.get("repel_" .. a) then
          add_queue(a)
        end
      end
    else
      flags.set("totem_statue", bolts)
    end
  end,
}

tr.symp = {
  ablaze = function ()
    flags.damaged_health()
    add_queue("ablaze")
    burning()
  end,
  aeon = function ()
    if not aethercraft.is_locked() then
      if not has("aeon") and (has("blackout") or flags.get("check_aeon")) then
        defs.del("speed")
        aeon()
        flags.clear{"check_aeon", "checking_aeon"}
        EnableTrigger("checking_aeon1__", false)
      elseif not has("aeon") then
        flags.set("check_aeon", true, 0.7)
      end
    end
    if flags.get("slow_sent") then
      flags.set("slow_going", flags.get("slow_sent"), 1.5)
      flags.clear("slow_sent")
    end
  end,
  agoraphobia = function ()
    poison("agoraphobia")
  end,
  amnesia = function ()
    if flags.get("slow_sent") or flags.get("slow_going") then
      flags.clear{"slow_sent", "slow_going"}
    end
  end,
  anorexia = function ()
    no_eating_allowed("anorexia")
  end,
  asleep = function ()
    if not has("asleep") then
      prone{"asleep", function () failsafe.fire() end}
    end
  end,
  asthma_smoking = function ()
    no_smoking_allowed("asthma")
  end,
  black_lung = function ()
    add_queue("black_lung")
  end,
  black_lung_smoke = function ()
    no_smoking_allowed("black_lung")
  end,
  broken_jaw = function ()
    add_queue("broken_jaw")
  end,
  claustrophobia = function ()
    poison("claustrophobia")
  end,
  clumsiness = function ()
    add_queue("clumsiness")
  end,
  collapsed_lungs = function ()
    prompt.preillqueue(function ()
      if affs.has("blackout") then
        affs.add("collapsed_lungs")
      end
    end, "collung")
  end,
  collapsed_lungs_smoking = function ()
    no_smoking_allowed("collapsed_lungs")
  end,
  confused = function ()
    if flags.get("concentrate_try") or has("sap") then
      add_queue("confusion")
      flags.clear{"concentrate_try", "slow_going", "slow_sent"}
    end
  end,
  crippled_arms = function ()
    -- TODO: check other arm afflictions before assuming broken
    add_queue("mending_arms")
  end,
  crippled_legs = function ()
    limb_queue("left", "leg", "broken")
    limb_queue("right", "leg", "broken")
  end,
  crotamine1 = function ()
    add_queue("crotamine", 1)
  end,
  crotamine2 = function ()
    add_queue("crotamine", 2)
  end,
  crotamine3 = function ()
    add_queue("crotamine", 3)
  end,
  crotamine4 = function ()
    add_queue("crotamine", 4)
  end,
  crushed_windpipe = function ()
    no_eating_allowed("crushed_windpipe")
  end,
  darkfate_focus = function ()
    if flags.get("focusing") == "mind" then
      add_queue("darkfate")
    end
  end,
  darkfate_herb = function ()
    if string.find(flags.get("last_cure") or "", "^eat %a+$") then
      add_queue("darkfate")
      flags.clear("last_cure")
    end
  end,
  dizziness = function ()
    prone{"prone", "dizziness"}
  end,
  dysentery = function ()
    add_queue("dysentery")
  end,
  entangled = function ()
    prone("entangled")
  end,
  epilepsy = function ()
    add_queue("epilepsy")
  end,
  fear = function ()
    add_queue("fear")
  end,
  feat_failed = function ()
    flags.damaged_power()
  end,
  frozen = function ()
    prone("frozen")
    defs.del_queue("fire")
  end,
  furrowed_brow = function ()
    add_queue("furrowed_brow")
  end,
  gluttony = function ()
    add_queue("gluttony")
  end,
  hallucinations = function ()
    add_queue("hallucinations")
  end,
  hallucinations_prone = function ()
    prone{"prone", "hallucinations"}
  end,
  hallucinations_stun = function ()
    stunned()
    prone("hallucinations")
  end,
  healthleech = function ()
    add_queue("healthleech")
  end,
  hemiplegy_legs = function ()
    add_queue("hemiplegy_legs")
  end,
  hemophilia = function ()
    if flags.get("clot_try") then
      add_queue("hemophilia")
      flags.clear("clot_try")
    end
  end,
  hypersomnia = function ()
    if flags.get("insomnia_try") then
      add_queue("hypersomnia")
      flags.clear("insomnia_try")
    end
  end,
  hypochondria1 = function ()
    add_queue("hypochondria")
    flags.clear("hypocchondriac")
  end,
  hypochondria2 = function ()
    prompt.preillqueue(function ()
      if not prompt.gstats.prone then
        affs.add("hypochondria")
        flags.clear("hypochondriac")
      end
    end, "hypoch")
  end,
  hypochondria3 = function ()
    hypochondria()
    prompt.preillqueue(function ()
      if not prompt.gstats.blind and not defs.has("sixthsense") then
        affs.add("hypochondria")
        flags.clear("hypochondriac")
      end
    end, "hypoch")
  end,
  hypochondria4 = function ()
    hypochondria()
  end,
  impatience = function ()
    if flags.get("focus_try") then
      add_queue("impatience")
      failsafe.exec("focus")
    end
  end,
  impatience_med = function ()
    add_queue("impatience")
    flags.clear("check_impatience")
    EnableTrigger("check_impatience__", false)
  end,
  justice = function ()
    add_queue("justice")
  end,
  kneecap_stance = function ()
    defs.del_queue("stance")
    if not has("kneecap_left") then
      add_queue("kneecap_right")
    end
  end,
  leglocked = function (wc)
    add_queue("leg_locked")
    --display.Alert("DISRUPT the telekinetic one!")
    if string.find(wc[0], "unable") then
      flags.clear("stand_try")
    end
  end,
  loneliness = function ()
    add_queue("loneliness")
  end,
  lost_ear = function (wc)
    add_queue{"dizziness", "lostear_" .. wc[1]}
  end,
  lost_eyes = function ()
    add_queue{"losteye_left", "losteye_right"}
  end,
  lovers = function ()
    add_queue("lovers")
  end,
  masochism = function ()
    add_queue("masochism")
  end,
  narcolepsy = function ()
    add_queue("narcolepsy")
  end,
  need_two_legs = function (wc)
    if (limb("left", "leg") == "healthy" and limb("right", "leg") == "healthy") and
       not (grapples.leftleg or grapples.rightleg) and
       not (has("hemiplegy_left") or has("hemiplegy_right") or has("hemiplegy")) then
      limb_queue("right", "leg", "broken")
    end
    if flags.get("stand_try") and string.find(wc[0], "must") then
      flags.clear("stand_try")
      prone()
    end
  end,
  paralysis = function ()
    if not has("severed_spine") then
      prone("paralysis")
    end
    flags.clear{"stand_try", "slow_sent", "slow_going"}
  end,
  paranoia = function ()
    failsafe.check("paranoia", "paranoia")
  end,
  paranoia2 = function ()
    failsafe.check("paranoia", "paranoia")
  end,
  peace = function ()
    add_queue("peace")
  end,
  phrenic_nerve = function ()
    no_smoking_allowed("phrenic_nerve")
  end,
  pierced_leg = function ()
    if not (has("pierced_leftleg") or has("pierced_rightleg")) then
      prone("smoke_myrtle")
    end
  end,
  powersap = function ()
    add_queue("powersap")
  end,
  pox = function ()
    add_queue("pox")
  end,
  punctured_chest = function ()
    prompt.preillqueue(function ()
      if affs.has("blackout") then
        affs.add("punctured_chest")
      end
    end, "punchest")
  end,
  relapsing = function ()
    add_queue("relapsing")
    main.poisons_on()
  end,
  repugnance = function ()
    if flags.get("beast_order") or
       main.has_skill("wiccan") then
      flags.clear("beast_order")
      add_queue("repugnance")
    end
  end,
  rigormortis = function (wc)
    add_queue("rigormortis")
    limb_queue(wc[1], wc[2], "broken")
  end,
  rivulets = function (wc)
    if wc[2] == "arm" then
      add_queue("bicep_" .. wc[1])
    else
      add_queue("thigh_" .. wc[1])
    end
  end,
  roped = function ()
    prone("roped")
  end,
  scabies = function ()
    prompt.illqueue(function ()
      if not bals.get("bal") then
        affs.add("scabies")
      end
    end, "scabiestick")
  end,
  scarab = function ()
    no_eating_allowed("scarab")
  end,
  severed_arms = function ()
    failsafe.check("severed_arms", "severed_arm")
  end,
  shackled = function ()
    prone("shackled")
  end,
  shivering = function ()
    add_queue("shivering")
    defs.del_queue("fire")
  end,
  shivering_disrupted = function ()
    flags.set("shivering", true)
  end,
  shyness = function ()
    add_queue("shyness")
  end,
  shyness_fear = function ()
    add_queue{"shyness", "fear"}
  end,
  sliced_gut = function ()
    prone{"prone", "sliced_gut"}
  end,
  sliced_torso = function (wc)
    add_queue("sliced_" .. wc[1])
    bleed(150)
  end,
  slickness_arnica = function ()
    if flags.get("arnica_try") then
      add_queue("slickness")
      bals.gain("herb")
      flags.clear("last_cure")
    end
  end,
  slickness_health = function ()
    if flags.get("health_applying") then
      add_queue("slickness")
      bals.gain("health")
      flags.clear{"last_cure", "health_applying"}
      -- TODO: clear scanned flags
    end
  end,
  slickness_salve = function ()
    if flags.get("applied") then
      add_queue("slickness")
      bals.gain("salve")
      if flags.get("applied") == "regeneration" and flags.get("applied_to") then
        flags.clear("regenerating")
        failsafe.disable("regeneration")
      end
      flags.clear("last_cure")
      -- TODO: clear scanned flags
    end
  end,
  slit_throat = function ()
    no_eating_allowed("slit_throat")
  end,
  stance_stumble = function ()
    defs.del_queue("stance")
  end,
  stunned = function ()
    stunned()
  end,
  stupidity = function ()
    if not has("fractured_head") then
      add_queue("stupidity")
    end
  end,
  sunallergy = function ()
    add_queue("sunallergy")
  end,
  sunallergy_paralysis = function ()
    prone{"sunallergy", "paralysis"}
  end,
  throat_locked = function ()
    no_eating_allowed("throat_locked")
    if has("blackout") then
      del_queue("clot_unknown")
      burst(-3)
    end
  end,
  transfixed = function ()
    add_queue("transfixed")
  end,
  vapors = function ()
    flags.set("blackout", function () affs.add("vapors") end)
    prone()
  end,
  vertigo = function ()
    add_queue("vertigo")
  end,
  vertigo_climb = function ()
    if flags.get("climb_try") then
      add_queue("vertigo")
      flags.clear("climb_try")
    end
  end,
  vestiphobia = function ()
    add_queue("vestiphobia")
  end,
  vomiting = function ()
    add_queue("vomiting")
  end,
  vomiting_blood = function ()
    flags.set("vomiting_blood", true)
  end,
  weakness = function ()
    add_queue("weakness")
  end,
}


tr.acrobatics = {
  forwardflip = function (wc)
    if main.attacked(wc[1], "acrobatics", "forwardflip") then
      prone()
      bleed(75)
      flags.damaged_health()
      EnableTrigger("acrobatics_flipleg__", true)
      prompt.queue(function () EnableTrigger("acrobatics_flipleg__", false) end, "flipleg")
    end
  end,
  flipleg = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  backflip = function (wc)
    if main.attacked(wc[1], "acrobatics", "backflip") then
      prone()
      stunned()
    end
  end,
  highjump = function (wc)
    if main.attacked(wc[1], "acrobatics", "highjump") then
      defs.del_queue("flying")
    end
  end,
  jumpkick = function (wc)
    if main.attacked(wc[1], "acrobatics", "jumpkick") then
      prone()
      stunned()
      flags.damaged_health()
    end
  end,
}

tr.aeonics = {
  aeon = function (wc)
    if main.attacked(wc[1], "aeonics", "aeon") then
      aeoned()
    end
  end,
  timewarp = function (wc)
    if main.attacked(wc[1], "aeonics", "timewarp") then
      timewarp(7)
    end
  end,
  temporalbonds = function (wc)
    if main.attacked("", "aeonics", "temporalbonds") then
      timewarp(5)
    end
  end,
  timeechoes = function (wc)
    if main.attacked(wc[1], "aeonics", "timeechoes") then
      add_queue("time_echoes")
      flags.set("time_echoes", 5, 0)
    end
  end,
  timeechoes_symp = function (wc)
    if main.attacked("", "aeonics", "timeechoes") then
      if has("time_echoes") then
        local echoes = flags.get("time_echoes") or 1
        if echoes < 2 then
          del_queue("time_echoes")
          flags.clear("time_echoes")
        else
          flags.set("time_echoes", echoes - 1, 0)
        end
        timewarp(4)
        failsafe.check("dementia", "dementia")
        hidden("time_echo", (has("time_echo") or 0) + 1)
      end
    end
  end,
  oracle = function (wc)
    if main.attacked(wc[1], "aeonics", "oracle") then
      add_queue("oracle")
    end
  end,
  oracle_symp = function (wc)
    if has("oracle") and main.attacked("", "aeonics", "oracle") then
      hidden("hidden_oracle")
      failsafe.check("paranoia", "paranoia")
      timewarp(4)
    end
  end,
  aeonfield = function (wc)
    if main.attacked(wc[1], "aeonics", "aeonfield") then
      EnableTrigger("aeonics_aeonfield_hit__", true)
      prompt.queue(function () EnableTrigger("aeonics_aeonfield_hit__", false) end)
    end
  end,
  aeonfield_hit = function (wc)
    if main.attacked(wc[1], "aeonics", "aeonfield") then
      aeoned()
      timewarp(4)
    end
  end,
  displacement = function (wc)
    if main.attacked(wc[1], "aeonics", "displacement") then
      EnableTrigger("aeonics_displaced__", true)
      failsafe.exec("displaced", 1.5, true)
      SendNoEcho("ql")
    end
  end,
  displaced = function (wc)
    displaced()
    failsafe.disable("displaced")
  end,
  timequake = function (wc)
    flags.set("timequaker", wc[1])
    EnableTrigger("aeonics_timequake_hit__", true)
    prompt.queue(function () EnableTrigger("aeonics_timequake_hit__", false) end)
  end,
  timequake_hit = function (wc)
    if main.attacked(flags.get("timequaker"), "aeonics", "timequake") then
      add_queue("time_echoes")
      flags.set("time_echoes", 5, 0)
    end
  end,
}

tr.aerochemantics = {
  stratus = function (wc)
    if main.attacked(wc[1], "aerochemantics", "stratus") then
      flags.damaged_health()
    end
  end,
  cirrus = function (wc)
    if main.attacked(wc[1], "aerochemantics", "cirrus") then
      add_queue("sensitivity")
    end
  end,
  cumulus = function (wc)
    if main.attacked(wc[1], "aerochemantics", "cumulus") then
      add_queue("epilepsy")
    end
  end,
  cloudkill = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aerochemantics_cloudkill2__", true)
    prompt.queue(function () EnableTrigger("aerochemantics_cloudkill2__", false) end)
  end,
  cloudkill2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aerochemantics", "cloudkill") then
      add_queue("sensitivity")
      flags.damaged_health()
    end
  end,
  quantum = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aerochemantics_quantum2__", true)
    prompt.queue(function () EnableTrigger("aerochemantics_quantum2__", false) end)
  end,
  quantum2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aerochemantics", "quantum") then
      timewarp(14)
      flags.damaged_health()
    end
  end,
  altostratus = function (wc)
    if main.attacked(wc[1], "aerochemantics", "altostratus") then
      add_queue("asthma")
    end
  end,
  dynomatic = function (wc)
    if main.attacked(wc[1], "aerochemantics", "dynomatic") then
      aeon()
    end
  end,
  aurora = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aerochemantics_aurora2__", true)
    prompt.queue(function () EnableTrigger("aerochemantics_aurora2__", false) end)
  end,
  aurora2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aerochemantics", "aurora") then
      local coils = has("coils") or 0
      if coils <= 7 then
        add_queue("coils", coils + 2)
      end
      flags.damaged_health()
    end
  end,
  electromagnetic = function (wc)
    main.attacked(wc[1], "aerochemantics", "electromagnetic")
  end,
  positronic = function (wc)
    if main.attacked(wc[1], "aerochemantics", "positronic") then
      add_queue("short_breath")
    end
  end,
  vacuum = function (wc)
    enemy.shielded(wc[1], false)
    enemy.rebound(wc[1], false)
    prompt.preillqueue(function () display.Warning("Aerochemantic Vacuum Coming!") end)
  end,
  vacuum2 = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aerochemantics_vacuum3__", true)
    prompt.queue(function () EnableTrigger("aerochemantics_vacuum3__", false) end)
  end,
  vacuum3 = function ()
    if main.attacked(flags.get("chemancer") or "", "aerochemantics", "vacuum") then
      flags.damaged_health()
    end
  end,
  static = function ()
    if main.attacked("", "aerochemantics", "static") then
      stunned()
      prone()
    end
  end,
}

tr.aeromancy = {
  thunderclouds = function (wc)
    if main.attacked(wc[1] or "", "aeromancy", "thunderclouds") then
      if wc[1] and #wc[1] > 0 then
        prone()
      end
      flags.damaged_health()
    end
  end,
  eastwind = function (wc)
    if main.attacked("", "aeromancy", "eastwind") then
      add_queue("pierced_" .. wc[1] .. wc[2])
    end
  end,
  blizzard = function ()
    if main.attacked("", "aeromancy", "blizzard") then
      cold()
    end
  end,
  rainbowclouds = function ()
    if main.attacked("", "aeromancy", "rainbowclouds") then
      add_queue("confusion")
    end
  end,
  thunderbird = function ()
    if main.attacked("", "aeromancy", "thunderbird") then
      flags.damaged_health()
      add_queue("epilepsy")
    end
  end,
  miasma = function ()
    if main.attacked("", "aeromancy", "miasma") then
      flags.damaged_mana()
    end
  end,
  twister = function ()
    if main.attacked("", "aeromancy", "twister") then
      defs.del_queue("flying")
    end
  end,
  airnet = function ()
    if main.attacked("", "aeromancy", "airnet") then
      prone("entangled")
    end
  end,
  southwind = function ()
    if main.attacked("", "aeromancy", "southwind") then
      hidden("southwind", has("southwind"), 5)
      failsafe.check("dementia", "dementia")
      failsafe.check("paranoia", "paranoia")
    end
  end,
  raise_staff_stripped = function (wc)
    if main.attacked(wc[1], "aeromancy", "staffraise") then
      defs.del_queue("levitating")
      prompt.preillqueue(function () display.Alert("Levitation stripped!") end, "nolev")
    end
  end,
  raise_staff_thrown = function (wc)
    if main.attacked(wc[1], "aeromancy", "staffraise") then
      defs.add_queue("flying")
    end
  end,
  northwind = function (wc)
    if main.attacked(wc[1], "aeromancy", "northwind") then
      local coils = has("coils") or 0
      if coils <= 7 then
        add_queue("coils", coils + 1)
      end
    end
  end,
}

tr.aquachemantics = {
  pellucid = function (wc)
    if main.attacked(wc[1], "aquachemantics", "pellucid") then
      flags.damaged_ego()
    end
  end,
  peaceful = function (wc)
    if main.attacked(wc[1], "aquachemantics", "peaceful") then
      flags.damaged_ego()
    end
  end,
  humid = function (wc)
    if main.attacked(wc[1], "aquachemantics", "humid") then
      flags.set("blackout", function () affs.add("vapors") end)
    end
  end,
  virtuous = function (wc)
    if main.attacked(wc[1], "aquachemantics", "virtuous") then
      add_queue("justice")
    end
  end,
  bubbling = function (wc)
    if main.attacked(wc[1], "aquachemantics", "bubbling") then
      add_queue("recklessness")
    end
  end,
  depuration = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aquachemantics_depuration2__", true)
    prompt.queue(function () EnableTrigger("aquachemantics_depuration2__", false) end)
  end,
  depuration2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aquachemantics", "depuration") then
      flags.set("blackout", function () affs.add("vapors") end)
    end
  end,
  chalice = function (wc)
    if main.attacked(wc[1], "aquachemantics", "chalice") then
      flags.damaged_health()
    end
  end,
  percolation = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aquachemantics_percolation2__", true)
    prompt.queue(function () EnableTrigger("aquachemantics_percolation2__", false) end)
  end,
  percolation2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aquachemantics", "percolation") then
      flags.set("blackout", function ()
        affs.add{"recklessness", "sensitivity", "vapors"}
      end)
    end
  end,
  luminated = function (wc)
    if main.attacked(wc[1], "aquachemantics", "luminated") then
      failsafe.check("blind", function () affs.add("faeriefire") end)
    end
  end,
  fervid = function (wc)
    if main.attacked(wc[1], "aquachemantics", "fervid") then
      add_queue("addiction")
    end
  end,
  dehydration = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aquachemantics_dehydration2__", true)
    prompt.queue(function () EnableTrigger("aquachemantics_dehydration2__", false) end)
  end,
  dehydration2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aquachemantics", "dehydration") then
      flags.damaged_health()
    end
  end,
  argent = function (wc)
    if main.attacked(wc[1], "aquachemantics", "argent") then
      add_queue("lovers")
    end
  end,
  aquoxitism = function (wc)
    flags.set("chemancer", wc[1])
    EnableTrigger("aquachemantics_aquoxitism2__", true)
    prompt.queue(function () EnableTrigger("aquachemantics_aquoxitism2__", false) end)
  end,
  aquoxitism2 = function ()
    if main.attacked(flags.get("chemancer") or "", "aquachemantics", "aquoxitism") then
      flags.damaged_health()
    end
  end,
}

tr.aquamancy = {
  hailstorm = function (wc)
    if main.attacked(wc[1], "aquamancy", "hailstorm") then
      EnableTrigger("aquamancy_hailstoned__", true)
      prompt.queue(function () EnableTrigger("aquamancy_hailstoned__", false) end)
    end
  end,
  hailstoned = function (wc)
    flags.damaged_health()
  end,
  icefloe1 = function ()
    if main.attacked("", "aquamancy", "icefloe") then
      defs.del_queue("fire")
    end
  end,
  icefloe2 = function ()
    if main.attacked("", "aquamancy", "icefloe") then
      defs.del_queue("fire")
      add_queue("shivering")
      del_queue("ablaze")
    end
  end,
  icefloe3 = function ()
    if main.attacked("", "aquamancy", "icefloe") then
      defs.del_queue("fire")
      prone("frozen")
      del_queue("ablaze")
    end
  end,
  tsunami = function ()
    if main.attacked("", "aquamancy", "tsunami") then
      prone()
    end
  end,
  currents = function ()
    if main.attacked("", "aquamancy", "currents") then
      defs.del_queue("protection")
    end
  end,
  needlerain = function ()
    if main.attacked("", "aquamancy", "needlerain") then
      defs.del_queue{"fire", "frost", "protection"}
      prompt.preillqueue(function () display.Alert("Check DEF!") end)
    end
  end,
  jellies = function ()
    if main.attacked("", "aquamancy", "jellies") and not is_prone() then
      stunned()
    end
  end,
  bubble = function (wc)
    if main.attacked(wc[1], "aquamancy", "bubble") and not slow() then
      prompt.illqueue(function () flags.set("bubble", true, 2) SendNoEcho("ql") end)
    end
  end,
  bubbled = function ()
    if flags.get("bubble") then
      add("bubble")
      flags.clear("bubble")
    end
  end,
  unbubble = function ()
    del("bubble")
  end,
  staff = function (wc)
    if main.attacked(wc[1], "aquamancy", "staffpoint") then
      flags.damaged_health()
    end
  end,
  preserve1 = function ()
    if main.attacked("", "aquamancy", "preserve") then
      defs.del_queue("fire")
      if not main.auto("fire") then
        main.auto("fire", true)
      end
    end
  end,
  preserve2 = function ()
    if main.attacked("", "aquamancy", "preserve") then
      defs.del_queue("fire")
      add_queue("shivering")
      if not main.auto("fire") then
        main.auto("fire", true)
      end
    end
  end,
  preserve3 = function ()
    if main.attacked("", "aquamancy", "preserve") then
      defs.del_queue("fire")
      prone("frozen")
      bals.lose("purgative")
      if not main.auto("fire") then
        main.auto("fire", true)
      end
      flags.damaged_health()
      prompt.preillqueue(function () display.Warning("Frozen solid!") end)
    end
  end,
  maelstrom_hit = function ()
    if main.attacked("", "aquamancy", "maelstrom") then
      bleed(250)
      flags.damaged_health()
    end
  end,
}

local astro_affs = {
  Sun = function () flags.damaged_health() end,
  Moon = function () hidden("moon_ray", has("moon_ray"), 2) failsafe.check("dementia", "dementia") end,
  Eroee = function () hidden("eroee_ray", 0) end,
  Sidiak = function () hidden("sidiak_ray", has("sidiak_ray"), 2) end, 
  Tarox = function () failsafe.check("asthma", "asthma") failsafe.check("impatience", "impatience") end,
  Papaxi = function () end,
  Aapek = function () failsafe.check("eating", "anorexia") aeon() end,
}

tr.astrology = {
  astrocast = function (wc)
    if main.attacked(wc[1], "astrology", "astrocast") then
      EnableTrigger("astrology_sphere__", true)
      prompt.queue(function () EnableTrigger("astrology_sphere__", false) end, "astrosphere")
    end
  end,
  sphere = function (wc)
    local sign = wc[1]
    local fn = astro_affs[sign]
    if fn then
      fn()
    end
  end,
  meteor1 = function (wc)
    if main.attacked(wc[1], "astrology", "meteor") then
      flags.set("meteoric", wc[1], 20)
      Execute("OnInstakill Meteor Cast - " .. wc[1] .. "! MOVE!")
    end
  end,
  meteor2 = function ()
    if main.attacked(flags.get("meteoric") or "", "astrology", "meteor") then
      Execute("OnInstakill Meteor Coming!! MOVE!!")
    end
  end,
  meteor3 = function ()
    if main.attacked(flags.get("meteoric") or "", "astrology", "meteor") then
      add_queue("ablaze")
      burning()
      flags.damaged_health()
    end
  end,
}

tr.athletics = {
  headslam = function (wc)
    if main.attacked(wc[1], "athletics", "headslam") then
      stunned()
      EnableTrigger("athletics_headslammed__", true)
      prompt.queue(function () EnableTrigger("athletics_headslammed__", false) end, "headslamming")
    end
  end,
  headslammed = function ()
    prone()
  end,
  intimidate = function (wc)
    if main.attacked(wc[1], "athletics", "intimidate") then
      add_queue("fear")
    end
  end,
  tackle = function (wc)
    if main.attacked(wc[1], "athletics", "tackle") then
      display.Alert("Tackled by " .. string.upper(wc[1]))
      flags.set("tackled", string.upper(wc[2]))
      EnableTrigger("athletics_tackled__", true)
      prompt.queue(function () EnableTrigger("athletics_tackled__", false) end, "tackled")
    end
  end,
  tackled = function ()
    display.Alert("Carried " .. flags.get("tackled"))
    stunned()
    prone()
  end,
  tackling = function ()
    prone()
  end,
  barge = function (wc)
    if main.attacked(wc[1], "athletics", "barge") then
      flags.set("barger", wc[1])
      EnableTrigger("athletics_barged__", true)
      prompt.queue(function () EnableTrigger("athletics_barged__", false) end, "barged")
    end
  end,
  barged = function (wc)
    if wc[1] == flags.get("barger") then
      display.Alert("Carried " .. string.upper(wc[2]))
      stunned()
    end
  end,
  charge = function (wc)
    if main.attacked(wc[1], "athletics", "charge") then
      EnableTrigger("athletics_charged__", true)
      prompt.queue(function () EnableTrigger("athletics_charged__", false) end, "charge")
    end
  end,
  charged = function (wc)
    display.Alert("Carried " .. wc[1])
    stunned()
    EnableTrigger("athletics_slammed__", true)
    prompt.queue(function () EnableTrigger("athletics_slammed__", false) end, "charged")
  end,
  slammed = function ()
    prone()
    flags.damaged_health()
  end,
  charging = function (wc)
    flags.set("charging", wc[1])
    EnableTrigger("athletics_charger__", true)
    prompt.queue(function () EnableTrigger("athletics_charger__", false) end, "charging")
  end,
  charger = function (wc)
    if wc[1] == flags.get("charging") then
      EnableTrigger("athletics_slammer__", true)
      prompt.queue(function () EnableTrigger("athletics_slammer__", false) end, "charger")
    end
  end,
  slammer = function (wc)
    prone()
  end,
}

tr.beastmastery = {
  minorbreath = function ()
    if main.attacked("", "beastmastery", "minorbreath") then
      flags.damaged_health()
    end
  end,
  poison = function ()
    if main.attacked("", "beastmastery", "poison") then
      main.poisons_on()
    end
  end,
  hypnoticgaze = function (wc)
    if main.attacked("", "beastmastery", "hypnoticgaze") then
      local colors = {
        azure = function () add_queue("dizziness") end,
        cerulean = function () add_queue("confusion") end,
        crimson = function () prone("paralysis") end,
        emerald = function () add_queue("vertigo") end,
        fuchsia = function () add_queue("daydreams") end,
        lavender = function () add_queue("pacifism") end,
        magenta = function () defs.del_queue("sixthsense") end,
        mauve = function () flags.set("blackout", function () affs.add("vapors") end) end,
        pink = function () add_queue("hallucinations") end,
        purple = function () end,
        scarlet = function () add_queue("fear") end,
        sapphire = function () add_queue("dementia") end,
        topaz = function () add_queue("stupidity") end,
      }
      for c,a in pairs(colors) do
        if string.find(wc[1], c) then
          a()
        end
      end
    end
  end,
  kicking = function (wc)
    if main.attacked(wc[1], "beastmastery", "kicking") then
      prone()
    end
  end,
  trample = function (wc)
    if main.attacked(wc[1], "beastmastery", "trample") then
      flags.set("trampler", string.lower(wc[2]))
      EnableTrigger("beastmastery_trampled__", true)
      prompt.queue(function () EnableTrigger("beastmastery_trampled__", false) end)
    end
  end,
  trampled = function (wc)
    if is_prone() and string.lower(wc[1]) == flags.get("trampler") then
      limb_queue(wc[2], wc[3], "broken")
      bleed(10, true)
      flags.damaged_health()
    end
  end,
  death_plague = function ()
    if main.attacked("", "beastmastery", "deathplague") then
      add_queue{"epilepsy", "rigormortis"}
    end
  end,
  peaceful_companion = function ()
    if main.attacked("", "beastmastery", "peacefulcompanion") then
      add_queue("peace")
    end
  end,
}

tr.celestialism = {
  atone = function (wc)
    if main.attacked(wc[1], "celestialism", "atone") then
      display.Alert("Check DEF!")
      defs.del_queue{"insomnia", "speed"}
    end
  end,
  angel_shakiniel = function ()
    if main.attacked("", "celestialism", "shakiniel") then
      unknown(1)
      failsafe.check("eating", "anorexia", function () affs.add("hypochondria") end)
    end
  end,
  angel_japhiel = function ()
    if main.attacked("", "celestialism", "japhiel") then
      hidden("japhiel", has("japhiel"), 2)
      failsafe.check("dementia", "dementia")
    end
  end,
  angel_elohora = function ()
    if main.attacked("", "celestialism", "elohora") then
      prone("paralysis")
      flags.set("elohora", true, 1)
      failsafe.check("blind", "blindness", function () affs.add("addiction") end)
    end
  end,
  angel_raziela = function ()
    if main.attacked("", "celestialism", "raziela") then
      flags.set("blackout", function () affs.add("vapors") end)
      unknown(1)
    end
  end,
  angel_methrenton = function ()
    if main.attacked("", "celestialism", "methrenton") then
      flags.set("methrenton", true, 1)
      bleed(100)
      unknown(1)
    end
  end,
  angel_kneel = function ()
    if main.attacked("", "celestialism", "elohora") then
      stunned()
      prone()
    end
  end,
  handmaiden_blackout = function ()
    main.attacked("", "celestialism", "champion")
  end,
  handmaiden_paralysis = function ()
    if main.attacked("", "celestialism", "champion") then
      prone("paralysis")
    end
  end,
  handmaiden_damage = function ()
    if main.attacked("", "celestialism", "champion") then
      flags.damaged_mana()
    end
  end,
}

tr.cosmic = {
  fear = function ()
    add_queue("fear")
  end,
  enfeeble = function (wc)
    local att = wc[1]
    if not att or #att < 1 then
      att = flags.get("enchant_attacker") or ""
    end
    if main.attacked(att, "cosmic", "enfeeble") then
      add_queue("enfeebled")
    end
  end,
}

tr.crow = {
  scavenger_hoist = function (wc)
    if main.attacked(wc[1], "crow", "hoist") then
      add_queue("hoisted")
      display.Warning("Hoisted by " .. wc[1])
    end
  end,
  eyepeck = function (wc)
    if main.attacked(wc[1], "crow", "eyepeck") then
      add_queue("losteye_" .. wc[2])
    end
  end,
  stench = function (wc)
    if main.attacked(wc[1], "crow", "stench") then
      EnableTrigger("crow_stenched__", true)
      prompt.queue(function () EnableTrigger("crow_stenched__", false) end, "crowstench")
    end
  end,
  stenched = function ()
    bleed(300)
  end,
  disease = function (wc)
    local att = wc[1] or ""
    if #att < 1 then
      att = wc[2]
    end
    if main.attacked(att, "crow", "disease") then
      unknown(1)
    end
  end,
  spew = function ()
    if has("bleeding") then
      add_queue("slickness")
    end
    -- hemophilia, pox, scabies, dysentery, or slickness
  end,
  trees = function (wc)
    if main.attacked(wc[1], "crow", "trees") then
      main.no_trees()
    end
  end,
}

tr.dramatics = {
  lost_attitude = function ()
    if main.attacked(flags.get("fasttalker"), "dramatics", "fasttalk") then
      defs.del_queue("attitude")
    end
  end,
  affliction = function (wc)
    if main.attacked(flags.get("fasttalker"), "dramatics", "fasttalk") then
      if string.find(wc[1], "hurry") then
        add_queue("debate_hurry")
      elseif string.find(wc[1], "circuitous") then
        add_queue("debate_circuitous")
      else
        add_queue("debate_loophole")
      end
    end
  end,
}

tr.dreamweaving = {
  motes = function ()
    if main.attacked("", "dreamweaving", "motes") then
      add_queue{"narcolepsy", "daydreams"}
      unknown(1)
      display.Warning("Dreamweaver attack!")
    end
  end,
  puncture = function (wc)
    if main.attacked(wc[1], "dreamweaving", "puncture") then
      add_queue("lightheaded")
    end
  end,
  spook = function ()
    if main.attacked("", "dreamweaving", "spook") then
      add_queue("fear")
      display.Warning("Dreamweaver attack!")
    end
  end,
  haunt = function ()
    if main.attacked("", "dreamweaving", "haunt") then
      add_queue{"paranoia", "confusion", "dementia", "fear"}
      display.Warning("Dreamweaver attack!")
    end
  end,
  daydreaming = function ()
    add_queue("daydreams")
  end,
  nightmare = function ()
    if main.attacked("", "dreamweaving", "nightmare") and has("asleep") then
      flags.damaged_health()
      flags.damaged_mana()
      display.Warning("Dreamweaver attack!")
    end
  end,
  channel = function ()
    if main.attacked("", "dreamweaving", "channel") then
      flags.damaged_mana()
      display.Warning("Dreamweaver attack!")
    end
  end,
  sap = function ()
    if main.attacked("", "dreamweaving", "sap") then
      flags.damaged_health()
      display.Warning("Dreamweaver attack!")
    end
  end,
  drowse = function ()
    if main.attacked("", "dreamweaving", "drowse") then
      display.Warning("Dreamweaver attack! You're getting sleepy!")
    end
  end,
  deepsleep = function ()
    if main.attacked("", "dreamweaving", "deepsleep") then
      display.Warning("Dreamweaver attack! You're getting very sleepy!")
    end
  end,
  drift = function ()
    display.Alert("Dreamweaver teleporting to you! Move!")
    flags.set("dreamdrift", true, 10)
  end,
  drifted = function ()
    if flags.get("dreamdrift") then
      flags.clear("dreamdrift")
      display.Alert("Dreamweaver teleported!")
    end
  end,
  void = function ()
    if not bals.get("herb") then
      bals.gain("herb")
    end
    add_queue("void")
  end,
  sleepmist = function ()
    local s = (flags.get("sleepier") or 0) + 1
    Execute("OnDanger Sleepmist makes you SLEEPY! [" .. s .. "]")
    flags.set("sleepier", s, 120)
  end,
}

tr.druidry = {
  briars = function ()
    if main.attacked("", "druidry", "briars") then
      prone("entangled")
    end
  end,
  seedcloud = function (wc)
    if main.attacked(wc[1], "druidry", "seedcloud") then
      local amt = 1
      if map.elevation() == "trees" then
        amt = 3
      end
      allergy(amt)
    end
  end,
  squirrels = function ()
    if main.attacked("", "druidry", "squirrels") then
      bleed(125)
      failsafe.check("blind", "blindness")
    end
  end,
  murder = function ()
    if main.attacked("", "druidry", "murder") then
      flags.set("murder", true, 1)
      bleed(100)
      failsafe.check("blind", "blindness", function () affs.add("black_lung") end)
    end
  end,
  spores = function ()
    if main.attacked("", "druidry", "spores") then
      hidden("spores", has("spores"), 3)
      defs.del_queue("protection")
      --flags.set("hostile_meld", true, 30)
    end
  end,
  pollen = function ()
    if main.attacked("", "druidry", "pollen") then
      add_queue("asthma")
      defs.del_queue("protection")
      --flags.set("hostile_meld", true, 30)
      if has("allergies") then
        local amt = 1
        if map.elevation() == "trees" then
          amt = 2
        end
        allergy(amt)
      end
    end
  end,
  treelife = function ()
    if main.attacked("", "druidry", "treelife") then
      main.no_trees()
    end
  end,
  treebane = function ()
    if main.attacked("", "druidry", "treebane") then
      flags.clear{"climb_down", "climbing_down", "climb_try"}
      display.Alert("Knocked down by Treebane!")
    end
  end,
  thorns = function ()
    if main.attacked("", "druidry", "thorns") then
      bleed(150)
    end
  end,
  pathtwist = function ()
    if main.attacked("", "druidry", "pathtwist") then
      add_queue("dizziness")
      EnableTrigger("druidry_pathtwist2__", true)
      prompt.queue(function () EnableTrigger("druidry_pathtwist2__", false) end, "pathtwisted")
    end
  end,
  pathtwist2 = function ()
    prone("entangled")
  end,
  spiders = function ()
    if main.attacked("", "druidry", "spiders") then
      main.poisons_on()
    end
  end,
  swarm = function ()
    if main.attacked("", "druidry", "swarm") then
      prone("paralysis")
      if has("allergies") then
        allergy(1)
      end
    end
  end,
  cudgel_raise = function ()
    if main.attacked("", "druidry", "raise") then
      main.no_trees()
      stunned()
    end
  end,
  cudgel_point = function (wc)
    if main.attacked(wc[1], "druidry", "point") then
      flags.damaged_health()
      bleed(300)
    end
  end,
  sap = function (wc)
    if map.elevation() == "trees" and main.attacked(wc[1], "druidry", "sap") then
      add_queue("sap")
    end
    EnableTrigger("cure_jinx__", true)
    prompt.queue(function () EnableTrigger("cure_jinx__", false) end, "jinxy")
  end,
  sapped = function ()
    if has("blackout") or flags.get("check_sap") then
      add_queue("sap")
      flags.clear("check_sap")
    elseif not has("sap") then
      flags.set("check_sap", true, 0.7)
    end
    if flags.get("slow_sent") then
      flags.set("slow_going", flags.get("slow_sent"), 2)
      flags.clear("slow_sent")
    end
  end,
  storm = function ()
    if main.attacked("", "druidry", "storm") then
      flags.damaged_health()
    end
  end,
  thornlash = function (wc)
    if main.attacked("", "druidry", "thornlash") then
      add_queue("thorns_" .. string.gsub(wc[1], " ", ""))
    end
  end,
  thornlash_movement = function ()
    bleed(120)
  end,
  thornrend = function (wc)
    if main.attacked(wc[1], "druidry", "thornrend") then
      EnableTrigger("druidry_thornrended__", true)
      prompt.queue(function () EnableTrigger("druidry_thornrended__", false) end)
    end
  end,
  thornrended = function ()
    local dq = {}
    for _,th in ipairs{"leftarm", "leftleg", "rightarm", "rightleg"} do
      if has("thorns_" .. th) then
        bleed(350)
        table.insert(dq, "thorns_" .. th)
      end
    end
    del_queue(dq)
  end,
  darkseed = function (wc)
    if main.attacked(wc[1], "druidry", "darkseed") then
      add_queue("darkseed")
    end
  end,
  darkseed_entangled = function ()
    prone{"darkseed", "entangled"}
    EnableTimer("druid_darkseed__", true)
    ResetTimer("druid_darkseed__")
  end,
  scarab = function (wc)
    if main.attacked(wc[1], "druidry", "scarab") then
      display.Alert("Scarab!")
      flags.set("scarab", true, 30)
    end
  end,
  scarab_crawl = function ()
    if flags.get("scarab") then
      add_queue("scarab")
      flags.set("scarab", true, 30)
    end
  end,
  stag_treetoss = function ()
    if main.attacked("", "druidry", "treetoss") then
      main.no_trees()
    end
  end,
  crow_blacklung = function ()
    if main.attacked("", "druidry", "blacklung") then
      add_queue("black_lung")
    end
  end,
}

tr.ecology = {
  smudge_hills = function ()
    if main.attacked("", "ecology", "hillssmudge") then
      EnableTrigger("ecology_smudged_hills__", true)
      prompt.queue(function () EnableTrigger("ecology_smudged_hills__", false) end)
    end
  end,
  smudged_hills = function ()
    prone{"prone", "muddy"}
  end,
  fetish = function (wc)
    if main.attacked(wc[1] or "", "ecology", "fetish") then
      main.charybdon()
    end
  end,
  smudge_desert = function ()
    if main.attacked("", "ecology", "desertsmudge") then
      EnableTrigger("ecology_smudged_desert__", true)
      prompt.queue(function () EnableTrigger("ecology_smudged_desert__", false) end)
    end
  end,
  smudged_desert = function ()
    bleed(300)
  end,
  smudge_swamp = function ()
    if main.attacked("", "ecology", "swampsmudge") then
      EnableTrigger("ecology_smudged_swamp__", true)
      prompt.queue(function () EnableTrigger("ecology_smudged_swamp__", false) end)
    end
  end,
  smudged_swamp = function ()
    display.Warning("Swamp smudge! DON'T MOVE!")
  end,
  familiar_sting = function ()
    if main.attacked("", "ecology", "familiarsting") then
      main.poisons_on()
    end
  end,
  smudge_valley = function ()
    if main.attacked("", "ecology", "valleysmudge") then
      EnableTrigger("ecology_smudged_valley_indoors__", true)
      EnableTrigger("ecology_smudged_valley_outdoors__", true)
      prompt.queue(function ()
        EnableTrigger("ecology_smudged_valley_indoors__", false)
        EnableTrigger("ecology_smudged_valley_outdoors__", false)
      end)
    end
  end,
  smudged_valley_indoors = function ()
    prone{"prone", "damaged_head"}
    flags.damaged_health()
  end,
  smudged_valley_outdoors = function ()
    defs.add_queue("flying")
  end,
  bane = function (wc)
    local bane = "herb"
    if string.find(wc[2], "bat") then
      bane = "bat"
    elseif string.find(wc[2], "snake") then
      bane = "snake"
    end
    if main.attacked(wc[1], "ecology", bane .. "bane") then
      add_queue("bane_" .. bane)
    end
  end,
  smudge_mountain = function ()
    if main.attacked("", "ecology", "mountainsmudge") then
      EnableTrigger("ecology_smudged_mountain__", true)
      prompt.queue(function () EnableTrigger("ecology_smudged_mountain__", false) end)
    end
  end,
  smudged_mountain = function ()
    prone()
    flags.damaged_health()
  end,
  smudge_forest = function ()
    if main.attacked("", "ecology", "forestsmudge") then
      EnableTrigger("ecology_smudged_forest__", true)
      prompt.queue(function () EnableTrigger("ecology_smudged_forest__", false) end)
    end
  end,
  smudged_forest = function ()
    add_queue("ablaze")
    burning()
    flags.damaged_health()
  end,
}

tr.elementalism = {
  blast = function (wc)
    if main.attacked(wc[1], "elementalism", "blast") then
      flags.damaged_health()
    end
  end,
  firewall = function ()
    add_queue("ablaze")
    burning()
  end,
  freeze = function (wc)
    if main.attacked(wc[1], "elementalism", "freeze") then
      cold()
    end
  end,
  icewall = function (wc)
    Execute("OnDanger Icewalled - " .. string.upper(wc[1]))
  end,
  ignite = function (wc)
    if main.attacked(wc[1], "elementalism", "ignite") then
      add_queue("ablaze")
      burning()
    end
  end,
}

tr.geochemantics = {
  ferrous = function (wc)
    if main.attacked(wc[1], "geochemantics", "ferrous") then
      add_queue("vomiting")
    end
  end,
  chemical = function (wc)
    if main.attacked(wc[1], "geochemantics", "chemical") then
      add_queue("dizziness")
    end
  end,
  toxic = function (wc)
    if main.attacked(wc[1], "geochemantics", "toxic") then
      add_queue("pox")
    end
  end,
  taint = function (wc)
    if main.attacked(wc[1], "geochemantics", "taint") then
      flags.damaged_health()
    end
  end,
  metal_storm = function ()
    if main.attacked("", "geochemantics", "metalstorm") then
      EnableTrigger("geochemantics_metal_storm2__", true)
      prompt.queue(function () EnableTrigger("geochemantics_metal_storm2__", false) end)
    end
  end,
  metal_storm2 = function ()
    flags.damaged_health()
    add_queue{"dizziness", "vomiting"}
  end,
  foul = function ()
    if main.attacked("", "geochemantics", "foul") then
      EnableTrigger("geochemantics_foul2__", true)
      prompt.queue(function () EnableTrigger("geochemantics_foul2__", false) end)
    end
  end,
  foul2 = function ()
    flags.damaged_health()
    add_queue{"dizziness", "pox"}
  end,
  contagion = function ()
    if main.attacked("", "geochemantics", "contagion") then
      EnableTrigger("geochemantics_contagion2__", true)
      prompt.queue(function () EnableTrigger("geochemantics_contagion2__", false) end)
    end
  end,
  contagion2 = function ()
    flags.damaged_health()
    add_queue("plague", math.min((has("plague") or 0) + 2, 5))
  end,
}

tr.geomancy = {
  tremors = function (wc)
    if main.attacked("", "geomancy", "tremors") then
      if string.find(wc[1], "buck") then
        prone{"prone", "mending_legs"}
      end
    end
  end,
  dust = function ()
    if main.attacked("", "geomancy", "duststorm") then
      blinded()
    end
  end,
  lodestone = function ()
    if main.attacked("", "geomancy", "lodestone") then
      prone()
      if defs.has("levitating") then
        defs.del_queue("levitating")
      else
        stunned()
      end
    end
  end,
  stonerain = function ()
    if main.attacked("", "geomancy", "stonerain") then
      defs.del_queue("flying")
      display.Alert("Knocked to the ground!")
    end
  end,
  stonewall = function (wc)
    Execute("OnDanger Stonewalled - " .. string.upper(wc[1]))
  end,
  stonewall2 = function ()
    Execute("OnDanger Stonewall")
  end,
  rockslide = function ()
    if main.attacked("", "geomancy", "rockslide") then
      flags.damaged_health()
    end
  end,
  sickening = function ()
    if main.attacked("", "geomancy", "sickening") then
      add_queue("taint_sick")
    end
  end,
  staff_point = function (wc)
    if main.attacked(wc[1] or "", "geomancy", "staffpoint") then
      flags.damaged_health()
    end
  end,
  staff_twirl = function (wc)
    if main.attacked(wc[1], "geomancy", "stafftwirl") then
      add_queue("gunk")
    end
  end,
  chasm1 = function (wc)
    Execute("OnInstakill Chasm - Stage One - Stop " .. string.upper(wc[1]) .. " or MOVE!")
  end,
  chasm2 = function (wc)
    Execute("OnInstakill Chasm - Stage Two - Stop " .. string.upper(wc[1]) .. " or MOVE!")
  end,
  fleshstone = function (wc)
    if main.attacked(wc[1], "geomancy", "fleshstone") and not slow() then
      prompt.illqueue(function () flags.set("statue", true, 2) SendNoEcho("ql") end)
    end
  end,
  fleshstoned = function ()
    if flags.get("statue") then
      add("statue")
      flags.clear("statue")
    end
  end,
}

tr.glamours = {
  colourburst = function (wc)
    if main.attacked(wc[1], "glamours", "colourburst") then
      if has("blindness") or defs.has("sixthsense") then
        glamour(wc[2], 2)
      else
        glamour(wc[2], 4)
      end
    end
  end,
  colourspray = function (wc)
    if main.attacked(wc[1], "glamours", "colourspray") then
      EnableTrigger("glamours_coloursprayed__", true)
      prompt.queue(function () EnableTrigger("glamours_coloursprayed__", false) end)
    end
  end,
  coloursprayed = function (wc)
    if has("blindness") or defs.has("sixthsense") then
      glamour(wc[1], 2)
    else
      glamour(wc[1], 4)
    end
  end,
  fascination = function (wc)
    if main.attacked(wc[1], "glamours", "fascination") then
      if not (has("blindness") or defs.has("sixthsense")) then
        add_queue("transfixed")
      end
    end
  end,
  fireworks = function ()
    add_queue("ablaze")
    burning()
  end,
  rainbowpattern = function (wc)
    if main.attacked(wc[1], "glamours", "rainbowpatterns") then
      add_queue("rainbow_patterns")
      EnableGroup("Rainbows", true)
      EnableTimer("glamours_rainbowpatterns__", true)
      ResetTimer("glamours_rainbowpatterns__")
    end
  end,
  rainbows_done = function ()
    del("rainbow_patterns")
    EnableGroup("Rainbows", false)
    EnableTimer("glamours_rainbowpatterns__", false)
  end,
  rainbowpatterns = function ()
    del("rainbow_patterns")
    EnableGroup("Rainbows", false)
    EnableTimer("glamours_rainbowpatterns__", false)
  end,
  rainbows_confusion = function ()
    add_queue("confusion")
  end,
  rainbows_hallucinations = function ()
    add_queue("hallucinations")
  end,
  rainbows_addiction = function ()
    add_queue("addiction")
  end,
  rainbows_clumsiness = function ()
    add_queue("clumsiness")
  end,
  rainbows_dizziness = function ()
    add_queue("dizziness")
  end,
  rainbows_epilepsy = function ()
    add_queue("epilepsy")
  end,
  rainbows_paralysis = function ()
    prone("paralysis")
  end,
  flare = function (wc)
    if main.attacked(wc[1], "glamours", "flare") then
      if string.find(wc[2], "afterimage") then
        add_queue("afterimage")
      end
    end
  end,
  afterimage = function ()
    if not (has("blindness") or defs.has("sixthsense")) then
      add_queue("afterimage")
      flags.clear("waiting_for_sixthsense")
    end
  end,
  mesmerize = function (wc)
    if main.attacked(wc[1], "glamours", "mesmerize") then
      if not (has("blindness") or defs.has("sixthsense")) then
        Execute("OnDanger You are getting sleepier!")
      end
    end
  end,
  hypnoticpattern = function (wc)
    if main.attacked(wc[1], "glamours", "hypnoticpattern") then
      add_queue("hypnotic_patterns")
    end
  end,
  lightspray = function (wc)
    flags.set("lightsprayer", wc[1])
    EnableTrigger("glamours_lightsprayed__", true)
    prompt.queue(function () EnableTrigger("glamours_lightsprayed__", false) end, "lspray")
  end,
  lightsprayed = function (wc)
    if main.attacked(flags.get("lightsprayer") or "", "glamours", "lightspray") then
      add_queue("illuminated")
    end
  end,
  colourmaelstrom = function (wc)
    if main.attacked("", "glamours", "maelstrom") then
      local max = 3
      if has("blindness") or defs.has("sixthsense") then
        max = 2
      end
      if flags.get("in_maze") then
        max = max + 1
      end
      glamour(wc[1], max)
    end
  end,
  deadlypattern = function (wc)
    if main.attacked(wc[1], "glamours", "deadlypattern") then
      defs.del_queue("insomnia")
      Execute("OnDanger Check your defenses!")
    end
  end,
  maze = function (wc)
    if main.attacked(wc[1], "glamours", "maze") then
      flags.set("mazed", true, 1)
    end
  end,
  maze_done = function (wc)
    flags.clear("in_maze")
    add_queue{"pennyroyal", "wormwood", "focus_mind"}
    unknown(3)
  end,
}

tr.harmonics = {
  garnet = function (wc)
    if main.attacked(wc[1], "harmonics", "garnet") then
      flags.damaged_mana()
      flags.set("mana_careful", true, 60)
    end
  end,
  mendingstone = function ()
    EnableTrigger("harmonics_mendingstone_cure__", true)
    prompt.queue(function () EnableTrigger("harmonics_mendingstone_cure__", false) end)
  end,
  mendingstone_cure = function ()
    main.cures_on()
    flags.set("last_cure", "harmonics mendingstone")
  end,
  balestone = function (wc)
    flags.set("balestone_attacker", wc[1])
    EnableTrigger("harmonics_balestone_fire__", true)
    prompt.queue(function () EnableTrigger("harmonics_balestone_fire__", false) end)
  end,
  balestone_fire = function ()
    if main.attacked(flags.get("balestone_attacker") or "", "harmonics", "balestone") then
      flags.damaged_health()
      timewarp(7)
    end
  end,
  opal = function (wc)
    if main.attacked(wc[1], "harmonics", "opal") then
      flags.damaged_ego()
    end
  end,
  onyx = function (wc)
    if main.attacked(wc[1], "harmonics", "onyx") then
      flags.set("onyx", true, 0.3)
      flags.set("blackout", function () affs.add("vapors") end)
      prone("paralysis")
    end
  end,
  bloodstone = function (wc)
    if main.attacked(wc[1], "harmonics", "bloodstone") then
      bleed(175)
    end
  end,
  emerald = function ()
    main.cures_on()
    flags.set("last_cure", "harmonics emerald")
  end,
  malefactgem = function (wc)
    flags.set("malefact_attacker", wc[1])
    EnableTrigger("harmonics_malefactgem_affs__", true)
    prompt.queue(function () EnableTrigger("harmonics_malefactgem_affs__", false) end)
  end,
  malefactgem_affs = function ()
    if main.attacked(flags.get("malefact_attacker") or "", "harmonics", "malefactgem") then
      prone("paralysis")
      prompt.preillqueue(function () if not prompt.gstats.prone then affs.add("focus_mind") end end, "malefacted")
    end
  end,
  sapphire = function (wc)
    if main.attacked(wc[1], "harmonics", "sapphire") then
      hidden("hidden_mental")
    end
  end,
  shockstone = function (wc)
    if main.attacked(wc[1], "harmonics", "shockstone") then
      add_queue("disrupted")
    end
  end,
  ruby = function (wc)
    if main.attacked(wc[1], "harmonics", "ruby") then
      local rubies = (has("rubies") or 0) + 1
      add_queue("rubies", rubies)
      Execute("OnDanger Rubies - " .. wc[1] .. " - " .. rubies .. " OF 7")
    end
  end,
  ruby_balefire = function ()
    if has("rubies") then
      flags.damaged_health()
      timewarp(1)
    end
  end,
  ruby_explode = function ()
    local rubies = (has("rubies") or 0) - 1
    if rubies <= 0 then
      del_queue("rubies")
    else
      add_queue("rubies", rubies)
    end
  end,
  shatterplex = function (wc)
    if main.attacked(wc[1], "harmonics", "shatterplex") then
      del_queue("rubies")
      flags.damaged_health()
      timewarp(50)
    end
  end,
  champion_pet1 = function ()
    if main.attacked("", "harmonics", "champion") then
      aeon()
    end
  end,
  champion_pet2 = function ()
    if main.attacked("", "harmonics", "champion") then
      flags.damaged_mana()
    end
  end,
  champion_pet3 = function ()
    if main.attacked("", "harmonics", "champion") then
      bleed(200)
    end
  end,
}

tr.harmony = {
  chuuti = function (wc)
    if main.attacked(wc[1], "harmony", "chuuti") then
      add_queue("peace")
    end
  end,
  akhlum = function (wc)
    if main.attacked(wc[1], "harmony", "akhlum") then
      cold()
    end
  end,
  krakmun = function (wc)
    if main.attacked(wc[1], "harmony", "krakmun") then
      flags.damaged_health()
    end
  end,
  krakuti = function (wc)
    if main.attacked(wc[1], "harmony", "krakuti") then
      flags.damaged_mana()
    end
  end,
  akhangooshkrak = function (wc)
    if main.attacked(wc[1], "harmony", "akhangooshkrak") then
      Execute("OnInstakill DEATHTOUCH! - MOVE, BLIND OR SLEEP " .. string.upper(wc[1]) .. "!")
    end
  end,
}

failsafe.fn.aurawarp = function ()
  if affs.has("aurawarp") then
    affs.del{"aurawarp", "homeostasis"}
  end
end

failsafe.fn.bedevil = function ()
  if affs.has("bedeviled") then
    affs.del("bedeviled")
  end
end

tr.healing = {
  aurashift = function (wc)
    if main.attacked(wc[1], "healing", "aurashift") then
      display.Alert("Healing aura transferred to you.")
    end
  end,
  aurawarp = function (wc)
    if main.attacked(wc[1], "healing", "aurawarp") then
      add_queue("aurawarp")
      flags.set("aurawarper", wc[1], 60)
      flags.set("mana_careful", true, 60)
      failsafe.exec("aurawarp", 10)
      enemy.shielded(wc[1], false)
      Execute("OnDanger Move away from " .. wc[1] .. " to cure AuraWarp!")
    end
  end,
  aurawarp_homeostasis = function ()
    add_queue{"aurawarp", "homeostasis"}
    display.Warning("AuraWarp - Homeostasis")
  end,
  bedevil = function (wc)
    if main.attacked(wc[1], "healing", "bedevil") then
      add_queue("bedeviled")
      flags.set("bedeviler", wc[1], 300)
      flags.set("mana_careful", true, 60)
      failsafe.exec("bedevil", 30)
      enemy.shielded(wc[1], false)
      display.Warning("Move away from " .. wc[1] .. " to cure Bedevil")
    end
  end,
  bedevil_symptom = function ()
    flags.set("bedevil", flags.get("last_cure") or false)
  end,
  aurawarp_bedevil_fail = function (wc)
    local aff = "Bedevil"
    if wc[2] == "warped aura" then
      aff = "AuraWarp"
      if not flags.get("aurawarper") then
        flags.set("aurawarper", wc[1], 30)
      end
    elseif not flags.get("bedeviler") then
      flags.set("bedeviler", wc[1], 30)
    end
    display.Warning("Move away from " .. wc[1] .. " to cure " .. aff)
  end,
}

tr.hexes = {
  hex = function (wc)
    if main.attacked(wc[1], "hexes", "hex") then
      if prompt.stat("hp") < prompt.stat("maxhp") then
        flags.damaged_health()
      elseif prompt.stat("mp") < prompt.stat("maxmp") then
        flags.damaged_mana()
      elseif prompt.stat("ep") < prompt.stat("maxep") then
        flags.damaged_ego()
      end
      flags.set("blackout", function () affs.add("vapors") end)
      flags.set("hex", true, 0.3)
      main.poisons_on()
      prompt.illqueue(hexed, "mehexed")
      flags.set("tea_aff", (flags.get("tea_aff") or 0) + 1)
    end
  end,
  hexenthroat = function (wc)
    if main.attacked("", "hexes", "hexenthroat") then
      main.poisons_on()
    end
  end,
  jinx = function (wc)
    if main.attacked(wc[1], "hexes", "jinx") then
      add_queue("jinx")
      display.Alert("You've been Jinxed!")
    end
  end,
  jinx_symptom = function ()
    add_queue("jinx")
  end,
  hexensoles = function ()
    if main.attacked("", "hexes", "hexensoles") then
      main.poisons_on()
    end
  end,
}

tr.highmagic = {
  hexagram = function ()
    EnableTrigger("highmagic_hexagrammed__", true)
    prompt.queue(function () EnableTrigger("highmagic_hexagrammed__", false) end, "hexagrammed")
  end,
  hexagrammed = function ()
    flags.clear{"climb_down", "climbing_down"}
    defs.del_queue("flying")
    display.Alert("Knocked down by Hexagram!")
  end,
  binah = function (wc)
    if main.attacked(wc[1], "highmagic", "binah") then
      add_queue("binah_sphere")
    end
  end,
}

tr.hunting = {
  ambush = function (wc)
    if main.attacked(wc[1], "hunting", "ambush") then
      prone()
      stunned()
      defs.del_queue("shield")
    end
  end,
}

tr.illusions = {
  spook = function (wc)
    if main.attacked(wc[1], "illusions", "spook") then
      if not (affs.has("blindness") or defs.has("sixthsense")) then
        add_queue("fear")
      end
    end
  end,
}

tr.kata = {
  hold = function (wc)
    if main.attacked(wc[1], "kata", "hold") then
      grapple("body", wc[1])
    end
  end,
  hold_symptom1 = function (wc)
    if not is_grappled() then
      grapple("body", wc[1])
    end
  end,
  hold_symptom2 = function ()
    if is_prone() and not is_grappled() then
      grapple("body", "Someone")
    end
  end,
  release = function (wc)
    if main.attacked(wc[1], "kata", "release") then
      grapple(nil, wc[1])
    end
  end,
  throw = function (wc)
    if main.attacked(wc[1], "kata", "throw") then
      wounds.kata_mods{"Nekotai", "Ninjakari", "Shofangi", "Tahtetso"}
      grapple(nil, wc[1])
      prone()
    end
  end,
  choke = function (wc)
    if main.attacked(wc[1], "kata", "choke") then
      grapple("head", wc[1])
    end
  end,
  choking = function (wc)
    if main.attacked(wc[1], "kata", "choke") then
      grapple("head", wc[1])
    end
  end,
  lock = function (wc)
    if main.attacked(wc[1], "kata", "lock") then
      local part = string.gsub(wc[2], " ", "")
      grapple(part, wc[1])
    end
  end,
  lock_symptom = function (wc)
    if not is_grappled() then
      local part = string.gsub(wc[1], " ", "")
      grapple(part, wc[2])
    end
  end,
  snap = function (wc)
    if main.attacked(wc[1], "kata", "snap") then
      local part = string.gsub(wc[2], " ", "")
      if part == "chest" then
        add_queue("broken_chest")
      elseif part == "head" then
        blackout()
      elseif part ~= "gut" then
        local side = string.gsub(wc[2], " .*", "")
        local limb = string.gsub(wc[2], ".* ", "")
        limb_queue(side, limb, "broken")
      end
      grapple(nil, wc[1])
      wounds.kata(part, 100)
      wounds.kata_mods{"Nekotai", "Ninjakari", "Shofangi", "Tahtetso"}
    end
  end,
  toss = function (wc)
    if main.attacked(wc[1], "kata", "toss") then
      grapple()
      prone()
    end
  end,
  raze = function (wc)
    if main.attacked(wc[1], "kata", "raze") then
      wounds.kata_mods{"Nekotai", "Ninjakari", "Shofangi", "Tahtetso"}
    end
  end,

  pinchnerve = function ()
    prone("paralysis")
  end,
  break_head = function ()
    add_queue("broken_nose")
  end,
  break_leg = function (wc)
    limb_queue(wc[1], "leg", "broken")
  end,
  break_leg2 = function (wc)
    cracked(wc[1], "leg")
  end,
  break_arm = function (wc)
    limb_queue(wc[1], "arm", "broken")
  end,
  break_arm2 = function (wc)
    cracked(wc[1], "arm")
  end,
  stun = function ()
    stunned()
  end,
  concussion = function ()
    add_queue("concussion")
  end,
}

tr.loralaria = {
  singing = function (wc)
    local effects = {
      [", coaxing a passionate tune from .-"] = "aureolinaubade",
      [", making .- thunder with booming harmonies"] = "fleckedfortissimo",
      [", striking a sudden, sharp chord upon .-"] = "skysforzando",
      [", making .- ring with pure harmonies"] = "convergence",
    }
    for m,t in pairs(effects) do
      if string.find(wc[2], m) and main.attacked(wc[1], "loralaria", t) then
        flags.set("singer", wc[1])
        EnableTrigger("loralaria_" .. t .. "__", true)
        prompt.queue(function () EnableTrigger("loralaria_" .. t .. "__", false) end)
        break
      end
    end
  end,
  blueberceuse = function (wc)
    main.attacked(wc[1], "loralaria", "blueberceuse")
  end,
  blueberceused = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "loralaria", "blueberceuse") then
      prone{"prone", "asleep"}
      flags.damaged_health()
    end
  end,
  aureolinaubade = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "loralaria", "aureolinaubade") then
      iff.lust(wc[1])
    end
  end,
  midnightminuet = function ()
    main.attacked("", "loralaria", "midnightminuet")
  end,
  fleckedfortissimo = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(flags.get("singer") or "", "loralaria", "fleckedfortissimo") then
      stunned()
      prone()
    end
  end,
  violetvibrato = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "loralaria", "fleckedfortissimo") then
      flags.set("blackout", function () affs.add("vapors") end)
      prompt.preillqueue(function () if not affs.has("blackout") then affs.hidden("violetvibrato") end end, "vvibrato")
    end
  end,
  skysforzando = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(flags.get("singer") or "", "loralaria", "skysforzando") then
      stunned()
      aeoned()
    end
  end,
  redrubato = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "loralaria", "redrubato") then
      flags.damaged_health()
      timewarp(4)
    end
  end,
  convergence = function ()
    if not (has("deafness") or defs.has("truehearing")) and has("asleep") and main.attacked(flags.get("singer") or "", "loralaria", "skysforzando") then
      stunned()
      aeoned()
    end
  end,
}

failsafe.fn.strange_trip = function ()
  affs.del("strange_trip")
end

tr.minstrelry = {
  singing = function (wc)
    local effects = {
      [", with a raucous, bawdy laugh piercing zinger notes ring upon .-"] = "shotnote",
      [", playing a frenzied bolero upon .- with a knowing wink"] = "drunkenfool",
    }
    for m,t in pairs(effects) do
      if string.find(wc[2], m) and main.attacked(wc[1], "minstrelry", t) then
        flags.set("singer", wc[1])
        EnableTrigger("minstrelry_" .. t .. "__", true)
        prompt.queue(function () EnableTrigger("minstrelry_" .. t .. "__", false) end)
        break
      end
    end
  end,
  stumbling = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "minstrelry", "stumbling") then
      prone()
    end
  end,
  alcoholfumes = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "minstrelry", "alcoholfumes") then
      display.Alert("Drunkenness increased!")
      drunken(4)
    end
  end,
  strangetrip = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "minstrelry", "strangetrip") then
      add_queue("strange_trip")
      failsafe.exec("strange_trip", 60)
    end
  end,
  yaikoyaiko = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "minstrelry", "yaikoyaiko") then
      flags.damaged_mana()
      flags.damaged_ego()
    end
  end,
  shotnote = function ()
    display.Alert("Drunkenness increased!")
    drunken(75 - drunk / 2 - math.random(math.max(drunk, 2) / 2))
  end,
  purplehaze = function ()
    if not (has("deafness") or defs.has("truehearing")) and has("strange_trip") and main.attacked("", "minstrelry", "purplehaze") then
      hidden("purplehaze")
      failsafe.check("dementia", "dementia")
    end
  end,
  firefugue = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "minstrelry", "firefugue") then
      flags.damaged_health()
    end
  end,
  jamboree = function ()
    main.cures_on()
  end,
  cancan = function ()
    flags.damaged_health()
  end,
  drunkenfool = function ()
    drunken("sober and in control")
  end,
}

tr.moon = {
  succumb1 = function (wc)
    if main.attacked(wc[1], "moon", "succumb") then
      add_queue("succumbing")
      flags.damaged_mana()
      display.Alert("Succumb! Watch mana!")
    end
  end,
  succumb2 = function (wc)
    if main.attacked(wc[1], "moon", "succumb") then
      add_queue("succumbing")
      flags.damaged_mana()
      display.Alert("Succumb! Watch mana!")
    end
  end,
  succumb3 = function ()
    add_queue("succumbing")
    flags.damaged_mana()
    display.Alert("Succumb! Watch mana!")
  end,
  waning1 = function (wc)
    if main.attacked(wc[1], "moon", "waning") then
      aeoned()
    end
  end,
  waning2 = function (wc)
    if main.attacked(wc[1], "moon", "waning") then
      aeoned()
    end
  end,
  dark1 = function (wc)
    if main.attacked(wc[1], "moon", "dark") then
      add_queue("darkmoon")
    end
  end,
  dark2 = function ()
    hidden("dark")
  end,
  moonburst = function (wc)
    if main.attacked(wc[1], "moon", "moonburst") then
      flags.damaged_health()
    end
  end,
  moonfire = function (wc)
    if main.attacked(wc[1], "moon", "moonfire") then
      flags.damaged_health()
    end
  end,
}

tr.music = {
  blanknote = function (wc)
    if main.attacked(wc[1], "music", "blanknote") then
      if string.find(wc[0], "no sound") then
        flags.set("earache", "chord")
      else
        flags.set("earache", "note")
      end
    end
  end,
  blanknote_earache = function ()
    if flags.get("last_cure") == "eat earwort" or flags.get("slow_going") == "eat earwort" then
      defs.del("truehearing")
      add_queue("earache", os.clock())
      flags.clear{"last_cure", "slow_going"}
      flags.damaged_health()
    end
  end,
  play = function (wc)
    local effects = {
      whispering = "majorsecond",
      ominous = "tritone",
      screeching = "minorseventh",
      jarring = "majorseventh",
      trembling = "minorsixth",
      disharmonic = "minorsecond",
      exquisite = "perfectfifth",
      chaotic = "chaoschord",
      harsh = "ironchord",
      resonating = "loralchord",
      shadowy = "shadowchord",
      stately = "starchord",
      wild = "wildechord",
    }
    if main.attacked(wc[1], "music", effects[wc[2]]) then
      EnableTrigger("music_" .. effects[wc[2]] .. "__", true)
      prompt.queue(function () EnableTrigger("music_" .. effects[wc[2]] .. "__", false) end)
    end
  end,
  majorsecond = function ()
    add_queue("ego_vice")
  end,
  tritone = function ()
    add_queue("manabarbs")
  end,
  minorseventh = function ()
    add_queue("achromatic")
  end,
  majorseventh = function ()
    add_queue("power_spikes")
  end,
  minorsixth = function ()
    flags.damaged_mana()
    flags.damaged_ego()
  end,
  minorsecond = function ()
    flags.damaged_health()
  end,
  perfectfifth = function (wc)
    if main.attacked(wc[1], "music", "perfectfifth") then
      add_queue("perfect_fifth", wc[1])
      add_queue("earache", os.clock())
      Execute("OnDanger Perfect Fifth - " .. wc[1] .. "!")
    end
  end,
  majorsecond_symp = function ()
    add_queue("ego_vice")
    flags.damaged_ego()
    flags.damaged_health()
  end,
  tritone_symp = function ()
    add_queue("manabarbs")
    flags.damaged_mana()
    flags.damaged_health()
  end,
  majorseventh_symp = function ()
    add_queue("power_spikes")
    flags.damaged_power()
    flags.damaged_health()
  end,
  perfectfifth_symp = function (wc)
    if main.attacked(wc[1], "music", "perfectfifth") then
      add_queue("perfect_fifth", wc[1])
      Execute("OnDanger Perfect Fifth - " .. wc[1] .. "!")
    end
  end,
  octave = function (wc)
    if main.attacked(wc[1], "music", "octave") then
      Execute("OnDanger Maestoso Coming Soon! - " .. wc[1])
      main.maestoso(wc[1])
    end
  end,
  octave_up = function ()
    Execute("OnDanger Maestoso UP!")
    main.maestoso()
  end,
  octave_down = function ()
    flags.clear{"maestoso_caster", "maestoso"}
  end,
  octave_symp = function (wc)
    display.Alert("Maestoso! Cover your ears!")
    if string.find(wc[1], "spirit") and flags.get("focus_try") then
      failsafe.exec("focus")
    elseif flags.get("last_cure") == "eat horehound" then
      flags.clear("last_cure")
    else
      return
    end
    main.maestoso()
  end,
  discordantchord = function (wc)
    if main.attacked(wc[1], "music", "discordantchord") then
      EnableTrigger("music_discordantchorded__", true)
      prompt.queue(function () EnableTrigger("music_discordantchorded__", false) end)
    end
  end,
  discordantchorded = function ()
    flags.damaged_health()
    if not flags.get("maestoso") then
      del_queue{"ego_vice", "manabarbs", "achromatic", "power_spikes"}
    end
  end,
  deathsong1 = function (wc)
    if main.attacked(wc[1], "music", "deathsong") then
      flags.set("deathsong", true, 15)
      Execute("OnInstakill Deathsong - Stage One - " .. wc[1] .. " - EAT EARWORT, GUST, OR MOVE!")
    end
  end,
  deathsong2 = function (wc)
    local name = ""
    if wc[1] and #wc[1] > 0 then
      name = wc[1]
    elseif wc[2] and #wc[2] > 0 then
      name = wc[2]
    elseif wc[3] and #wc[3] > 0 then
      name = wc[3]
    elseif wc[4] and #wc[4] > 0 then
      name = wc[4]
    elseif wc[5] and #wc[5] > 0 then
      name = wc[5]
    elseif wc[6] and #wc[6] > 0 then
      name = wc[6]
    else
      return
    end
    Execute("OnInstakill Deathsong - Stage Two - " .. name .. " - EAT EARWORT, GUST, OR MOVE!")
    flags.set("deathsong", true, 15)
  end,
  chaoschord = function ()
    flags.damaged_health()
  end,
  ironchord = function ()
    flags.damaged_health()
  end,
  loralchord = function ()
    flags.damaged_health()
  end,
  shadowchord = function ()
    flags.damaged_health()
  end,
  starchord = function ()
    flags.damaged_health()
  end,
  wildechord = function ()
    flags.damaged_health()
  end,
}

tr.nature = {
  curse_sickle = function (wc)
    if main.attacked(wc[1], "nature", "curse") then
      flags.damaged_health()
    end
  end,
  curse_athame_cudgel = function (wc)
    if main.attacked(wc[1], "nature", "curse") then
      flags.damaged_health()
    end
  end,
  curse_talisman = function (wc)
    if main.attacked(wc[1], "nature", "curse") then
      flags.damaged_health()
    end
  end,
  faeriefire = function (wc)
    if main.attacked(wc[1], "nature", "faeriefire") then
      add_queue("illuminated")
    end
  end,
  vines = function (wc)
    if main.attacked(wc[1], "nature", "vines") then
      prone("entangled")
    end
  end,
}

tr.necromancy = {
  feed = function (wc)
    if main.attacked(wc[1], "necromancy", "feed") then
      Execute("OnDanger HUNGER INCREASED!")
    end
  end,
  feed_constitution = function (wc)
    if main.attacked(wc[1], "necromancy", "feed") then
      defs.del_queue("constitution")
    end
  end,
  shrivel = function (wc)
    if main.attacked(wc[1], "necromancy", "shrivel") then
      EnableTrigger("necromancy_shriveled__", true)
      prompt.queue(function () EnableTrigger("necromancy_shriveled__", false) end)
    end
  end,
  shriveled = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  leech = function (wc)
    if main.attacked(wc[1], "necromancy", "leech") then
      flags.damaged_mana()
    end
  end,
  omen = function (wc)
    if main.attacked(wc[1], "necromancy", "omen") then
      add_queue("omen")
    end
  end,
  disfigure = function (wc)
    if main.attacked(wc[1], "necromancy", "disfigure") then
      add_queue("repugnance")
    end
  end,
  ectoplasm = function (wc)
    flags.set("ectoplasmer", wc[1])
    EnableTrigger("necromancy_ectoplasmed__", true)
    prompt.queue(function () EnableTrigger("necromancy_ectoplasmed__", false) end)
  end,
  ectoplasmed = function ()
    if main.attacked(flags.get("ectoplasmer"), "necromancy", "ectoplasm") then
      add_queue("ectoplasm")
    end
  end,
  contagion = function ()
    if main.attacked("", "necromancy", "contagion") then
      display.Alert("Contagion!")
      add_queue("plague", math.min((has("plague") or 0) + 1, 5))
    end
  end,
  deathmark = function (wc)
    if main.attacked(wc[1], "necromancy", "deathmark") then
      flags.set("deathmarked", wc[1], 300)
      deathmark(1)
    end
  end,
  deathmarks = function (wc)
    if flags.get("deathmarked") then
      deathmark(wc[1])
    end
  end,
  crucify = function (wc)
    if main.attacked(wc[1], "necromancy", "crucify") then
      add_queue("crucified")
    end
  end,
  crucified_jerk = function ()
    if has("crucified") then
      if limb("left", "leg") == "healthy" then
        limb_queue("left", "leg", "broken")
      else
        limb_queue("right", "leg", "broken")
      end
      if limb("left", "arm") == "healthy" then
        limb_queue("left", "arm", "broken")
      else
        limb_queue("right", "arm", "broken")
      end
    end
  end,
  crucified_impossible = function ()
    local crux = flags.get("crucified") or 0
    if crux > 2 then
      flags.clear("crucified")
      add_queue("crucified")
    else
      flags.set("crucified", crux + 1, 2)
    end
  end,
  crucified_bleed = function ()
    local crux = flags.get("crucified") or 0
    if crux > 2 then
      flags.clear("crucified")
      flags.damaged_health()
      add_queue("crucified")
    elseif has("crucified") then
      flags.damaged_health()
    else
      flags.set("crucified", crux + 1, 2)
    end
  end,
  crucified_nofocus = function ()
    local crux = flags.get("crucified") or 0
    if crux > 2 then
      flags.clear{"crucified", "focus_try"}
      add_queue("crucified")
    else
      flags.set("crucified", crux + 1, 2)
    end
  end,
  lichdom_touch = function (wc)
    if main.attacked(wc[1], "necromancy", "lichtouch") then
      cold()
    end
  end,
  lichdom_coldaura = function ()
    if main.attacked("", "necromancy", "lichaura") then
      cold()
    end
  end,
}

tr.necroscream = {
  singing = function (wc)
    local effects = {
      [", playing .- with a throbbing intensity"] = "sickeningplague",
      [", making .- scream loud enough to wake the dead"] = "queenslament",
      [", as screaming notes howl wrathfully from .-"] = "wrathfulcanticle",
      [", letting .- sound with a rocking cacophony"] = "carillonknell",
    }
    for m,t in pairs(effects) do
      if string.find(wc[2], m) and main.attacked(wc[1], "necroscream", t) then
        EnableTrigger("necroscream_" .. t .. "__", true)
        prompt.queue(function () EnableTrigger("necroscream_" .. t .. "__", false) end)
        break
      end
    end
  end,
  blackdeath = function ()
    hidden("plague", nil, 5)
    EnableTrigger("poison_worms__", true)
    EnableTrigger("poison_epilepsy__", true)
    prompt.queue(function ()
      EnableTrigger("poison_worms__", false)
      EnableTrigger("poison_epilepsy__", false)
    end)
  end,
  queenslament = function ()
    if main.attacked("", "necroscream", "queenslament") then
      prone("shackled")
    end
  end,
  sickeningplague = function ()
    if main.attacked("", "necroscream", "sickeningplague") then
      EnableTrigger("defdown_consciousness_sp__", true)
      prompt.queue(function () EnableTrigger("defdown_consciousness_sp__", false) end)
      hidden("plague", nil, 5)
      display.Alert("Sustenance would be good")
    end
  end,
  wrathfulcanticle = function ()
    if main.attacked("", "necroscream", "wrathfulcanticle") then
      local plague = 0
      for _,a in ipairs{"pox", "scabies", "epilepsy", "worms", "rigormortis"} do
        if has(a) then
          plague = plague + 1
        end
      end
      if plague == 4 and not has("sensitivity") then
        add_queue("sensitivity")
      elseif plague == 3 and not has("stupidity") then
        add_queue("stupidity")
      elseif plague == 2 and not has("confusion") then
        add_queue("confusion")
      elseif plague == 1 and not has("recklessness") then
        add_queue("recklessness")
      end
    end

    flags.set("blackout", function () del("plague") add{"vapors", "pox", "scabies", "epilepsy", "worms", "rigormortis"} end)
  end,
  carillonknell = function ()
    flags.damaged_health()
    flags.damaged_mana()
    flags.damaged_ego()
  end,
}

tr.nekotai = {
  nekai = function (wc)
    if main.attacked(wc[1], "nekotai", "nekai") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[3])
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(25)
    end
  end,
  angknek_limb = function (wc)
    if main.attacked(wc[1], "nekotai", "angknek") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "angknek")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      if wc[3] == "arm" then
        add_queue("bicep_" .. wc[2])
      else
        add_queue("thigh_" .. wc[2])
      end
      bleed(100)
    end
  end,
  angknek_gut = function (wc)
    if main.attacked(wc[1], "nekotai", "angknek") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "angknek")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      add_queue("sliced_gut")
      bleed(100)
    end
  end,
  angknek_chest = function (wc)
    if main.attacked(wc[1], "nekotai", "angknek") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "angknek")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      add_queue("punctured_lung")
      bleed(100)
    end
  end,
  angknek_head = function (wc)
    if main.attacked(wc[1], "nekotai", "angknek") then
      wounds.kata("head")
      wounds.kata_attack("head", "angknek")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      add_queue("gashed_cheek")
      bleed(100)
    end
  end,
  oothai = function (wc)
    if main.attacked(wc[1], "nekotai", "oothai") then
      wounds.kata_attack("head", "oothai")
      wounds.kata_mods("Nekotai")

      flags.damaged_health()
      grapple("head", wc[1])
    end
  end,
  kaife = function (wc)
    if main.attacked(wc[1], "nekotai", "kaife") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "kaife")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(15)
    end
  end,
  scorpionstrike = function (wc)
    if main.attacked(wc[1], "nekotai", "scorpionstrike") then
      wounds.kata_mods("Nekotai")
      main.poisons_on()
    end
  end,
  spit = function (wc)
    if main.attacked(wc[1], "nekotai", "spit") then
      main.poisons_on()
    end
  end,
  angkai_limb = function (wc)
    if main.attacked(wc[1], "nekotai", "angkai") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "angkai")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(30)
      add_queue("pierced_" .. wc[2] .. wc[3])
    end
  end,
  angkai_head = function (wc)
    if main.attacked(wc[1], "nekotai", "angkai") then
      wounds.kata("head")
      wounds.kata_attack("head", "angkai")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(30)
      add_queue("losteye_" .. wc[2])
    end
  end,
  angkai_chest = function (wc)
    if main.attacked(wc[1], "nekotai", "angkai") then
      wounds.kata("head")
      wounds.kata_attack("head", "angkai")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(30)
      add_queue("severed_phrenic")
    end
  end,
  angkai_gut = function (wc)
    if main.attacked(wc[1], "nekotai", "angkai") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "angkai")
      wounds.kata_mods("Nekotai")
      
      main.poisons_on()
      bleed(30)
      add_queue("relapsing")
    end
  end,
  scorpiontail = function (wc)
    if main.attacked(wc[1], "nekotai", "scorpiontail") then
      prone()
    end
  end,
  ootangk = function (wc)
    if main.attacked(wc[1], "nekotai", "ootangk") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "ootangk")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      grapple(part, wc[1], "ootangk")
    end
  end,
  sprongk = function (wc)
    if main.attacked(wc[1], "nekotai", "sprongk") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "sprongk")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue("stiff_" .. part)
    end
  end,
  spronghai = function (wc)
    if main.attacked(wc[1], "nekotai", "spronghai") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "spronghai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue("hemophilia")
      bleed(250)
    end
  end,
  angkhai = function (wc)
    if main.attacked(wc[1], "nekotai", "angkhai") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "angkhai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue("relapsing")
    end
  end,
  angkhai_head = function (wc)
    if main.attacked(wc[1], "nekotai", "angkhai") then
      wounds.kata("head")
      wounds.kata_attack("head", "angkhai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue{"slit_throat", "relapsing"}
    end
  end,
  angkhai_leg = function (wc)
    if main.attacked(wc[1], "nekotai", "angkhai") then
      local part = wc[2] .. "leg"
      wounds.kata(part)
      wounds.kata_attack(part, "angkhai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue{"tendon_" .. wc[2], "relapsing", "prone"}
    end
  end,
  sprongma_gut = function (wc)
    if main.attacked(wc[1], "nekotai", "sprongma") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "sprongma")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue("severed_spine")
      bleed(100)
    end
  end,
  sprongma_chest = function (wc)
    if main.attacked(wc[1], "nekotai", "sprongma") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "sprongma")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      add_queue("collapsed_lungs")
      bleed(100)
    end
  end,
  amihai = function (wc)
    if main.attacked(wc[1], "nekotai", "amihai") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "amihai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      grapple(nil, wc[1])
      bleed(300)
    end
  end,
  finalsting = function (wc)
    if main.attacked(wc[1], "nekotai", "finalsting") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "amihai")
      wounds.kata_mods("Nekotai")

      main.poisons_on()
      bleed(750)
    end
  end,
  kaiga = function ()
    burst(2)
  end,
  oriama1 = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  oriama2 = function (wc)
    limb_queue(wc[1], wc[2], "mangled")
  end,
}

tr.night = {
  cauldron_release = function (wc)
    if main.attacked(wc[1], "night", "shadows") then
      Execute("OnDanger " .. wc[1] .. " released SHADOWS!")
      enemy.shielded(wc[1], false)
    end
  end,
  scourge = function (wc)
    if main.attacked(wc[1], "night", "scourge") then
      defs.del("sixthsense")
      enemy.shielded(wc[1], false)
    end
  end,
  brumetower = function ()
    flags.clear{"climbing_down", "climbing_up", "slow_sent", "slow_going"}
  end,
  steal = function (wc)
    if main.attacked(wc[1], "night", "steal") then
      display.Alert("Shadow stolen by " .. string.upper(wc[1]))
      enemy.shielded(wc[1], false)
    end
  end,
  damage = function (wc)
    if #wc[1] > 0 then
      if main.attacked(wc[1], "night", "steal") then
        flags.damaged_health()
      end
    elseif main.attacked(wc[2], "night", "nightkiss") then
      enemy.shielded(wc[2], false)
      flags.damaged_health()
    end
  end,
  nightkiss_noshield = function (wc)
    enemy.shielded(wc[1], false)
  end,
  lash = function (wc)
    if main.attacked(wc[1], "night", "lash") then
      flags.damaged_mana()
      display.Alert("Watch mana!")
      flags.set("mana_careful", true, 60)
      enemy.shielded(wc[1], false)
    end
  end,
  choke = function (wc)
  --[[  if main.attacked(wc[1], "night", "choke") then
      affs.add_queue("choke")
      Execute("OnDanger Shadow Choke! Get away from " .. string.upper(wc[1]) .. "!")
      EnableTrigger("cure_jinx__", true)
      prompt.queue(function () EnableTrigger("cure_jinx__", false) end)
      SetVariable("target_choker", wc[1])
      enemy.rebound(wc[1], false)
    end
    --]]
  end,
  choke_symp = function ()
  --[[
    if not affs.has("choke") and (affs.has("blackout") or flags.get("check_choke")) then
      affs.add_queue("choke")
      display.Warning("Shadow Choke!")
      flags.clear("check_choke")
    elseif not affs.has("choke") then
      flags.set("check_choke", true, 0.7)
    end
    if flags.get("slow_sent") then
      flags.set("slow_going", flags.get("slow_sent"), 1)
      flags.clear("slow_sent")
    end
  --]]
  end,
  shadowtwist = function (wc)
    if main.attacked(wc[1], "night", "shadowtwist") then
      flags.damaged_mana()
      defs.del_queue("speed")
      EnableTrigger("night_shadowtwist_aff__", true)
      prompt.queue(function () EnableTrigger("night_shadowtwist_aff__", false) end, "shadtwisted")
    end
  end,
  shadowtwist_aff = function (wc)
    defs.del_queue("insomnia")
    failsafe.check("standing", "leg_locked")
    failsafe.check("aeon", "aeon")
    failsafe.check("eating", "throat_locked")
  end,
}

tr.nihilism = {
  sting = function (wc)
    if main.attacked(wc[1], "nihilism", "sting") then
      main.charybdon()
    end
  end,
  demon_nifilhema = function ()
    failsafe.check("standing")
  end,
  demon_baalphegar = function ()
    failsafe.check("dementia", "dementia")
    failsafe.check("paranoia", "paranoia")
    hidden("baalphegar")
  end,
  demon_gorgulu = function ()
    failsafe.check("eating", "anorexia", function () affs.add("scabies") end)
  end,
  demon_luciphage = function ()
    prone("paralysis")
  end,
  demon_ashtorath = function ()
    if prompt.stat("hp") < prompt.stat("maxhp") then
      flags.damaged_health()
    elseif prompt.stat("mp") < prompt.stat("maxmp") then
      flags.damaged_mana()
    elseif prompt.stat("ego") < prompt.stat("maxego") then
      flags.damaged_ego()
    end
    unknown(1)
  end,
  champion_pet1 = function ()
    if main.attacked("", "nihilism", "champion") then
      -- blackout
    end
  end,
  champion_pet2 = function ()
    if main.attacked("", "nihilism", "champion") then
      cold()
    end
  end,
  champion_pet3 = function ()
    if main.attacked("", "nihilism", "champion") then
      add_queue("fear")
    end
  end,
  torture = function (wc)
    prompt.preillqueue(function ()
      if prompt.gstats.prone and main.attacked(wc[1], "nihilism", "torture") then
        flags.damaged_health()
        failsafe.check("bleeding")
        if not (affs.has("paralysis") or affs.has("entangled") or affs.has("shackled")) then
          failsafe.check("standing")
        end
      end
    end, "tortured")
  end,
  evoke_luciphage = function (wc)
    if main.attacked(wc[1], "nihilism", "luciphage") then
      tr.nihilism.demon_luciphage()
    end
  end,
  evoke_ashtorath = function (wc)
    if main.attacked(wc[1], "nihilism", "ashtorath") then
      tr.nihilism.demon_ashtorath()
    end
  end,
  evoke_nifilhema = function (wc)
    if main.attacked(wc[1], "nihilism", "nifilhema") then
      tr.nihilism.demon_nifilhema()
    end
  end,
  evoke_gorgulu = function (wc)
    if main.attacked(wc[1], "nihilism", "gorgulu") then
      tr.nihilism.demon_gorgulu()
    end
  end,
  evoke_baalphegar = function (wc)
    if main.attacked(wc[1], "nihilism", "baalphegar") then
      tr.nihilism.demon_baalphegar()
    end
  end,
  demonweb = function (wc)
    if main.attacked(wc[1], "nihilism", "demonweb") then
      flags.damaged_health()
    end
  end,
}

tr.ninjakari = {
  jakari = function (wc)
    if main.attacked(wc[1], "ninjakari", "jakari") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
    end
  end,
  ninchu = function (wc)
    if main.attacked(wc[2], "ninjakari", "ninchu") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata_attack(part, wc[1])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
    end
  end,
  ninshi = function (wc)
    if main.attacked(wc[2], "ninjakari", "ninshi") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[1])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      grapple(part, wc[2], "ninshi")
    end
  end,
  ninshi_salve = function (wc)
    if not wc[1] or #wc[1] < 1 then
      if flags.get("applied") then
        flags.clear{"last_cure", "applied"}
      end
    else
      flags.clear{"last_cure", "health_applying"}
    end
  end,
  ninshi_yank = function (wc)
    if main.attacked(wc[1], "ninjakari", "yank") then
      for _,p in ipairs{"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
        if grapples[p] == wc[1] then
          wounds.kata(p)
          wounds.kata_attack(p, wc[1])
        end
      end
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      grapple(nil, wc[1])
    end
  end,
  akogh = function (wc)
    if main.attacked(wc[1], "ninjakari", "akogh") then
      local part = wc[2]
      wounds.kata(part)
      wounds.kata_attack(part, "kick")
      wounds.kata_mods(part)
      if part == "head" and not string.find(wc[0], "ooze") then
        stunned()
      elseif part == "chest" then
        add_queue("broken_chest")
        stunned()
      end
    end
  end,
  akogh_limb = function (wc)
    if main.attacked(wc[1], "ninjakari", "akogh") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "kick")
      wounds.kata_mods("Ninjakari")
      limb_queue(wc[2], wc[3], "broken")
    end
  end,
  ninombhi_head = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninombhi") then
      wounds.kata("head")
      wounds.kata_attack("head", "ninombhi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("crushed_windpipe")
    end
  end,
  ninombhi_chest = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninombhi") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "ninombhi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("snapped_rib")
    end
  end,
  ninombhi_gut = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninombhi") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "ninombhi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("vomiting")
    end
  end,
  ninombhi_limb = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninombhi") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "ninombhi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("lacerated_" .. part)
    end
  end,
  ninukhi = function (wc)
    if main.attacked(wc[2], "ninjakari", "ninukhi") then
      display.Warning("Dragged " .. string.upper(wc[1]) .. " by " .. wc[2] .. "!")
    end
  end,
  ninthugi_head = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninthugi") then
      wounds.kata("head")
      wounds.kata_attack("head", "ninthugi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("fractured_head")
    end
  end,
  ninthugi_gut = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninthugi") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "ninthugi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("dysentery")
    end
  end,
  ninthugi_chest = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninthugi") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "ninthugi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("broken_chest")
    end
  end,
  ninthugi_limb = function (wc)
    if main.attacked(wc[1], "ninjakari", "ninthugi") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "ninthugi")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      del_queue("numb_" .. part)
      add_queue("twisted_" .. part)
    end
  end,
  umubah = function (wc)
    if main.attacked(wc[1], "ninjakari", "umubah") then
      wounds.kata(wc[3])
      wounds.kata_attack(wc[3], wc[2])
      wounds.kata_mods("Ninjakari")
      if wc[3] == "head" then
        add_queue("confusion")
        failsafe.check("blind", "blindness")
      end
    end
  end,
  oolibah = function (wc)
    if main.attacked(wc[1], "ninjakari", "oolibah") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "oolibah")
      wounds.kata_mods("Ninjakari")
      numb(part)
    end
  end,
  ashlamkh_gut = function (wc)
    if main.attacked(wc[1], "ninjakari", "ashlamkh") then
      wounds.kata("gut")
      wounds.kata_attack("gut", wc[2])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("ruptured_gut")
    end
  end,
  ashlamkh_chest = function (wc)
    if main.attacked(wc[1], "ninjakari", "ashlamkh") then
      wounds.kata("chest")
      wounds.kata_attack("chest", wc[2])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("crushed_chest")
    end
  end,
  ashlamkh_limb_mangle = function (wc)
    if main.attacked(wc[1], "ninjakari", "ashlamkh") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, wc[4])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      limb_queue(wc[2], wc[3], "mangled")
    end
  end,
  ashlamkh_limb_break = function (wc)
    if main.attacked(wc[1], "ninjakari", "ashlamkh") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, wc[4])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      limb_queue(wc[2], wc[3], "broken")
      if wc[3] == "leg" then
        prone()
      end
    end
  end,
  ashlamkh_head = function (wc)
    if main.attacked(wc[1], "ninjakari", "ashlamkh") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      add_queue("shattered_jaw")
    end
  end,
  byahkari = function ()
    if main.attacked("", "ninjakari", "byahkari") then
      main.kata_mods("Ninjakari")
      main.poisons_on()
      stunned()
      add_queue("unconscious")
    end
  end,
  ughathalogg = function (wc)
    if main.attacked(wc[1], "ninjakari", "ughathalogg") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "ughathalogg")
      wounds.kata_mods("Ninjakari")
      main.poisons_on()
      if string.find(wc[0], "organs") then
        add_queue("burst_organs")
      end
    end
  end,
  ochai = function (wc)
    if main.attacked(wc[1], "ninjakari", "ochai") then
      bleed(150)
    end
  end,
  dhatogh = function ()
    prone()
  end,
  bhaddogho = function ()
    stunned()
    hidden("disoriented", has("disoriented"), 2)
  end,
  ninoaghi = function ()
    stunned()
    prone()
  end,
  ninaali = function ()
    add_queue("tumbling")
  end,
  illgathoru_head = function ()
    bleed(175)
  end,
  illgathoru_chest = function ()
    add_queue("severed_phrenic")
    bleed(175)
  end,
  illgathoru_gut = function ()
    add_queue("sliced_gut")
    bleed(175)
  end,
  illgathoru_leg = function (wc)
    add_queue("tendon_" .. wc[1])
    bleed(175)
  end,
  illgathoru_arm = function (wc)
    add_queue("hemiplegy_" .. wc[1])
    bleed(175)
  end,
  constrict = function ()
    main.attacked("", "ninjakari", "constrict")
  end,
}

tr.paradigmatics = {
  enthrall = function (wc)
    if iff.is_lusted(wc[1]) then
      if main.attacked(wc[1], "paradigmatics", "enthrall") then
        display.Alert("Enthralled! Reject " .. string.upper(wc[1]) .. "!")
      end
    end
  end,
  revelations = function (wc)
    if main.attacked(wc[1], "paradigmatics", "revelations") then
      insanity(7)
    end
  end,
  flux = function ()
    if main.attacked("", "paradigmatics", "flux") then
      insanity(5)
    end
  end,
  badluck = function (wc)
    if main.attacked(wc[1], "paradigmatics", "badluck") then
      insanity(3)
      add_queue("bad_luck")
    end
  end,
  greywhispers = function (wc)
    if main.attacked(wc[1], "paradigmatics", "greywhispers") then
      insanity(3)
      add_queue("grey_whispers", 16)
    end
  end,
  greywhispers_symp = function ()
    if main.attacked("", "paradigmatics", "greywhispers") then
      insanity(5)
      add_queue("grey_whispers", (has("grey_whispers") or 0) - 1)
      hidden("hidden_mental")
      failsafe.check("eating")
      failsafe.check("dementia", "dementia")
      failsafe.check("impatience", "impatience")
      failsafe.check("paranoia", "paranoia")
    end
  end,
  eyesnare = function ()
    if main.attacked("", "paradigmatics", "eyesnare") then
      insanity(5)
    end
  end,
  visionflux = function ()
    if main.attacked("", "paradigmatics", "visionflux") then
      insanity(7)
      hidden("hidden_mental")
    end
  end,
  truename = function (wc)
    if main.attacked(wc[1], "paradigmatics", "truename") then
      if string.find(wc[2], "humiliation") then
        flags.damaged_health()
        if (has("insanity") or 0) < 15 then
          add_queue("insanity", 30)
        else
          insanity(7)
        end
      end
    end
  end,
  chaosaura = function (wc)
    if main.attacked(wc[1], "paradigmatics", "chaosaura") then
      insanity(4)
    end
  end,
  butterfly1 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      prone("entangled")
      stunned()
    end
  end,
  butterfly2 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      flags.damaged_health()
    end
  end,
  butterfly3 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      add_queue{"pox", "scabies", "vomiting", "worms"}
    end
  end,
  butterfly4 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      limb_queue("left", "arm", "broken")
      limb_queue("right", "arm", "broken")
      limb_queue("left", "leg", "broken")
      limb_queue("right", "leg", "broken")
    end
  end,
  butterfly5 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      flags.clear("climbing_up")
      flags.set("skip_hypochondria", true)

      if beast.locate() ~= "stable" then
        beast.locate("lost")
      end

      if not defs.has("levitating") then
        add_queue("mending_legs")
        stunned()
      end
    end
  end,
  butterfly6 = function ()
    if main.attacked("", "paradigmatics", "butterfly") then
      prompt.preillqueue(function ()
        affs.reset()
        wounds.reset()
        defs.del("insomnia")
      end)
    end
  end,
  smileys = function ()
  end,
}

tr.phantasms = {
  whisper = function (wc)
    if main.attacked(wc[1], "phantasms", "whisper") then
      add_queue("disrupted")
    end
  end,
  phantomwall = function ()
    if main.attacked("", "phantasms", "phantomwall") then
      prone("entangled")
    end
  end,
  phantom = function (wc)
    if main.attacked(wc[1], "phantasms", "phantom") then
      add_queue("phantoms")
    end
  end,
  phantom_entangled = function ()
    if main.attacked("", "phantasms", "phantom") then
      prone{"entangled", "phantoms"}
    end
  end,
  phantom_claustrophobia = function ()
    if main.attacked("", "phantasms", "phantom") then
      add_queue{"claustrophobia", "phantoms"}
    end
  end,
  phantom_confusion = function ()
    if main.attacked("", "phantasms", "phantom") then
      add_queue{"confusion", "phantoms"}
    end
  end,
  phantom_vestiphobia = function ()
    if main.attacked("", "phantasms", "phantom") then
      add_queue{"vestiphobia", "phantoms"}
    end
  end,
  phantom_hallucinations = function ()
    if main.attacked("", "phantasms", "phantom") then
      add_queue{"hallucinations", "phantoms"}
    end
  end,
  phantom_paranoia = function ()
    if main.attacked("", "phantasms", "phantom") then
      add_queue{"paranoia", "phantoms"}
    end
  end,
  redmask_evenblade = function (wc)
    local a = "evenblade"
    if string.find(wc[0], "Fain") then
      a = "redmask"
    end
    if main.attacked(wc[1], "phantasms", a) then
      flags.damaged_mana()
      flags.set("mana_careful", true, 60)
    end
  end,
  wounds = function (wc)
    if main.attacked(wc[1], "phantasms", "wounds") then
      add_queue("illusory_wounds")
    end
  end,
  stalker = function ()
    if main.attacked("", "phantasms", "stalker") then
      add_queue("phantoms")
    end
  end,
  claws = function (wc)
    if main.attacked(wc[1], "phantasms", "claws") then
      bleed(400)
    end
  end,
  phantomarmour = function (wc)
    main.attacked(wc[1], "phantasms", "phantomarmour")
  end,
  phantomsphere_unshield = function ()
    if main.attacked("", "phantasms", "phantomsphere") then
      defs.del_queue("shield")
    end
  end,
  phantomsphere_attack = function ()
    if main.attacked("", "phantasms", "phantomsphere") then
      EnableTrigger("phantasms_phantomsphere_attacked__", true)
      EnableTrigger("phantasms_phantomsphere_detonated__", true)
      prompt.queue(function ()
        EnableTrigger("phantasms_phantomsphere_attacked__", false)
        EnableTrigger("phantasms_phantomsphere_detonated__", false)
      end)
    end
  end,
  phantomsphere_attacked = function (wc)
    if main.attacked("", "phantasms", "phantomsphere") then
      local count = 1
      if string.find(wc[0], "joining one ") then
        count = 2
      elseif string.find(wc[0], "joining two ") then
        count = 3
      end
      Execute("OnDanger Phantom Spheres: " .. count .. "  Leave the Demesne!")
    end
  end,
  phantomsphere_detonated = function ()
    if main.attacked("", "phantasms", "phantomsphere") then
      flags.damaged_health()
      del_queue("phantomsphere")
    end
  end,
  reality_cast = function (wc)
    if main.attacked(wc[1], "phantasms", "reality") then
      Execute("OnDanger " .. string.upper(wc[1]) .. " Altered Reality!")
    end
  end,
  reality = function ()
    hidden("reality")
    failsafe.check("dementia", "dementia")
  end,
}

tr.poisons = {
  shrug = function ()
    flags.clear{"last_cure", "charybdon"}
    flags.set("shrugged", true)
  end,
  mactans = function ()
    cold()
    flags.clear("last_cure")
  end,
  pyrotoxin = function ()
    defs.del_queue("frost")
    burning()
    flags.clear("last_cure")
  end,
  mantakaya = function ()
    if flags.get("hex") then
      flags.clear("hex")
      prompt.unqueue("mehexed")
    end
    prone("paralysis")
    flags.clear{"charybdon", "last_cure"}
  end,
  dendroxin = function (wc)
    limb_queue(wc[1], "arm", "broken")
    flags.clear("last_cure")
  end,
  calcise = function (wc)
    limb_queue(wc[1], "leg", "broken")
    flags.clear("last_cure")
  end,
  addiction = function ()
    poison("addiction")
  end,
  anorexia = function ()
    poison("anorexia")
  end,
  asthma = function ()
    poison("asthma")
  end,
  clumsiness = function ()
    poison("clumsiness")
  end,
  dementia = function ()
    poison("dementia")
  end,
  dizziness = function ()
    poison("dizziness")
  end,
  epilepsy = function ()
    poison("epilepsy")
  end,
  gluttony = function ()
    poison("gluttony")
  end,
  healthleech = function ()
    poison("healthleech")
  end,
  hemophilia = function ()
    poison("hemophilia")
  end,
  impatience = function ()
    poison("impatience")
  end,
  masochism = function ()
    poison("masochism")
  end,
  paranoia = function ()
    poison("paranoia")
  end,
  peace = function ()
    poison("peace")
  end,
  powersap = function ()
    poison("powersap")
  end,
  recklessness = function ()
    poison("recklessness")
  end,
  relapsing = function ()
    poison("relapsing")
  end,
  repugnance = function ()
    poison("repugnance")
  end,
  sensitivity = function ()
    poison("sensitivity")
  end,
  slickness = function ()
    poison("slickness")
  end,
  stupidity = function ()
    poison("stupidity")
  end,
  sunallergy = function ()
    poison("sunallergy")
  end,
  sunallergy2 = function ()
    poison("sunallergy")
    local charyb = (flags.get("charybdon") or 1) - 1
    if charyb <= 0 then
      flags.clear("charybdon")
    else
      flags.set("charybdon", charyb, 0)
    end
  end,
  vapors = function ()
    poison("vapors")
  end,
  vertigo = function ()
    poison("vertigo")
  end,
  vomiting = function ()
    poison("vomiting")
  end,
  weakness = function ()
    poison("weakness")
  end,
  worms = function ()
    poison("worms")
  end,
}

tr.pyromancy = {
  fireball = function (wc)
    EnableTrigger("pyromancy_fireballed__", true)
    prompt.queue(function () EnableTrigger("pyromancy_fireballed__", false) end)
    flags.set("caster", wc[1])
  end,
  fireballed = function ()
    if main.attacked(flags.get("caster") or "", "pyromancy", "fireball") then
      flags.damaged_health()
    end
  end,
  smokehaze = function ()
    if main.attacked("", "pyromancy", "smokehaze") then
      add_queue("asthma")
    end
  end,
  firestorm_salamanders = function ()
    if main.attacked("", "pyromancy", "firestorm") then
      add_queue("ablaze")
      burning()
    end
  end,
  heatwave = function ()
    if main.attacked("", "pyromancy", "heatwave") then
      add_queue("sunallergy")
      burning()
    end
  end,
  flashfire = function ()
    if main.attacked("", "pyromancy", "flashfire") then
      burning()
      flags.damaged_health()
    end
  end,
  salamanders_dizziness = function ()
    if main.attacked("", "pyromancy", "salamanders") then
      add_queue("dizziness")
    end
  end,
  salamanders_blindness = function ()
    if main.attacked("", "pyromancy", "salamanders") then
      defs.del("sixthsense")
    end
  end,
  phoenix = function ()
    if main.attacked("", "pyromancy", "phoenix") then
      add_queue("ablaze")
      burning()
    end
  end,
  firerain = function ()
    if main.attacked("", "pyromancy", "firerain") then
      burning()
      stunned()
      EnableTrigger("pyromancy_limb_severed__", true)
      prompt.queue(function () EnableTrigger("pyromancy_limb_severed__", false) end)
    end
  end,
  heatstroke = function ()
    if main.attacked("", "pyromancy", "heatstroke") then
      add_queue("slickness")
    end
  end,
  ashfall = function ()
    if main.attacked("", "pyromancy", "ashfall") then
      add_queue("black_lung")
    end
  end,
  flamering = function (wc)
    if main.attacked(wc[1], "pyromancy", "flamering") then
      add_queue("ablaze")
      burning()
    end
  end,
  staff_point = function (wc)
    if main.attacked(wc[1] or "", "pyromancy", "staffpoint") then
      flags.damaged_health()
    end
  end,
  staff_twirl = function ()
    if main.attacked("", "pyromancy", "stafftwirl") then
      burning()
    end
  end,
  incinerate = function (wc)
    if main.attacked(wc[1], "pyromancy", "incinerate") then
      burning()
    end
  end,
  limb_severed = function (wc)
    limb_queue(wc[1], wc[2], "severed")
    bleed(500)
    stunned()
  end,
}

tr.rituals = {
  amissio = function (wc)
    if main.attacked(wc[1], "rituals", "amissio") then
      display.Alert("Watch mana!")
      flags.damaged_mana()
      flags.set("mana_careful", true, 60)
    end
  end,
}

tr.runes = {
  sling1 = function (wc)
    if check_runes(wc[1], "sling") then
      runed(wc[2])
    end
  end,
  sling2 = function (wc)
    if check_runes(wc[1], "doublesling") then
      runed(wc[2])
      runed(wc[3])
    end
  end,
  sling_other = function (wc)
    flags.set("antirunes_" .. wc[1], true, 1)
  end,
  sling_adjacent1 = function (wc)
    if map.is_exit_valid(wc[2]) then
      runed(wc[1])
    end
  end,
  sling_adjacent2 = function (wc)
    if map.is_exit_valid(wc[3]) then
      runed(wc[1])
      runed(wc[2])
    end
  end,
  embedded = function (wc)
    local gr = flags.get("ghost_rune")
    if not gr or gr == wc[1] then
      runed(wc[1])
      flags.set("ghost_rune", wc[1], 12)
    end
  end,
  prophesy = function (wc)
    if main.attacked(wc[1], "runes", "malignprophesy") then
      add_queue{"scabies", "pox", "masochism", "addiction"}
    end
  end,
}

tr.sacraments = {
  heretic = function (wc)
    if main.attacked(wc[1], "sacraments", "heretic") then
      add_queue("heretic")
      Execute("OnDanger You are a HERETIC!")
      DoAfterSpecial(3, "display.Warning('Watch for Infidel in two seconds!')", 12)
      DoAfterSpecial(8, "display.Warning('Watch for Infidel in two seconds!')", 12)
    end
  end,
  heretic_tick = function ()
    if has("heretic") and main.attacked("", "sacraments", "heretic") then
      Execute("OnDanger HERETIC AFFLICTION!")
      hidden("hidden_heretic", has("hidden_heretic"), 6)
    end
  end,
  judgement_start = function (wc)
    if main.attacked(wc[1], "sacraments", "judgement") then
      Execute("OnInstakill Judgement - " .. wc[1] .. " - Stage One")
    end
  end,
  judgement_continue = function (wc)
    if main.attacked(wc[1], "sacraments", "judgement") then
      Execute("OnInstakill Judgement - " .. wc[1] .. " - Stage Two - MOVE!")
    end
  end,
  infidel = function (wc)
    if has("heretic") and main.attacked(wc[1], "sacraments", "infidel") then
      add_queue("infidel")
      Execute("OnDanger You are an INFIDEL!")
      DoAfterSpecial(3, "display.Warning('Watch for INQUISITION in two seconds! Get out now!')", 12)
      DoAfterSpecial(8, "display.Warning('Watch for INQUISITION in two seconds! Get out now!')", 12)
    end
  end,
  inquisition = function (wc)
    if has("infidel") and main.attacked(wc[1], "sacraments", "inquisition") then
      prompt.illqueue(function () flags.set("inquisition", true, 2) SendNoEcho("ql") end)
    end
  end,
  inquisition_symptom = function ()
    if flags.get("inquisition") then
      flags.clear("inquisition")
      add("inquisition")
      del{"heretic", "infidel"}
    end
    if has("inquisition") then
      Execute("OnDanger -=<< INQUISITION >>=-")
    end
  end,
  inquisition_done = function ()
    if has("inquisition") then
      del_queue{"heretic", "infidel", "inquisition"}
      defs.reset_death()
      display.Alert("INQUISITION ENDED!")
    end
  end,
}

tr.shadowbeat = {
  singing = function (wc)
    local effects = {
      [", playing .- with cackling melodies"] = "crowcaw",
    }
    for m,t in pairs(effects) do
      if string.find(wc[2], m) and main.attacked(wc[1], "shadowbeat", t) then
        flags.set("singer", wc[1])
        EnableTrigger("shadowbeat_" .. t .. "__", true)
        prompt.queue(function () EnableTrigger("shadowbeat_" .. t .. "__", false) end)
        break
      end
    end
  end,
  shadowrave = function ()
    if main.attacked("", "shadowbeat", "shadowrave") then
      prone()
    end
  end,
  shadowpulse = function ()
    if main.attacked("", "shadowbeat", "shadowpulse") then
      prone("paralysis")
      failsafe.check("bleeding")
    end
  end,
  bloodycaps = function ()
    if main.attacked("", "shadowbeat", "bloodycaps") then
      add_queue("hemophilia")
      failsafe.check("bleeding")
    end
  end,
  crowcaw = function ()
    if main.attacked(flags.get("singer") or "", "shadowbeat", "crowcaw") then
      add_queue("epilepsy")
      if not (has("deafness") or defs.has("truehearing")) then
        stunned()
      end
      bleed(400)
      failsafe.check("standing")
      hidden("crowcaw", has("crowcaw"), 2)
    end
  end,
  widowsmercy = function (wc)
    if main.attacked(wc[1], "shadowbeat", "widowsmercy") then
      flags.damaged_health()
    end
  end,
  spidercantiga = function ()
    if main.attacked("", "shadowbeat", "spidercantiga") then
      main.poisons_on()
      prompt.preillqueue(function ()
        if not flags.get("shrugged") and not flags.get("repelled") and not prompt.stat("deaf") then
          failsafe.check("asthma", "asthma", function () affs.add("sensitivity") end)
        end
      end, "spidercantiga")
    end
  end,
}

tr.shamanism = {
  coldweather = function ()
    cold()
  end,
  hotweather = function ()
    add_queue("slickness")
  end,
  lightburst = function (wc)
    EnableTrigger("cure_frozen__", true)
    EnableTrigger("cure_shivering__", true)
    EnableTrigger("cure_fire__", true)
    prompt.queue(function ()
      EnableTrigger("cure_frozen__", false)
      EnableTrigger("cure_shivering__", false)
      EnableTrigger("cure_fire__", false)
    end, "unfreeze")
  end,
  claw = function (wc)
    if main.attacked(wc[1], "shamanism", "claw") then
      flags.damaged_health()
      bleed(250)
      stunned()
    end
  end,
  bloom = function (wc)
    if main.attacked(wc[1], "shamanism", "bloom") then
      add_queue{"dizziness", "clumsiness"}
      flags.set("blackout", function () affs.add("vapors") end)
    end
  end,
  earthquake = function (wc)
    if main.attacked(wc[1], "shamanism", "earthquake") then
      EnableTrigger("shamanism_earthquaked__", true)
      prompt.queue(function () EnableTrigger("shamanism_earthquaked__", false) end)
    end
  end,
  earthquaked = function ()
    prone()
    stunned()
  end,
  muddy = function ()
    prone()
  end,
  bone = function (wc)
    if main.attacked(wc[1], "shamanism", "bone") then
      EnableTrigger("shamanism_boned__", true)
      prompt.queue(function () EnableTrigger("shamanism_boned__", false) end)
    end
  end,
  boned = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  frogs = function (wc)
    if main.attacked(wc[1], "shamanism", "frogs") then
      EnableTrigger("shamanism_frogged__", true)
      prompt.queue(function () EnableTrigger("shamanism_frogged__", false) end)
    end
  end,
  frogged = function ()
    main.charybdon()
  end,
  golem_vines = function ()
    prone("entangled")
  end,
  golem_rake = function ()
    bleed(30)
  end,
  pressure = function (wc)
    if main.attacked(wc[1], "shamanism", "pressure") then
      EnableTrigger("shamanism_pressured__", true)
      prompt.queue(function () EnableTrigger("shamanism_pressured__", false) end)
    end
  end,
  pressured = function ()
    flags.damaged_health()
    bleed(200)
  end,
  sky = function (wc)
    if main.attacked(wc[1], "shamanism", "sky") then
      EnableTrigger("shamanism_skies__", true)
      prompt.queue(function () EnableTrigger("shamanism_skies__", false) end)
    end
  end,
  skies = function ()
    defs.add_queue("flying")
  end,
  snowman_prone = function ()
    prone()
  end,
  snowman_cold = function ()
    cold()
  end,
  freeze = function (wc)
    if main.attacked(wc[1], "shamanism", "freeze") then
      cold()
    end
  end,
  lightning = function ()
    if main.attacked("", "shamanism", "lightning") then
      flags.damaged_health()
    end
  end,
}

tr.shofangi = {
  shofa = function (wc)
    if main.attacked(wc[1], "shofangi", "shofa") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[3])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
    end
  end,
  skive = function (wc)
    if main.attacked(wc[1], "shofangi", "skive") then
      wounds.kata_mods("Shofangi")
    end
  end,
  logami = function (wc)
    if main.attacked(wc[1], "shofangi", "logami") then
      wounds.kata("leftarm")
      wounds.kata("rightarm")
      wounds.kata_mods("Shofangi")
      main.poisons_on()      
      grapple("leftarm", wc[1])
      grapple("rightarm", wc[1])
    end
  end,
  shotah = function (wc)
    if main.attacked(wc[1], "shofangi", "shotah") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "shotah")
      wounds.kata_mods("Shofangi")
      main.poisons_on()      
    end
  end,
  disarm = function (wc)
    if main.attacked(wc[1], "shofangi", "disarm") then
      wounds.kata("leftarm")
      wounds.kata("rightarm")
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      grapple(nil, wc[1])
      limb_queue("left", "arm", "broken")
      limb_queue("right", "arm", "broken")
    end
  end,
  stomp = function (wc)
    if main.attacked(wc[1], "shofangi", "stomp") then
      wounds.kata(wc[2])
      wounds.kata_attack(wc[2], "stomp")
      wounds.kata_mods("Shofangi")
      if is_prone() then
        if wc[2] == "chest" then
          add_queue("snapped_rib")
        elseif wc[2] == "head" then
          add_queue("broken_jaw")
        end
      end
    end
  end,
  stomp_limb = function (wc)
    if main.attacked(wc[1], "shofangi", "stomp") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "stomp")
      wounds.kata_mods("Shofangi")
      if not is_prone() then
        if wc[3] == "leg" then
          add_queue("foot_" .. wc[2])
        end
      else
        limb_queue(wc[2], wc[3], "broken")
      end
    end
  end,
  bogami = function (wc)
    if main.attacked(wc[1], "shofangi", "bogami") then
      wounds.kata("leftleg")
      wounds.kata("rightleg")
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      grapple("leftleg", wc[1])
      grapple("rightleg", wc[1])
    end
  end,
  bullsnort = function (wc)
    if main.attacked(wc[1], "shofangi", "bullsnort") then
      add_queue("disrupted")
    end
  end,
  headbutt = function (wc)
    if main.attacked(wc[1], "shofangi", "headbutt") then
      EnableTrigger("shofangi_headbutt_prone__", true)
      prompt.queue(function () EnableTrigger("shofangi_headbutt_prone__", false) end)
    end
  end,
  headbutt_prone = function ()
    prone()
  end,
  butanj = function (wc)
    if main.attacked(wc[1], "shofangi", "butanj") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      add_queue("broken_jaw")
    end
  end,
  whibuta = function (wc)
    if main.attacked(wc[1], "shofangi", "whibuta") then
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      defs.del_queue("sixthsense")
    end
  end,
  heelslam_head = function (wc)
    if main.attacked(wc[1], "shofangi", "heelslam") then
      wounds.kata("head")
      wounds.kata_attack("head", "heelslam")
      add_queue("fractured_head")
    end
  end,
  heelslam_chest = function (wc)
    if main.attacked(wc[1], "shofangi", "heelslam") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "heelslam")
      add_queue("broken_chest")
    end
  end,
  heelslam_gut = function (wc)
    if main.attacked(wc[1], "shofangi", "heelslam") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "heelslam")
    end
  end,
  heelslam_limb = function (wc)
    if main.attacked(wc[1], "shofangi", "heelslam") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "heelslam")
      add_queue("dislocated_" .. part)
    end
  end,
  butojo_sliced_tongue = function (wc)
    if main.attacked(wc[1], "shofangi", "butojo") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      add_queue("sliced_tongue")
    end
  end,
  butojo_slit_throat = function (wc)
    if main.attacked(wc[1], "shofangi", "butojo") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      add_queue("slit_throat")
    end
  end,
  tomati = function (wc)
    if main.attacked(wc[1], "shofangi", "tomati") then
      wounds.kata("gut")
      wounds.kata_attack("gut", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      grapple("gut", wc[1])
    end
  end,
  shred = function (wc)
    if main.attacked(wc[1], "shofangi", "shred") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      if part == "chest" then
        add_queue("sliced_chest")
        stunned()
      elseif part == "gut" then
        add_queue("sliced_gut")
      elseif string.find(part, "arm") or string.find(part, "leg") then
        add_queue("lacerated_" .. part)
      end
      main.poisons_on()
      grapple(part)
      bleed(300)
    end
  end,
  shred2 = function (wc)
    local part1 = string.gsub(wc[3], " ", "")
    local part2 = string.gsub(wc[4], " ", "")
    if part1 ~= part2 and main.attacked(wc[1], "shofangi", "shred") then
      wounds.kata(part1)
      wounds.kata(part2)
      wounds.kata_attack(part1, wc[2])
      wounds.kata_attack(part2, wc[2])
      if part1 == "chest" or part2 == "chest" then
        add_queue("sliced_chest")
        stunned()
      end
      if part1 == "gut" or part2 == "gut" then
        add_queue("sliced_gut")
      end
      if string.find(part1, "arm") or string.find(part1, "leg") then
        add_queue("lacerated_" .. part1)
      end
      if string.find(part2, "arm") or string.find(part2, "leg") then
        add_queue("lacerated_" .. part2)
      end
      main.poisons_on()
      grapple(part1)
      grapple(part2)
      bleed(300)
    end
  end,
  boganj_arm = function (wc)
    if main.attacked(wc[1], "shofangi", "boganj") then
      wounds.kata(wc[2] .. "arm")
      wounds.kata_attack(wc[2] .. "arm", wc[3])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      bleed()
      cracked(wc[2], "arm")
    end
  end,
  boganj_leg = function (wc)
    if main.attacked(wc[1], "shofangi", "boganj") then
      wounds.kata(wc[2] .. "leg")
      wounds.kata_attack(wc[2] .. "leg", wc[3])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      if has("kneecap_" .. wc[2]) then
        prone()
      end
      cracked(wc[2], "leg")
    end
  end,
  kumati = function (wc)
    if main.attacked(wc[1], "shofangi", "kumati") then
      wounds.kata("chest")
      wounds.kata_attack("chest", wc[2])
      wounds.kata_mods("Shofangi")
      main.poisons_on()
      grapple("chest", wc[1])
    end
  end,
  crunch = function (wc)
    if main.attacked(wc[1], "shofangi", "crunch") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, "crunch")
      grapple(part)
    end
  end,
  rake = function (wc)
    add_queue("lacerated_" .. wc[1] .. wc[2])
    bleed(200)
  end,
  shoflai = function ()
    bals.lose("salve")
  end,
  bullstrength = function ()
    local part = flags.get("kata_hit") or ""
    if part == "chest" then
      add_queue("broken_chest")
    elseif string.find(part, "arm") then
      local side = string.sub(part, 1, -4)
      limb_queue(side, "arm", "broken")
    elseif string.find(part, "leg") then
      local side = string.sub(part, 1, -4)
      limb_queue(side, "leg", "broken")
    end
  end,
  hook = function (wc)
    add("prone")
    if wc[1] and #wc[1] > 0 then
      stunned()
    end
  end,
  kumaki = function ()
    prone("paralysis")
  end,
  buck_limb = function (wc)
    if main.attacked(wc[1], "shofangi", "buck") then
      local part = wc[2] .. wc[3]
      wounds.kata(part)
      wounds.kata_attack(part, "buck")
      wounds.kata_mods("Shofangi")
      limb_queue(wc[2], wc[3], "mangled")
    end
  end,
  buck_head = function (wc)
    if main.attacked(wc[1], "shofangi", "buck") then
      wounds.kata("head")
      wounds.kata_attack("head", "buck")
    end
  end,
  buck_gut = function (wc)
    if main.attacked(wc[1], "shofangi", "buck") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "buck")
      add_queue("ruptured_gut")
    end
  end,
  buck_chest = function (wc)
    if main.attacked(wc[1], "shofangi", "buck") then
      wounds.kata("chest")
      wounds.kata_attack("chest", "buck")
      add_queue("crushed_chest")
    end
  end,
  kumato = function (wc)
    if main.attacked(wc[1], "shofangi", "kumato") then
      wounds.kata("leftleg")
      wounds.kata("rightleg")
      grapple()
      EnableTrigger("shofangi_kumato_toss__", true)
      prompt.queue(function () EnableTrigger("shofangi_kumato_toss__", false) end)
    end
  end,
  kumato_toss = function (wc)
    display.Alert("Shofangi Throw")
    beast.lost()
  end,
  bullkick = function (wc)
    if main.attacked(wc[1], "shofangi", "bullkick") then
      wounds.kata(wc[2])
      wounds.kata_attack(wc[2], "bullkick")
      beast.lost()
      display.Alert("Bullkick")
    end
  end,
  bullcharge = function (wc)
    if main.attacked(wc[1], "shofangi", "bullcharge") then
      wounds.kata("gut")
      wounds.kata_attack("gut", "bullcharge")
      main.poisons_on()
      grapple("gut", wc[1])
      prone()
    end
  end,
}

tr.stag = {
  stagstomp1 = function (wc)
    if main.attacked(wc[1], "stag", "stagstomp") then
      prone{"prone", "disrupted"}
      EnableTrigger("stag_stagstomp_break__", true)
      prompt.queue(function () EnableTrigger("stag_stagstomp_break__", false) end)
    end
  end,
  stagstomp2 = function (wc)
    if main.attacked(wc[1], "stag", "stagstomp") then
      prone{"prone", "disrupted"}
      EnableTrigger("stag_stagstomp_break__", true)
      prompt.queue(function () EnableTrigger("stag_stagstomp_break__", false) end)
    end
  end,
  stagstomp_break = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  bellow = function (wc)
    if main.attacked(wc[1], "stag", "bellow") then
      stunned()
    end
  end,
  headbutt = function (wc)
    if main.attacked(wc[1], "stag", "headbutt") then
      display.Alert("Headbutted by " .. string.upper(wc[1]))
      EnableTrigger("stag_headbutted__", true)
      prompt.queue(function () EnableTrigger("stag_headbutted__", false) end, "headbutted")
    end
  end,
  headbutted = function (wc)
    display.Alert("Hurled " .. string.upper(wc[1]))
  end,
  ancestralcurse = function (wc)
    if main.attacked(wc[1], "stag", "ancestralcurse") then
      hidden("ancestralcurse")
      --failsafe.check("paranoia", "paranoia")
      --failsafe.check("impatience", "impatience")
    end
  end,
  gore_pain = function (wc)
    if main.attacked(wc[1], "stag", "gore") then
      flags.damaged_health()
      main.poisons_on()
    end
  end,
  gore_impale = function (wc)
    if main.attacked(wc[1], "stag", "gore") then
      prone("impale_antlers")
      main.poisons_on()
    end
  end,
  gore_impaled = function (wc)
    prone("impale_antlers")
    flags.damaged_health()
  end,
}

tr.starhymn = {
  singing = function (wc)
    local effects = {
      [", letting .- fill the air with pure notes that sparkle in the air"] = "starlight",
      [", making .- fairly weep with tragic notes"] = "princessfarewell",
    }
    for m,t in pairs(effects) do
      if string.find(wc[2], m) and main.attacked(wc[1], "starhymn", t) then
        EnableTrigger("starhymn_" .. t .. "__", true)
        prompt.queue(function () EnableTrigger("starhymn_" .. t .. "__", false) end)
        break
      end
    end
  end,
  starlight = function ()
    add_queue{"sensitivity", "vomiting", "sunallergy"}
  end,
  crusadercanto = function ()
    if main.attacked("", "starhymn", "crusadercanto") then
      flags.damaged_health()
    end
  end,
  lightcantata = function ()
    if main.attacked("", "starhymn", "lightcantata") then
      EnableTrigger("starhymn_lightcantata_blind__", true)
      prompt.queue(function () EnableTrigger("starhymn_lightcantata_blind__", false) end)
    end
  end,
  lightcantata_blind = function ()
    defs.del("sixthsense")
    if has("afterimage") then
      prone{"prone", "confusion", "epilepsy"}
    else
      prone()
    end
  end,
  princessfarewell = function ()
    if main.attacked("", "starhymn", "princessfarewell") then
      aeoned()
      stunned()
    end
  end,
  justchorale = function (wc)
    if main.attacked("", "starhymn", "justchorale") and
       (not (has("deafness") or defs.has("truehearing")) or has("angelic_host")) then
      prone("paralysis")
      prompt.preillqueue(function () if not prompt.gstats.prone then affs.add("focus_mind") end end, "justchorale")
    end
  end,
  avengingangel = function (wc)
    if main.attacked(wc[1], "starhymn", "avengingangel") then
      failsafe.check("impatience", "impatience")
      flags.set("blackout", function () affs.add("vapors") end)
      prompt.queue(function () if not affs.has("vapors") then affs.hidden("avengingangel", affs.has("avengingangel"), 2) end end, "avenge")
    end
  end,
  recessional = function (wc)
    if main.attacked("", "starhymn", "recessional") and
       (not (has("deafness") or defs.has("truehearing")) or has("angelic_host")) then
      if wc[1] == "eat" then
        if flags.get("herb_try") then
          bals.gain("herb")
        elseif flags.get("sparkle_try") then
          bals.gain("sparkle")
        end
      else
        if flags.get("health_try") then
          bals.gain("health")
        elseif flags.get("elixir_try") then
          bals.gain("elixir")
        elseif flags.get("allheale_try") then
          bals.gain("allheale")
        elseif flags.get("speed_try") == "quicksilver" then
          flags.clear("speed_try")
        end
      end
    end
  end,
  eversea = function ()
    if main.attacked("", "starhymn", "eversea") then
      defs.del_queue("shield")
      display.Alert("Song prevents shield!")
    end
  end,
  angelichost = function (wc)
    if main.attacked(wc[1], "starhymn", "angelichost") then
      add_queue("angelic_host", wc[1])
    end
  end,
}

tr.stealth = {
  blowgun = function (wc)
    if main.attacked(wc[1], "stealth", "blowgun") then
      main.poisons_on()
    end
  end,
  blowgun_aim = function (wc)
    if main.attacked("", "stealth", "blowgun") then
      main.poisons_on()
    end
  end,
  truss = function (wc)
    if main.attacked(wc[1], "stealth", "truss") then
      prone("trussed")
    end
  end,
  waylay = function (wc)
    if main.attacked(wc[1], "stealth", "waylay") then
      prone()
    end
  end,
  rush = function (wc)
    if main.attacked(wc[1], "stealth", "rush") then
      prone{"prone", "trussed"}
    end
  end,
  drag = function (wc)
    if main.attacked(wc[1], "stealth", "drag") and has("trussed") then
      display.Alert("Dragged to the " .. string.upper(wc[2]) .. "!")
    end
  end,
}

tr.tahtetso = {
  tahto = function (wc)
    if main.attacked(wc[1], "tahtetso", "tahto") then
      local part = string.gsub(wc[2], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[3])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
    end
  end,
  rakto_head = function ()
    add_queue("broken_jaw")
  end,
  rakto_limb = function (wc)
    limb_queue(wc[1], wc[2], "broken")
  end,
  rakto_gut = function ()
    prone("paralysis")
  end,
  raktiini_chest = function ()
    add_queue("short_breath")
  end,
  raktiini_gut = function ()
    stunned()
  end,
  raktiini_leg = function (wc)
    add_queue("kneecap_" .. wc[1])
  end,
  bomrakini_arm = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomrakini") then
      local part = wc[3] .. "arm"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("fractured_" .. part)
    end
  end,
  bomrakini_leg = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomrakini") then
      local part = wc[3] .. "leg"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("foot_" .. part)
    end
  end,
  bomrakobo = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomrakobo") then
      if wc[2] and #wc[2] > 0 then
        local part = string.gsub(wc[2], " ", "")
        wounds.kata(part, 400)
        if string.find(part, "leg") or string.find(part, "arm") then
          add_queue("dislocated_" .. part)
        end
      else
        for _,p in ipairs{"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
          if grapples[p] == wc[1] then
            wounds.kata(p, 400)
            grapple(p)
          end
        end
      end
      wounds.kata_mods("Tahtetso")
    end
  end,
  bairak = function (wc)
    if main.attacked(wc[1], "tahtetso", "bairak") then
      wounds.kata("head", 400)
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Tahtetso")
      grapple("head", wc[1])
    end
  end,
  bairak_choking = function (wc)
    if main.attacked(wc[1], "tahtetso", "bairak") then
      wounds.kata("head", 500)
      wounds.kata_attack("head", "tahto")
      wounds.kata_mods("Tahtetso")
      grapple("head", wc[1])
    end
  end,
  starkick = function (wc)
    if main.attacked(wc[1], "tahtetso", "starkick") then
      wounds.kata(wc[2], 175)
      wounds.kata_attack(wc[2], "starkick")
      wounds.kata_mods("Tahtetso")
      if wc[3] and #wc[3] > 0 then
        prone()
      end
      if wc[2] == "head" and wounds.get("head") >= 1000 then
        add_queue("confusion") -- pick up stupidity through symptoms
      elseif wc[2] == "chest" and wounds.get("chest") >= 900 then
        add_queue("snapped_rib")
      end
    end
  end,
  tidesweep = function (wc)
    if main.attacked(wc[1], "tahtetso", "tidesweep") then
      EnableTrigger("tahtetso_tideswept__", true)
      prompt.queue(function () EnableTrigger("tahtetso_tideswept__", false) end)
    end
  end,
  tideswept = function ()
    prone()
    flags.damaged_health()
  end,
  bomolini = function ()
    prone()
  end,
  bairakobo = function (wc)
    if main.attacked(wc[1], "tahtetso", "bairakobo") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Tahtetso")
      grapple("head", wc[1])
      add_queue("crushed_windpipe")
      main.poisons_on()
    end
  end,
  tahtosho = function (wc)
    if main.attacked(wc[1], "tahtetso", "tahtosho") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
    end
  end,
  raktisho_arm = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktisho") then
      local part = wc[3] .. "arm"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      display.Alert("You dropped " .. wc[4] .. "!")
    end
  end,
  raktisho_chest = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktisho") then
      wounds.kata("chest")
      wounds.kata_attack("chest", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("broken_chest")
      if string.find(wc[3], "ground") then
        prone()
      end
    end
  end,
  raktisho_leg = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktisho") then
      local part = wc[3] .. "leg"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      prone()
    end
  end,
  raktisho_head = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktisho") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("scrambled")
    end
  end,
  raktisho_gut = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktisho") then
      wounds.kata("gut")
      wounds.kata_attack("gut", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      stunned()
    end
  end,
  bomolsho = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomolsho") then
      local part = wc[3] .. "leg"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("hemiplegy_legs")
    end
  end,
  twist = function (wc)
    if main.attacked(wc[1], "tahtetso", "twist") then
      bleed(150)
    end
  end,
  bomirrak = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomirrak") then
      local part = wc[3] .. "arm"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("hemiplegy_" .. wc[3])
    end
  end,
  raktiahsho_gut = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktiahsho") then
      wounds.kata("gut")
      wounds.kata_attack("gut", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("severed_spine")
    end
  end,
  raktiahsho_head = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktiahsho") then
      wounds.kata("head")
      wounds.kata_attack("head", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
    end
  end,
  raktiahsho_limb1 = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktiahsho") then
      local part = wc[3] .. wc[4]
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      limb_queue(wc[3], wc[4], "mangled")
    end
  end,
  raktiahsho_limb2 = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktiahsho") then
      local part = wc[3] .. wc[4]
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      limb_queue(wc[3], wc[4], "broken")
      if wc[4] == "leg" then
        prone()
      else
        EnableTrigger("tahtetso_raktiahsho_unwield__", true)
        prompt.queue(function () EnableTrigger("tahtetso_raktiahsho_unwield__", false) end)
      end
    end
  end,
  raktiahsho_unwield = function (wc)
    display.Alert("Unwielded " .. wc[1] .. "!")
  end,
  raktiahsho_chest = function (wc)
    if main.attacked(wc[1], "tahtetso", "raktiahsho") then
      wounds.kata("chest")
      wounds.kata_attack("chest", wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      add_queue("collapsed_lungs")
    end
  end,
  bomolahsho = function (wc)
    if main.attacked(wc[1], "tahtetso", "bomolahsho") then
      local part = wc[3] .. "leg"
      wounds.kata(part)
      wounds.kata_attack(part, wc[2])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
      if string.find(wc[0], "ankle") then
        add_queue("ankle_" .. wc[3])
      end
    end
  end,
  gahtiahsho = function ()
    add_queue("chest_pain")
  end,
  gahtiraksho_fail = function (wc)
    if main.attacked(wc[2], "tahtetso", "gahtiraksho") then
      local part = string.gsub(wc[3], " ", "")
      wounds.kata(part)
      wounds.kata_attack(part, wc[1])
      wounds.kata_mods("Tahtetso")
      main.poisons_on()
    end
  end,
}

tr.tarot = {
  hangedman = function (wc)
    if main.attacked(wc[1], "tarot", "hangedman") then
      prone("roped")
    end
  end,
  fool = function (wc)
    if main.attacked(wc[1], "tarot", "fool") then
      failsafe.check("aeon", "aeon")
      failsafe.check("standing", "roped")
      --iff.lust(wc[1])
    end
  end,
  lovers = function (wc)
    if main.attacked(wc[1], "tarot", "lovers") then
      add_queue("lovers")
    end
  end,
  warrior = function ()
    if main.attacked("", "tarot", "warrior") then
      flags.damaged_health()
    end
  end,
  moon = function (wc)
    if main.attacked(wc[1], "tarot", "moon") then
      add_queue{"stupidity", "dizziness", "confusion"}
    end
  end,
  dreamer = function (wc)
    if main.attacked(wc[1], "tarot", "dreamer") then
      add_queue("dreamer")
    end
  end,
  dreamer_tick = function ()
    if main.attacked("", "tarot", "dreamer") then
      flags.damaged_mana()
      flags.damaged_ego()
    end
  end,
  judge = function (wc)
    if main.attacked(wc[1], "tarot", "judge") then
      add_queue("justice")
    end
  end,
  aeon = function (wc)
    if main.attacked(wc[1], "tarot", "aeon") then
      aeoned()
    end
  end,
  lust = function (wc)
    if main.attacked(wc[1], "tarot", "lust") then
      iff.lust(wc[1])
    end
  end,
  soulless_rub = function (wc)
    if main.attacked(wc[1], "tarot", "soulless") then
      local rubs = (flags.get("soulless_" .. wc[1]) or 0) + 1
      local plural = "S"
      if rubs == 1 then
        plural = ""
      elseif rubs > 7 then
        rubs = 7
      end
      Execute("OnDanger Soulless - " .. wc[1] .. " - " .. rubs .. " RUB" .. plural .. " OF 7")
      flags.set("soulless_" .. wc[1], rubs, 0)
    end
  end,
  soulless_fling = function (wc)
    if main.attacked(wc[1], "tarot", "soulless") then
      flags.clear("soulless_" .. wc[1])
      Execute("OnInstakill Soulless - " .. wc[1] .. " - GET OUT NOW!!")
    end
  end,
  world = function ()
    if main.attacked("", "tarot", "world") then
      defs.del_queue("shield")
    end
  end,
}

tr.telekinesis = {
  trip = function ()
    if main.attacked(nil, "telekinetics", "trip") then
      prone()
      stunned()
    end
  end,
  burst = function ()
    if main.attacked(nil, "telekinetics", "burst") then
      burst(3)
    end
  end,
  animatedagger = function ()
    if main.attacked(nil, "telekinetics", "animatedagger") then
      main.charybdon()
      display.Alert("DISRUPT the telekinetic one!")
    end
  end,
  pyre = function ()
    if main.attacked(nil, "telekinetics", "pyre") then
      add_queue("ablaze")
      flags.damaged_health()
    end
  end,
  fling = function (wc)
    if main.attacked(nil, "telekinetics", "fling") then
      if string.find(wc[1], "sailing") then
        defs.add_queue("flying")
      else
        bleed(50)
        prone{"prone", "damaged_head"}
      end
    end
  end,
  choke = function ()
    if main.attacked(nil, "telekinetics", "choke") then
      display.Warning("Telekinetic Choke!")
      blackout()
      burst(3)
      add_queue("clot_unknown")
    end
  end,
  psychicfist_limb = function (wc)
    if main.attacked(nil, "telekinetics", "psychicfist") then
      limb_queue(wc[1], wc[2], "broken")
      if wc[2] == "leg" then
        EnableTrigger("telekinetics_psychicfist_fall__", true)
        prompt.queue(function () EnableTrigger("telekinetics_psychicfist_fall__", false) end)
      end
    end
  end,
  psychicfist_body = function (wc)
    if main.attacked(nil, "telekinetics", "psychicfist") then
      if wc[1] == "ribcage" then
        add_queue("snapped_rib")
        EnableTrigger("telekinetics_psychicfist_stun__", true)
        prompt.queue(function () EnableTrigger("telekinetics_psychicfist_stun__", false) end)
      else
        add_queue("broken_jaw")
        EnableTrigger("telekinetics_psychicfist_confuse__", true)
        prompt.queue(function () EnableTrigger("telekinetics_psychicfist_confuse__", false) end)
      end
    end
  end,
  clot = function (wc)
    if main.attacked(nil, "telekinetics", "clot") then
      if wc[2] == "hip" then
        add_queue("clot_" .. wc[1] .. "leg")
      else
        add_queue("clot_" .. wc[1] .. "arm")
      end
    end
  end,
  throatlock = function ()
    if main.attacked(nil, "telekinetics", "throatlock") then
      add_queue("throat_locked")
    end
  end,
  sweat = function ()
    if main.attacked(nil, "telekinetics", "sweat") then
      add_queue("slickness")
    end
  end,
  forcefield = function (wc)
    if enemy.is_target(wc[1]) then
      display.Alert("DISRUPT the telekinetic one!")
    end
  end,
  barrier = function ()
    Execute("OnDanger Telekinetic Barrier! Disrupt the mage!")
  end,

  psychicfist_fall = function ()
    prone()
  end,
  psychicfist_confuse = function ()
    add_queue("confusion")
  end,
  psychicfist_stun = function ()
    stunned()
  end,
}

tr.telepathy = {
  affliction = function ()
    if main.attacked(nil, "telepathy", "affliction") then
      EnableTrigger("poisons_powersap__", true)
      prompt.queue(function () EnableTrigger("poisons_powersap__", false) end)
      if not is_prone() then
        failsafe.check("paralysis", "paralysis")
      end
      failsafe.check("dementia", "dementia", telepathy)
      hidden("telepathy")
    end
  end,
  psychicvampirism = function ()
    if main.attacked(nil, "telepathy", "psychicvampirism") then
      flags.damaged_ego()
      display.Warning("Psychic Vampirism! Watch ego!")
      add_queue("vampirism", "unknown")
    end
  end,
  mindblast = function (wc)
    if main.attacked(wc[1], "telepathy", "mindblast") then
      flags.damaged_ego()
      display.Warning(wc[1] .. " Mindblasting! Watch ego!")
    end
  end,
  mindblast2 = function ()
    if main.attacked(nil, "telepathy", "mindblast") then
      flags.damaged_ego()
      display.Warning("Mindblast! Watch ego!")
    end
  end,
}

tr.tracking = {
  legsnare = function ()
    if main.attacked("", "tracking", "legsnare") then
      prone{"roped", function () wounds.add("leftleg", 70) end}
    end
  end,
  springtrap = function ()
    if main.attacked("", "tracking", "springtrap") then
      stunned()
      display.Alert("Spring Trap!")
    end
  end,
  deadfall = function ()
    if main.attacked("", "tracking", "deadfall") then
      prone{"prone", "concussion"}
    end
  end,
  pit = function ()
    if main.attacked("", "tracking", "pit") then
      flags.clear("climbing_up")
      flags.set("skip_hypochondria", true)

      beast.lost()

      if not defs.has("levitating") then
        add_queue("mending_legs")
        stunned()
      end
      main.poisons_on()
    end
  end,
  bond_clamp = function (wc)
    if main.attacked("", "tracking", "clamp") then
      add_queue("clamped_" .. wc[1])
      flags.damaged_health()
      bleed(200)
    end
  end,
  darts = function ()
    if main.attacked("", "tracking", "darts") then
      main.charybdon(true)
      flags.set("skip_hypochondria", true)
    end
  end,
}

tr.transmology = {
  eyes_hypnotize = function (wc)
    if main.attacked(wc[1], "transmology", "hypnotize") then
      display.Alert("Hypnotized by " .. wc[1] .. "!")
    end
  end,
  spix_transfix = function ()
    if not (has("blindness") or defs.has("sixthsense")) and main.attacked("", "transmology", "spix") then
      add_queue("transfixed")
      if not main.auto("sixthsense") then
        Execute("auto sixthsense on")
      end
    end
  end,
  nose_slime = function (wc)
    if main.attacked(wc[1], "transmology", "slime") then
      add_queue("ectoplasm")
    end
  end,
  nose_peck = function (wc)
    if main.attacked(wc[1], "transmology", "peck") then
      flags.damaged_health()
      bleed(50)
    end
  end,
  sludgeworm = function ()
    if main.attacked("", "transmology", "sludgeworm") then
      add_queue("mucous")
    end
  end,
  sludgeworm_fall = function ()
    if main.attacked("", "transmology", "sludgeworm") then
      prone{"prone", "mucous"}
    end
  end,
  torso_block = function (wc)
    if main.attacked(wc[1], "transmology", "block") then
      prone("entangled")
    end
  end,
  morrible = function ()
    if main.attacked("", "transmology", "morrible") then
      add_queue("focus_mind")
    end
  end,
  hands_claw = function (wc)
    if main.attacked(wc[1], "transmology", "claw") then
      main.charybdon()
      bleed(70)
    end
  end,
  hands_crush = function (wc)
    if main.attacked(wc[1], "transmology", "crush") then
      flags.damaged_health()
      bleed(70)
    end
  end,
  throat_scream = function (wc)
    if main.attacked(wc[1], "transmology", "scream") then
      stunned()
    end
  end,
  throat_croak = function ()
    EnableTrigger("transmology_throat_croaked__", true)
    prompt.queue(function () EnableTrigger("transmology_throat_croaked__", false) end)
  end,
  throat_croaked = function ()
    if main.attacked("", "transmology", "croak") then
      flags.damaged_health()
    end
  end,
  hekoskeri = function ()
    if main.attacked("", "transmology", "hekoskeri") then
      add_queue("sluggish")
    end
  end,
  mouth_bite = function (wc)
    if main.attacked(wc[1], "transmology", "bite") then
      flags.damaged_health()
    end
  end,
  madfly = function (wc)
    if main.attacked(wc[1], "transmology", "madfly") then
      flags.set("madfly", true, 120)
    end
  end,
  madfly_insanity = function ()
    if flags.get("madfly") then
      insanity(10)
      EnableTrigger("transmology_madfly_gone__", true)
      prompt.queue(function () EnableTrigger("transmology_madfly_gone__", false) end)
    end
  end,
  madfly_gone = function ()
    flags.clear("madfly")
  end,
  aura_psychedelia = function (wc)
    if main.attacked(wc[1], "transmology", "psychedelia") then
      add_queue("pennyroyal")
    end
  end,
  champion_mob1 = function ()
    if main.attacked("", "transmology", "champion") then
      add_queue("stupidity")
    end
  end,
  champion_mob2 = function ()
    if main.attacked("", "transmology", "champion") then
      prone("entangled")
    end
  end,
  champion_mob3 = function ()
    if main.attacked("", "transmology", "champion") then
      flags.damaged_health()
    end
  end,
  champion_mob4 = function ()
    if main.attacked("", "transmology", "champion") then
      flags.damaged_mana()
    end
  end,
  homunculus1 = function ()
    if main.attacked("homunculus", "paradigmatics", "badluck") then
      insanity(3)
      add_queue("bad_luck")
    end
  end,
  homunculus2 = function ()
    if main.attacked("homunculus", "transmology", "bite") then
      insanity(7)
      flags.damaged_health()
    end
  end,
  homunculus3 = function ()
    if main.attacked("homunculus", "paradigmatics", "greywhispers") then
      insanity(3)
      add_queue("grey_whispers", 16)
    end
  end,
  throat_sing1 = function ()
    Execute("OnDanger Transmology Summon! MOVE!")
  end,
  throat_sing2 = function ()
    Execute("OnDanger You were SUMMONED!")
  end,
}

tr.wicca = {
  barghest = function ()
    if main.attacked("", "wicca", "barghest") then
      prone("paralysis")
    end
  end,
  pigwidgeon = function ()
    if main.attacked("", "wicca", "pigwidgeon") then
      flags.set("pigwidgeon", true, 60)
    end
  end,
  pigwidgeon_move = function ()
    if main.attacked("", "wicca", "pigwidgeon") then
      flags.set("pigwidgeon", true, 60)
      prone()
    end
  end,
  redcap = function ()
    if main.attacked("", "wicca", "redcap") then
      bleed(250)
    end
  end,
  banshee = function ()
    if main.attacked("", "wicca", "banshee") then
      display.Alert("Watch Mana!")
      flags.set("mana_careful", true, 60)
      flags.damaged_mana()
    end
  end,
  willowisp = function ()
    if main.attacked("", "wicca", "willowisp") then
      Execute("OnDanger Willowisp Summon started!")
    end
  end,
  willowisp_done = function ()
    if main.attacked("", "wicca", "willowisp") then
      Execute("OnDanger WILLOWISP SUMMONED!")
    end
  end,
  crone = function ()
    if main.attacked("", "wicca", "crone") then
      if not (defs.has("sixthsense") or has("blindness")) then
        prompt.illqueue(function ()
          if not prompt.stat("blind") then
            affs.hidden("crone")
            failsafe.check("eating", "anorexia")
          end
        end, "croned")
      else
        if defs.has("sixthsense") then
          failsafe.check("blind", "blindness")
        end
        hidden("crone")
        failsafe.check("eating", "anorexia")
      end
    end
  end,
  slaugh = function ()
    if main.attacked("", "wicca", "slaugh") then
      add_queue{"liniment", "choleric"}
      failsafe.check("paranoia", "paranoia")
    end
  end,
  patchou_aeon = function ()
    if main.attacked("", "wicca", "patchou") then
      aeon()
    end
  end,
  patchou_manadrain = function ()
    if main.attacked("", "wicca", "patchou") then
      flags.damaged_mana()
    end
  end,
  blackshuck_aeon = function ()
    if main.attacked("", "wicca", "blackshuck") then
      aeon()
    end
  end,
  blackshuck_black_lung = function ()
    if main.attacked("", "wicca", "blackshuck") then
      add_queue("black_lung")
    end
  end,
  blackshuck_paralysis = function ()
    if main.attacked("", "wicca", "blackshuck") then
      prone("paralysis")
    end
  end,
  toadcurse = function (wc)
    if main.attacked(wc[1], "wicca", "toadcurse") then
      Execute("OnDanger Toadcurse - GET OUT NOW!!")
      reset()
      defs.reset()
      wounds.reset()
      if not main.is_paused() then
        flags.set("toad_pause", true, 0)
        main.pause()
      end
    end
  end,
  untoaded = function ()
    display.Alert("Not a Toad!")
    if flags.get("toad_pause") then
      main.unpause()
      flags.clear("toad_pause")
    end
  end,
}

local wa_spirits = 0
tr.wildarrane = {
  singing = function (wc)
    for t in ipairs{"0", "1", "3", "4", "5"} do
      EnableTrigger("wildarrane_cairnlargo" .. t .. "__", true)
    end
    prompt.queue(function () EnableTriggerGroup("SongEffects", false) end, "unsung")
    flags.set("singer", wc[1])
  end,
  singing2 = function (wc)
    EnableTrigger("wildarrane_cairnlargo2__", true)
    prompt.queue(function () EnableTrigger("wildarrane_cairnlargo2__", false) end)
    flags.set("singer", wc[1])
  end,
  ancientcurse = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "wildarrane", "ancientcurse") then
      prone("paralysis")
      add_queue("focus_mind")
    end
  end,
  naturerhythm = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "wildarrane", "naturerhythm") then
      flags.damaged_health()
    end
  end,
  ancientfeud = function (wc)
    if not (has("deafness") or defs.has("truehearing")) and main.attacked(wc[1], "wildarrane", "ancientfeud") then
      flags.damaged_health()
    end
  end,
  ancientfeud_movement = function ()
    if not (has("deafness") or defs.has("truehearing")) and main.attacked("", "wildarrane", "ancientfeud") then
      display.Alert("Movement blocked!")
    end
  end,
  cairnlargo0 = function (wc)
    if main.attacked(wc[1] or flags.get("singer") or "", "wildarrane", "cairnlargo") then
      wa_spirits = math.min(wa_spirits + 1, 5)
    	prompt.illqueue(function () display.Warning("CAIRNLARGO! " .. wa_spirits .. " of 5 SPIRITS!") end, "wa_spirits")
    end
  end,
  cairnlargo1 = function ()
    if main.attacked(flags.get("singer") or "", "wildarrane", "cairnlargo") then
      prone("shackled")
      wa_spirits = math.max(wa_spirits - 1, 0)
    end
  end,
  cairnlargo2 = function (wc)
    if main.attacked(wc[1] or flags.get("singer") or "", "wildarrane", "cairnlargo") then
      enemy.reset()
      display.Alert("Summoned by " .. wc[1] .. "!")
      wa_spirits = math.max(wa_spirits - 2, 0)
    end
  end,
  cairnlargo3 = function ()
    if main.attacked(flags.get("singer") or "", "wildarrane", "cairnlargo") then
      flags.damaged_health()
      wa_spirits = math.max(wa_spirits - 3, 0)
    end
  end,
  cairnlargo4 = function ()
    if main.attacked(flags.get("singer") or "", "wildarrane", "cairnlargo") then
      add_queue("transfixed")
      hidden("hidden_mental", (has("hidden_mental") or 0) + 2)
      main.diag()
      wa_spirits = math.max(wa_spirits - 4, 0)
    end
  end,
  cairnlargo5 = function ()
    if main.attacked(flags.get("singer") or "", "wildarrane", "cairnlargo") then
      if defs.has("fire") then
        defs.del_queue("fire")
        add_queue("shivering")
      elseif has("shivering") then
        prone("frozen")
      else
        prone{"frozen", "shivering"}
      end
      stunned()
      flags.damaged_health()
      wa_spirits = math.max(wa_spirits - 5, 0)
    end
  end,
  cairnlargo_recall = function (wc)
    local convert = {
      one = 1,
      two = 2,
      three = 3,
      four = 4,
      five = 5,
      six = 6,
      seven = 7,
      eight = 8,
      nine = 9,
      ten = 10,
    }
    wa_spirits = math.max(wa_spirits - (convert[wc[1]] or 0), 0)
  end,
}

tr.wildewood = {
  barktouch = function (wc)
    if main.attacked(wc[1], "wildewood", "barktouch") then
      flags.damaged_health()
    end
  end,
  bluebell = function (wc)
    if main.attacked(wc[1], "wildewood", "bluebell") then
      failsafe.check("blind", "blindness", function () affs.add("faeriefire") end)
    end
  end,
  knobbled = function (wc)
    if main.attacked(wc[1], "wildewood", "knobbled") then
      failsafe.check("standing", "broken_leg", function () affs.add("broken_arm") end)
    end
  end,
  hornedlily = function (wc)
    if main.attacked(wc[1], "wildewood", "hornedlily") then
      failsafe.check("standing", nil, function () affs.add("broken_arm") end)
    end
  end,
  moontear = function (wc)
    if main.attacked(wc[1], "wildewood", "moontear") then
      add_queue("fractured_head")
    end
  end,
  bluehorn = function (wc)
    flags.set("wildewooder", wc[1])
    EnableTrigger("wildewood_bluehorn2__", true)
    prompt.queue(function () EnableTrigger("wildewood_bluehorn2__", false) end)
  end,
  bluehorn2 = function ()
    if main.attacked(flags.get("wildewooder") or "", "wildewood", "bluehorn") then
      add_queue("succumb")
      flags.damaged_mana()
    end
  end,
  garland = function (wc)
    if main.attacked(wc[1], "wildewood", "garland") then
      flags.damaged_health()
    end
  end,
  hartpine = function (wc)
    flags.set("wildewooder", wc[1])
    EnableTrigger("wildewood_hartpine2__", true)
    prompt.queue(function () EnableTrigger("wildewood_hartpine2__", false) end)
  end,
  hartpine2 = function ()
    if main.attacked(flags.get("wildewooder") or "", "wildewood", "hartpine") then
      add_queue("manabarbs")
    end
  end,
  faeblossom = function (wc)
    if main.attacked(wc[1], "wildewood", "faeblossom") then
      add_queue("slickness")
    end
  end,
  gossamer = function (wc)
    if main.attacked(wc[1], "wildewood", "gossamer") then
      add_queue("clumsiness")
    end
  end,
  flowerpower = function (wc)
    flags.set("wildewooder", wc[1])
    EnableTrigger("wildewood_flowerpower2__", true)
    prompt.queue(function () EnableTrigger("wildewood_flowerpower2__", false) end)
  end,
  flowerpower2 = function ()
    if main.attacked(flags.get("wildewooder") or "", "wildewood", "flowerpower") then
      prone("paralysis")
      failsafe.check("standing", nil, function () affs.add("broken_arm") end)
    end
  end,
  treehug = function (wc)
    if main.attacked(wc[1], "wildewood", "treehug") then
      limb_queue(wc[2], wc[3])
      flags.damaged_health()
    end
  end,
  flowering = function (wc)
    if main.attacked(wc[1], "wildewood", "flowering") then
      prone()
    end
  end,
  mossy = function (wc)
    if main.attacked(wc[1], "wildewood", "mossy") then
      prone("paralysis")
    end
  end,
  glinshari = function (wc)
    flags.set("wildewooder", wc[1])
    EnableTrigger("wildewood_glinshari2__", true)
    prompt.queue(function () EnableTrigger("wildewood_glinshari2__", false) end)
  end,
  glinshari2 = function ()
    if main.attacked(flags.get("wildewooder") or "", "wildewood", "glinshari") then
      stunned()
      flags.damaged_health()
    end
  end,
  wildecall_wolverine = function (wc)
    if main.attacked(wc[1], "wildewood", "wildecall") then
      bleed(100)
    end
  end,
  wildecall_treefrog = function (wc)
    main.attacked(wc[1], "wildewood", "wildecall")
  end,
}

tr.wyrdenwood = {
  oozing = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "oozing") then
      add_queue("dysentery")
    end
  end,
  pepper = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "pepper") then
      add_queue("masochism")
    end
  end,
  worm = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "worm") then
      add_queue("worms")
    end
  end,
  blood = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "blood") then
      failsafe.check("bleeding")
    end
  end,
  insect = function ()
    EnableTrigger("wyrdenwood_insect2__", true)
    prompt.queue(function () EnableTrigger("wyrdenwood_insect2__", false) end)
  end,
  insect2 = function ()
    if main.attacked("", "wyrdenwood", "insect") then
      add_queue{"dysentery", "masochism"}
      flags.damaged_health()
    end
  end,
  wasp = function ()
    EnableTrigger("wyrdenwood_wasp2__", true)
    prompt.queue(function () EnableTrigger("wyrdenwood_wasp2__", false) end)
  end,
  wasp2 = function ()
    if main.attacked("", "wyrdenwood", "wasp") then
      prone("paralysis")
      failsafe.check("bleeding")
      flags.damaged_health()
    end
  end,
  hornet = function ()
    EnableTrigger("wyrdenwood_hornet2__", true)
    prompt.queue(function () EnableTrigger("wyrdenwood_hornet2__", false) end)
  end,
  hornet2 = function ()
    if main.attacked("", "wyrdenwood", "hornet") then
      add_queue("black_lung")
      flags.damaged_health()
    end
  end,
  creeping = function ()
    EnableTrigger("wyrdenwood_creeping2__", true)
    prompt.queue(function () EnableTrigger("wyrdenwood_creeping2__", false) end)
  end,
  creeping2 = function ()
    if main.attacked("", "wyrdenwood", "creeping") then
      stunned()
      failsafe.check("bleeding")
      flags.damaged_health()
    end
  end,
  vine_noose = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "noose") then
      failsafe.check("bleeding")
      add_queue("entangled")
    end
  end,
  vine_noose_dir = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "noose") then
      failsafe.check("bleeding")
      add_queue("entangled")
      display.Warning("Noose from the " .. string.upper(wc[2]) .. " (" .. wc[1] .. ")")
    end
  end,
  deadened = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "deadened") then
      add_queue("repugnance")
    end
  end,
  razor = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "razor") then
      failsafe.check("bleeding")
    end
  end,
  thorny = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "thorny") then
      add_queue("hemophilia")
    end
  end,
  tangled = function (wc)
    if main.attacked(wc[1], "wyrdenwood", "tangled") then
      prone("entangled")
    end
  end,
}

function process(name, line, wildcards, styles)
  local sk, af = string.match(name, "^(%w+)_(.-)__")
  if not sk or not af or not tr or not tr[sk] or not tr[sk][af] then
    display.Error("No trigger function for affliction '" .. tostring(af) .. "' in skill '" .. tostring(sk) .. "' [" .. name .. "]")
    return
  end
  tr[sk][af](wildcards)
end


for _,a in ipairs{"love"} do
  local v = GetVariable("sg1_aff_" .. a)
  if v == "1" then
    add_queue(a)
  end
end

DeleteTrigger("glamours_rainbows_done")
