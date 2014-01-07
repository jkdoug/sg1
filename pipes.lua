module (..., package.seeall)

require "main"

local unassigned = {}
local assigned = {}
local items = main.bootstrap("pipes") or {}

mapping = {}


function puffs(herb, count)
  if not herb or not items[herb] then
    return 0
  end

  if count then
    items[herb].puffs = count
    main.archive("pipes", items)
    display.Debug("Puffs left in pipe with '" .. tostring(herb) .. "' now " .. count, "gear")
  end

  return items[herb].puffs or 0
end

function lit(herb, flag)
  if not herb or not items[herb] then
    return 0
  end

  if flag ~= nil then
    items[herb].lit = flag
    main.archive("pipes", items)
  end

  return items[herb].lit or false
end

function emptied()
  if flags.get("emptying") then
    puffs(flags.get("emptying"), 0)
    flags.clear("emptying")
  else
    sync()
  end
end

function filled(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  if not herb or not items[herb] then
    if not flags.get("pipe_warning") then
      display.Error("Pipes not fully configured. Check PIPELIST!")
      flags.set("pipe_warning", true, 30)
    end
    return
  end

  if flags.get("filling_" .. herb) then
    if flags.get("slow_going") == "fill " .. herb then
      flags.clear{"slow_sent", "slow_going"}
    end

    puffs(herb, tonumber(GetVariable("sg1_option_maxpuffs") or "20"))
    flags.clear("filling_" .. herb)
  end
end

function smoked(name, line, wildcards, styles)
  local herb = mapping[wildcards[1]]
  if not herb then
    herb = flags.get("smoking")
    if not herb then
      display.Error("What the hell are you smoking?")
      return
    end
  end

  if herb == "faeleaf" then
    if affs.has("coils") then
      if bals.confirm("herb", 8) then
        affs.del("smoke_faeleaf", true)
        flags.set("last_cure", "smoke faeleaf", 0)
        main.cures_on()
      end
    elseif not defs.has("rebounding") then
      flags.set("aura_timer", true, 0)
      failsafe.exec("rebounding", 8, true)
    end
  elseif herb == "myrtle" then
    if bals.confirm("herb", 8) then
      affs.del("smoke_myrtle", true)
      flags.set("last_cure", "smoke myrtle", 0)
      main.cures_on()
      if affs.has("phrenic_nerve") then
        flags.set("phrenic_smoke", (flags.get("phrenic_smoke") or 0) + 1, 0)
      else
        flags.clear("phrenic_smoke")
      end
    end
  elseif herb == "coltsfoot" then
    if bals.confirm("herb", 8) then
      affs.del("smoke_coltsfoot", true)
      flags.set("last_cure", "smoke coltsfoot", 0)
      main.cures_on()
    end
  else
    display.Error("Smoking " .. herb .. " will kill you.")
    return
  end

  if flags.get("slow_going") == "smoke " .. herb then
    flags.clear{"slow_sent", "slow_going"}
  end

  if not flags.get("arena") then
    puffs(herb, puffs(herb) - 1)
  end
  flags.clear("smoking")
  failsafe.disable("smoking")
end

function not_smoked()
  local s = flags.get("smoking")
  if s then
    if s ~= "faeleaf" or affs.has("coils") then
      bals.gain("herb")
    end
    puffs(s, 0)
    failsafe.disable("smoking")
    flags.clear("smoking")
  end
end


function check()
  display.Debug("Pipes checked", "gear")
  for _,h in ipairs{"coltsfoot", "faeleaf", "myrtle"} do
    if not assigned[h] then
      if #unassigned == 0 then
        display.Error("No empty pipe for " .. h)
      else
        local pipe = table.remove(unassigned, 1)
        display.Debug("Assigning pipe " .. tostring(pipe.id) .. " to hold " .. h)
        items[h] = {id = pipe.id, puffs = 0, lit = pipe.lit}
      end
    end
  end
  main.archive("pipes", items)
end

function assign(name, line, wildcards, styles)
  local id = tonumber(wildcards[1])
  local herb = wildcards[2]
  local puffs = tonumber(wildcards[3])
  local lit = wildcards[4] == "Lit"
  items[herb] = {id = id, puffs = puffs, lit = lit}
  assigned[herb] = id
  display.Debug("Pipe assigned: " .. herb .. " = " .. id .. ", puffs = " .. puffs .. ", lit = " .. tostring(lit), "gear")
end

function unassign(name, line, wildcards, styles)
  local id = tonumber(wildcards[1])
  local lit = wildcards[2] == "Lit"
  table.insert(unassigned, {id = id, lit = lit})
  display.Debug("Pipe unassigned: " .. id, "gear")
end


function sync(name, line, wildcards, styles)
  if not main.has_ability("discernment", "pipelist") or
     flags.get("pipe_sync_try") then
    return
  end

  EnableTriggerGroup("PipeList", true)
  EnableTrigger("pipelist_hide__", true)
  flags.set("pipe_sync_try", true, 1)
  SendNoEcho("pipel")
end

function list(name, line, wildcards, styles)
  EnableTriggerGroup("PipeList", true)
  EnableTrigger("pipelist_hide__", false)
  flags.set("pipe_sync_try", true, 5)
  Send("pipel")
end

function toggle(name, line, wildcards, styles)
  local on = string.lower(wildcards[1]) == "on"
  if on then
    scan.process()
  end
  main.auto("pipes", on)
end

function listed()
  if flags.get("pipe_sync_try") then
    items = {}
    assigned = {}
    unassigned = {}
    EnableTriggerGroup("PipeList", true)
    flags.clear("pipe_sync_try")
    prompt.queue(function ()
      EnableTriggerGroup("PipeList", false)
      pipes.check()
    end)
  end
end

function light()
  flags.set("pipe_light_try", true, 1)
  --[[
  for _,h in ipairs{"coltsfoot", "faeleaf", "myrtle"} do
    if items[h] and not items[h].lit and items[h].puffs > 0 then
      SendNoEcho("light " .. items[h].id)
    end
  end
  --]]
  SendNoEcho("light pipes")
end

function empty(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  if not items[herb] then
    if not flags.get("pipe_warning") then
      display.Error("Pipes not fully configured. Check PIPELIST!")
      flags.set("pipe_warning", true, 30)
    end
    return
  end

  flags.set("emptying", herb, 2)
  Send("empty " .. items[herb].id)
end

function fill(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  if not items[herb] then
    if not flags.get("pipe_warning") then
      display.Error("Pipes not fully configured. Check PIPELIST!")
      flags.set("pipe_warning", true, 30)
    end
    return
  end

  flags.set("filling_" .. herb, true, 4)
  Send("outr " .. herb)
  if affs.slow() then
    flags.set("in_pipe", herb .. " in " .. items[herb].id, 0)
    EnableTrigger("fill_now__", true)
    failsafe.exec("fill_slow", 2)
  else
    Send("put " .. herb .. " in " .. items[herb].id)
  end
end

function smoke(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  if not items[herb] then
    if not flags.get("pipe_warning") then
      display.Error("Pipes not fully configured. Check PIPELIST!")
      flags.set("pipe_warning", true, 30)
    end
    return
  end

  flags.set("smoking", herb, 2)
  if herb ~= "faeleaf" or affs.has("coils") then
    bals.lose("herb", 2)
  end
  Send("smoke " .. items[herb].id)
end

failsafe.fn.fill_slow = function ()
  if flags.get("in_pipe") then
    flags.clear("in_pipe")
    EnableTrigger("fill_now_", false)
  end
end

function fill_now(name, line, wildcards, styles)
  if flags.get("in_pipe") and string.find(flags.get("in_pipe"), wildcards[1]) then
    Send("put " .. flags.get("in_pipe"))
    flags.set("slow_sent", "fill " .. wildcards[1], 1)
    flags.clear("in_pipe")
    EnableTrigger("fill_now__", false)
    failsafe.disable("fill_slow")
  end
end


function show()
  display.Info("Pipe Status Report:")

  for _,h in ipairs{"coltsfoot", "faeleaf", "myrtle"} do
    display.Prefix()
    ColourTell("silver", "", "  " .. string.format("%-20s", h))

    if not items[h] then
      ColourNote("red", "", string.format("%-10s", "unknown"))
    else
      ColourTell("darkcyan", "", string.format("%-10s", items[h].id))

      local puffs = items[h].puffs or 0
      local color = "red"
      if puffs > 5 then
        color = "green"
      elseif puffs > 0 then
        color = "yellow"
      end
      ColourTell(color, "", string.format("%-10s", puffs))

      if items[h].lit then
        ColourNote("darkcyan", "", string.format("%-8s", "lit"))
      else
        ColourNote("red", "", string.format("%-8s", "unlit"))
      end
    end
  end
  if IsConnected() then
    Send("")
  end
end

if IsConnected() then
  DoAfterSpecial(0.5, "pipes sync", 10)
else
  prompt.queue("pipes sync", "syncopipes")
end

for _,p in pairs{"coltsfoot", "faeleaf", "myrtle"} do
  if GetVariable("sg1_" .. p .. "_id") then
    items[p] = {id = tonumber(GetVariable("sg1_" .. p .. "_id") or "0"),
                puffs = tonumber(GetVariable("sg1_" .. p .. "_puffs") or "0"),
                lit = GetVariable("sg1_" .. p .. "_lit") == "1"}
    main.archive("pipes", items)

    DeleteVariable("sg1_" .. p .. "_id")
    DeleteVariable("sg1_" .. p .. "_puffs")
    DeleteVariable("sg1_" .. p .. "_lit")
  end
end
