module (..., package.seeall)

require "pairsbykeys"
require "main"

local my_kills = main.bootstrap("kills_me") or {}
local my_kills_arena = main.bootstrap("kills_me_arena") or {}
local my_deaths = main.bootstrap("kills_them") or {}
local my_deaths_arena = main.bootstrap("kills_them_arena") or {}

function add_arena_kill(name)
  my_kills_arena[name] = (my_kills_arena[name] or 0) + 1
  main.archive("kills_me_arena", my_kills_arena)
end

function add_arena_death(name)
  my_deaths_arena[name] = (my_deaths_arena[name] or 0) + 1
  main.archive("kills_them_arena", my_deaths_arena)
end

function add_kill(name)
  if flags.get("arena") then
    add_arena_kill(name)
    return
  end

  my_kills[name] = (my_kills[name] or 0) + 1
  main.archive("kills_me", my_kills)
end

function add_death(name)
  if flags.get("arena") then
    add_arena_death(name)
    return
  end

  my_deaths[name] = (my_deaths[name] or 0) + 1
  main.archive("kills_them", my_deaths)
end

function show_one(name)
  if flags.get("arena") then
    show_one_arena(name)
    return
  end

  local k = 0
  local d = 0

  if my_kills then
    k = my_kills[name] or 0
  end

  if my_deaths then
    d = my_deaths[name] or 0
  end

  display.Prefix()
  ColourNote("khaki", "", "Kills: ",
             "peru", "", k,
             "khaki", "", " Deaths: ",
             "peru", "", d,
             "lightslategray", "", " (" .. name .. ") ")
end

function show_one_arena(name)
  local k = 0
  local d = 0

  if my_kills_arena then
    k = my_kills_arena[name] or 0
  end

  if my_deaths_arena then
    d = my_deaths_arena[name] or 0
  end

  display.Prefix()
  ColourNote("khaki", "", "Arena Kills: ",
             "peru", "", k,
             "khaki", "", " Arena Deaths: ",
             "peru", "", d,
             "lightslategray", "", " (" .. name .. ") ")
end

function show_kills(name, line, wildcards, styles)
  local filter = wildcards[1] or ""
  display.Info("Kills Report:")

  local i = 0
  for n,v in pairsByKeys(my_kills) do
    if #filter == 0 or string.find(n, filter) then
      if i % 2 == 0 then
        display.Prefix()
        ColourTell("blue", "", "  [")
        ColourTell("darkcyan", "", string.format("%5d", v))
        ColourTell("blue", "", "] ")
        ColourTell("silver", "", string.format("%-31s", string.sub(n, 1, 30)))
      else
        ColourTell("blue", "", "  [")
        ColourTell("darkcyan", "", string.format("%5d", v))
        ColourTell("blue", "", "] ")
        ColourNote("silver", "", string.format("%-31s", string.sub(n, 1, 30)))
      end
      i = i + 1
    end
  end
  if i == 0 then
    display.Prefix()
    ColourNote("silver", "", "  None yet! Get to work!")
  end
  if i % 2 == 1 then
    Note("")
  end
  if IsConnected() then
    Send("")
  end
end

function show_deaths(name, line, wildcards, styles)
  local filter = wildcards[1] or ""
  display.Info("Deaths Report:")

  local i = 0
  for n,v in pairsByKeys(my_deaths) do
    if #filter == 0 or string.find(n, filter) then
      if i % 2 == 0 then
        display.Prefix()
        ColourTell("blue", "", "  [")
        ColourTell("darkcyan", "", string.format("%5d", v))
        ColourTell("blue", "", "] ")
        ColourTell("silver", "", string.format("%-31s", string.sub(n, 1, 30)))
      else
        ColourTell("blue", "", "  [")
        ColourTell("darkcyan", "", string.format("%5d", v))
        ColourTell("blue", "", "] ")
        ColourNote("silver", "", string.format("%-31s", string.sub(n, 1, 30)))
      end
      i = i + 1
    end
  end
  if i == 0 then
    display.Prefix()
    ColourNote("silver", "", "  None yet! Way to go!")
  end
  if i % 2 == 1 then
    Note("")
  end
  if IsConnected() then
    Send("")
  end
end


function win(name, line, wildcards, styles)
  local foe = wildcards[1]
  if flags.get("arena") then
    prompt.preillqueue(function () kills.add_arena_kill(foe)
      kills.show_one_arena(foe) end, "killcount")
  else
    prompt.preillqueue(function () kills.add_kill(foe)
      kills.show_one(foe) end, "killcount")
  end
end

function lose(name, line, wildcards, styles)
  local foe = wildcards[1]
  if flags.get("arena") then
    prompt.preillqueue(function () kills.add_arena_death(foe)
      kills.show_one_arena(foe) end, "deathcount")
  else
    prompt.preillqueue(function () kills.add_death(foe)
      kills.show_one(foe) end, "deathcount")
  end
end
