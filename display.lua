module (..., package.seeall)

local figlet = require "figlet"

local sysid = GetVariable("sg1_id") or "SG1"
local saved = {}

standard_colors =
{
  prefix_bg = "saddlebrown",
  prefix_br = "goldenrod",
  prefix_id = "darkkhaki",

  info_bg = "black",
  info_tx = "white",

  alert_bg = "wheat",
  alert_tx = "brown",

  warning_bg = "firebrick",
  warning_tx = "gold",

  error_bg = "wheat",
  error_tx = "crimson",

  debug_bg = "black",
  debug_tx = "cadetblue",

  diff_br_bg = "black",
  diff_br_tx = "silver",
  diff_lo_bg = "black",
  diff_lo_tx = "salmon",
  diff_hi_bg = "black",
  diff_hi_tx = "lightgreen",

  timestamp_tx = "dimgray",
  timestamp_bg = "black",

  en_alert_tx = "black",
  en_alert_bg = "darkseagreen",
  en_leave_tx = "black",
  en_leave_bg = "darkseagreen",
  en_gone_tx = "darkslategray",
  en_gone_bg = "mediumturquoise",
  en_return_tx = "mediumturquoise",
  en_return_bg = "darkslategray",
  en_aura_tx = "linen",
  en_aura_bg = "mediumorchid",
}

q = false

local debug_cats = {"actions", "affs", "bals", "bash", "beast", "cures", "debate", "defs", "enemy", "failsafes", "flags", "gear", "gmcp", "iff", "map", "scan", "todo", "wounds"}


function debug_switch(name, line, wildcards, styles)
  local cat = string.lower(wildcards[1])
  local on = string.lower(wildcards[2]) == "on"

  if on then
    SetVariable("sg1_option_debug_" .. cat, 1)
    Info("Switched on '" .. cat .. "' debug")
  else
    DeleteVariable("sg1_option_debug_" .. cat)
    Info("Switched off '" .. cat .. "' debug")
  end
  if cat == "gmcp" then
    EnableAlias("debug_gmcp__", GetVariable("sg1_option_debug_gmcp") == "1")
  end
end

function debug_toggle(name, line, wildcards, styles)
  if string.lower(wildcards[1] or "") == "off" then
    for _,d in ipairs(debug_cats) do
      DeleteVariable("sg1_option_debug_" .. d)
    end
    Info("Switched off all debug")
  else
    for _,d in ipairs(debug_cats) do
      SetVariable("sg1_option_debug_" .. d, 1)
    end
    Info("Switched on all debug")
  end
  EnableAlias("debug_gmcp__", GetVariable("sg1_option_debug_gmcp") == "1")
end

function debug_summary(name, line, wildcards, styles)
  Info("Debug Summary:")
  for _,d in ipairs(debug_cats) do
    Prefix()
    ColourTell("silver", "black", string.format("%11s", d) .. "  ")
    if GetVariable("sg1_option_debug_" .. d) == "1" then
      ColourNote("green", "", "ON")
    else
      ColourNote("red", "", "OFF")
    end
  end

  if IsConnected() then
    Send("")
  end
end

function debug_gmcp(name, line, wildcards, styles)
  if wildcards[1] == "Char.Vitals" or 
     wildcards[1] == "Char.Items.Remove" or
     wildcards[1] == "IRE.Rift.Change" then
    q = true
  end
  Debug("GMCP '" .. wildcards[1] .. "' -> '" .. wildcards[2] .. "'", "gmcp")
end


function enemy_alert(msg)
  Prefix()
  ColourNote(standard_colors.en_alert_tx, standard_colors.en_alert_bg, "Target: " .. msg)
end

function enemy_leaving(msg)
  Prefix()
  ColourNote(standard_colors.en_leave_tx, standard_colors.en_leave_bg, "Target: " .. msg)
end

function enemy_gone(msg)
  Prefix()
  ColourNote(standard_colors.en_gone_tx, standard_colors.en_gone_bg, "Target Gone: " .. msg)
end

function enemy_returned(msg)
  Prefix()
  ColourNote(standard_colors.en_return_tx, standard_colors.en_return_bg, "Target Returned: " .. msg)
end

function enemy_aura()
  Prefix()
  ColourNote(standard_colors.en_aura_tx, standard_colors.en_aura_bg, "Target: REBOUNDING UP")
end

function enemy_unaura()
  Prefix()
  ColourNote(standard_colors.en_aura_bg, standard_colors.en_aura_tx, "Target: REBOUNDING DOWN")
end

function enemy_noaura()
  Prefix()
  ColourNote(standard_colors.en_aura_bg, standard_colors.en_aura_tx, "Target: NO AURA OR SHIELD")
end


function Prefix(sub)
  local clr = standard_colors

  ColourTell(clr.prefix_br, clr.prefix_bg, "[")
  ColourTell(clr.prefix_id, clr.prefix_bg, sysid)
  if sub then
    ColourTell(clr.prefix_id, clr.prefix_bg, " " .. sub)
  end
  ColourTell(clr.prefix_br, clr.prefix_bg, "]")
  ColourTell("", clr.info_bg, " ")
end

function Info(msg, newline)
  if newline == nil then
    newline = true
  end

  if q then
    table.insert(saved, {fn = Info, msg = msg, nl = newline})
    return
  end

  local clr = standard_colors

  Prefix()
  if newline then
    ColourNote(clr.info_tx, clr.info_bg, msg)
  else
    ColourTell(clr.info_tx, clr.info_bg, msg)
  end
end

function Alert(msg)
  if q then
    table.insert(saved, {fn = Alert, msg = msg})
    return
  end

  local clr = standard_colors

  Prefix()
  ColourNote(clr.alert_tx, clr.alert_bg, msg)
end

function Warning(msg)
  if q then
    table.insert(saved, {fn = Warning, msg = msg})
    return
  end

  local clr = standard_colors

  Prefix()
  ColourNote(clr.warning_tx, clr.warning_bg, msg)
end

function Error(msg)
  if q then
    table.insert(saved, {fn = Error, msg = msg})
    return
  end

  local clr = standard_colors

  Prefix()
  ColourNote(clr.error_tx, clr.error_bg, msg)
end

function Debug(msg, ctg)
  if not ctg or #ctg < 1 or GetVariable("sg1_option_debug_" .. ctg) ~= "1" then
    return
  end

  if q then
    table.insert(saved, {tm = os.clock() - math.floor(os.clock() / 1000) * 1000, fn = Debug, mg = msg, nl = ctg})
    return
  end

  local clr = standard_colors

  Prefix("SR")
  if type(msg) == "table" then
    ColourTell("dimgray", "", "<" .. string.format("%6.3f", msg.tm) .. "> ")
    ColourNote(clr.debug_tx, clr.debug_bg, msg.mg)
  else
    local time_ms = os.clock() - math.floor(os.clock() / 1000) * 1000
    ColourTell("dimgray", "", "[" .. string.format("%6.3f", time_ms) .. "] ")
    ColourNote(clr.debug_tx, clr.debug_bg, msg)
  end
end

function Danger(msg)
  local count = tonumber(GetVariable("sg1_option_danger") or "2")
  if count > 5 then
    count = 5
  elseif count <= 0 then
    count = 1
  end
  for i = 1,count do
    display.Alert(msg)
  end
end

function Instakill(msg)
  local count = tonumber(GetVariable("sg1_option_instakill") or "3")
  if count > 5 then
    count = 5
  elseif count <= 0 then
    count = 1
  end
  for i = 1,count do
    display.Warning(msg)
  end
end


function afflist()
  local clr = {on = "salmon", off = "lightgreen"}
  ColourTell("silver", "", " [")
  local first = true
  for a in pairs(affs.mine()) do
    if not first then
      ColourTell("dimgray", "", "|")
    end
    if flags.get("scanned_" .. a) then
      ColourTell(clr.off, "", a)
    else
      ColourTell(clr.on, "", a)
    end
    first = false
  end
  ColourTell("silver", "", "]")
end

function timestamp(on)
  if not on then
    return
  end

  local clr = standard_colors
  local time_ms = os.clock() - math.floor(os.clock() / 1000) * 1000
  ColourTell(clr.timestamp_tx, clr.timestamp_bg, "[")
  Hyperlink("time_diff " .. os.clock() .. " " .. os.time(), string.format("%0.3f", time_ms), "Compute time difference", clr.timestamp_tx, clr.timestamp_bg, 0)
  ColourTell(clr.timestamp_tx, clr.timestamp_bg, "] ")
end

function elevation()
  ColourTell("lime", "", "[" .. string.upper(map.elevation()) .. "] ")
end

function defs_wanted(count)
  ColourTell("slategray", "", " [")
  Hyperlink("defs wanted", "Defup: " .. count, "Show defenses remaining", "steelblue", "", 0)
  ColourTell("slategray", "", "]")
end

function diff(a, s)
  local clr = standard_colors
  if a < 0 then
    ColourTell(clr.diff_br_tx, clr.diff_br_bg, " [", clr.diff_lo_tx, clr.diff_lo_bg, string.format("%+i%s", a, s), clr.diff_br_tx, clr.diff_br_bg, "]")
  elseif a > 0 then
    ColourTell(clr.diff_br_tx, clr.diff_br_bg, " [", clr.diff_hi_tx, clr.diff_hi_bg, string.format("%+i%s", a, s), clr.diff_br_tx, clr.diff_br_bg, "]")
  else
    return
  end
  scan.update = true
end

function fatality()
  figlet.readfont("poison.flf")
  local t = figlet.ascii_art("FATALITY", true, false)
  local red = 255
  for _,l in pairs(t) do
    red = red - (255 - 65) / #t
    Prefix()
    ColourNote(RGBColourToName(red), "",  "  " .. l)
  end
end

function winner()
  figlet.readfont("doom.flf")
  local green = 215
  local win = figlet.ascii_art("WINNER!!!", true, true)
  for _,l in pairs(win) do
    Prefix()
    ColourNote(RGBColourToName(255 + green * 256), "", "  " .. l)
    green = green - math.floor((215 - 105) / #win)
  end
end

function OnPrompt()
  q = false
  for _,d in ipairs(saved) do
    d.fn(d.msg or d, d.nl)
  end
  saved = {}
end

EnableAlias("debug_gmcp__", GetVariable("sg1_option_debug_gmcp") == "1")
