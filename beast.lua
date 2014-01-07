module (..., package.seeall)

require "main"

local stats = main.bootstrap("beast_stats") or {}
local last_regen = 0

local current_health
local current_mana
local current_ego

local mana_cost = {
  ["breathe fire"] = 500,
  ["breathe cold"] = 500,
  ["breathe lightning"] = 500,
  ["breathe gas"] = 500,
  ["breathe psionicblast"] = 500,
  ["breathe steam"] = 500,
  ["breathe sleepcloud"] = 1500,
  ["breathe amnesiacloud"] = 1500,
  ["chameleon on"] = 500,
  ["chameleon off"] = 500,
  ["cast reflection"] = 1500,
  ["cast hypnoticgaze"] = 1500,
  ["empath mana"] = -250
}

local ego_cost = {
  ["heal health"] = 500,
  ["heal mana"] = 500,
  ["heal ego"] = 500,
  ["cure body"] = 1000,
  ["cure mind"] = 1000,
  ["cure spirit"] = 1000,
  ["empath ego"] = -250
}

local location = "stable"

function order(cmd)
  cmd = string.lower(cmd)
  display.Debug("Beast order given '" .. cmd .. "'", "beast")
  flags.set("beast_order", cmd, 0)
  bals.lose("beast", 1)
  Send("beast order " .. cmd)
end

function empath(cmd)
  cmd = string.lower(cmd)
  flags.set("beast_order", "empath " .. cmd, 0)
  bals.lose("beast", 3)
  Send("beast empath " .. cmd)
end

function ordered(b, cmd)
  display.Debug("Beast '" .. b .. "' ordered '" .. cmd .. "'", "beast")

  local desc = get("desc")
  if desc and b and string.lower(b) ~= string.lower(desc) then
    return
  end

  if cmd == "purge" then
    set("poison", "")
    set("doses", 0)
  end

  if string.find(flags.get("beast_order") or "", cmd) then
    if bals.confirm("beast", 14) then
      flags.clear("beast_order")
      use_mana(mana_cost[cmd] or 0)
      use_ego(ego_cost[cmd] or 0)

      if flags.get("slow_going") == "beast order " .. cmd then
        flags.clear{"slow_sent", "slow_going"}
      end
    end
  end
end

function max_health()
  return get("maxhealth") or 10000
end

function max_mana()
  return get("maxmana") or 10000
end

function max_ego()
  return get("maxego") or 10000
end

function health(h)
  current_health = h or current_health or max_health()

  return current_health
end

function mana(m)
  current_mana = m or current_mana or max_mana()

  if current_mana < 0 then
    current_mana = 0
  elseif current_mana > max_mana() then
    current_mana = max_mana()
  end

  return current_mana
end

function ego(e)
  current_ego = e or current_ego or max_ego()

  if current_ego < 0 then
    current_ego = 0
  elseif current_ego > max_ego() then
    current_ego = max_ego()
  end

  return current_ego
end

function use_mana(amt)
  local m = mana()

  mana(m - amt)

  if m ~= mana() then
    display.Debug("Beast mana used = " .. amt .. ", Current = " .. mana(), "beast")
  end
end

function use_ego(amt)
  local e = ego()

  ego(e - amt)

  if e ~= ego() then
    display.Debug("Beast ego used = " .. amt .. ", Current = " .. ego(), "beast")
  end
end

function set(stat, val)
  if not stat or not val then
    display.Debug("Beast stat given a nil parameter", "beast")
    return
  end

  local stat = string.lower(stat)
  stats[stat] = val
  main.archive("beast_stats", stats)

  display.Debug("Setting '" .. stat .. "' to " .. val, "beast")
end

function get(stat)
  local stat = string.lower(stat) or ""
  if stat == "desc" then
    return GetVariable("sg1_beast_desc")
  end
  return stats[stat]
end

function add_ability(name, line, wildcards, styles)
  if wildcards[1] == " " then
    return
  end
  set(wildcards[1], 1)
end

function has_ability(ab)
  return stats[ab] ~= nil
end

function clear()
  stats = {}
  display.Debug("Beast variables cleared out", "beast")
end

function locate(pos)
  if pos then
    local pos = string.lower(pos)
    if pos == location then
      return
    end
    if pos == "lost" then
      if tonumber(location) then
        return
      end
      if map.current_room > 0 then
        pos = map.current_room
      end
    end
    location = pos
    main.info("beast")
    display.Info("Beast location set to '" .. location .. "'")
  end

  return location
end

function lost()
  local pos = locate()
  if pos ~= "stable" and
     pos ~= "inventory" and
     pos ~= "enroute" then
    locate("lost")
  end

  return locate() == "lost"
end

function regen()
  if last_regen <= 0 then
    last_regen = os.clock()
    return
  end

  local bc = os.clock()
  local bt = bc - last_regen
  local mgain = math.floor((max_mana() / 700) * (bt / 5.2))
  local egain = math.floor((max_ego() / 700) * (bt / 5.2))
  if has_ability("regenerate mana") then
    mgain = mgain * 2
  end
  if has_ability("regenerate ego") then
    egain = egain * 2
  end
  use_mana(-mgain)
  use_ego(-egain)
  last_regen = bc
end
