module (..., package.seeall)

require "prompt"

modname = GetVariable("sg1_aether_module") or ""
docked = GetVariable("sg1_aether_docked") == "1"

power = 0
hull = 0
max_hull = 0
status = "no damage"
willpower = 0

modules = {}

target = ""
next_target = ""

ab = {
  ["grid modules"] = "empathy",
  ["grid repair hull"] = "empathy",
  ["grid join"] = "interlink",
  ["grid remove"] = "interlink",
  ["grid repair module"] = "modules",
  ["grid trade"] = "trade",
  ["grid analyze"] = "analyze",
  ["grid distribution"] = "distribute",
  ["grid hail"] = "steward",
  ["grid channel"] = "steward",
  ["grid dissonance"] = "steward",
  ["grid screech"] = "steward",
  ["grid song"] = "steward",
  ["grid astralsense"] = "astralsight",
  ["grid clarity"] = "purser",
  ["grid flush"] = "purser",
  ["grid regenerate"] = "purser",
  ["grid scan"] = "scan",
  ["grid covey"] = "firstmate",
  ["grid deepbond"] = "firstmate",
  ["grid parasite"] = "firstmate",
  ["grid planarbond"] = "firstmate",
  ["grid synchronize"] = "firstmate",
  ["grid resonance"] = "resonance",

  ["pilot funnel"] = "aethercraft",
  ["pilot launch"] = "aethercraft",
  ["fly"] = "aethercraft",
  ["pilot dock"] = "aethercraft",
  ["pilot offer"] = "offerings",
  ["pilot armada"] = "armada",
  ["pilot ram"] = "ram",
  ["pilot breakaway"] = "ram",
  ["pilot scoop"] = "scoop",
  ["pilot transverse"] = "transverse",
  ["pilot glide"] = "gliding",
  ["pilot trail"] = "trail",
  ["pilot evade"] = "cadet",
  ["pilot roll"] = "cadet",
  ["pilot sluice"] = "cadet",
  ["pilot spin"] = "cadet",
  ["pilot tunnel"] = "tunnel",
  ["pilot farhorizon"] = "thirdmate",
  ["pilot maneuver"] = "thirdmate",
  ["pilot shadow"] = "thirdmate",
  ["pilot silentrun"] = "thirdmate",
  ["pilot flashpoint"] = "flashpoint",
  ["pilot fuse"] = "captain",
  ["pilot immerse"] = "captain",
  ["pilot seal"] = "captain",
  ["pilot spiral"] = "spiral",

  ["ship worldscan"] = "worldscan",

  ["siphon vortex"] = "siphon",
  ["siphon ship"] = "siphon",
  ["siphon energy into nexus"] = "siphon",
  ["siphon energy into me"] = "siphon",

  ["turret fire"] = "battle",
  ["turret target ship"] = "battle",
  ["turret target creature"] = "battle",
  ["turret target nothing"] = "battle",
  ["turret target module"] = "targeting",
  ["turret bombard"] = "bombard",
  ["turret rupture"] = "rupture",
  ["turret murkle"] = "bosun",
  ["turret repulse"] = "bosun",
  ["turret sludge"] = "bosun",
  ["turret strip"] = "bosun",
  ["turret worble"] = "bosun",
  ["turret siphon"] = "turretsiphon",
  ["turret deaden"] = "secondmate",
  ["turret jinsunjolt"] = "secondmate",
  ["turret marmuckle"] = "secondmate",
  ["turret marwurble"] = "secondmate",
  ["turret shock"] = "shock",
  ["turret shockwave"] = "shock",
  ["turret clarionblast"] = "clarionblast",
}

local beast_xlate = {
  ["forestal gargantuan"] = "gargantuan",
  ["scorpion-like slanikk"] = "slanikk",
  ["school of burning pyrinnes"] = "pyrinnes",
  ["coiling flux serpent"] = "serpent",
  ["gaseous cloier"] = "cloier",
  ["spiked hydrian"] = "hydrian",
  ["horrifying lixin"] = "lixin",
  ["swarm of gorgogs"] = "gorgogs",
  ["cloud of shifting colours"] = "cloud",
  ["noxious, many-winged gruul"] = "gruul",
  ["mountainous elemental"] = "elemental",
  ["inferno elemental"] = "elemental",
  ["oceanic elemental"] = "elemental",
  ["vortex karibidean"] = "karibidean",
  ["six-headed scyllus"] = "scyllus",
  ["black dragon"] = "dragon",
  ["ominous shadow"] = "shadow",
  ["tendril of Kethuru"] = "tendril",
}

local last_module = {}

local aff_xlate = {
  ["has been blown up"] = "clarionblast",
  ["is irresponsive to any commands"] = "shock",
  ["is covered in sludge"] = "sludge",
  ["is disrupted"] = "murkle",
  ["is slowed"] = "worble",
  ["is dead"] = "dead",
  ["is currently disabled"] = "disabled",
}

local mod_xlate = {
  ["a battle turret"] = "turret",
  ["the empathic grid"] = "grid",
  ["the command chair"] = "chair",
  ["a shield orb"] = "orb",
  ["a bulky ramhead"] = "ramhead",
  ["a cloaking cube"] = "cube",
  ["an energy collector"] = "collector",
  ["an aetherhold"] = "aetherhold",
}


local function comms(msg)
  display.Prefix()
  ColourNote("midnightblue", "silver", msg)
end

local function announce(msg, not_spam)
  if not_spam or not flags.get("aether_spam") then
    Send("shipt " .. msg)
    if not not_spam then
      local t = tonumber(GetVariable("sg1_option_spam_timer") or "2")
      if t and t > 0 then
        flags.set("aether_spam", true, t)
      end
    end
  end
end


function is_locked()
  return #modname > 0
end

function is_docked(val)
  if val ~= nil then
    docked = val
    if docked then
      SetVariable("sg1_aether_docked", 1)
    else
      DeleteVariable("sg1_aether_docked")
    end
    main.info("docked")
  end
  return docked
end


function lock(name, line, wildcards, styles)
  local mod = wildcards[1]
  modname = mod_xlate[mod] or mod
  SetVariable("sg1_aether_module", modname)

  if modname == "chair" then
    Accelerator("Numpad1", "fly sw")
    Accelerator("Numpad2", "fly s")
    Accelerator("Numpad3", "fly se")
    Accelerator("Numpad4", "fly w")
    Accelerator("Numpad6", "fly e")
    Accelerator("Numpad7", "fly nw")
    Accelerator("Numpad8", "fly n")
    Accelerator("Numpad9", "fly ne")

    Send("config shipsight 1")
    Send("config aethermap on")

    EnableGroup("Aether_Chair", true)
    comms("Welcome aboard, captain! The helm is yours.")
  elseif modname == "grid" then
    modules = nil
    EnableGroup("Aether_Grid", true)
    comms("Welcome aboard, engineer! Take good care of her.")
  elseif modname == "turret" then
    EnableGroup("Aether_Turret", true)
    target = ""
    next_target = ""
    comms("Welcome aboard, sharpshooter! Knock 'em dead.")
  else
    EnableGroup("Aether_Collector", true)
    comms("Welcome aboard, ensign! Powering up console.")
  end
  Execute("OnModuleLock " .. modname)

  main.info("aethercraft")
  max_hull = 0
  EnableGroup("Aethercraft", true)
end

function unlock()
  if modname == "chair" then
    Accelerator("Numpad1", "sw")
    Accelerator("Numpad2", "s")
    Accelerator("Numpad3", "se")
    Accelerator("Numpad4", "w")
    Accelerator("Numpad6", "e")
    Accelerator("Numpad7", "nw")
    Accelerator("Numpad8", "n")
    Accelerator("Numpad9", "ne")

    Send("config shipsight 0")
    Send("config aethermap off")

    EnableGroup("Aether_Chair", false)
  elseif modname == "grid" then
    EnableGroup("Aether_Grid", false)
  elseif modname == "turret" then
    EnableGroup("Aether_Turret", false)
  else
    EnableGroup("Aether_Collector", false)
  end

  EnableGroup("Aethercraft", false)

  comms("So long for now!")
  Execute("OnModuleUnlock " .. modname)

  reset()
  main.info("aethercraft")
end

function reset()
  modname = ""
  DeleteVariable("sg1_aether_module")
end


function captain(name, line, wildcards, styles)
  SetVariable("sg1_aether_captain", wildcards[1] or "")
  comms("Your captain for this trip is " .. GetVariable("sg1_aether_captain") .. ".")
end

function docking(name, line, wildcards, styles)
  is_docked(#wildcards[1] == 0)
end

function launch(name, line, wildcards, styles)
  is_docked(false)
  if modname == "grid" then
    grid("modules")
  end
end

function dock(name, line, wildcards, styles)
  is_docked(true)
end

function toggle(name, line, wildcards, styles)
  local m = string.lower(wildcards[1])
  local on = string.lower(wildcards[2]) == "on"
  if m == "grid" then
    m = "empath"
    if on and modname == "grid" then
      aethercraft.grid("damage report")
    end
  end
  if m == "chair" then
    m = "pilot"
  end
  Execute("auto " .. m .. " " .. wildcards[2])
end

function flying(name, line, wildcards, styles)
  local dir = string.lower(wildcards[1])
  if main.auto("gliding") then
    if flags.get("gliding_dir") == dir then
      Send("pilot glide stop")
    else
      Send("pilot glide " .. dir)
      flags.set("gliding_dir", dir, 0)
    end
  else
    Send("pilot steer " .. dir)
  end
end

function cmd_grid(name, line, wildcards, styles)
  local cmd = string.lower(wildcards[1])
  if cmd == "clarity" then
    local arg = string.lower(wildcards[2] or "")
    grid(cmd, arg)
  else
    grid(cmd)
  end
end

function cmd_turret(name, line, wildcards, styles)
  local cmd = string.lower(wildcards[1])
  local cmd_xlate = {
    ttc = "target creature",
    ttm = "target module",
    tts = "target ship",
    ttn = "target nothing",
    bomb = "bombard",
  }
  if string.find(name, "arg") and wildcards[2] then
    local arg = string.lower(wildcards[2])
    turret(cmd_xlate[cmd] or cmd, arg)
  else
    turret(cmd_xlate[cmd] or cmd)
  end
end


function match(name, line, wildcards, styles)
  display.OnPrompt()

  wounds.OnPrompt()
  affs.OnPrompt()
  defs.OnPrompt()

  prompt.exec(true)

  hull = tonumber(wildcards[1])
  power = tonumber(wildcards[2])
  status = wildcards[3]
  willpower = tonumber(wildcards[4])
  local oldbal = balance
  balance = #wildcards[5] > 0
  if oldbal and not balance then
    flags.clear("aether_cmd")
  end

  prompt.check_stats()

  if hull > max_hull then
    max_hull = hull
  end

  if scan.update then
    scan.process()
  end

  -- Just want to gag this prompt entirely
  if prompt.gag then
    prompt.gag = false
  else
    display.timestamp(GetVariable("sg1_option_timestamp") == "prefix" or not GetVariable("sg1_option_timestamp"))

    for _, v in ipairs(styles) do
      if v.text ~= " *"..wildcards[5].."*]" then
        ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), v.text)
      end
    end

    if balance then
      ColourTell(GetVariable("sg1_prompt_onbal") or "goldenrod", "", " *"..wildcards[5].."*", "silver", "", "]")
    else
      ColourTell(GetVariable("sg1_prompt_offbal") or "gray", "", " *"..wildcards[5].."*", "silver", "", "]")
    end

    if bals.can_act() then
      ColourTell(GetVariable("sg1_prompt_onbal") or "goldenrod", "", " " .. bals.pflags())
    else
      ColourTell(GetVariable("sg1_prompt_offbal") or "gray", "", " " .. bals.pflags())
    end

    display.timestamp(GetVariable("sg1_option_timestamp") == "suffix")
    prompt.alerts()
    prompt.diffs{health = prompt.stat("hp"),
                 mana = prompt.stat("mp"),
                 ego = prompt.stat("ego"),
                 xp = prompt.stat("nl"),
                 essence = prompt.stat("essence")}
    Note("")

  end

  flags.OnPrompt()
  prompt.exec(false)

  if not balance then
    return
  end

  if modname == "grid" then
    do_grid()
  elseif modname == "turret" then
    do_turret()
  elseif modname == "collector" then
    do_siphon()
  else
    do_chair()
  end
end

function stopped_sailing(name, line, wildcards, styles)
  flags.clear("gliding_dir")
end

function grid_module(name, line, wildcards, styles)
  local mod = wildcards[1]
  local id = tonumber(wildcards[2])
  local status = wildcards[3]
  local person = wildcards[4]

  docked = false

  modules = modules or {}
  if mod == "turret" or mod == "collector" or mod == "aetherhold" then
    modules[mod] = modules[mod] or {}
    table.insert(modules[mod], { id = id, status = status, person = person })
  else
    modules[mod] = { id = id, status = status, person = person }
  end

  last_module = { mod = mod, id = id, status = status, person = person }

  prompt.queue(function ()
    flags.clear("aether_cmd")
    if slivvens then
      if #slivvens == 0 then
        announce("No parasites detected.", true)
      elseif #slivvens == 1 then
        announce("Parasite detected on " .. slivvens[1])
      else
        local last = table.remove(slivvens)
        announce("Parasites detected on " .. table.concat(slivvens, ", ") .. " and " .. last)
      end
    end
    last_module = {}
    EnableTrigger("aethercraft_modules__", false)
    EnableTrigger("aethercraft_modules_hide__", false)
    EnableTrigger("aethercraft_afflictions_hide__", false)
    EnableTrigger("aethercraft_modules_parasite__", false)
  end, "modules_check")
end

function grid_afflicted(name, line, wildcards, styles)
  local aff = aff_xlate[wildcards[1]] or wildcards[1]
  local mod = wildcards[2]

  modules = modules or {}
  if last_module.mod then
    if last_module.mod == "turret" or
       last_module.mod == "collector" or
       last_module.mod == "aetherhold" then
      for i,t in ipairs(modules[last_module.mod]) do
        if t.id == last_module.id then
          modules[last_module.mod][i][aff] = true
        end
      end
    else
      modules[last_module.mod] = modules[last_module.mod] or {}
      modules[last_module.mod][aff] = true
    end
  elseif mod and mod_xlate[mod] then
    local mod = mod_xlate[mod]
    if mod == "turret" or
       mod == "collector" or
       mod == "aetherhold" then
      grid("damage report")
    else
      modules[mod] = modules[mod] or {}
      modules[mod][aff] = true
      Note("Afflicted '" .. mod .. "' with '" .. aff .. "'")
    end
  end
end

function grid_healed(name, line, wildcards, styles)
  local mod = wildcards[1]
  local full = wildcards[2] == "fully"

  flags.clear("aether_cmd")
  if not full then
    grid("damage report")
    return
  end

  local healing = flags.get("grid_healing") or mod_xlate[mod]
  if not healing then
    return
  elseif string.find(healing, "^turret(%d)$") then
    _,_,n = string.find(healing, "^turret(%d)$")
    modules.turret[n].status = "no damage"
  elseif string.find(healing, "^collector(%d)$") then
    _,_,n = string.find(healing, "^collector(%d)$")
    modules.collector[n].status = "no damage"
  elseif string.find(healing, "^aetherhold(%d)$") then
    _,_,n = string.find(healing, "^aetherhold(%d)$")
    modules.aetherhold[n].status = "no damage"
  else
    local found = false
    for _,m in ipairs{"chair", "grid", "orb", "ramhead", "cube"} do
      if healing == m or (tonumber(healing) and modules[m] and modules[m].id == tonumber(healing)) then
        modules[m].status = "no damage"
        found = true
        break
      end
    end
    if not found and tonumber(healing) then
      for _,m in ipairs{"turret", "collector", "aetherhold"} do
        for i in ipairs(modules[m] or {}) do
          if modules[m][i].id == tonumber(healing) then
            modules[m][i].status = "no damage"
            break
          end
        end
      end
    end
  end
  grid("damage report")
end

function grid_slivven(name, line, wildcards, styles)
  local mod = wildcards[1]
  local id = tonumber(wildcards[2])
  local status = wildcards[3]
  local person = wildcards[4]

  grid_module(mod, id, status, person)

  if not slivvens then
    return
  end

  if #person > 0 then
    table.insert(slivvens, string.format("%s %d at %s", mod, id, person))
  else
    table.insert(slivvens, string.format("%s %d", mod, id))
  end
end

function grid_claritied(name, line, wildcards, styles)
  grid("claritied")
end

function grid_damage_report(name, line, wildcards, styles)
  grid("damage report")
end

function grid_worbled(name, line, wildcards, styles)
  grid_afflicted(name, line, {"worble", wildcards[1]}, styles)
end

function grid_murkled(name, line, wildcards, styles)
  grid_afflicted(name, line, {"murkle", wildcards[1]}, styles)
end

function grid_shockwaved(name, line, wildcards, styles)
  grid_afflicted(name, line, {"shock", "the command chair"}, styles)
end

function grid_unshockwaved(name, line, wildcards, styles)
  grid("damage report")
  Send("")
end

function grid_noheal(name, line, wildcards, styles)
  if flags.get("grid_healing") then
    grid_healed(name, line, {flags.get("grid_healing"), "fully"}, styles)
    flags.clear("aether_cmd")
  end
end

function grid_noclarity(name, line, wildcards, styles)
  flags.clear("aether_cmd")
end

function grid_module_hide(name, line, wildcards, styles)
  grid_module(name, line, wildcards, styles)
  prompt.gag = true
end

function siphon_auto(name, line, wildcards, styles)
  siphon("autovortex")
end

function siphon_success(name, line, wildcards, styles)
  local amt = tonumber(wildcards[1])
  announce("Energy siphoned, bringing the total to " .. amt, true)
end

function siphon_novortex(name, line, wildcards, styles)
  announce("No vortex.")
end

function siphon_full(name, line, wildcards, styles)
  announce("My collector will hold no more.")
end

function turret_shockwave(name, line, wildcards, styles)
  turret("shockwave")
end

function turret_fire_at_will(name, line, wildcards, styles)
  beast(wildcards[1])
  turret("autofire")
  is_docked(false)
end

function turret_autofire(name, line, wildcards, styles)
  turret("autofire")
end

function turret_pause(name, line, wildcards, styles)
  turret("pause")
end

function turret_unpause(name, line, wildcards, styles)
  turret("unpause")
end

function turret_newtarget(name, line, wildcards, styles)
  local targ = wildcards[1]
  if targ and #targ > 0 then
    turret("newtarget", targ)
  else
    turret("newtarget", target)
  end
end

function turret_targeted(name, line, wildcards, styles)
  turret("targeted", wildcards[1])
end

function turret_kill(name, line, wildcards, styles)
  beast_killed(wildcards[1])
end

function turret_notarget(name, line, wildcards, styles)
  beast_notfound()
end

function turret_beast(name, line, wildcards, styles)
  beast(wildcards[1])
end


function exec(cmd, args)
  if not main.has_ability("aethercraft", ab[cmd] or "clarionblast") then
    display.Debug("You do not possess the ability to '" .. cmd .. ".'", "actions")
    return false
  end

  if not able.to("aethercraft", cmd) then
    return false
  end

  local _,_,mn = string.find(cmd, "^siphon energy into (%a+)$")
  if mn then
    Send("siphon " .. args .. " energy into " .. mn)
  elseif args then
    Send(cmd .. " " .. args)
  else
    Send(cmd)
  end

  flags.set("aether_cmd", cmd, 1)

  return true
end

local slivvens = {}
function grid(cmd, arg)
  if cmd == "check" then
    if exec("grid modules") then
      slivvens = {}
      modules = nil
      EnableTrigger("aethercraft_modules__", true)
      EnableTrigger("aethercraft_modules_parasite__", true)
    end
  elseif cmd == "damage report" then
    if exec("grid modules") then
      slivvens = nil
      modules = nil
      EnableTrigger("aethercraft_modules__", true)
      EnableTrigger("aethercraft_modules_hide__", true)
      EnableTrigger("aethercraft_afflictions_hide__", true)
    end
  elseif cmd == "modules" then
    if exec("grid modules") then
      slivvens = nil
      modules = nil
      EnableTrigger("aethercraft_modules__", true)
    end
  elseif cmd == "autoclarity" then
    if main.auto("clarity") then
      grid("clarity", arg)
    end
  elseif cmd == "clarity" then
    local arg = string.lower(arg or "chair")
    if arg == "chair" then
      exec("grid clarity", modules.chair.id)
    elseif arg == "grid" then
      exec("grid clarity", modules.grid.id)
    elseif string.find(arg, "^turret%d$") then
      _,_,n = string.find(arg, "^turret(%d)$")
      exec("grid clarity", modules.turret[tonumber(n)].id)
    end
  elseif cmd == "claritied" then
    flags.clear("aether_cmd")
    grid("damage report")
  elseif cmd == "repair" then
    if hull < max_hull then
      exec("grid repair hull")
    else
      exec("grid repair module")
    end
  elseif cmd == "repair module" then
    if not modules then
      grid("modules")
      exec("grid repair module")
      return
    end

    if arg == "chair" then
      flags.set("grid_healing", arg, 1)
      exec("grid repair module", modules.chair.id)
    elseif arg == "grid" then
      flags.set("grid_healing", arg, 1)
      exec("grid repair module", modules.grid.id)
    elseif string.find(arg, "^turret%d$") then
      _,_,n = string.find(arg, "^turret(%d)$")
      flags.set("grid_healing", arg, 1)
      exec("grid repair module", modules.turret[tonumber(n)].id)
    elseif string.find(arg, "^collector%d$") then
      _,_,n = string.find(arg, "^collector(%d)$")
      flags.set("grid_healing", arg, 1)
      exec("grid repair module", modules.collector[tonumber(n)].id)
    elseif arg then
      flags.set("grid_healing", arg, 1)
      exec("grid repair module", arg)
    else
      flags.set("grid_healing", "module", 1)
      exec("grid repair module")
    end
  else
    exec("grid " .. cmd)
  end
end

function siphon(cmd)
  if modname ~= "collector" then
    display.Error("You're not a siphoner!")
    if IsConnected() then
      Send("")
    end
    return
  end

  if not balance then
    return
  end

  if cmd == "autovortex" then
    if main.auto("siphon") then
      exec("siphon vortex")
    end
  elseif cmd == "pause" then
    if main.auto("siphon") then
      main.auto("siphon", false)
    end
  elseif cmd == "unpause" then
    if not main.auto("siphon") then
      main.auto("siphon", true)
    end
  elseif cmd == "vortex" then
    exec("siphon vortex")
  end
end

function beast(desc)
  if not main.auto("turret") then
    return
  end

  if not beast_xlate[desc] then
    display.Warning("Unknown beast type '" .. desc .. "'")
    return
  end

  -- TODO: check for 'allowed' mobs, maybe prioritize/queue
  if target ~= beast_xlate[desc] then
    if not balance then
      next_target = beast_xlate[desc]
      main.info("aethercraft")
    else
      turret("target creature", beast_xlate[desc])
    end
  end
end

function beast_killed(desc)
  if not beast_xlate[desc] then
    return
  end

  if target == beast_xlate[desc] then
    if not next_target or #next_target < 1 then
      next_target = target
    end
    target = ""
  else
    next_target = beast_xlate[desc]
  end
  main.info("aethercraft")
end

function beast_notfound()
  flags.clear("aether_cmd")
  if next_target and #next_target > 0 then
    target = ""
    turret("target creature", next_target)
    next_target = ""
  else
    target = ""
  end
  main.info("aethercraft")
end

function turret(cmd, arg)
  if modname ~= "turret" then
    display.Error("You're not a gunner!")
    if IsConnected() then
      Send("")
    end
    return
  end

  if docked or not balance then
    return
  end

  if cmd == "autofire" then
    if main.auto("turret") then
      if next_target and #next_target > 0 and next_target ~= target then
        exec("turret target creature", next_target)
      elseif target and #target > 0 then
        exec("turret fire")
      end
    end
  elseif cmd == "pause" then
    if main.auto("turret") then
      main.auto("turret", false)
    end
  elseif cmd == "unpause" then
    if not main.auto("turret") then
      main.auto("turret", true)
    end
    turret("autofire")
  elseif cmd == "newtarget" then
    next_target = string.lower(arg)
    display.Info("Next target: " .. next_target)
    main.info("aethercraft")
    turret("autofire")
  elseif cmd == "targeted" then
    target = beast_xlate[arg] or arg
    display.Info("Targeted: " .. target)
    main.info("aethercraft")
  else
    exec("turret " .. cmd, arg)
  end
end

function pilot(cmd, arg)
end


function do_grid()
  if not modules and not flags.get("aether_cmd") and not flags.get("auto_modules") then
    grid("modules")
    flags.set("auto_modules", true, 2)    
  end
  if docked or not modules or not main.auto("empath") then
    return
  end

  modules.grid.status = status

  if affs.slow() then
    -- TODO: handle worble
    return
  end


  if hull < max_hull then
    grid("repair hull")
  elseif modules["chair"].shock then
    grid("autoclarity")
  elseif modules["chair"].status ~= "no damage" then
    --announce("Chair is damaged. Healing it now.")
    grid("repair module", "chair")
  elseif modules["grid"].status ~= "no damage" then
    --announce("Grid is damaged. Healing it now.")
    grid("repair module", "grid")
  else
    for _,t in ipairs(modules["turret"] or {}) do
      if t.status ~= "no damage" and #t.person > 0 then
        --announce("Manned turret is damaged. Healing it now.")
        grid("repair module", t.id)
        return
      end
    end

    for _,t in ipairs(modules["collector"] or {}) do
      if t.status ~= "no damage" and #t.person > 0 then
        --announce("Manned collector is damaged. Healing it now.")
        grid("repair module", t.id)
        return
      end
    end

    for _,t in ipairs(modules["turret"] or {}) do
      if t.status ~= "no damage" then
        --announce("Unmanned turret is damaged. Healing it now.")
        grid("repair module", t.id)
        return
      end
    end

    for _,t in ipairs(modules["collector"] or {}) do
      if t.status ~= "no damage" then
        --announce("Unmanned collector is damaged. Healing it now.")
        grid("repair module", t.id)
        return
      end
    end

    if modules["orb"] and modules["orb"].status ~= "no damage" then
      --announce("Shield orb is damaged. Healing it now.")
      grid("repair module", modules.orb.id)
    elseif modules["cube"] and modules["cube"].status ~= "no damage" then
      --announce("Cloaking cube is damaged. Healing it now.")
      grid("repair module", modules.cube.id)
    elseif modules["ramhead"] and modules["ramhead"].status ~= "no damage" then
      --announce("Ramhead is damaged. Healing it now.")
      grid("repair module", modules.ramhead.id)
    else
      for _,t in ipairs(modules["aetherhold"] or {}) do
        if t.status ~= "no damage" then
          --announce("Aetherhold is damaged. Healing it now.")
          grid("repair module", t.id)
          return
        end
      end
    end
  end
end

function do_turret()
  turret("autofire")
end

function do_siphon()
end

function do_chair()
end


function color_module(mod)
  if mod.status == "critical damage" then
    return "red"
  elseif mod.status == "heavy damage" then
    return "orangered"
  elseif mod.status == "moderate damage" then
    return "orange"
  elseif mod.status == "light damage" then
    return "yellow"
  end
  return "darkgreen"
end

function show_modules(name, line, wildcards, styles)
  display.Info("Ship Modules Report:")

  display.Prefix()
  ColourTell("silver", "", "  Chair:      ", color_module(modules["chair"]), "", string.format("%d", modules["chair"].id))
  if #modules["chair"].person > 0 then
    ColourNote("dimgray", "", " (" .. modules["chair"].person .. ")")
  else
    Note("")
  end

  display.Prefix()
  ColourTell("silver", "", "  Grid:       ", color_module(modules["grid"]), "", string.format("%d", modules["grid"].id))
  if #modules["grid"].person > 0 then
    ColourNote("dimgray", "", " (" .. modules["grid"].person .. ")")
  else
    Note("")
  end

  -- TODO: show cube, ramhead, orb, and aetherholds?

  display.Prefix()
  ColourTell("silver", "", "  Turrets:    ")
  if #modules["turret"] > 0 then
    for i,t in ipairs(modules["turret"]) do
      ColourTell(color_module(t), "", string.format("%d", t.id))
      if #t.person > 0 then
        ColourTell("dimgray", "", " (" .. t.person .. ")")
      end
      if i < #modules["turret"] then
        Tell("  ")
      end
    end
    Note("")
  else
    ColourNote("firebrick", "", " None found.")
  end

  display.Prefix()
  ColourTell("silver", "", "  Collectors: ")
  if #modules["collector"] > 0 then
    for i,t in ipairs(modules["collector"]) do
      ColourTell(color_module(t), "", string.format("%d", t.id))
      if #t.person > 0 then
        ColourTell("dimgray", "", " (" .. t.person .. ")")
      end
      if i < #modules["collector"] then
        Tell("  ")
      end
    end
    Note("")
  else
    display.Prefix()
    ColourNote("firebrick", "", "    None found.")
  end

  if IsConnected() then
    Send("")
  end
end


if #modname > 0 and IsConnected() then
  EnableTrigger("aethercraft_prompt__", true)
  prompt.queue(function () aethercraft.lock("", "", {aethercraft.modname}, {}) end, "aetherlock")
end
