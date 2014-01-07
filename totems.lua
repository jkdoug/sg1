module(..., package.seeall)

require "json"

db = main.bootstrap("totems_db") or {}
 
function toggle(name, line, wc)
  local enable = string.lower(wc[1]) == "on"
  main.auto("carving", enable)
  EnableTrigger("totems_room__", enable)

  if enable then
    Send("date\nql")
  elseif IsConnected() then
    SendNoEcho("")
  end
end

local function date_math(days)
  local y = math.floor(days / 300)
  local m = math.floor((days % 300) / 25)
  local d = math.floor((days % 300) % 25)

  local cy = calendar.year
  local cm = calendar.months[calendar.month]
  local cd = calendar.day

  cd = cd + d
  while cd > 25 do
    cd = cd - 25
    cm = cm + 1
  end

  cm = cm + m
  while cm > 12 do
    cm = cm - 12
    cy = cy + 1
  end

  cy = cy + y

  return cy, cm, cd
end
  

function room(name, line, wildcards, styles)
  if not main.auto("carving") and not main.is_paused() then
    EnableTrigger("totems_room__", false)
    return
  end

  if string.find(line, "elder") then
    Send("totemcarve elder")
  else
    Send("p totem")
  end
end

function probe(name, line, wildcards, styles)
  local r = tostring(map.current_room)
  local y, m, d = date_math(tonumber(wildcards[1]))
  db[r] = {y = y, m = m, d = d}

  main.archive("totems_db", db)
end

function reset()
  local r = tostring(map.current_room)
  local y, m, d = date_math(289)
  db[r] = {y = y, m = m, d = d}

  main.archive("totems_db", db)
end

function generate_project()
  local t = {}
  local ca = calendar.day + calendar.months[calendar.month] * 25 + calendar.year * 300
  for r,i in pairs(db) do
    local a = i.d + i.m * 25 + i.y * 300
    if a > ca then
      table.insert(t, {r = r, d = i.d, m = i.m, y = i.y, w = a})
    end
  end
  
  table.sort(t, function(a,b) return a.w < b.w end)
  
  local prj = {
    "The following totems will revert on the indicated dates. The 'Map' column shows the room number you see on maps. Dates are in YYY-MM-DD format.",
    "",
    "  Date       Map    Name",
    "---------   -----   --------------------------------------------------",
  }

  for _,i in ipairs(t) do
    table.insert(prj, string.format("%4d-%02d-%02d  %-6s  %s", i.y, i.m, i.d, i.r, map.rooms[tonumber(i.r)].name))
  end

  return prj
end

function coming_reversions(name, line, wildcards, styles)
  local expiry = tonumber(wildcards[1]) or 25
  local t = {}
  local ca = calendar.day + calendar.months[calendar.month] * 25 + calendar.year * 300
  for r,i in pairs(db) do
    local a = i.d + i.m * 25 + i.y * 300
    if a < ca + expiry then
      table.insert(t, {r = r, d = i.d, m = i.m, y = i.y, w = a, reverted = ca > a})
    end
  end

  table.sort(t, function(a,b) return a.w < b.w end)

  display.Info("Totems Status Report:")
  for _,i in ipairs(t) do
    display.Prefix()
    if i.reverted then
      ColourTell("sienna", "", string.format("  %-12s", "REVERTED"))
    else
      ColourTell("silver", "", string.format("  %4d-%02d-%02d  ", i.y, i.m, i.d))
    end
    Hyperlink("go " .. i.r, i.r, "Travel to totem", map.colors.room_vnum, "", 0)
    Tell(string.rep(" ", 6 - string.len(i.r)))
    ColourNote(map.colors.room_name, "", map.rooms[tonumber(i.r)].name)
  end

  if IsConnected() then
    SendNoEcho("")
  end
end

prompt.queue(function ()
  if main.auto("carving") then
    EnableTrigger("totems_room__", true)
  end
end, "carving")
