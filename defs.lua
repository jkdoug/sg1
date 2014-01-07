module (..., package.seeall)

require "flags"
require "scan"

local current = {}
local domoths = {}

local qadd = {}
local qdel = {}
local qwant = {}

defq = {
  weathering = "free",
  insomnia = "free",
  nightsight = "free",
  resistance = "free",
  gripping = "free",
  thirdeye = "free",
  speed = "free",
  perfection = "free",
  kingdom = "free",
  mercy = "free",
  beauty = "free",
  combatstyle = "free",
  charismaticaura = "free",
  stance = "free",
  adroitness = "free",
  elasticity = "free",
  falling = "free",
  bardicpresence = "free",
  regeneration = "free",
  boosting = "free",

  kafe = "herb",
  truehearing = "herb",
  sixthsense = "herb",

  fire = "elixir",
  frost = "elixir",
  galvanism = "elixir",
}

commands = {
  protection = "read protection",
  kafe = "eat kafe",
  truehearing = "eat earwort",
  sixthsense = "eat faeleaf",
  fire = "sip fire",
  frost = "sip frost",
  galvanism = "sip galvanism",
  throne = "throne",

  -- Acrobatics
  hyperventilating = "hyperventilate",
  limber = "limber",
  elasticity = "elasticity",
  falling = "falling",
  balancing = "balancing on",
  adroitness = "adroitness",
  avoid = "avoid",
  tripleflash = "tripleflash",

  -- Athletics
  breathing = "breathe deep",
  consciousness = "consciousness on",
  constitution = "constitution",
  immunity = "immunity",
  speed = "adrenaline",
  strength = "flex",
  regeneration = "regeneration on",
  boosting = "boost regeneration",
  resistance = "resistance",
  sturdiness = "stand firm",
  surging = "surge",
  vitality = "vitality",
  weathering = "weathering",

  -- Cavalier
  guard = "guard self",
  recovery = "recover strikes",

  -- Combat
  keeneye = "keeneye on",
  stance = "stance legs",

  -- Discernment
  aethersight = "aethersight on",
  deathsense = "deathsense",
  lipreading = "lipread",
  nightsight = "nightsight",
  thirdeye = "thirdeye",

  -- Discipline
  insomnia = "insomnia",
  metawake = "metawake on",

  -- Dramatics
  performance = "performance on",
  role = "perform sycophant",
  wounded = "perform wounded",
  sober = "perform sober",
  drunkard = "perform drunkard",
  attitude = "attitude saintly",
  diplomat = "perform diplomat",

  -- Dramaturgy
  etiquette = "drama etiquette",
  foppery = "drama foppery",

  -- Dreamweaving
  control = "dreamweave control",

  -- Druidry
  deflect = "twirl cudgel",

  -- Enchantments
  acquisitio = "rub acquisitio",
  avarice = "blow avaricehorn",
  beauty = "rub beauty",
  deathsight = "rub deathsight",
  kingdom = "rub kingdom",
  levitating = "rub levitate",
  mercy = "rub mercy",
  nimbus = "rub nimbus",
  perfection = "rub perfection",
  waterbreathing = "rub waterbreathe",
  waterwalking = "rub waterwalk",

  -- Environment
  attuned = "attune",

  -- Glamours
  illusoryself = "weave illusoryself",

  -- Healing
  aura_vitality = "radiate vitality",
  aurasense = "aurasense on",

  -- Highmagic
  shroud = "evoke yesod",
  geburah = "evoke geburah",
  netzach = "evoke netzach",
  hod = "evoke hod",
  greatpentagram = "evoke greatpentagram",

  -- Hunting
  camouflage = "camouflage on",

  -- Illusions
  blur = "weave blur",

  -- Influence
  charismaticaura = "charismaticaura on",

  -- Knighthood
  combatstyle = "combatstyle concentrated",
  gripping = "grip",

  -- Lowmagic
  roots = "invoke red",
  blue = "invoke blue",
  autumn = "invoke autumn",
  orange = "invoke orange",
  yellow = "invoke yellow",

  -- Moon
  drawdown = "moondance drawdown",
  shine = "moondance shine",
  moonaura = "moondance aura",
  harvest = "moondance harvest",

  -- Music
  bardicpresence = "bardicpresence on",

  -- Nature
  blend = "nature blend on",
  barkskin = "nature barkskin",
  rooting = "nature rooting",

  -- Shamanism
  weatherguard = "manipulate weatherguard",

  -- Stag
  stagform = "stagform",
  bolting = "bolting on",
  staghide = "staghide",
  greenman = "paint face greenman",
  ringwalk = "ringwalk",
  trueheart = "paint face trueheart",
  lightning = "paint face lightning",
  swiftstripes = "paint face swiftstripes",

  -- Totems
  nature = "spiritbond nature",  -- Fuck individual totem spirits!

  -- Tracking
  poisonexpert = "focus poisons",

  -- Wicca
  channels = "open channels",
}

local domoth_effects =
{
  Nature = {
    minor = "Double growth rate for an herb",
    lesser = "Increase an herb's room maximum, skip hibernation",
    major = "One herb has the sparkleberry effect"
  },
  Knowledge = {
    minor = "+2 intelligence for your race",
    lesser = "10 Magic DMP for your guild",
    major = "Increased power/culture for scholars"
  },
  Beauty = {
    minor = "+2 charisma for your race",
    lesser = "Increased influence damage for your guild",
    major = "Increased power/culture for bards"
  },
  Chaos = {
    minor = "+3 to a random stat for your race",
    lesser = "Random regeneration for your guild",
    major = "Increased resistance to astral insanity"
  },
  Harmony = {
    minor = "Increased experience gain for your race",
    lesser = "Decreased experience loss for your guild",
    major = "Double the dross power limit"
  },
  Justice = {
    minor = "Increased willpower for your race",
    lesser = "Aura of justice for your guild",
    major = "Increased damage from discretionary powers"
  },
  War = {
    minor = "+2 strength for your race",
    lesser = "Increased attack damage for your guild",
    major = "Increased level of guards"
  },
  Life = {
    minor = "+2 constitution for your race",
    lesser = "Decreased damage received for your guild",
    major = "Health regeneration on Prime non-enemy grounds"
  },
  Death = {
    minor = "Increased endurance for your race",
    lesser = "Aura of vengeance for your guild",
    major = "Catacombs of the Dead map at the nexus"
  }
}


function add(name, val)
  if type(name) == "table" then
    for _,def in pairs(name) do
      add(def, val)
    end
    return
  end

  local val = val or true
  if not current[name] then
    display.Debug("Defense added - " .. name .. " (" .. tostring(val) .. ")", "defs")
    flags.clear{"last_cure", "slow_going"} -- TODO: don't want to clear slow_going for speed/rebounding
    scan.update = true
  end

  current[name] = val
  progress(name)
end

function del(name)
  if type(name) == "table" then
    for _,def in pairs(name) do
      del(def, val)
    end
    return
  end

  if current[name] ~= nil then
    display.Debug("Defense removed - " .. name, "defs")
    flags.clear("last_cure")
    scan.update = true
  end

  current[name] = nil
end

function add_queue(name, val)
  if type(name) == "table" then
    for _,def in pairs(name) do
      add_queue(def, val)
    end
    return
  end

  local val = val or true
  if has(name) == val then
    return
  end

  display.Debug("Queued defense '" .. name .. "' (" .. tostring(val) .. ")", "defs")
  qadd[name] = val
  qdel[name] = nil
end

function del_queue(name)
  if type(name) == "table" then
    for _,def in pairs(name) do
      del_queue(def)
    end
    return
  end

  if not has(name) then
    return
  end

  display.Debug("Queued defense removal '" .. name .. "'", "defs")
  qadd[name] = nil
  qdel[name] = true
end

function clear_queue()
  qadd = {}
  qdel = {}
  display.Debug("Defense queues cleared", "defs")
end


function domoth(realm, lvl)
  domoths[realm] = domoths[realm] or {}
  table.insert(domoths[realm], lvl)
  display.Debug("Defense added - domoth " .. realm .. " (" .. lvl .. ")", "defs")
end


function has(name)
  return current[name] or false
end

function coming(name)
  return qadd[name] or false
end

function going(name)
  return qdel[name] or false
end


function reset()
  current = {}
  domoths = {}
  display.Debug("Defenses cleared", "defs")
  scan.update = true
  clear_queue()
end

function reset_death()
  local keepers = {
    aethersight = true,
    drawdown = true,
    moonchilde = true,
    shine = true,
    shroud = true,
    stagform = true,
    wings = true
  }

  for d in pairs(current) do
    if not keepers[d] then
      current[d] = nil
    end
  end

  scan.update = true
  clear_queue()
end


local function wantadd(name)
  if has(name) then
    return
  end

  if not commands[name] then
    display.Error("Unfamiliar defense name: " .. name)
    return
  end

  local q = defq[name] or "bal"
  qwant[q] = qwant[q] or {}
  table.insert(qwant[q], name)

  display.Debug("Defense '" .. name .. "' wanted on '" .. q .. "'", "defs")
end

function show_wanted()
  local color_cat = "darkcyan"
  local color_def = "silver"

  display.Prefix()
  ColourNote("white", "", "Defenses Wanted Report:")
  local f = false
  for qn,qd in pairs(qwant) do
    f = true
    display.Prefix()
    ColourNote(color_cat, "", " Queue - " .. qn .. " [" .. #qd .. "]")
    display.Prefix()
    ColourNote(color_def, "", "   " .. table.concat(qd, ", "))
  end
  if not f then
    display.Prefix()
    ColourNote("dimgray", "", "  Nothing in the queues")
  end

  if IsConnected() then
    Send("")
  end
end

function want(name)
  qwant = {}
  flags.clear{"defs_free", "defs_bal", "defs_herb", "defs_elixir", "defs_sub", "defs_super", "defs_id"}

  if not name then
    display.Info("Defense sequence aborted")
    return
  end

  if type(name) == "table" then
    for _,n in ipairs(name) do
      wantadd(n)
    end
    scan.process()
    return
  end

  wantadd(name)
  scan.process()
end

function wanted(bal)
  if not bal then
    local c = 0
    for _,b in ipairs{"free", "bal", "herb", "elixir", "sub", "super", "id"} do
      c = c + wanted(b)
    end
    return c
  end
  return table.getn(qwant[bal] or {})
end

function progress(name)
  local q = defq[name] or "bal"
  for i,d in ipairs(qwant[q] or {}) do
    if d == name then
      if q ~= "free" then
        flags.clear{"defs_" .. q, "scanned_defup_" .. q}
      end
      table.remove(qwant[q], i)
      if table.getn(qwant[q]) < 1 then
        qwant[q] = nil
        return
      end
      scan.update = true
      return
    end
  end
end

function exec(name, line, wildcards, styles)
  local q = wildcards[1] or "bal"

  if not defs.has("vitality") then
    for _,d in ipairs(qwant.bal or {}) do
      if d == "vitality" then
        local cmd = commands[d] or d
        if able.to(cmd) then
          if q == "free" then
            return
          elseif q == "bal" then
            Execute(cmd)
            return
          end
        end
        break
      end
    end
  end

  if q == "free" then
    for _,d in ipairs(qwant[q] or {}) do
      local cmd = commands[d] or d
      if able.to(cmd) then
        flags.set("defs_" .. q, true, 2)
        Execute(cmd)
      end
    end
  else
    for _,d in ipairs(qwant[q] or {}) do
      local cmd = commands[d] or d
      if able.to(cmd) then
        flags.set("defs_" .. q, true, 2)
        Execute(cmd)
        return
      end
    end
  end
end


function OnPrompt()
  for a,v in pairs(qadd) do
    add(a, v)
  end
  for a in pairs(qdel) do
    del(a)
  end
  qadd = {}
  qdel = {}
end



function build_defs()
  local bd = {
    ["Beastmastery"] = { "mounted" },
    ["Combat"] = { "keeneye", "stance" },
    ["Discernment"] = { "aethersight", "deathsense", "lipreading", "nightsight", "powermask", "thirdeye" },
    ["Discipline"] = { "held_breath", "insomnia", "metawake", "selfish" },
    ["Dramatics"] = { "attitude", "drunkard", "performance", "role", "sober", "wounded" },
    ["Enchantments"] = { "acquisitio", "avarice", "beauty", "deathsight", "kingdom", "levitating", "mercy", "nimbus", "perfection", "protection", "waterbreathing", "waterwalking" },
    ["Environment"] = { "attuned" },
    ["Influence"] = { "charismaticaura" },
  }

  if main.has_skill("athletics") then
    bd["Athletics"] = { "boosting", "breathing", "consciousness", "constitution", "immunity", "regeneration", "resistance", "strength", "sturdiness", "surging", "vitality", "weathering" }
  end
  if main.has_skill("knighthood") then
    if main.has_skill("cavalier") then
      bd["Knighthood"] = { "gripping", "guard", "hook", "recovery", "combatstyle" }
    else
      bd["Knighthood"] = { "gripping", "combatstyle" }
    end
  end
  if main.has_skill("moon") then
    bd["Moon"] = { "drawdown", "harvest", "moonaura", "shine" }
  end
  if main.has_skill("stag") then
    bd["Stag"] = { "bolting", "greenman", "lightning", "ringwalk", "stagform", "staghide", "swiftstripes", "trueheart" }
  end
  if main.has_skill("lowmagic") then
    bd["Lowmagic"] = { "autumn", "blue", "orange", "roots", "serpent", "yellow" }
  end
  if main.has_skill("highmagic") then
    bd["Highmagic"] = { "geburah", "greatpentagram", "hod", "netzach", "roots", "shroud" }
  end
  if main.has_skill("runes") then
    bd["Runes"] = { "runicamulet" }
  end
  if main.has_skill("acrobatics") then
    bd["Acrobatics"] = { "adroitness", "avoid", "balancing", "elasticity", "falling", "hyperventilating", "limber" }
  end
  if main.has_skill("music") then
    bd["Music"] = { "bardicpresence" }
  end
  if main.has_skill("Dramaturgy") then
    bd["Dramaturgy"] = { "etiquette", "foppery" }
  end
  if main.has_skill("hunting") then
    bd["Hunting"] = { "camouflage" }
  end
  if main.has_skill("tracking") then
    bd["Tracking"] = { "poisonexpert" }
  end
  if main.has_skill("illusions") then
    bd["Illusions"] = { "blur" }
  end
  if main.has_skill("glamours") then
    bd["Glamours"] = { "glamour", "illusoryself" }
  end
  if main.has_skill("nature") then
    bd["Nature"] = { "blend", "barkskin", "rooting" }
  end
  if main.has_skill("druidry") then
    bd["Druidry"] = { "deflect" }
  end
  if main.has_skill("dreamweaving") then
    bd["Dreamweaving"] = { "control" }
  end
  if main.has_skill("wicca") then
    bd["Wicca"] = { "channels" }
  end
  if main.has_skill("healing") then
    bd["Healing"] = { "aura_vitality", "aurasense" }
  end

  for _,s in ipairs{"antlers", "bumblebee", "burning_censer", "crocodile", "dolphin", "dragon", "glacier", "lion", "skull", "spider", "twin_crystals", "volcano"} do
    if has(s) then
      bd["Astrology"] = bd["Astrology"] or {}
      table.insert(bd["Astrology"], s)
    end
  end
  return bd
end

function show(num)
  local my_defs = build_defs()

  local color_cat = "lime"
  local color_def = "forestgreen"
  local color_x = "yellow"
  local col = 1
  local ncols = tonumber(GetVariable("sg1_option_defcols") or "3")
  local unprinted = {}
  for k,v in pairs(current) do
    unprinted[k] = true
  end
  local doms = false
  for _ in pairs(domoths) do
    doms = true
    break
  end
  display.Prefix()
  ColourTell("white", "", "Defense Status Report")
  if type(num) ~= "string" then
    ColourTell("silver", "", " (" .. tostring(num) .. ")")
  end
  ColourNote("white", "", ":")
  for skill,ab in pairs(my_defs) do
    if skill ~= "Miscellaneous" then
      display.Prefix()
      ColourNote(color_cat, "", " " .. skill)
      for _,def in pairs(ab) do
        if col == 1 then
          display.Prefix()
        end
        local val = has(def)
        ColourTell("darkgray", "", "   [")
        if val ~= false then
          ColourTell(color_x, "", "X")
        else
          Tell(" ")
        end
        ColourTell("darkgray", "", "] ")

        local name = ""
        if val == true or val == false then
          name = string.format("%-25s", def)
        else
          name = string.format("%-25s", def .. " - " .. tostring(val))
        end
        ColourTell(color_def, "", name)
        unprinted[def] = nil
        col = col + 1
        if col == ncols + 1 then
          Note("")
          col = 1
        end
      end
    end
    if col > 1 then
      Note("")
    end
    col = 1
  end
  if domoths and doms then
    display.Prefix()
    ColourNote(color_cat, "", " Domoth Blessings")
    for realm,strs in pairs(domoths) do
      for _,str in pairs(strs) do
        display.Prefix()
        ColourTell("darkgray", "", "   [")
        ColourTell(color_x, "", "X")
        ColourTell("darkgray", "", "] ")

        ColourNote(color_def, "", realm .. " - " .. str .. " - " .. domoth_effects[realm][str])
      end
    end
  end
  for _,def in pairs(my_defs["Miscellaneous"] or unprinted) do
    display.Prefix()
    ColourNote(color_cat, "", " Miscellaneous")
    break
  end
  col = 1
  if my_defs["Miscellaneous"] then
    for _,def in pairs(my_defs["Miscellaneous"]) do
      local val = has(def)
      if col == 1 then
        display.Prefix()
      end
      ColourTell("darkgray", "", "   [")
      if val ~= false then
        ColourTell(color_x, "", "X")
      else
        Tell(" ")
      end
      ColourTell("darkgray", "", "] ")

      local name = ""
      if val == true or val == false then
        name = string.format("%-25s", def)
      else
        name = string.format("%-25s", def .. " - " .. tostring(val))
      end
      ColourTell(color_def, "", name)
      unprinted[def] = nil
      col = col + 1
      if col == ncols + 1 then
        Note("")
        col = 1
      end
    end
  end
  for def in pairs(unprinted) do
    if col == 1 then
      display.Prefix()
    end
    ColourTell("darkgray", "", "   [")
    ColourTell(color_x, "", "X")
    ColourTell("darkgray", "", "] ")

    local val = has(def)
    if val == true then
        name = string.format("%-25s", def)
      else
        name = string.format("%-25s", def .. " - " .. tostring(val))
    end
    ColourTell(color_def, "", name)
    col = col + 1
    if col == ncols + 1 then
      Note("")
      col = 1
    end
  end

  if IsConnected() and type(num) == "string" then
    Send("")
  else
    Note("")
  end
end


function start(name, line, wildcards, styles)
  local nat = has("nature")
  reset()
  if nat then
    add("nature")
  end
  failsafe.disable("def")
  EnableTriggerGroup("DEF", true)
end

function done(name, line, wildcards, styles)
  EnableTriggerGroup("DEF", false)
  show(tonumber(wildcards[1]))
end

function up(name, line, wildcards, styles)
  local d = string.match(name, "^defup_([%a%_]-)__$")
  if d then
    add_queue(d)
  else
    d = string.match(name, "^def_([%a%_]-)__$")
    if d then
      add(d)
    end
  end
end

function down(name, line, wildcards, styles)
  local d = string.match(name, "^defdown_([%a%_]-)__$")
  if d then
    del_queue(d)
  end
end


for _,d in ipairs{"immune", "immunity", "moonchilde", "shroud", "wings"} do
  local v = GetVariable("sg1_def_" .. d)
  if v == "1" then
    add(d)
  elseif v ~= nil then
    add(d, v)
  end
end
