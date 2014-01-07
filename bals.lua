module (..., package.seeall)

local lost = {}
local locked = {}
prone = false

function lose(b, time)
  if lost[b] then
    return
  end

  lost[b] = true

  if affs.slow() and time and time < 4 then
    time = 4
  end

  local dbg = "Balance '" .. b .. "' lost"
  if time then
    flags.set(b .. "_try", true, 0)
    if failsafe.fn[b] then
      failsafe.exec(b, time)
    end
    dbg = dbg .. " (timeout = " .. tostring(time) .. ")"
  end
  display.Debug(dbg, "bals")
end

function gain(b)
  if not lost[b] then
    return
  end

  lost[b] = nil
  flags.clear(b .. "_try")
  failsafe.disable(b)
  failsafe.disable(b .. "_off")
  scan.update = true

  display.Debug("Balance '" .. b .. "' restored", "bals")
end

function gained(name, line, wildcards, styles)
  gain(wildcards[1])
end

function gained_brew(name, line, wildcards, styles)
  gain(wildcards[1])
  flags.clear("brew_off")
end

function regain(name, line, wildcards, styles)
  local bx = {
    ["balance on all limbs"] = "bal",
    ["equilibrium"] = "eq",
    ["balance on your left arm"] = "larm",
    ["balance on your right arm"] = "rarm",
    ["balance on your left leg"] = "legs",
    ["balance on your right leg"] = "legs",
  }
  local wc = wildcards[1]
  if not bx[wc] then
    return
  end
  local fg = GetVariable("sg1_color_fg_" .. bx[wc]) or "silver"
  local bg = GetVariable("sg1_color_bg_" .. bx[wc]) or ""
  local t = flags.get(bx[wc] .. "_time")
  ColourTell(fg, bg, line)
  if t then
    ColourTell("dimgray", "", " [" .. string.format("%0.3f", os.clock() - t) .. "s]")
  end
  Note("")
end

function get(b)
  return not lost[b]
end

function reset()
  display.Debug("Balances cleared", "bals")
  lost = {}
end


function confirm(b, time)
  if not flags.get(b .. "_try") then
    return false
  end

  flags.clear(b .. "_try")
  failsafe.disable(b)
  if time then
    failsafe.exec(b .. "_off", time, true)
  end

  return true
end


function lock(name, line, wildcards, styles)
  local chan = string.lower(wildcards[1])
  locked[chan] = true
end

function unlock(name, line, wildcards, styles)
  local chan = string.lower(wildcards[1])
  locked[chan] = nil
end

function is_locked(chan)
  return locked[string.lower(chan)] or false
end


function can_act()
  if not get("bal") or not get("eq") then
    return false
  end

  if not get("rarm") or not get("larm") then
    return false
  end

  if (not get("sub") and not is_locked("sub")) or
     (not get("super") and not is_locked("super")) or
     (not get("id") and not is_locked("id")) then
    return false
  end

  return true
end


function pflags()
  local pf = ""
  if beast.locate() == "mounted" then
    pf = pf .. "m"
  else
    pf = pf .. "-"
  end
  if get("eq") then
    pf = pf .. "e"
  end
  if main.has_skill("psionics") then
    if get("sub") then
      pf = pf .. "s"
    end
    if get("super") then
      pf = pf .. "S"
    end
    if get("id") then
      pf = pf .. "i"
    end
  end
  if main.has_skill("kata") then
    if get("head") then
      pf = pf .. "h"
    end
    if get("legs") then
      pf = pf .. "L"
    end
    if get("larm") then
      pf = pf .. "l"
    end
    if get("rarm") then
      pf = pf .. "r"
    end
  elseif main.has_skill("bonecrusher") or main.has_skill("blademaster") then
    if get("larm") then
      pf = pf .. "l"
    end
    if get("rarm") then
      pf = pf .. "r"
    end
  end
  if get("bal") then
    pf = pf .. "x"
  end
  if defs.has("kafe") then
    pf = pf .. "k"
  end
  if defs.has("truehearing") or affs.has("deafness") then
    pf = pf .. "d"
  end
  if defs.has("sixthsense") or affs.has("blindness") then
    pf = pf .. "b"
  end
  if prone then
    pf = pf .. "p"
  end
  if prompt.cloaked then
    pf = pf .. "<>"
  end
  pf = pf .. "-"

  return pf
end


function show()
  local all = {"allheale", "beast", "brew", "charm", "focus", "health", "herb", "music", "purgative",
               "salve", "scroll", "sparkle"}

  if main.has_skill("bonecrusher") or main.has_skill("blademaster") then
    table.insert(all, "larm")
    table.insert(all, "rarm")
  end
  if main.has_skill("kata") then
    table.insert(all, "head")
    table.insert(all, "larm")
    table.insert(all, "rarm")
    table.insert(all, "legs")
  end
  if main.has_skill("psionics") then
    table.insert(all, "id")
    table.insert(all, "sub")
    table.insert(all, "super")
  end

  display.Info("Balance Status Report:")
  for _,bal in pairs(all) do
    display.Prefix()
    ColourTell("silver", "black", string.format("%11s", bal) .. "  ")
    if is_locked(bal) then
      ColourNote("yellow", "", "LOCKED")
    elseif lost[bal] then
      ColourNote("red", "", "OFF")
    else
      ColourNote("green", "", "ON")
    end
  end

  if IsConnected() then
    Send("")
  end
end


function failed(b)
  if flags.get(b .. "_try") then
    bals.gain(b)
  end
end

failsafe.fn.allheale = function ()
  bals.failed("allheale")
  flags.clear_elixir("allheale")
end

failsafe.fn.allheale_off = function ()
  bals.gain("allheale")
end

failsafe.fn.beast = function ()
  bals.failed("beast")
  flags.clear("beast_order")
end

failsafe.fn.beast_off = function ()
  bals.gain("beast")
end

failsafe.fn.brew = function ()
  bals.failed("brew")
end

failsafe.fn.brew_off = function ()
  bals.gain("brew")
end

failsafe.fn.charm = function ()
  bals.failed("charm")
end

failsafe.fn.charm_off = function ()
  bals.gain("charm")
end

failsafe.fn.focus = function ()
  bals.failed("focus")
  local f = flags.get("focusing")
  if f and f ~= "body" then
    flags.clear("focusing")
  end
end

failsafe.fn.focus_off = function ()
  bals.gain("focus")
end

failsafe.fn.health = function ()
  bals.failed("health")
  flags.clear("health_applying")
  flags.clear_elixir("health mana bromide")
end

failsafe.fn.health_off = function ()
  bals.gain("health")
end

failsafe.fn.herb = function ()
  bals.failed("herb")
  if flags.get("smoking") ~= "faeleaf" then
    flags.clear("smoking")
  end
end

failsafe.fn.herb_off = function ()
  bals.gain("herb")
end

failsafe.fn.music = function ()
  bals.failed("music")
end

failsafe.fn.music_off = function ()
  bals.gain("music")
end

failsafe.fn.purgative = function ()
  bals.failed("purgative")
  flags.clear_elixir("antidote choleric fire frost galvanism love phlegmatic sanguine")
end

failsafe.fn.purgative_off = function ()
  bals.gain("purgative")
end

failsafe.fn.salve = function ()
  bals.failed("salve")
  flags.clear{"salve", "regenerating_arms", "regenerating_chest",
    "regenerating_gut", "regenerating_head", "regenerating_legs"}
end

failsafe.fn.salve_off = function ()
  bals.gain("salve")
end

failsafe.fn.scroll = function ()
  bals.failed("scroll")
end

failsafe.fn.scroll_off = function ()
  bals.gain("scroll")
end

failsafe.fn.sparkle = function ()
  bals.failed("sparkle")
end

failsafe.fn.sparkle_off = function ()
  bals.gain("sparkle")
end
