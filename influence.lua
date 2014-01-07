module (..., package.seeall)

require "main"

attacks = {
  charity = { "begging", "supplication", "wheedling" },
  empower = { "compliments", "admiration", "praise" },
  weaken = { "teasing", "mockery", "derision" },
  paranoid = { "rumours", "distrust", "conspiracies" },
  seduce = { "flattery", "charm", "beguiling" },
  village = { "lectures", "recitation", "oration" },
  amnesty = { "amnesty" },
}

local immune = {
  brave = "weaken",
  friendly = "paranoid",
  intimidating = "seduce",
  sensual = "empower",
  avaricious = "charity",
}
local vulnerable = {
  brave = "empower",
  friendly = "charity",
  intimidating = "paranoid",
  sensual = "seduce",
  avaricious = "weaken",
}

local amnesty_target = false

local my_influences = main.bootstrap("influences") or {}

function sway(targ, att)
  local attack = string.lower(att or GetVariable("sg1_influence_attack") or "charity")
  local methods = attacks[attack]
  if not methods then
    display.Error("Invalid influencing category. Valid options are: charity, empower, weaken, paranoid, seduce, village")
    return
  end
  SetVariable("sg1_influence_attack", attack)

  local index = tonumber(GetVariable("sg1_influence_index") or "0")
  local c = 0
  while c < 3 do
    index = (index % table.getn(methods)) + 1
    if main.has_ability("influence", methods[index]) then
      break
    end
    c = c + 1
  end
  SetVariable("sg1_influence_index", index)

  if methods[index] == "amnesty" and amnesty_target then
    Execute("do1 influence " .. targ .. " with amnesty for " .. amnesty_target)
  else
    Execute("do1 influence " .. targ .. " with " .. methods[index])
  end
end

function set(att)
  if not att or not attacks[string.lower(att)] then
    display.Error("Invalid influencing category. Valid options are: charity, empower, weaken, paranoid, seduce, village")
    return
  end

  SetVariable("sg1_influence_attack", string.lower(att))
  SetVariable("sg1_influence_index", 0)

  main.info("influence_attack")

  display.Info("Influencing method: " .. GetVariable("sg1_influence_attack"))
  if IsConnected() then
    Send("")
  end
end

function analyze(name, line, wildcards, styles)
  local targ = string.gsub(string.gsub(string.gsub(wildcards[1], "^(A )", "a "), "^(An )", "an "), "^(The )", "the ")
  local personality = wildcards[2]
  local busy = string.find(wildcards[3], "currently laidback") == nil
  local personalities = {
    ["has a brave soul"] = "brave",
    ["displays a friendly disposition"] = "friendly",
    ["possesses an intimidating demeanor"] = "intimidating",
    ["enjoys an extremely sensuous disposition"] = "sensual",
    ["is a greedy bugger"] = "avaricious",
  }
  local pers = personalities[string.lower(personality)] or "none"
  if not immune[pers] then
    display.Error("info => Invalid personality type: " .. tostring(personality))
    return
  end

  display.Prefix()
  ColourTell("white", "", "Analysis of '" .. targ .. "' ")
  if busy then
    ColourNote("firebrick", "", "(not open)")
  else
    ColourNote("lime", "", "(OPEN)")
  end
  display.Prefix()
  ColourNote("silver", "", "  Immune: ", "darkcyan", "", immune[pers], "silver", "", "  Vulnerable: ", "darkcyan", "", vulnerable[pers])
end

function progress()
  if main.auto("influence") then
    flags.set("doing", true)
    sway(GetVariable("target_influence") or "nobody")
  end
end

function completed(name, line, wildcards, styles)
  local targ = wildcards[1]
  local mode = string.match(name, "^influence_(%a+)__$")
  my_influences[mode] = my_influences[mode] or {}
  my_influences[mode][targ] = (my_influences[mode][targ] or 0) + 1
  main.archive("influences", my_influences)
end

function ignored()
  todo.del_match("^influence %w+ with %a+$")
  todo.del_match("^influence %w+ with amnesty for %w+$")
end

function immunity()
  ignored()
end


function handle_target(name, line, wildcards, styles)
  SetVariable("target_influence", wildcards[1])
  display.Info("Targeting for influence: " .. GetVariable("target_influence"))
  main.info("target_influence")
  if IsConnected() then
    Send("")
  end
end

function handle_type(name, line, wildcards, styles)
  if #wildcards[2] > 0 then
    SetVariable("target_influence", wildcards[2])
    display.Info("Targeting for influence: " .. GetVariable("target_influence"))
    main.info("target_influence")
  end
  set(wildcards[1])
end

function handle_sway(name, line, wildcards, styles)
  sway(GetVariable("target_influence") or "nobody")
end

function handle_amnesty(name, line, wildcards, styles)
  local person = wildcards[1]
  if #person > 0 then
    amnesty_target = string.lower(person)
  else
    amnesty_target = false
  end

  set("amnesty")
  sway(GetVariable("target_influence") or "nobody")
end
