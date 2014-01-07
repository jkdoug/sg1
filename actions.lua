module (..., package.seeall)

require "failsafe"

fn = {}
vial_map = {}
parry_pending = {}
parry_desired = {}

local cleanse_affs = {"cleanse", "mucous", "sap", "gunk", "muddy", "ectoplasm",
                      "ablaze", "slickness", "deathmarks", "stinky", "oil"}

function exec(action, params)
  if not action or action == "" then
    return
  end

  local func = fn[string.gsub(action, " ", "_")]
  if not func then
    display.Debug("Missing 'actions' method: " .. action, "actions")
    if params then
      Execute(action .. " " .. params)
    else
      Execute(action)
    end
    return
  end

  func(params)
end


local function eat(herb)
  --if not gear.find_herb(herb) then
    Send("outr " .. herb)
    if affs.slow() then
      flags.set("to_eat", herb, 0)
      EnableTrigger("eat_now__", true)
      failsafe.exec("eat_slow", 2)
    elseif affs.is_stupid() then
      Send("outr " .. herb)
      Send("eat " .. herb)
      Send("inr " .. herb)
      Send("eat " .. herb)
      Send("inr " .. herb)
    else
      Send("eat " .. herb)
    end
  --else
  --  Send("eat " .. herb)
  --end
end

local herbs = {
  ["a calamus root"] = "calamus",
  ["a sprig of chervil"] = "chervil",
  ["a plug of coltsfoot"] = "coltsfoot",
  ["a piece of black earwort"] = "earwort",
  ["a stalk of faeleaf"] = "faeleaf",
  ["a stem of galingale"] = "galingale",
  ["a horehound blossom"] = "horehound",
  ["a kafe bean"] = "kafe",
  ["kombu seaweed"] = "kombu",
  ["a sprig of marjoram"] = "marjoram",
  ["a piece of merbloom seaweed"] = "merbloom",
  ["a bog myrtle leaf"] = "myrtle",
  ["a bunch of pennyroyal"] = "pennyroyal",
  ["a reishi mushroom"] = "reishi",
  ["a sparkleberry"] = "sparkleberry",
  ["a wormwood stem"] = "wormwood",
  ["a yarrow sprig"] = "yarrow",
}
function ate_herb(name, line, wildcards, styles)
  local herb = herbs[wildcards[1]]
  if not herb then
    return
  end

  flags.set("maybe_ate", herb)
  if herb == "sparkleberry" then
    EnableTrigger("cure_burst_vessel__", true)
    EnableTrigger("cure_burst_vessels__", true)
    EnableTrigger("sparkleberry_healing__", true)
    prompt.queue(function ()
      EnableTrigger("cure_burst_vessel__", false)
      EnableTrigger("cure_burst_vessels__", false)
      EnableTrigger("sparkleberry_healing__", false)
    end, "sparkle_heal")
  else
    flags.set("last_cure", "eat " .. herb, 0)
    main.cures_on()
  end
  if flags.get("arena") then
    ate_herb_checked()
  end
end

function ate_herb_checked()
  local qherb = flags.get("maybe_ate")
  if not qherb then
    return
  end

  flags.clear("maybe_ate")
  if qherb == "sparkleberry" then
    if bals.confirm("sparkle", 10) then
      flags.clear{"slow_sent", "slow_going"}
    end
  elseif #qherb > 0 then
    if bals.confirm("herb", 3) then
      prompt.illqueue(function () affs.del(qherb) end)
      flags.clear{"slow_sent", "slow_going"}
    end
  end
end

local function sip_elixir(name)
  local et = flags.get("elixir") or {}
  table.insert(et, name)
  flags.set("elixir", et, 2)
  flags.set("sip_" .. name .. "_try", true, 2)
  Send("sip " .. name)
  display.Debug("Sipping " .. name, "actions")
end

local function using_enchantment(name)
  local using = flags.get("using_enchant") or {}
  table.insert(using, name)
  flags.set("using_enchant", using, 1)
end

function used_enchantment(name, line, wildcards, styles)
  local using = flags.get("using_enchant") or {}
  if #using > 0 then
    local used = table.remove(using)
    flags.set("used_enchant", used)
    if used == "powerful" then
      flags.set("last_cure", "rub focus")
      main.cures_on()
    end
    if #using > 0 then
      flags.set("using_enchant", using, 1)
    else
      flags.clear("using_enchant")
    end
  else
    display.Error("No action set for enchantment.")
  end
end

function activated_enchantment(name)
  if name == "waterwalk" and flags.get("used_enchant") == "surfboard" then
    name = "waterwalk"
  end
  display.Debug("Activated enchantment: '" .. tostring(name) .. "' (" .. tostring(flags.get("used_enchant")) .. ")", "actions")
  if flags.get("used_enchant") == name then
    magic.use_charge(name)
    flags.clear("used_enchant")
  end
end

function failed_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment(flags.get("used_enchant") or "") end, "actench")
end

function gust_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment("gust") end, "actench")
end

function icewall_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment("icewall") end, "actench")
end

function ignite_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment("ignite") end, "actench")
end

function size_enchantment(name, line, wildcards, styles)
  local e = "enlarge"
  if wildcards[1] == "shrink" then
    e = "diminish"
  end
  prompt.preillqueue(function () actions.activated_enchantment(e) end, "actench")
end

function sleep_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment("sleep") end, "actench")
end

function webbing_enchantment(name, line, wildcards, styles)
  prompt.preillqueue(function () actions.activated_enchantment("webbing") end, "actench")
end


failsafe.fn.apply_now = function ()
  if flags.get("to_apply") then
    flags.clear("to_apply")
    EnableTrigger("apply_now__", false)
  end
end

failsafe.fn.climb = function ()
  local dir = flags.get("climb_try")
  if dir and not flags.get("climbing_" .. dir) then
    flags.clear("climb_try")
  end
end

failsafe.fn.climb_up = function ()
  if flags.get("climbing_up") then
    flags.clear{"climbing_up", "climb_try"}
    display.Alert("Failed to climb out of the pit!")
  else
    EnableTrigger("climbed_out_rocks__", false)
  end
end

failsafe.fn.def = function ()
  EnableTrigger("def_start__", false)
end

failsafe.fn.diag = function ()
  flags.clear("diag_try")
  EnableTrigger("diag_start__", false)
end

failsafe.fn.eat_slow = function ()
  flags.clear("to_eat")
  EnableTrigger("eat_now__", false)
end

failsafe.fn.protection = function ()
  if flags.get("protectorate") then
    defs.del("protection")
    flags.clear("protectorate")
  end
end

failsafe.fn.rebounding = function ()
  flags.clear("aura_timer")
  if flags.get("smoking") == "faeleaf" then
    flags.clear("smoking")
  end
end

failsafe.fn.regeneration = function ()
  if flags.get("regenerating") then
    cures.clear("apply regeneration to " .. flags.get("regenerating"))
    flags.clear("regenerating")
  end
end

failsafe.fn.wait_for_speed = function ()
  if flags.get("waiting_for_speed") then
    defs.add("speed")
    flags.clear("waiting_for_speed")
  end
end

failsafe.fn.writhe = function ()
  if flags.get("writhe_try") then
    flags.clear{"writhing", "writhe_try"}
  end
end


function adrenaline()
  flags.set("speed_try", "adrenaline", 2)
  Send("adrenaline")
end

function apply_arnica(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  bals.lose("herb", 2)
  if affs.has("fractured_head") and
     not affs.slow() then
    flags.set("arnica_try", part, 2)
    Send("outr arnica")
    Send("outr arnica")
    Send("apply arnica to " .. part)
    Send("inr arnica")
    Send("apply arnica to " .. part)
    Send("inr arnica")
  else
    --if gear.find_herb("arnica") then
    --  flags.set("arnica_try", part, 2)
    --  Send("apply arnica to " .. part)
    --else
      Send("outr arnica")
      if affs.slow() then
        flags.set("to_apply", "arnica to " .. part, 0)
        EnableTrigger("apply_now__", true)
        failsafe.exec("apply_slow", 2)
      else
        flags.set("arnica_try", part, 2)
        Send("apply arnica to " .. part)
      end
    --end
  end
end

function apply_now(name, line, wildcards, styles)
  local stuff = string.lower(wildcards[1])
  if stuff == "arnica" and flags.get("to_apply") then
    if affs.slow() then
      flags.set("slow_sent", "apply arnica to " .. flags.get("to_apply"), 1.5)
    end
    flags.set("arnica_try", flags.get("to_apply"), 2)
    Send("apply " .. flags.get("to_apply"))
    flags.clear("to_apply")
    EnableTrigger("apply_now__", false)
    failsafe.disable("apply_slow")
  end
end

function apply_health(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  bals.lose("health", 2)
  flags.set("health_applying", part, 2)
  Send("apply health to " .. part)
end

function apply_salve(name, line, wildcards, styles)
  local salve = string.lower(wildcards[1])
  local part = string.lower(wildcards[2] or "")
  bals.lose("salve", 2)
  flags.set("salve", salve, 2)
  if #part > 0 then
    flags.set("applied_to", part, 2)
    Send("apply " .. salve .. " to " .. part)
  else
    flags.clear("applied_to")
    Send("apply " .. salve)
  end
end

function applied_arnica(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  if #part < 1 then
    part = flags.get("arnica_try")
    if not part then
      return
    end
  end

  if bals.confirm("herb", 8) then
    affs.del("arnica_" .. part, true)
    flags.set("last_cure", "apply arnica to " .. part, 0)
    flags.clear{"slow_sent", "slow_going"}
    main.cures_on()
  end
end

function applied_health(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  if bals.confirm("health", 8) then
    gear.decrement_application("healing")
    flags.set("last_cure", "apply health to " .. part, 0)
    main.cures_on()

    failsafe.disable("health")
    EnableTrigger("balance_health_failed__", true)
    prompt.queue(function () EnableTrigger("balance_health_failed__", false) end, "healthappfailed")

    flags.clear{"slow_sent", "slow_going"}
  end
end

function applied_salve(name, line, wildcards, styles)
  local salve = wildcards[1]
  local part = wildcards[2]

  if not bals.confirm("salve", 3) then
    return
  end

  gear.decrement_application(salve)

  if salve == "regeneration" then
    affs.del("regen_" .. part, true)
    flags.set("regenerating", part, 10)
    failsafe.exec("regeneration", 5, true)
  else
    affs.del(salve .. "_" .. part, true)
    flags.set("last_cure", "apply " .. salve .. " to " .. part, 0)
    main.cures_on()
  end

  flags.set("applied", salve)
  flags.clear{"salve", "slow_sent", "slow_going"}

  EnableTrigger("balance_salve_failed__", true)
  prompt.queue(function () EnableTrigger("balance_salve_failed__", false) flags.clear("applied_to") end, "salvefail")
end

function ash_herb(name, line, wildcards, styles)
  if string.find(wildcards[1], string.match(flags.get("last_cure") or "", "eat (%w+)") or "") then
    flags.clear{"herb_try", "last_cure"}
    bals.gain("herb")
  end
end

function ate_failed(name, line, wildcards, styles)
  if string.match(flags.get("last_cure") or "", "eat %w+") then
    bals.gain("herb")
    flags.clear("last_cure")
  end
end

function ate_offbal(name, line, wildcards, styles)
  if string.match(flags.get("last_cure") or "", "eat %w+") or
     string.match(flags.get("last_cure") or "", "apply arnica to %w+") then
    flags.clear("last_cure")
  end
end

function ate_sparkle_failed(name, line, wildcards, styles)
  bals.gain("sparkle")
end

function attitude(name, line, wildcards, styles)
  local at = string.lower(wildcards[1])
  flags.set("attitude_try", at, 2)
  Send("attitude " .. at)
end

function auto_tea(name, line, wildcards, styles)
  local tea = main.auto("tea")
  if tea == true or not tea then
    tea = "tea"
  end
  exec("sip " .. tea)
end


function blow_enchantment(name, line, wildcards, styles)
  local enchant = string.lower(wildcards[1])
  local targ
  if wildcards[2] and #wildcards[2] > 0 then
    targ = string.lower(wildcards[2])
  end
  using_enchantment(enchant)
  if targ then
    Send("blow " .. enchant .. " at " .. targ)
  else
    Send("blow " .. enchant)
  end
end


function climb(name, line, wildcards, styles)
  local xlate = {u = "up", d = "down"}
  local dir = string.lower(wildcards[1])
  dir = xlate[dir] or dir
  flags.set("climb_try", dir, 0)
  failsafe.exec("climb", 2)
  if dir:sub(1,1) == "u" then
    Send("climb up")
  elseif dir == "rocks" then
    flags.set("climb_rocks", true, 2)
    Send("climb rocks")
  else
    Send("climb down")
  end
end

function climbing_down(name, line, wildcards, styles)
  if flags.get("climb_try") then
    flags.clear("climb_try")
    flags.set("climbing_down", true, 0)
    prompt.queue(function ()
      if flags.get("climbing_down") then
        flags.clear("climbing_down")
        flags.set("climb_down", true, 0)
      end
    end, "climber")
  end
end

function climbing_up(name, line, wildcards, styles)
  if not flags.get("climb_try") then
    return
  end

  flags.clear("climb_try")
  local val = true
  if string.find(line, "advantage") then
    val = "rocks"
  end
  flags.set("climbing_up", val, 0)
  if flags.get("climb_rocks") then
    EnableTrigger("climbed_out_rocks__", true)
  end
end

function climbing_no_pit(name, line, wildcards, styles)
  prompt.preillqueue(function ()
    flags.clear{"climbing_up", "climb_try"}
    failsafe.disable("climb_up")
  end)
end

function climbing_trees(name, line, wildcards, styles)
  if flags.get("climb_try") then
    flags.clear{"climb_up", "climb_try"}
    failsafe.disable("climb")
  end
end

function climbed_rocks(name, line, wildcards, styles)
  flags.clear("climbing_up")
  failsafe.exec("climb_up")
end

function clotted()
  if flags.get("clot_try") then
    prompt.gag = true
    flags.clear{"clot_try", "scanned_bleeding_clot", "slow_sent", "slow_going"}
    affs.bleed(-20)
    flags.damaged_mana()
  end
end

function contort(name, line, wildcards, styles)
  local form = string.lower(wildcards[1])
  if #form > 0 and form ~= "impale" then
    flags.set("writhe_try", form, 0)
    Send("contort " .. form)
  else
    flags.set("writhe_try", true, 0)
    Send("contort")
  end
  failsafe.exec("writhe", 2)
end

function crank_enchantment(name, line, wildcards, styles)
  local enchant = string.lower(wildcards[1])
  using_enchantment(enchant)
  Send("crank " .. enchant)
  bals.lose("music", 2)
end

function cranked_enchantment(name, line, wildcards, styles)
  local using = flags.get("using_enchant") or {}
  if #using > 0 then
    if bals.confirm("music", 12) then
      flags.set("used_enchant", table.remove(using))
      if #using > 0 then
        flags.set("using_enchant", using, 1)
      else
        flags.clear("using_enchant")
      end
      prompt.preillqueue(function () actions.activated_enchantment(flags.get("used_enchant") or "") end)
    end
  else
    display.Error("No action set for enchantment.")
  end
end


function def()
  EnableTrigger("def_start__", true)
  failsafe.exec("def", 5)
  Send("def")
end

function diag()
  if not able.to("diagnose") then
    flags.set("diagnose", true, 0)
  end
  EnableTrigger("diag_start__", true)
  flags.set("diag_try", true, 0)
  failsafe.exec("diag", 2)
  Send("diag")
end

function diagnosing()
  if not flags.get("diag_try") then
    display.Alert("Possible diagnose illusion")
    return
  end

  if affs.has("earache") then
    flags.set("earache_timer", affs.has("earache"))
  end
  if affs.has("grey_whispers") then
    flags.set("grey_whispers_count", affs.has("grey_whispers"))
  end

  flags.clear{"diag_try", "diagnose", "damaged_health", "damaged_mana", "damaged_ego", "damaged_power",
    "telepathy", "blackout", "harmonics_gem_hit"}
  affs.reset(true)
  defs.del("insomnia")

  failsafe.disable("diag")
  EnableTrigger("diag_start__", false)
  EnableTriggerGroup("Diagnose", true)
  prompt.queue(actions.diagnosed, "diagnosed")
end

function diagnosed()
  EnableTriggerGroup("Diagnose", false)
  wounds.check()
  flags.clear{"slow_sent", "slow_going"}
end


function eat_herb(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  bals.lose("herb", 2)
  if herb == "chervil" then
    flags.set("eating_chervil", true, 1)
  elseif herb == "merbloom" then
    flags.set("insomnia_try", true, 2)
  end
  eat(herb)
end

function eat_now(name, line, wildcards, styles)
  local stuff = string.lower(wildcards[1])
  if stuff == flags.get("to_eat") then
    if affs.slow() then
      flags.set("slow_sent", "eat %1", 1.5)
    end
    Send("eat " .. stuff)
    flags.clear("to_eat")
    EnableTrigger("eat_now__", false)
    failsafe.disable("eat_slow")
  end
end

function eat_sparkleberry()
  bals.lose("sparkle", 4)
  eat("sparkleberry")
end


function escape_p5()
  if not affs.has("deafness") and
     not defs.has("truehearing") then
    if not flags.get("to_eat") and
       not affs.has("earache") then
      Execute("eat earwort")
    end
  end

  if not flags.get("tumbling") and
     not affs.slow() then
    -- User's choice
    if flags.get("tumble_dir") then
      Execute("tumble " .. flags.get("tumble_dir"))
    -- Go back the way you came in
    elseif map.is_exit_valid(map.dir_reverse[map.last_move or "none"]) then
      Execute("tumble " .. map.dir_reverse[map.last_move])
    -- Completely random exit
    else
      local x = {}
      for d in pairs(map.rooms[map.current_room].exits) do
        table.insert(x, d)
      end
      local r = math.random(#x)
      Execute("tumble " .. x[r])
    end
  end  
end


function fastwrithe(name, line, wildcards, styles)
  flags.set("fastwrithe", wildcards[1], 2)
  for _,i in ipairs{"entangled", "roped", "shackled", "trussed"} do
    if affs.has(i) then
      flags.set("scanned_" .. i, true, 0.5)
    end
  end
  Send(wildcards[0])
end

function focus(name, line, wildcards, styles)
  local f = string.lower(wildcards[1])
  bals.lose("focus", 2)
  flags.set("focusing", f, 2)
  Send("focus " .. f)
end

function focused(name, line, wildcards, styles)
  if not bals.confirm("focus", 5) then
    return
  end

  local _,_,f = string.find(name, "^focused_(%a-)_")
  if not f then
    display.Error("WTFBBQ!")
    return
  end

  affs.del("focus_" .. f)
  if string.find("mind spirit", f) then
    flags.clear("focusing")
    flags.set("last_cure", "focus " .. f, 0)
    main.cures_on()
    if f == "mind" then
      prompt.preillqueue(function ()
        if flags.get("last_cure") then
          if affs.has("telepathy") or affs.has("hidden_mental") then
            local lh = flags.get("last_hidden")
            affs.hidden("hidden_kombu")
            if lh then
              flags.set("last_hidden")
            end
          end
        end
      end, "unfocusable")
    end
  else
    flags.set("focusing", "body", 4)
  end

  flags.clear{"slow_sent", "slow_going"}
end


function hold_breath()
  flags.set("hold_breath_try", true, 2)
  Send("hold breath")
end

function hungered()
  if flags.get("hunger_try") then
    flags.clear{"hunger_try", "slow_sent", "slow_going"}
    main.cures_on()

    local nutrition = (flags.get("nutrition") or 0) - 1
    flags.set("nutrition", nutrition, 300)
    if nutrition <= -3 then
      display.Warning("You should really find some food to eat!")
    end
  end
end


function jitterbug_herb(name, line, wildcards, styles)
  if flags.get("maybe_ate") == "sparkleberry" then
    flags.clear("sparkle_try")
  elseif string.match(flags.get("last_cure") or "", "eat (%w+)") then
    flags.unscan(flags.get("last_cure") or "")
    flags.clear{"herb_try", "last_cure"}
  end
end


function kneel(name, line, wildcards, styles)
  flags.set("stand_try", true, 0)
  Send("kneel " .. (wildcards[1] or ""))
end


function metawake(name, line, wildcards, styles)
  local tog = string.lower(wildcards[1]) == "on"
  if tog and not main.auto("metawake") then
    Execute("auto metawake on")
  elseif not tog and main.auto("metawake") then
    Execute("auto metawake off")
  else
    flags.set("metawake_try", true, 2)
    Send(line)
  end
end

function mindset(name, line, wildcards, styles)
  local ms = string.lower(wildcards[1])
  flags.set("mindset_try", ms, 2)
  -- TODO: set new mindset for debate module
  Send("mindset " .. ms)
end


function no_apply(name, line, wildcards, styles)
  if flags.get("salve") then
    display.Alert("You may be out of " .. flags.get("salve") .. "!")
    flags.clear("salve")
  end
end

function no_drink(name, line, wildcards, styles)
  local elix = find_elixir()
  if elix ~= "unknown" then
    display.Alert("You may be out of " .. elix .. "!")
  end
end


function power_cure(name, line, wildcards, styles)
  flags.set("power_cure_try", true, 2)
  Send(wildcards[1] .. " " .. wildcards[2])
end

function simple(name, line, wildcards, styles)
  local cmd = string.lower(wildcards[0])
  flags.set(string.gsub(cmd, "%s+", "_") .. "_try", true, 2)
  Send(cmd)
end


function raise_shield(name, line, wildcards, styles)
  flags.set("shield_try", true, 2)
  Send(wildcards[1] .. " " .. wildcards[2])
end

function read_scroll(name, line, wildcards, styles)
  local pick = string.lower(wildcards[1])

  local item, tome = magic.scroll(pick)
  if not item then
    display.Error("No " .. pick .. " scroll found. Check MagicList!")
    return
  end
  if not tome and item.charges <= 1 then
    display.Alert("Scroll of " .. pick .. " has only one charge left!")
    return
  end

  if tome then
    Execute("read magictome " .. pick)
  else
    if pick == "healing" then
      bals.lose("scroll", 2)
    end
    Send("read " .. item.id)
  end
end

function read_scroll_to(name, line, wildcards, styles)
  local pick = string.lower(wildcards[1])
  local target = string.lower(wildcards[2])

  local scroll = pick
  if scroll == "curses" then
    scroll = "cursed"
  end

  local item, tome = magic.scroll(scroll)
  if not item then
    display.Error("No " .. pick .. " scroll found. Check MagicList!")
    return
  end

  if tome then
    Execute("read magictome " .. pick .. " to " .. target)
  else
    flags.set(pick .. "_try", true, 2)
    Send("read " .. pick .. " to " .. target)
  end
end

function read_magictome(name, line, wildcards, styles)
  local pick = string.lower(wildcards[1])

  local item = magic.scroll(pick)
  if not item or item.charges < 1 then
    display.Alert("Magic tome needs " .. pick .. " charges!")
    return
  end

  if pick == "healing" then
    bals.lose("scroll", 2)
  end
  
  flags.set("tome_" .. pick, true, 2)
  Send("read magictome " .. pick)
end

function read_magictome_to(name, line, wildcards, styles)
  local pick = string.lower(wildcards[1])
  local target = string.lower(wildcards[2])

  local scroll = pick
  if scroll == "curses" then
    scroll = "cursed"
  end

  local item = magic.scroll(scroll)
  if not item or item.charges < 1 then
    display.Alert("Magic tome needs " .. scroll .. " charges!")
    return
  end

  flags.set("tome_" .. pick, target, 2)
  Send("read magictome " .. pick .. " to " .. target)
end

function healing_read(name, line, wildcards, styles)
  local tome = string.find(name, "tome") ~= nil or (affs.has("blackout") and flags.get("tome_healing"))
  bals.confirm("scroll", 9)
  magic.use_charge("healing", tome)
  if tome then
    flags.clear("tome_healing")
  else
    flags.clear("scroll_try")
  end
end

function protection_read(name, line, wildcards, styles)
  local tome = string.find(name, "tome") ~= nil
  flags.set("protectorate", true, 0)
  failsafe.exec("protection", 10)
  magic.use_charge("protection", tome)
  if tome then
    flags.clear("tome_protection")
  else
    flags.clear("protection_try")
  end
end

function curses_read(name, line, wildcards, styles)
  local tome = string.find(name, "tome") ~= nil
  magic.use_charge("cursed", tome)
  if tome then
    flags.clear("tome_curses")
  else
    flags.clear("curses_try")
  end
end

function disruption_read(name, line, wildcards, styles)
  local tome = string.find(name, "tome") ~= nil
  magic.use_charge("disruption", tome)
  if tome then
    flags.clear("tome_disruption")
  else
    flags.clear("disrupt_try")
  end
end

function tome_read(name, line, wildcards, styles)
  if flags.get("tome_healing") then
    healing_read("tome")
  elseif flags.get("tome_protection") then
    protection_read("tome")
  end
end

function tome_read_to(name, line, wildcards, styles)
  local targ = string.lower(wildcards[1])
  if flags.get("tome_curses") == targ then
    curses_read("tome")
  elseif flags.get("tome_disruption") == targ then
    disruption_read("tome")
  end
end


function restore(name, line, wildcards, styles)
  flags.set("restore_try", true, 2)
  flags.set("scanned_broken_arm", true, 0.5)
  flags.set("scanned_broken_leg", true, 0.5)
  Send("restore")
end

function retrieve(name, line, wildcards, styles)
  flags.set("retrieve_try", true, 2)
  for i,c in pairs(failsafe.items_stored or {}) do
    Send("g " .. i .. " from " .. c)
  end
end

function rewear(name, line, wildcards, styles)
  flags.set("rewear_try", true, 2)
  for i in pairs(failsafe.items_unworn or {}) do
    if gear.inventory[i] then
      Send("don " .. i)
    end
  end
end


function point_enchantment(name, line, wildcards, styles)
  local enchant = string.lower(wildcards[1])
  local targ = string.lower(wildcards[2])
  if enchant == "ignite" and targ == "me" then
    flags.set("ignite_try", true, 2)
    for _,th in ipairs{"thorns_head", "thorns_leftarm", "thorns_leftleg", "thorns_rightarm", "thorns_rightleg"} do
      if affs.has(th) then
        flags.set("scanned_" .. th, true, 0.5)
      end
    end
  end
  using_enchantment(enchant)
  Send("point " .. enchant .. " at " .. targ)
end

function rub_enchantment(name, line, wildcards, styles)
  local enchant = string.lower(wildcards[1])
  local targ
  if wildcards[2] and #wildcards[2] > 0 then
    targ = string.lower(wildcards[2])
  end
  if enchant == "nimbus" then
    using_enchantment("cosmic")
  else
    using_enchantment(enchant)
  end
  if targ then
    Send("rub " .. enchant .. " " .. targ)
  else
    Send("rub " .. enchant)
  end
end

function rubbed_cleanse(name, line, wildcards, styles)
  local targ = wildcards[1]
  local act = wildcards[2]
  if targ == "you" then
    if string.find(act, "wash away the slimy muco?us") then
      scrubbed("cure_scrub_mucous__")
    elseif string.find(act, "wash away that sticky sap") then
      scrubbed("cure_scrub_sap__")
    elseif string.find(act, "wash away that awful mud caked all over your body") then
      scrubbed("cure_scrub_muddy__")
    elseif string.find(act, "wash away the horrible ectoplasm") then
      scrubbed("cure_scrub_ectoplasm__")
    elseif string.find(act, "wash away that horrible stench") then
      scrubbed("cure_scrub_stinky__")
    elseif string.find(act, "scrub all over until the oil on your skin is gone") then
      scrubbed("cure_scrub_slickness__")
    elseif string.find(act, "trying to wipe away the dark mark that stains your skin") then
      scrubbed("cure_scrub_deathmarks__")
    elseif string.find(act, "you are squeaky clean") then
      scrubbed("cure_scrub_clean__")
    end
    EnableTriggerGroup("Cleanse", true)
    prompt.queue(function () EnableTriggerGroup("Cleanse", false) end, "cleansed")
  end
  if flags.get("used_enchant") == "cleanse" then
    activated_enchantment("cleanse")
  end
end

function rub_focus(name, line, wildcards, styles)
  bals.lose("charm", 2)
  using_enchantment("powerful")
  Send("rub focus")
end

function rubbed_focus()
  if bals.confirm("charm", 7) then
    affs.del("focus", true)
    flags.set("last_cure", "rub focus")
    magic.use_charge("powerful")
    main.cures_on()
  end
end

function rub_medicinebag(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  bals.lose("health", 2)
  flags.set("health_applying", part, 0)
  Send("rub medicinebag on ", part)
end

function rubbed_medicinebag(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1] or "", " ", "")
  if #part < 1 then
    part = nil
    flags.set("last_cure", "apply health to " .. (flags.get("health_applying") or "skin"))
  end

  local uses = tonumber(GetVariable("sg1_medbag") or "0")
  if not flags.get("arena") then
    uses = uses - 1
  end
  if uses < 1 then
    uses = 1
  end
  SetVariable("sg1_medbag", uses)
  flags.clear{"medbag_rub", "slow_sent", "slow_going"}

  main.info("MedBag")

  if bals.confirm("health", 8) then
    flags.set("medbag_rub", part or true)
    failsafe.disable("health")
    main.cures_on()
  end
end

function rewield()
  local i = 0
  for w in pairs(gear.rewield) do
    if gear.inventory[w] then
      Send("wield " .. w)
      i = i + 1
      if i >= 2 then
        flags.set("rewield_try", true, 1)
        return
      end
--    else
--      gear.rewield[w] = nil
    end
  end

  if i > 0 then
    flags.set("rewield_try", true, 1)
  end
end


function scrub()
  flags.set("cleanse_try", true, 2)
  Send("scrub")
end

function scrubbed(name, line, wildcards, styles)
  flags.clear("cleanse_try")

  local aff = string.match(name, "^cure_scrub_(%a+)__$")
  if not aff then
    display.Error("Invalid scrub trigger: " .. name)
    return
  end

  if aff == "deathmarks" then
    affs.deathmark(-2)
  elseif aff == "oil" or aff == "clean" then
    defs.del_queue{"dragonsblood", "jasmine", "musk", "sandalwood", "vanilla"}
  end

  local adel = {}
  for _,ca in ipairs(cleanse_affs) do
    if ca ~= "deathmarks" and ca ~= "ablaze" then
      table.insert(adel, ca)
    end

    if ca == "sap" then
      flags.clear{"slow_sent", "slow_going"}
    end

    if aff == ca then
      break
    end
  end
  affs.del_queue(adel)
end

function stance(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  flags.set("stance_try", part, 2)
  Send("stance " .. part)
end

function stanced(name, line, wildcards, styles)
  local part = wildcards[1]
  if part == "vital" then
    part = "vitals"
  end
  defs.add_queue("stance", part)
  flags.clear("stance_try")
  flags.clear{"slow_sent", "slow_going"}
end

function unstanced()
  defs.del_queue("stance")
  flags.clear("stance_try")
end


function find_elixir()
  local elixir = "unknown"
  local et = flags.get("elixir") or {}
  if #et > 0 then
    elixir = table.remove(et, 1)
  end

  if #et < 1 then
    flags.clear("elixir")
  else
    flags.set("elixir", et, 2)
  end
  return elixir
end

function sipped_allheale()
  if bals.confirm("allheale", 25) then
    flags.set("last_cure", "sip allheale")
    flags.clear{"slow_going", "slow_sent", "scanned_allheale"}
    main.allcure(true)
  end
end

function sipped_hme()
  for _,purg in ipairs{"antidote", "choleric", "fire", "frost", "love", "phlegmatic", "sanguine"} do
    if string.find(flags.get("last_cure") or "", purg) then
      prompt.queue(function () flags.set("purgative_try", purg, 2) end, "hme_purgative")
    end
  end
  flags.clear{"slow_sent", "slow_going", "last_cure"}

  prompt.illqueue(function () bals.confirm("health", 8) end, "hme_reconfirm")
end

function sipped_health()
  sipped_hme()
end

function sipped(name, line, wildcards, styles)
  local vial = wildcards[3]
  local emptied = wildcards[1] == "down the last drop"
  local elixir = gear.xlate_potion[wildcards[2]] or wildcards[2]

  main.poisons_on()

  display.Debug("Sipped " .. elixir, "actions")

  local tried = flags.get("elixir") or {}
  for n,e in ipairs(tried) do
    if e == elixir then
      table.remove(tried, n)
      if #tried > 0 then
        flags.set("elixir", tried, 2)
      else
        flags.clear("elixir")
      end
      break
    end
  end

  flags.clear("sip_" .. elixir .. "_try")
  gear.decrement_potion(elixir, emptied)

  EnableGroup("Sipping", true)

  if string.find("health mana bromide", elixir) then
    if bals.confirm("health", 8) then
      flags.set("last_cure", "sip " .. elixir, 0)
      flags.clear{"slow_sent", "slow_going", "scanned_" .. elixir .. "_high", "scanned_" .. elixir .. "_mid", "scanned_" .. elixir .. "_low"}
    end
  elseif elixir == "allheale" then
    sipped_allheale()
  elseif string.find("antidote choleric fire frost galvanism love phlegmatic sanguine", elixir) then
    if bals.confirm("purgative", 4) then
      affs.del(elixir, true)
      flags.set("last_cure", "sip " .. elixir, 0)
      flags.clear{"slow_sent", "slow_going", "scanned_" .. elixir}
      main.cures_on()
    end
  elseif elixir == "quicksilver" then
    if flags.get("speed_try") then
      flags.clear{"slow_sent", "slow_going", "speed_try", "scanned_no_speed"}
      flags.set("waiting_for_speed", "quicksilver", 0)
      failsafe.exec("wait_for_speed", 7)
    end
  elseif string.find("blacktea greentea oolongtea teapot whitetea teapot", elixir) then
    flags.clear{"brew_off", "slow_sent", "slow_going", "scanned_no_tea"}
  end
end

function sip_allheale(name, line, wildcards, styles)
  bals.lose("allheale", 2)
  sip_elixir("allheale")
end

function sip_hme(name, line, wildcards, styles)
  local elixir = string.lower(wildcards[1])
  local xlate = {
    health = "healing",
    bromide = "bromides",
  }
  bals.lose("health", 2)
  flags.clear("health_applying")
  sip_elixir(xlate[elixir] or elixir)
end

function sip_moonwater(name, line, wildcards, styles)
  flags.set("moonwater_try", true, 2)
  sip_elixir("moonwater")
end

function sip_purgative(name, line, wildcards, styles)
  local elixir = string.lower(wildcards[1])
  bals.lose("purgative", 2)
  sip_elixir(elixir)
end

function sip_quicksilver(name, line, wildcards, styles)
  flags.set("speed_try", "quicksilver", 2)
  sip_elixir("quicksilver")
end

function sip_tea(name, line, wildcards, styles)
  local tea = string.lower(wildcards[1])
  if tea ~= "teapot" then
    tea = tea .. "tea"
  end
  sip_elixir(tea)
  flags.set("brew_off", true, 2)
end

function sit(name, line, wildcards, styles)
  flags.set("stand_try", true, 0)
  if #wildcards[1] > 0 then
    Send("sit on " .. string.lower(wildcards[1]))
  else
    Send("sit")
  end
end

function sleep(name, line, wildcards, styles)
  flags.set("wake_try", true, 0)
  Send("sleep")
end

function sprang_up(name, line, wildcards, styles)
  if flags.get("springup_try") then
    flags.clear{"slow_sent", "slow_going", "springup_try",
      "scanned_kneeling", "scanned_prone", "scanned_sitting"}
    affs.del_queue{"kneeling", "prone", "sitting"}
  end
end

function stood(name, line, wildcards, styles)
  if flags.get("stand_try") then
    flags.clear{"slow_sent", "slow_going", "stand_try",
      "scanned_kneeling", "scanned_prone", "scanned_sitting"}
    affs.del_queue{"kneeling", "prone", "sitting"}
    if affs.limb("left", "leg") ~= "healthy" then
      affs.limb_queue("left", "leg", "healthy")
    end
    if affs.limb("right", "leg") ~= "healthy" then
      affs.limb_queue("right", "leg", "healthy")
    end
  end
end

function succor()
  EnableTrigger("diag_start__", true)
  failsafe.exec("diag", 2)
  flags.set("diag_try", true, 0)
  Send("succor")
end


function touch_medicinebag(name, line, wildcards, styles)
  bals.lose("health", 2)
  flags.clear("health_applying")
  Send("touch medicinebag")
end

function touched_medicinebag(name, line, wildcards, styles)
  local nothing = wildcards[1] == "nothing"
  local uses = tonumber(GetVariable("sg1_medbag") or "0")
  if not flags.get("arena") then
    uses = uses - 1
  end
  if uses < 1 then
    uses = 1
  end
  SetVariable("sg1_medbag", uses)

  main.info("MedBag")

  if bals.confirm("health", 8) and not nothing then
    failsafe.disable("health")
    EnableTrigger("cure_burst_vessel__", true)
    EnableTrigger("cure_burst_vessels__", true)
    prompt.queue(function ()
      EnableTrigger("cure_burst_vessel__", false)
      EnableTrigger("cure_burst_vessels__", false)
    end, "tmedbag")
  end
  flags.clear{"slow_sent", "slow_going"}
end

function transmute(name, line, wildcards, styles)
  local amt = tonumber(wildcards[1])
  if not amt or amt < 1 or amt > 1000 then
    return
  end

  flags.set("transmute_try", true, 2)
  Send("transmute " .. amt)
end

function transmuted(name, line, wildcards, styles)
  if flags.get("transmute_try") then
    flags.damaged_mana()
    flags.clear("transmute_try")
  end
end

function tumble(name, line, wildcards, styles)
  if flags.get("tumble_try") and not bals.can_act() then
    return
  end
  local dir = string.lower(wildcards[1])
  dir = map.dir_lengthen[dir] or dir
  flags.set("tumble_try", dir, 2)
  Send("tumble " .. dir)
end

function tumble_auto(name, line, wildcards, styles)
  if not flags.get("tumble_dir") then
    return
  end
  tumble(name, line, {flags.get("tumble_dir")}, styles)
end

function tumble_setup(name, line, wildcards, styles)
  local dir = string.lower(wildcards[1])
  dir = map.dir_lengthen[dir] or dir
  flags.set("tumble_dir", dir, 30)
  scan.process()
end

function tumbling(name, line, wildcards, styles)
  local dir = wildcards[1]
  if string.find(dir, "ground") then
    dir = "below"
  else
    dir = wildcards[2]
  end
  if dir ~= flags.get("tumble_try") then
    return
  end
  flags.clear{"tumble_try", "tumble_dir"}
  flags.set("tumbling", dir, 6)

  display.Alert("YOU ARE TUMBLING " .. string.upper(dir) .. "!")

  if flags.get("slow_going") == "tumble " .. dir then
    flags.clear{"slow_sent", "slow_going"}
  end
end

function tumbled(name, line, wildcards, styles)
  local t = flags.get("tumbling")
  if not t then
    return
  end
  display.Alert("YOU TUMBLED " .. string.upper(t) .. "!")
  Execute("OnTumble " .. t)
  beast.lost()
  flags.clear{"tumbling", "tumble_dir"}
end

function tumble_fail(name, line, wildcards, styles)
  if flags.get("tumble_try") then
    local dir = flags.get("tumble_dir") or "that way"
    dir = map.dir_lengthen[dir] or dir
    display.Warning("YOU CANNOT TUMBLE " .. string.upper(dir) .. "!")
    flags.clear{"tumble_try", "tumble_dir"}
  end
end


function waking()
  if flags.get("wake_try") then
    flags.clear{"slow_sent", "slow_going", "wake_try"}
    flags.clear("wake_try")
    flags.set("waking", true, 0)
  end
end

function waked(name, line, wildcards, styles)
  flags.clear{"wake_try", "waking"}
  affs.del_queue("asleep")

  if name == "cure_asleep__" then
    defs.del_queue("insomnia")
  end
  affs.prone()
end


function wind_enchantment(name, line, wildcards, styles)
  local enchant = string.lower(wildcards[1])
  using_enchantment(enchant)
  Send("wind " .. enchant)
end

function writhe(name, line, wildcards, styles)
  local form = string.lower(wildcards[1])
  if #form > 0 and form ~= "impale" then
    flags.set("writhe_try", form, 0)
    Send("writhe " .. form)
  else
    flags.set("writhe_try", true, 0)
    Send("writhe")
  end
  failsafe.exec("writhe", 2)
end

function writhing(name, line, wildcards, styles)
  if flags.get("writhe_try") then
    local wt = string.match(name, "^writhing_(%a-)__$")
    failsafe.disable("writhe")
    flags.clear("writhe_try")
    local time = 6
    time = time + (affs.has("allergies") or 0) * 0.11
    flags.set("writhing", true, time)
    flags.clear_slow("writhe " .. wt)
  end
end
