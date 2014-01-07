module (..., package.seeall)

local json = require "json"
require "main"

session_stats = {}
stats = main.bootstrap("roulette_stats") or {}
history = main.bootstrap("roulette_history") or {}

function bet_gold(name, line, wildcards, styles)
  local amt = wildcards[1]
  local num = wildcards[2]
  SetVariable("sg1_roulette_amount", amt)
  flags.set("bet_try", num, 5)
  Send("bet " .. amt .. " gold on " .. num)
end

function show_stats()
  display.Info("Roulette Report:")

  display.Prefix()
  ColourNote("darkcyan", "", "  Recent History")
  display.Prefix()
  Tell("    ")
  if #history < 1 then
    ColourTell("dimgray", "", "<no data>")
  else
    for i=1,math.min(15, #history) do
      ColourTell("dimgray", "", " " .. history[i])
    end
  end
  Note("")

  display.Prefix()
  ColourNote("darkcyan", "", "  Spin Statistics")
  display.Prefix()
  ColourTell("black", "", "     ", "lime", "green", "00", "dimgray", "", string.format("  %4d", session_stats["00"] or 0), "dimgray", "", string.format("  %4d", stats["00"] or 0))
  ColourNote("black", "", "     ", "lime", "green", " 0", "dimgray", "", string.format("  %4d", session_stats["0"] or 0), "dimgray", "", string.format("  %4d", stats["0"] or 0))
  local session_summary = {green = (session_stats["00"] or 0) + (session_stats["0"] or 0), black = 0, red = 0}
  local summary = {green = (stats["00"] or 0) + (stats["0"] or 0), black = 0, red = 0}
  session_summary.total = session_summary.green
  summary.total = summary.green
  for i=1,36,2 do
    local session_black = session_stats[tostring(i)] or 0
    local session_red = session_stats[tostring(i + 1)] or 0
    local black = stats[tostring(i)] or 0
    local red = stats[tostring(i + 1)] or 0

    session_summary.black = session_summary.black + session_black
    session_summary.red = session_summary.red + session_red
    session_summary.total = session_summary.total + session_black + session_red
    summary.black = summary.black + black
    summary.red = summary.red + red
    summary.total = summary.total + black + red

    display.Prefix()
    ColourTell("black", "", "     ", "black", "silver", string.format("%2d", i), "dimgray", "", string.format("  %4d", session_black), "dimgray", "", string.format("  %4d", black))
    ColourNote("black", "", "     ", "pink", "red", string.format("%2d", i + 1), "dimgray", "", string.format("  %4d", session_red), "dimgray", "", string.format("  %4d", red))
  end
  display.Prefix()
  ColourNote("darkcyan", "", "  Color Summary")
  display.Prefix()
  ColourTell("lime", "", "    Green     ")
  if session_summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%   ", session_summary.green / session_summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>   ")
  end
  if summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%", summary.green / summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>")
  end
  Note("")
  display.Prefix()
  ColourTell("black", "", "    ", "black", "silver", "Black", "", "", "     ")
  if session_summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%   ", session_summary.black / session_summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>   ")
  end
  if summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%", summary.black / summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>")
  end
  Note("")
  display.Prefix()
  ColourTell("red", "", "    Red       ")
  if session_summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%   ", session_summary.red / session_summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>   ")
  end
  if summary.total > 0 then
    ColourTell("silver", "", string.format("%8.3f%%", summary.red / summary.total * 100.0))
  else
    ColourTell("dimgray", "", "<no data>")
  end
  Note("")

  if IsConnected() then
    Send("")
  end
end

function reset_session()
  session_stats = {}
  flags.clear{"bet_try", "roulette_number"}

  display.Info("Roulette session statistics cleared")
end

function reset_all()
  session_stats = {}
  history = {}
  stats = {}
  flags.clear{"bet_try", "roulette_number"}

  DeleteVariable("sg1_roulette_history")
  DeleteVariable("sg1_roulette_stats")

  display.Info("Roulette statistics and history cleared")
end


function bet_placed(name, line, wildcards, styles)
  local num = wildcards[1]
  if flags.get("bet_try") ~= num then
    return
  end

  flags.clear("bet_try")
  flags.set("roulette_number", num, 300)
end

function bet_won(name, line, wildcards, styles)
  display.winner()
end

function ball_landed(name, line, wildcards, styles)
  local num = wildcards[1]
  local color = wildcards[2]

  display.Prefix()
  local fg = "lime"
  local bg = "green"
  if color == "black" then
    fg = "black"
    bg = "silver"
  elseif color == "red" then
    fg = "pink"
    bg = "red"
  end
  ColourNote(fg, bg, "Roulette ball landed on " .. num)

  session_stats[num] = (session_stats[num] or 0) + 1

  table.insert(history, 1, num)
  stats[num] = (stats[num] or 0) + 1

  main.archive("roulette_history", history)
  main.archive("roulette_stats", stats)

  local mynum = flags.get("roulette_number")
  if not mynum then
    return
  end

  flags.clear("roulette_number")
  if num == mynum then
    return
  end
  
  if main.auto("bet") and not main.is_paused() then
    local amt = GetVariable("sg1_roulette_amount")
    if amt then
      Execute("bet " .. amt .. " gold on " .. mynum)
    end
  end
end
