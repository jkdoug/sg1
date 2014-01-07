module(..., package.seeall)

require "main"

local stuff = main.bootstrap("magic_items") or {}
local scrolls = main.bootstrap("magic_scrolls") or {}
local tome = main.bootstrap("magic_tome") or {}

function assign(name, line, wildcards, styles)
  local id = wildcards[1]
  local spell = ""
  local charges = 0
  local status = ""
  local regulator = wildcards[5] == "*"

  if not wildcards[5] then
    spell = wildcards[2]
    charges = tonumber(wildcards[3])
    regulator = wildcards[4] == "*"
    status = "tome"
  else
    status = wildcards[2]
    spell = wildcards[3]
    charges = tonumber(wildcards[4])
    if string.find(spell, "^waterbreat") then
      spell = "waterbreathe"
    elseif string.find(spell, "^revelation") then
      spell = "revelations"
    elseif string.find(spell, "^true") then
      spell = "truetime"
    elseif string.find(spell, "^powerful") then
      spell = "focus"
    elseif status == "box" and string.find("emerald azure golden", spell) then
      spell = spell .. "box"
    elseif string.find("piper golden blast", spell) then
      spell = spell .. "horn"
    end
  end

  if status == "scroll" then
    scrolls[spell] = {id=id, charges=charges, regulator=regulator}
    main.archive("magic_scrolls", scrolls)
  elseif status == "tome" then
    tome[spell] = {id=id, charges=charges, regulator=regulator}
    main.archive("magic_tome", tome)
  else
    stuff[spell] = {id=id, charges=charges, regulator=regulator}
    main.archive("magic_items", stuff)
  end
  display.Debug("Set magic '" .. spell .. "' with ID " .. id .. " and " .. tostring(charges) .. " charges", "gear")
end

function use_charge(spell, is_tome)
  if flags.get("arena") or
     flags.get("used_enchant") == "surfboard" or
     spell == "powerful" then
    return
  end

  if spell == "nimbus" then
    spell = "cosmic"
  end

  local ch = charges(spell, is_tome) - 1
  if is_tome then
    if tome[spell] and not tome[spell].regulator then
      tome[spell].charges = ch
      main.archive("magic_tome", tome)
    end
  elseif string.find("cursed disruption healing protection", spell) then
    if scrolls[spell] and not scrolls[spell].regulator then
      scrolls[spell].charges = ch
      main.archive("magic_scrolls", scrolls)
    end
  elseif stuff[spell] and not stuff[spell].regulator then
    stuff[spell].charges = ch
    main.archive("magic_items", stuff)
  end

  display.Debug("Charges on '" .. spell .. "' set to " .. ch, "gear")
end

function charges(spell, is_tome)
  if spell == "nimbus" then
    spell = "cosmic"
  end

  local ch = {}
  if is_tome then
    ch = tome[spell] or {}
  elseif string.find("cursed disruption healing protection", spell) then
    ch = scrolls[spell] or {}
  else
    ch = stuff[spell] or {}
  end

  return ch.charges or 0
end

function scroll(spell)
  local item = tome[spell]
  if item then
    return tome[spell], true
  else
    return scrolls[spell], false
  end
end

function list(name, line, wildcards, styles)
  stuff = {}
  scrolls = {}
  tome = {}
  display.Debug("Cleared magic items", "gear")
  EnableTriggerGroup("MagicList", true)
  prompt.queue(function () EnableTriggerGroup("MagicList", false) end)
end

function recharge(name, line, wildcards, styles)
  for _,item in pairs(stuff) do
    Send("recharge " .. item.id .. " from cube")
  end
end

function recharge_all(name, line, wildcards, styles)
  for _,item in pairs(stuff) do
    Send("recharge " .. item.id .. " from cube")
  end
  for _,item in pairs(scrolls) do
    Send("recharge " .. item.id .. " from cube")
  end
end
