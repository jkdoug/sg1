module (..., package.seeall)

local copytable = require "copytable"
local json = require "json"
local php = require "php"
local wait = require "wait"
require "display"
require "main"

rooms = {}
areas = {}
tags = {}
environments = {}
terrain_colors = {}
user_terrain = {}

moves = {}
last_title = ""
last_room = false
last_move = false
gmcp_room_name = ""
current_room = tonumber(GetVariable("sg1_map_current_room") or "0")
current_room_name = ""
current_area = tonumber(GetVariable("sg1_map_current_area") or "0")
current_area_name = GetVariable("sg1_map_current_area_name") or "<Unknown Area>"

area_off = {}
door_closed = false
door_locked = false
autowalk = 0

colors = {
  room_vnum = "yellowgreen",
  room_name = "wheat",
  area_vnum = "steelblue",
  area_name = "cadetblue",
}

people_who = {}

local function get_preferred_font(t)
  local fonts = utils.getfontfamilies()
  local f2 = {}
  for k in pairs(fonts) do
    f2[k:upper()] = true
  end  
  for _, s in ipairs(t) do
    if f2[s:upper()] then
      return s
    end
  end
  return "Courier"
end

local function max_text_width(win, font_id, t, utf8)
  local max = 0
  for _,s in ipairs(t) do
    max = math.max(max, WindowTextWidth(win, font_id, s, utf8))
  end
  return max
end

local function wildcard_to_area(area_name)
  if not area_name or #area_name < 1 then -- Empty, default to current area
    return current_area
  elseif tostring(tonumber(area_name)) == area_name then -- Numeric area ID
    return tonumber(area_name)
  else -- Search for area matches
    local area_found = find_areas(area_name, true, true)
    if #area_found < 1 then
      display.Warning("Your cartographer knows no areas matching your inquiry.")
      if IsConnected() then
        Send("")
      end
      return nil
    elseif #area_found > 1 then
      -- Look for an exact match before resigning
      local exm = false
      for _,a in ipairs(area_found) do
        if string.lower(areas[a]) == string.lower(area_name) then
          return a
        end
      end

      display.Warning(string.format("Your cartographer found %d areas matching your inquiry:", #area_found))
      for _,a in ipairs(area_found) do
        display.Prefix()
        ColourNote(colors.area_name, "", "  " .. php.strproper(areas[a]))
      end

      if IsConnected() then
        Send("")
      end
      return nil
    end
    return area_found[1]
  end
end

config = main.bootstrap("mapper_config") or {
  BACKGROUND_COLOR        = { name = "Background",        color = ColourNameToRGB "lightseagreen", },
  ROOM_COLOR              = { name = "Room",              color = ColourNameToRGB "#1E1E1E", },
  EXIT_COLOR              = { name = "Exit",              color = ColourNameToRGB "darkgreen", },
  EXIT_COLOR_UP_DOWN      = { name = "Exit up/down",      color = ColourNameToRGB "darkmagenta", },
  EXIT_COLOR_IN_OUT       = { name = "Exit in/out",       color = ColourNameToRGB "#3775E8", },
--  OUR_ROOM_COLOR          = { name = "Our room",          color = ColourNameToRGB "blue", },
  UNKNOWN_ROOM_COLOR      = { name = "Unknown room",      color = ColourNameToRGB "#00CACA", },
  DIFFERENT_AREA_COLOR    = { name = "Another area",      color = ColourNameToRGB "#009393", },
  SHOP_FILL_COLOR         = { name = "Shop",              color = ColourNameToRGB "darkolivegreen", },
  POSTOFFICE_FILL_COLOR   = { name = "Post Office",       color = ColourNameToRGB "yellowgreen", },
  BANK_FILL_COLOR         = { name = "Bank",              color = ColourNameToRGB "gold", },
  NEWSROOM_FILL_COLOR     = { name = "Newsroom",          color = ColourNameToRGB "lightblue", },

  ROOM_NAME_TEXT          = { name = "Room name text",    color = ColourNameToRGB "#BEF3F1", },
  ROOM_NAME_FILL          = { name = "Room name fill",    color = ColourNameToRGB "#105653", },
  ROOM_NAME_BORDER        = { name = "Room name box",     color = ColourNameToRGB "black", },

  AREA_NAME_TEXT          = { name = "Area name text",    color = ColourNameToRGB "#BEF3F1",},
  AREA_NAME_FILL          = { name = "Area name fill",    color = ColourNameToRGB "#105653", },
  AREA_NAME_BORDER        = { name = "Area name box",     color = ColourNameToRGB "black", },

  FONT = {
    name = get_preferred_font{"Arial", "Dina", "Tahoma", "Lucida Console", "Fixedsys", "Courier", "Sylfaen",},
    size = 9
  },

  SCAN = { depth = 30 },

  WINDOW = {
    width = 300,
    height = 300
  }
}
if GetVariable("sg1_map_config") then
  loadstring(GetVariable("sg1_map_config"))()
  main.archive("mapper_config", config)
  DeleteVariable("sg1_map_config")
end


dir_shorten = {
  ["north"] = "n",
  ["northeast"] = "ne",
  ["east"] = "e",
  ["southeast"] = "se",
  ["south"] = "s",
  ["southwest"] = "sw",
  ["west"] = "w",
  ["northwest"] = "nw",
  ["up"] = "u",
  ["down"] = "d",
  ["in"] = "in",
  ["out"] = "out",
}
dir_lengthen = {
  ["n"] = "north",
  ["e"] = "east",
  ["w"] = "west",
  ["s"] = "south",
  ["nw"] = "northwest",
  ["ne"] = "northeast",
  ["sw"] = "southwest",
  ["se"] = "southeast",
  ["u"] = "up",
  ["d"] = "down",
  ["in"] = "in",
  ["out"] = "out",
}
dir_reverse = {
  ["north"] = "south",
  ["northeast"] = "southwest",
  ["east"] = "west",
  ["southeast"] = "northwest",
  ["south"] = "north",
  ["southwest"] = "northeast",
  ["west"] = "east",
  ["northwest"] = "southeast",
  ["up"] = "down",
  ["down"] = "up",
  ["in"] = "out",
  ["out"] = "in"
}

local ansi_colors = {
  [0] = ColourNameToRGB("black"),
  [1] = ColourNameToRGB("maroon"),
  [2] = ColourNameToRGB("green"),
  [3] = ColourNameToRGB("olive"),
  [4] = ColourNameToRGB("navy"),
  [5] = ColourNameToRGB("purple"),
  [6] = ColourNameToRGB("teal"),
  [7] = ColourNameToRGB("silver"),
  [8] = ColourNameToRGB("gray"),
  [9] = ColourNameToRGB("red"),
  [10] = ColourNameToRGB("lime"),
  [11] = ColourNameToRGB("yellow"),
  [12] = ColourNameToRGB("blue"),
  [13] = ColourNameToRGB("magenta"),
  [14] = ColourNameToRGB("cyan"),
  [15] = ColourNameToRGB("white")
}

local db = false
local dbu = false
local loaded = false

win = "sg1map"

local FONT_ID = "fn"
local FONT_ID_UL = FONT_ID .. "u"
local FONT_CONFIG_ID = "fnc"
local FONT_CONFIG_ID_UL = FONT_CONFIG_ID .. "u"
local font_height = 0
local font_config_height = 0

local ROOM_SIZE = 10
local DISTANCE_TO_NEXT_ROOM = 15
local HALF_ROOM = 5
local connectors = {}
local half_connectors = {}
local arrows = {}
local plan_to_draw = {}
local drawn = {}
local drawn_coords = {}
local last_drawn = {}
local depth = 0


local function fix_room_name(name)
  if name and #name > 0 then
    name = string.gsub(name, "^In the trees above ", "")
    name = string.gsub(name, "^Flying above ", "")
    name = string.gsub(name, "^On the rooftops over ", "")
    name = string.gsub(name, "^In a pit at ", "")
    name = string.gsub(name, "^In the mountains above ", "")
    name = string.gsub(name, " %(road%)$", "")
  end
  
  return name
end

local function draw_3d_box(win, left, top, width, height)
  local right = left + width
  local bottom = top + height
  
  WindowCircleOp(win, 3, left, top, right, bottom, 0x505050, 0, 3, 0, 1)   -- dark grey border (3 pixels)
  WindowCircleOp(win, 3, left + 1, top + 1, right - 1, bottom - 1, 0x7C7C7C, 0, 1, 0, 1)  -- lighter inner border
  WindowCircleOp(win, 3, left + 2, top + 2, right - 2, bottom - 2, 0x000000, 0, 1, 0, 1)  -- black inside that
  WindowLine(win, left + 1, top + 1, right - 1, top + 1, 0xC2C2C2, 0, 1)  -- light top edge
  WindowLine(win, left + 1, top + 1, left + 1,  bottom - 1, 0xC2C2C2, 0, 1)  -- light left edge (for 3D look)
end

local function draw_text_box (win, font, left, top, text, utf8, text_colour, fill_colour, border_colour)
  local width       = WindowTextWidth (win, font, text, utf8)
  local font_height = WindowFontInfo (win, font, 1) 

  WindowRectOp(win, 2, left - 3, top, left + width + 3, top + font_height + 1, fill_colour)  -- fill
  WindowText(win, font, text, left, top, 0, 0, text_colour, utf8)   -- draw text
  WindowRectOp(win, 1, left - 3, top, left + width + 3, top + font_height + 1, border_colour)  -- border
  
  return width
end

--[[
'Room.Info' -> '{ "num": 931, "name": "(SOUTHSEREN119) The Moonhart Mother Tree", "area": "the Serenwilde Forest", "environment": "forest", "coords": "188,0,0,0", "map": "www.lusternia.com/irex/maps/clientmap.php?map=188&building=0&level=0 22 10", "details": [ "the Prime Material Plane", "outdoors" ], "exits": { "n": 5809, "s": 854, "x": 0 } }'
--]]
function got_room_info(name, line, wildcards, styles)
  local msg = wildcards[1]
  if not msg or #msg < 1 then
    return
  end
  display.q = true

  local room = json.decode(msg)
  display.Debug("Room[" .. room.num .. "] = " .. room.name .. " (" .. room.area .. " [" .. room.coords .. "])", "map")

  local vnum = tonumber(room.num)
  local coords = php.split(room.coords, ",")

--  local anum = (rooms[vnum] and rooms[vnum].area) or 0
--  if rooms[last_room] and current_area_name == room.area and (anum == 0 or not string.find(areas[anum], room.area)) then
--    current_area = rooms[last_room].area
--  else
--    current_area = anum
--  end

  last_room = current_room
  current_room = vnum
  gmcp_room_name = room.name
  current_room_name = fix_room_name(room.name)
  current_area = tonumber(coords[1]) or 0
  current_area_name = room.area

  if current_area ~= 0 and aethercraft.is_locked() then
    aethercraft.unlock()
  end
  if flags.get("mazed") and string.find(current_room_name, "in an illusory maze") then
    flags.clear("mazed")
    flags.set("in_maze", true, 0)
    prompt.queue(function () Execute("OnDanger Maze! Put shield up!") end, "amazed")
  end

  if not rooms[vnum] or rooms[vnum].unknown then
--    if #coords < 4 then
      -- TODO: lookup/create area?
--    end

    rooms[vnum] = {
      ["vnum"] = vnum,
      ["area"] = current_area,
      ["env"] = get_environment_id(room.environment),
      ["name"] = current_room_name,
      ["x"] = tonumber(coords[2]),
      ["y"] = tonumber(coords[3]),
      ["z"] = tonumber(coords[4]),
      ["exits"] = {},
      ["spexits"] = {},
      ["tags"] = {},
      ["visited"] = not affs.has("dementia"),
      ["plane"] = room.details[1],
      ["indoors"] = room.details[2] == "indoors",
    }
    for dir,to in pairs(room.exits) do
      if dir ~= "x" then
        rooms[vnum].exits[dir_lengthen[dir] or dir] = to
      end
    end
    gui_config_room(vnum)

    save_room(rooms[vnum])
  else
    local updated = false
    if current_room_name ~= php.strproper(rooms[vnum].name or "") then
      rooms[vnum].name = current_room_name
      updated = true
    end

    for dir,to in pairs(room.exits) do
      if dir ~= "x" and rooms[vnum].exits[dir_lengthen[dir] or dir] ~= to then
        rooms[vnum].exits[dir_lengthen[dir] or dir] = to
        updated = true
      end
    end

    if updated then
      gui_config_room(vnum)
      save_room(rooms[vnum])
      gui_draw()
    end

    if not rooms[vnum].plane then
      rooms[vnum].plane = room.details[1]
      rooms[vnum].indoors = room.details[2] == "indoors"
      save_room_details(rooms[vnum])
    end
  end

  if current_area > 0 and not areas[current_area] then
    areas[current_area] = current_area_name
    save_area(current_area, current_area_name)
  end

  if not affs.has("dementia") then
    room_visited(vnum)
    affs.del("perfect_fifth")
  end

  SetVariable("sg1_map_current_room", current_room)
  SetVariable("sg1_map_current_area", current_area or 0)
  SetVariable("sg1_map_current_area_name", current_area_name)

  if autowalk == 1 then
    autowalk = 2
  end

  if last_room and last_room ~= current_room then
    changed_room()
  elseif flags.get("climbing_up") and map.elevation() ~= "pit" then
    flags.clear{"climbing_up", "climb_try"}
    failsafe.disable("climb")
    failsafe.exec("climb_up")
  elseif flags.get("climbing_down") and map.elevation() ~= "trees" then
    flags.clear{"climbing_down", "climb_try"}
    failsafe.disable("climb")
  end
  display.q = false
end

function changed_room()
  gui_draw()

  if flags.get("spexit") then
    local spexit = flags.get("spexit")
    if not rooms[spexit.from] then
      prompt.queue(function () display.Error("Your cartographer doesn't know from whence you started this special journey.") end, "sperror")
    else
      prompt.queue(function () display.Info("Creating special exit '" .. spexit.cmd .. "' from " .. spexit.from .. " to " .. current_room) end, "spexited")
      rooms[spexit.from].spexits[spexit.cmd] = {
        ["to"] = current_room,
        ["cost"] = 3,
        ["alias"] = spexit.alias
      }
      save_special_exit{from = spexit.from, to = current_room, cmd = spexit.cmd, cost = 3, alias = spexit.alias}
    end
    flags.clear("spexit")
  end

  if flags.get("arena_event") then
    if current_area == 54 or    -- Avenger
       current_area == 60 or    -- Shadowvale
       current_area == 67 or    -- Midnight
       current_area == 70 or    -- Glade
       current_area == 72 or    -- Amberle
       current_area == 205 or   -- Skylark
       current_area == 212 then -- Pyrodome
      main.arena_enter()
    end
  end

  if flags.get("arena") and
     (current_room == 6056 or   -- Avenger
      current_room == 6057 or
      current_room == 10163 or  -- Amberle
      current_room == 10164 or
      current_room == 10918 or  -- Shadowvale
      current_room == 10919 or
      current_room == 8962 or   -- Midnight
      current_room == 9116 or
      current_room == 21868 or  -- Skylark
      current_room == 21871 or
      current_room == 23917 or  -- Pyrodome
      current_room == 23946 or
      current_room == 9362 or   -- Glade
      current_room == 9363) then      
    main.arena_leave()
  end

  local do_scan = false
  if flags.get("aurawarper") then
    enemy.reset(flags.get("aurawarper"))
    do_scan = true
  end
  if flags.get("bedeviler") then
    enemy.reset(flags.get("bedeviler"))
    do_scan = true
  end
  if flags.get("maestoso_caster") then
    enemy.reset(flags.get("maestoso_caster"))
    do_scan = true
  end
  if flags.get("maestoso") then
    flags.clear{"maestoso", "maestoso_caster"}
    do_scan = true
  end

  if do_scan then
    scan.process()
  end
end

function room_visited(vnum)
  if not vnum then
    return
  end

  if rooms[vnum] and not rooms[vnum].visited then
    dbu:execute(string.format("REPLACE INTO visited (uid, date_added) VALUES (%s, DATETIME('NOW'))", fixsql(vnum)))
    rooms[vnum].visited = true

    rooms[vnum].unknown = nil
  end
end

local areas_nil = {
}
local areas_plane = {
  [3] = "the Realm of the Fates", -- Shallamar
  [23] = "the Ethereal Plane", -- Etherwilde
  [25] = "the Ethereal Plane", -- Faethorn
  [28] = "the Ethereal Plane", -- Etherglom
  [109] = "the Ethereal Plane", -- Catacombs of the Dead
  [134] = "the Ethereal Plane", -- Wydyr Glade
  [140] = "the Ethereal Plane", -- Maeve Gardens
  [149] = "the Ethereal Plane", -- Crystal Meadows
  [29] = "the Astral Plane", -- Taurus
  [30] = "the Astral Plane", -- Capricorn
  [31] = "the Astral Plane", -- Aries
  [32] = "the Astral Plane", -- Gemini
  [33] = "the Astral Plane", -- Cancer
  [34] = "the Astral Plane", -- Leo
  [35] = "the Astral Plane", -- Libra
  [36] = "the Astral Plane", -- Virgo
  [37] = "the Astral Plane", -- Scorpio
  [38] = "the Astral Plane", -- Sagittarius
  [39] = "the Astral Plane", -- Aquarius
  [40] = "the Astral Plane", -- Pisces
  [65] = "Tainted Plane of Nil", -- Nil
  [66] = "Celestia, Plane of Light", -- Celestia
  [98] = "the Water Elemental Plane", -- Mystic River
  [120] = "the Water Elemental Plane", -- Great Starry Sea
  [121] = "the Water Elemental Plane", -- Lake of Dreams
  [97] = "the Earth Elemental Plane", -- Catacombs of Corpus Clay
  [123] = "the Earth Elemental Plane", -- Mountains of Madness
  [179] = "the Cosmic Plane of Continuum", -- Continuum
  [180] = "the Cosmic Plane of Vortex", -- Vortex
  [183] = "the Fire Elemental Plane", -- Fire
  [184] = "the Air Elemental Plane", -- Air
  [106] = "an Aetherbubble", -- Frosticia
  [68] = "an Aetherbubble", -- Crumkindivia
  [99] = "an Aetherbubble", -- Facility
  [61] = "an Aetherbubble", -- Dramube
  [103] = "an Aetherbubble", -- Cankermore
  [102] = "an Aetherbubble", -- Xion
  [128] = "an Aetherbubble", -- Tree of Trees
  [137] = "an Aetherbubble", -- Bottledowns
  [172] = "an Aetherbubble", -- Mucklemarsh
  [48] = "an Aetherbubble", -- Moon
  [51] = "an Aetherbubble", -- Night
}

function get_room_plane(vnum)
  if not vnum or not rooms[vnum] or rooms[vnum].area == 0 then
    return nil
  end

  if rooms[vnum].plane then
    return rooms[vnum].plane
  end

  return areas_plane[rooms[vnum].area] or "the Prime Material Plane"
end

function cancel_speedwalk(reason)
  autowalk = 0
  for _,r in pairs(rooms) do
    r.pathing = nil
  end
  EnableTriggerGroup("Speedwalking", false)

  if reason then
    display.Info("Speedwalk cancelled; " .. reason .. ".")
  end
end

function go_next(quietly)
  if not current_room then
    cancel_speedwalk("you're lost")
    return
  end

  if not rooms[current_room].pathing or rooms[current_room].pathing == "dest" then
    cancel_speedwalk()
    flags.set("speedwalk_done", true, 0)
    return
  end

  local next_dir = rooms[current_room].pathing

  local move = false
  if dir_reverse[next_dir] then
    if door_closed then
      Send("open door " .. next_dir)
    elseif door_locked then
      door_locked = false
      door_closed = false

      cancel_speedwalk("door closed")
    else
      move = next_dir
    end
  else
    move = next_dir
  end

  if move then
    if dir_lengthen[move] or dir_shorten[move] then
      if quietly then
        SendNoEcho(move)
        prompt.gag = true
      else
        Send(move)
      end
    else
      Execute(move)
    end
  end

  autowalk = 1
end


failsafe.fn.mapper_who = function ()
  EnableTrigger("mapper_handle_who__", false)
  EnableTrigger("mapper_hide_who__", false)
  flags.clear("area_who")
  map.people_who = {}
end


function router(finish)
  if finish and rooms[finish] then
    local generation = {}
    local new_generation = {finish}

    for v,r in pairs(rooms) do
      r.pathing = nil
    end
    rooms[finish].pathing = "dest"

    local gen = 0
    local p = true
    while p do
      p = false
      generation = new_generation
      new_generation = {}
      gen = gen + 1

      for _,y in ipairs(generation) do
        for d,v in pairs(rooms[y].exits) do
          if rooms[v] and not rooms[v].pathing and
             not (rooms[v].area and area_off[rooms[v].area] and rooms[v].area ~= current_area) then
            rooms[v].pathing = dir_reverse[d]
            table.insert(new_generation, v)
            p = true
          end
        end
        for _,s in pairs(rooms[y].spexits) do
          local v = s.to
          if rooms[v] and not rooms[v].pathing then
            for cmd,s2 in pairs(rooms[v].spexits) do
              if s2.to == y and
                (cmd ~= "pathfind" or able.to("pathfind")) then
                rooms[v].pathing = cmd
                table.insert(new_generation, v)
                p = true
              end
            end
          end
        end
      end
    end
  end
end

function show_route(max_wrap)
  local v = current_room
  if not rooms[v] or not rooms[v].pathing then
    display.Error("Your cartographer informs you, \"There is no planned route from here, sir.\"")
    if IsConnected() then
      Send("")
    end
    return
  end

  local nr = 0
  local wrap = 7
  local max_wrap = max_wrap or tonumber(GetVariable("sg1_map_route_wrap") or "70")

  display.Prefix()
  ColourTell("red", "", "Path: ")
  while v and rooms[v] and rooms[v].pathing and rooms[v].pathing ~= "dest" do
    local d = dir_shorten[rooms[v].pathing] or rooms[v].pathing
    if wrap > max_wrap then
      ColourNote("red", "", ",")
      display.Prefix()
      wrap = 0
    elseif nr > 0 then
      ColourTell("red", "", ", ")
      wrap = wrap + 2
    end
    nr = nr + 1

    ColourTell("lime", "", d)
    wrap = wrap + #d

    if nr >= 100 then
      nr = 1001
      break
    end

    nv = rooms[v].exits[rooms[v].pathing]
    if not nv then
      for cmd,s in pairs(rooms[v].spexits) do
        if cmd == rooms[v].pathing then
          nv = s.to
          break
        end
      end
    end
    v = nv
  end

  if nr > 1000 then
    ColourTell("red", "", ", ", "lime", "", "...")
  end

  Note("")

  if IsConnected() then
    Send("")
  end
end


function make_particle(vnum, path)
  return {vnum=vnum, path=path or {}}
end

function path_finder(start, finish)
  if not finish then
    finish = start
    start = current_room
  end

  local explored_rooms = {}
  local particles = {}

  table.insert(particles, make_particle(start))
  while table.getn(particles) > 0 do
    new_generation = {}
    for _,part in ipairs(particles) do
      local room = rooms[part.vnum]
      if room and not (room.area and area_off[room.area] and room.area ~= current_area) then
        for dir,dest in pairs(room.exits) do
          if not explored_rooms[dest] then
            explored_rooms[dest] = true
            new_path = copytable.shallow(part.path)
            table.insert(new_path, {dir=dir, vnum=dest})

            if dest == finish then
              return new_path
            end

            table.insert(new_generation, make_particle(dest, new_path))
          end
        end

        for cmd,spe in pairs(room.spexits) do
          if not explored_rooms[spe.to] and
             (cmd ~= "pathfind" or able.to("pathfind")) then
            explored_rooms[spe.to] = true
            new_path = copytable.shallow(part.path)
            table.insert(new_path, {dir=cmd, vnum=spe.to})

            if spe.to == finish then
              return new_path
            end

            table.insert(new_generation, make_particle(spe.to, new_path))
          end
        end
      end
    end

    particles = new_generation
  end
end

function show_path(path, max_wrap)
  if not path then
    display.Info("Cannot find a path from here.")
    return
  end

  local nr = 0
  local wrap = 7
  display.Prefix()
  ColourTell("red", "", "Path: ")
  for _,step in ipairs(path) do
    local d = dir_shorten[step.dir] or step.dir
    if wrap > (max_wrap or 70) then
      ColourNote("red", "", ",")
      display.Prefix()
      wrap = 0
    elseif nr > 0 then
      ColourTell("red", "", ", ")
      wrap = wrap + 2
    end
    nr = nr + 1

    ColourTell("lime", "", d)
    wrap = wrap + #d

    if nr >= 100 then
      break
    end
  end

  if nr < #path then
    ColourTell("red", "", ", ", "lime", "", "...")
  end

  Note("")

  if IsConnected() then
    Send("")
  end
end

function check_movement(dir)
  local d = string.lower(dir_lengthen[dir] or dir)
  if d == "down" and elevation() == "trees" then
    return false
  end

  if current_room and rooms[current_room] then
    for cmd,spe in pairs(rooms[current_room].spexits) do
      if spe.alias == d then
        last_move = false
        Execute(cmd)
        return true
      end
    end
  end

  last_move = d
  return false
end

function is_exit_valid(dir, vnum)
  if affs.has("dementia") or
     affs.has("blindness") then
    return true
  end

  local vnum = vnum or current_room
  local rm = rooms[vnum]
  if not rm or not rm.exits then
    return true
  end

  local dir = dir_lengthen[dir] or dir
  if rm.exits[dir] then
    return true
  end

  return false
end

function elevation()
  if #gmcp_room_name > 0 then
    if string.find(gmcp_room_name, "^In the trees above ") then
      return "trees"
    elseif string.find(gmcp_room_name, "^Flying above ") then
      return "flying"
    elseif string.find(gmcp_room_name, "^On the rooftops over ") then
      return "rooftops"
    elseif string.find(gmcp_room_name, "^In a pit at ") then
      return "pit"
    elseif string.find(gmcp_room_name, "^In the mountains above ") then
      return "mountains"
    end
  end
  
  return "ground"
end

function movement(name, line, wildcards, styles)
  local moved = check_movement(wildcards[1])
  if not moved then
    local d = string.lower(line)
    table.insert(moves, dir_lengthen[d] or d)
    Send(d)
  end
end

function movement_special(name, line, wildcards, styles)
  local d = string.lower(wildcards[3] or "")
  if d and #d > 0 then
    d = dir_lengthen[d] or d
    if not dir_shorten[d] then
      d = ""
    end
  end

  local cmd = string.lower(wildcards[1] .. " " .. wildcards[2])
  flags.set("spexit", { from = current_room, cmd = cmd, alias = d }, 1)
  Execute(cmd)
end

function movement_autowalk(name, line, wildcards, styles)
  if string.find(name, "okay") then
    autowalk = 2
    prompt.gag = true
  elseif string.find(name, "onbal") then
    if autowalk == 3 then
      autowalk = 2
    end
  elseif string.find(name, "offbal") then
    autowalk = 3
    prompt.gag = true
  elseif string.find(name, "door") then
    autowalk = 2
    if string.find(name, "closed") then
      door_closed = true
    elseif string.find(name, "open") then
      door_closed = false
    end
    if string.find(name, "unlocked") then
      door_locked = false
    elseif string.find(name, "locked") then
      door_locked = true
    end
  end
end


function dbcheck(code)
  if code ~= sqlite3.OK and
     code ~= sqlite3.ROW and
     code ~= sqlite3.DONE then
    local err = db:errmsg()
    db:exec("ROLLBACK;")
    error(err, 2)
  end
end

function fixsql(s)
  if s then
    return "'" .. (string.gsub(s, "'", "''")) .. "'"
  end
  return "NULL"
end

function fixbool(b)
  if b then
    return 1
  end
  return 0
end

function create_database()
  dbcheck(db:execute[[
  PRAGMA foreign_keys = ON;

  DROP TABLE IF EXISTS exits;
  DROP TABLE IF EXISTS rooms;
  DROP TABLE IF EXISTS areas;
  DROP TABLE IF EXISTS environments;

  CREATE TABLE areas (
      areaid      INTEGER PRIMARY KEY AUTOINCREMENT,
      uid         TEXT    NOT NULL,   -- vnum or how the MUD identifies the area
      name        TEXT,               -- name of area
      date_added  DATE,               -- date added to database
      UNIQUE(uid)
    );


  CREATE TABLE environments (
      environmentid INTEGER PRIMARY KEY AUTOINCREMENT,
      uid           TEXT    NOT NULL,   -- code for the environment
      name          TEXT,               -- name of environment
      color         INTEGER,            -- ANSI color code
      date_added    DATE,               -- date added to database
      UNIQUE(uid)
    );
    
  CREATE INDEX IF NOT EXISTS name_index ON environments (name);

  CREATE TABLE rooms (
      roomid        INTEGER PRIMARY KEY AUTOINCREMENT,
      uid           TEXT NOT NULL,   -- vnum or how the MUD identifies the room
      name          TEXT,            -- name of room
      area          TEXT,            -- which area
      terrain       TEXT,            -- eg. road OR water
      plane         TEXT,            -- eg. the Prime Material Plane
      continent     TEXT,            -- eg. Undervault
      indoors       TEXT,            -- true/false
      info          TEXT,            -- eg. shop,postoffice
      notes         TEXT,            -- player notes
      x             INTEGER,
      y             INTEGER,
      z             INTEGER,
      date_added    DATE,            -- date added to database
      UNIQUE(uid)
    );

  CREATE INDEX IF NOT EXISTS info_index ON rooms (info);
  CREATE INDEX IF NOT EXISTS terrain_index ON rooms (terrain);
  CREATE INDEX IF NOT EXISTS area_index ON rooms (area);

  CREATE TABLE exits (
      exitid      INTEGER PRIMARY KEY AUTOINCREMENT,
      dir         TEXT    NOT NULL, -- direction, eg. "n", "s"
      fromuid     STRING  NOT NULL, -- exit from which room (in rooms table)
      touid       STRING  NOT NULL, -- exit to which room (in rooms table)
      date_added  DATE,             -- date added to database
      FOREIGN KEY(fromuid) REFERENCES rooms(uid)
    );
  CREATE INDEX IF NOT EXISTS fromuid_index ON exits (fromuid);
  CREATE INDEX IF NOT EXISTS touid_index   ON exits (touid);
  ]])
end

function create_user_database()
  dbcheck(dbu:execute[[
  PRAGMA foreign_keys = ON;

  DROP TABLE IF EXISTS exits;
  DROP TABLE IF EXISTS rooms;
  DROP TABLE IF EXISTS areas;
  DROP TABLE IF EXISTS special_exits;
  DROP TABLE IF EXISTS visited;
  DROP TABLE IF EXISTS tags;
  DROP TABLE IF EXISTS terrain;

  CREATE TABLE areas (
      areaid      INTEGER PRIMARY KEY AUTOINCREMENT,
      uid         TEXT    NOT NULL,   -- vnum or how the MUD identifies the area
      name        TEXT,               -- name of area
      date_added  DATE,               -- date added to database
      UNIQUE(uid)
    );

  CREATE TABLE rooms (
      roomid        INTEGER PRIMARY KEY AUTOINCREMENT,
      uid           TEXT NOT NULL,   -- vnum or how the MUD identifies the room
      name          TEXT,            -- name of room
      area          TEXT,            -- which area
      terrain       TEXT,            -- eg. road OR water
      info          TEXT,            -- eg. shop,postoffice
      notes         TEXT,            -- player notes
      x             INTEGER,
      y             INTEGER,
      z             INTEGER,
      date_added    DATE,            -- date added to database
      UNIQUE(uid)
    );

  CREATE INDEX IF NOT EXISTS info_index ON rooms (info);
  CREATE INDEX IF NOT EXISTS terrain_index ON rooms (terrain);
  CREATE INDEX IF NOT EXISTS area_index ON rooms (area);

  CREATE TABLE exits (
      exitid      INTEGER PRIMARY KEY AUTOINCREMENT,
      dir         TEXT    NOT NULL, -- direction, eg. "n", "s"
      fromuid     STRING  NOT NULL, -- exit from which room (in rooms table)
      touid       STRING  NOT NULL, -- exit to which room (in rooms table)
      date_added  DATE,             -- date added to database
      FOREIGN KEY(fromuid) REFERENCES rooms(uid)
    );
  CREATE INDEX IF NOT EXISTS fromuid_index ON exits (fromuid);
  CREATE INDEX IF NOT EXISTS touid_index   ON exits (touid);

  CREATE TABLE IF NOT EXISTS special_exits(
      exitid      INTEGER PRIMARY KEY AUTOINCREMENT,
      cmd         TEXT    NOT NULL, -- command, eg. "enter archway", "transverse prime"
      fromuid     STRING  NOT NULL, -- exit from which room(in rooms table)
      touid       STRING  NOT NULL, -- exit to which room(in rooms table)
      cost        INTEGER,          -- speedwalking cost
      alias       STRING,           -- aliased dir, eg. "n", "s"
      date_added  DATE,             -- date added to database
      FOREIGN KEY(fromuid) REFERENCES rooms(uid)
    );
  CREATE INDEX IF NOT EXISTS fromuid_index ON special_exits(fromuid);
  CREATE INDEX IF NOT EXISTS touid_index   ON special_exits(touid);

  CREATE TABLE IF NOT EXISTS visited(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      uid         TEXT    NOT NULL,   -- vnum of room
      date_added  DATE                -- date added to database
    );

  CREATE TABLE IF NOT EXISTS tags(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      uid         TEXT    NOT NULL,   -- vnum of room
      name        TEXT,               -- short name
      date_added  DATE,               -- date added to database
      UNIQUE(name)
    );

  CREATE TABLE IF NOT EXISTS terrain(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      name        TEXT    NOT NULL,   -- terrain name
      color       INTEGER,            -- RGB code
      date_added  DATE,               -- date added to database
      UNIQUE(name)
    );

  CREATE TABLE IF NOT EXISTS tags(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      uid         TEXT    NOT NULL,   -- vnum of room
      name        TEXT,               -- short name
      date_added  DATE,               -- date added to database
      UNIQUE(name)
    );
  ]])
end

function is_loaded()
  return loaded
end

function load_map()
  loaded = false
  if not db or not dbu then
    display.Error("Cannot load map; database not open")
    return
  end

  local query_rooms = "SELECT * FROM rooms"
  local query_areas = "SELECT * FROM areas"
  local query_exits = "SELECT * FROM exits"
  local query_spexits = "SELECT * FROM special_exits"
  local query_tags = "SELECT * FROM tags"
  local query_envs = "SELECT * FROM environments"
  local query_terrains = "SELECT * FROM terrain"
  local query_visited = "SELECT * FROM visited"

  local invalid_exits = {}
  local invalid_spexits = {}
  local invalid_tags = {}

  rooms = {}
  areas = {}
  tags = {}
  environments = {}
  terrain_colors = {}
  user_terrain = {}

  for row in db:nrows(query_rooms) do
    local uid = tonumber(row.uid)
    rooms[uid] = {
      ["vnum"] = uid,
      ["area"] = tonumber(row.area) or 0,
      ["env"] = tonumber(row.terrain) or 0,
      ["name"] = row.name,
      ["plane"] = row.plane,
      ["continent"] = row.continent,
      ["indoors"] = (tonumber(row.indoors) or 0) == 1,
      ["info"] = row.info,
      ["notes"] = row.notes,
      ["x"] = row.x,
      ["y"] = row.y,
      ["z"] = row.z,
      ["exits"] = {},
      ["spexits"] = {},
      ["tags"] = {},
      ["visited"] = false,
    }
  end

  for row in dbu:nrows(query_rooms) do
    local uid = tonumber(row.uid)
    rooms[uid] = {
      ["vnum"] = uid,
      ["area"] = tonumber(row.area) or 0,
      ["env"] = tonumber(row.terrain) or 0,
      ["name"] = row.name,
      ["info"] = row.info,
      ["notes"] = row.notes,
      ["x"] = row.x,
      ["y"] = row.y,
      ["z"] = row.z,
      ["exits"] = {},
      ["spexits"] = {},
      ["tags"] = {},
      ["visited"] = false
    }
  end

  for row in db:nrows(query_areas) do
    areas[tonumber(row.uid)] = row.name
  end

  for row in dbu:nrows(query_areas) do
    areas[tonumber(row.uid)] = row.name
  end

  for row in db:nrows(query_exits) do
    local from = tonumber(row.fromuid)
    if not rooms[from] then
      table.insert(invalid_exits, from)
    else
      rooms[tonumber(row.fromuid)].exits[row.dir] = tonumber(row.touid)
    end
  end

  for row in dbu:nrows(query_exits) do
    local from = tonumber(row.fromuid)
    if not rooms[from] then
      table.insert(invalid_exits, from)
    else
      rooms[tonumber(row.fromuid)].exits[row.dir] = tonumber(row.touid)
    end
  end

  for row in dbu:nrows(query_spexits) do
    local from = tonumber(row.fromuid)
    if not rooms[from] then
      table.insert(invalid_spexits, from)
    else
      rooms[from].spexits[row.cmd] = {
        ["to"] = tonumber(row.touid),
        ["cost"] = tonumber(row.cost),
        ["alias"] = row.alias
      }
    end
  end

  for row in dbu:nrows(query_visited) do
    if rooms[tonumber(row.uid)] then
      rooms[tonumber(row.uid)].visited = true
    end
  end

  for row in dbu:nrows(query_tags) do
    local vnum = tonumber(row.uid)
    if not rooms[vnum] then
      table.insert(invalid_tags, vnum)
    else
      table.insert(rooms[vnum].tags, row.name)
      tags[row.name] = vnum
    end
  end

  for row in db:nrows(query_envs) do
    environments[tonumber(row.uid)] = row.name
    terrain_colors[row.name] = ansi_colors[tonumber(row.color)]
  end

  for row in dbu:nrows(query_terrains) do
    terrain_colors[row.name] = tonumber(row.color)
    user_terrain[row.name] = true
  end

  if #invalid_exits > 0 then
    for _,uid in ipairs(invalid_exits) do
      dbu:execute(string.format("DELETE FROM exits WHERE fromuid = %s OR touid = %s;", fixsql(uid), fixsql(uid)))
    end
  end
  if #invalid_spexits > 0 then
    for _,uid in ipairs(invalid_spexits) do
      dbu:execute(string.format("DELETE FROM special_exits WHERE fromuid = %s OR touid = %s;", fixsql(uid), fixsql(uid)))
    end
  end
  if #invalid_tags > 0 then
    for _,uid in ipairs(invalid_tags) do
      dbu:execute(string.format("DELETE FROM tags WHERE uid = %s;", fixsql(uid)))
    end
  end

  local ao = GetVariable("sg1_map_area_off")
  if ao and #ao > 1 then
    ao = json.decode(ao)
    for k,v in pairs(ao) do
      area_off[tonumber(k)] = v
    end
  end

  gui_config_room()
  loaded = true
  display.Info("Cartographer awake and ready to go.")
end

function save_room_details(room)
  if room.plane then
    local i = 0
    if room.indoors then
      i = 1
    end
    db:exec("BEGIN TRANSACTION;")
    local query = string.format(
      "UPDATE rooms SET plane = %s, indoors = %s WHERE uid = %s;",
      fixsql(room.plane),
      fixsql(i),
      fixsql(room.vnum))
    local code = db:execute(query)
    if code ~= sqlite3.OK and
       code ~= sqlite3.ROW and
       code ~= sqlite3.DONE then
      db:exec("ROLLBACK;")
    else
      db:exec("COMMIT;")
    end
  end
end

function save_room(room)
  dbu:exec("BEGIN TRANSACTION;")

  local query = string.format(
    "REPLACE INTO rooms (uid, name, area, terrain, info, x, y, z, date_added) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, DATETIME('NOW'));",
    fixsql(room.vnum),
    fixsql(room.name),
    fixsql(room.area),
    fixsql(room.env),
    fixsql(room.info),
    fixsql(room.x),
    fixsql(room.y),
    fixsql(room.z))
  dbcheck(dbu:execute(query))

  for dir, exit in pairs(room.exits) do
    query = string.format("REPLACE INTO exits (dir, fromuid, touid, date_added) VALUES (%s, %s, %s, DATETIME('NOW'));",
      fixsql(dir),
      fixsql(room.vnum),
      fixsql(exit))
    dbcheck(dbu:execute(query))
  end

  if room.visited then
    dbcheck(dbu:execute(string.format("REPLACE INTO visited (uid, date_added) VALUES (%s, DATETIME('NOW'))", fixsql(room.vnum))))
  else
    dbcheck(dbu:execute(string.format("DELETE FROM visited WHERE uid = %s", fixsql(room.vnum))))
  end

  dbu:exec("COMMIT;")
end

function save_area(id, name)
  db:exec("BEGIN TRANSACTION;")

  local query = string.format(
    "INSERT INTO areas (uid, name, date_added) VALUES (%s, %s, DATETIME('NOW'));",
    fixsql(id),
    fixsql(name))
  dbcheck(db:execute(query))

  db:exec("COMMIT;")
end

function save_special_exit(spexit)
  dbu:exec("BEGIN TRANSACTION;")

  local query = string.format(
    "REPLACE INTO special_exits (cmd, fromuid, touid, cost, alias, date_added) VALUES (%s, %s, %s, %s, %s, DATETIME('NOW'));",
    fixsql(spexit.cmd),
    fixsql(spexit.from),
    fixsql(spexit.to),
    fixsql(spexit.cost),
    fixsql(spexit.alias)
    )
  dbcheck(dbu:execute(query))

  dbu:exec("COMMIT;")
end

function destroy_special_exit(cmd, from)
  dbu:exec("BEGIN TRANSACTION;")

  local query = string.format(
    "DELETE FROM special_exits WHERE cmd = %s AND fromuid = %s;",
    fixsql(cmd),
    fixsql(from)
    )
  dbcheck(dbu:execute(query))

  dbu:exec("COMMIT;")
end

function clear_duplicate_rooms()
  if not db or not dbu then
    return
  end

  local main_lookup = {}
  for r in db:nrows("SELECT uid FROM rooms") do
    main_lookup[tonumber(r.uid)] = true
  end

  dbu:exec("BEGIN TRANSACTION;")
  for r in dbu:nrows("SELECT uid FROM rooms") do
    v = tonumber(r.uid) or 0
    if main_lookup[v] then
      dbu:execute(string.format("DELETE FROM rooms WHERE uid = %s", fixsql(v)))
    end
  end
  dbu:exec("COMMIT;")
end

function fix_area_for_room(vnum, anum)
  local correct = {
    [18730] = 188, -- Halls of the Spirits
    [25690] = 188, -- Seren slot machine
    [25569] = 188, -- Seren Ghodak board
    [9433] = 159,  -- Temple of Shikari
    [9434] = 159,
    [9435] = 159,
    [9436] = 159,
    [9437] = 159,
    [9438] = 159,
    [9439] = 159,
    [9440] = 159,
    [9441] = 159,
    [24682] = 159,
    [24683] = 159,
    [24684] = 159,
    [24685] = 159,
    [24686] = 159,
    [22798] = 159,
  }
  return correct[tonumber(vnum) or 0] or anum
end

function fix_name_for_room(vnum, title)
  local correct = {
    [6080] = "stockroom of Symphonia", -- Not the fucking Higher Planar Fulcrux, Ranadae!
  }
  return correct[tonumber(vnum) or 0] or title
end

function process_xml(filename)
  if not filename then
    filename = utils.filepicker("Map XML", "", "xml", { xml = "XML files", ["*"] = "All files" }, false)
    if not filename then
      return
    end
  end

  local user_rooms = {}
  if dbu then
    -- TODO: preserve player notes
    for row in dbu:nrows("SELECT uid FROM rooms") do
      user_rooms[tonumber(row.uid)] = true
    end
  end

  local entities = {
    ['&amp;'] = '&',
    ['&quot;'] = '"',
    ['&lt;'] = '<',
    ['&gt;'] = '>',
  }

  local function get_params(s)
    local t = {}
    for name, contents in string.gmatch(s, '(%a+)="([^"]*)"') do
      t[name] = string.gsub(contents, '&%a-;', entities)
    end
    return t
  end

  local count = 0
  local room = {}
  local function process_area(args)
    if not (args.id and args.name) then
      return "Area needs ID and name"
    end

    local query = string.format(
      "INSERT INTO areas (uid, name, date_added) VALUES (%s, %s, DATETIME('NOW'));",
      fixsql(args.id),
      fixsql(args.name))
    dbcheck(db:execute(query))
  end
  local function process_environment(args)
    if not (args.id and args.name and args.color) then
      return "Environment needs ID, name, and nolor"
    end

    local query = string.format(
      "INSERT INTO environments (uid, name, color, date_added) VALUES (%s, %s, %i, DATETIME('NOW'));",
      fixsql(args.id),
      fixsql(args.name),
      args.color)
    dbcheck(db:execute(query))
  end
  local function process_start_room(args)
    if not (args.id and args.area and args.title and args.environment) then
      return "Room needs ID, area, title, and environment"
    end

    count = count + 1
    room = {
      ["vnum"] = args.id,
      ["area"] = fix_area_for_room(args.id, args.area),
      ["name"] = fix_name_for_room(args.id, args.title),
      ["env"] = args.environment,
      ["exits"] = {},
      ["x"] = 0,
      ["y"] = 0,
      ["z"] = 0
    }
  end
  local function process_end_room(args)
    local query = string.format(
      "INSERT INTO rooms (uid, name, area, terrain, info, x, y, z, date_added) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, DATETIME('NOW'));",
      fixsql(room.vnum),
      fixsql(room.name),
      fixsql(room.area),
      fixsql(room.env),
      fixsql(room.info),
      fixsql(room.x),
      fixsql(room.y),
      fixsql(room.z))
    dbcheck(db:execute(query))

    for dir, exit in pairs(room.exits) do
      query = string.format("INSERT INTO exits (dir, fromuid, touid, date_added) VALUES (%s, %s, %s, DATETIME('NOW'));",
        fixsql(dir),
        fixsql(room.vnum),
        fixsql(exit))
      dbcheck(db:execute(query))
    end

    if dbu and user_rooms[room.vnum] then
      display.Info("Replacing user room with XML room: v" .. room.vnum)
      query = string.format("DELETE FROM rooms WHERE uid = %s", fixsql(room.vnum))
      dbu:execute(query)
    end
  end
  local function process_coord(args)
    room.x = args.x
    room.y = args.y
    room.z = args.z
  end
  local function process_exit(args)
    if not (args.direction and args.target) then
      return "Exit needs direction and target"
    end

    room.exits[dir_lengthen[args.direction] or args.direction] = args.target
  end
  local function process_info(args)
    if not args.flags then
      return "Info needs flags"
    end

    room.info = args.flags
  end

  local xml_handlers = {
    ["area"] = process_area,
    ["room"] = process_start_room,
    ["coord"] = process_coord,
    ["environment"] = process_environment,
    ["exit"] = process_exit,
    ["info"] = process_info,
    ["/room"] = process_end_room
  }

  create_database()
  db:exec("BEGIN TRANSACTION;")

  for line in io.lines(filename) do
    local xml = string.match(line, "^%s*<(.-)/?>%s*$")

    if xml then
      local tag, things = string.match(xml, "^([%a/]+)%s*(.*)$")

      if tag then
        local f = xml_handlers[tag]

        if f then
          local t = get_params(things)

          local problem = f(t)
          if problem then
            display.Error("Error (" .. problem .. ") processing XML: " .. xml)
          end
        end

        if math.fmod(count, 200) == 0 then
          SetStatus("Processed " .. count .. " rooms")
        end
      end
    else
      display.Warning("Line not processed: " .. line)
    end
  end

  db:exec("COMMIT;")
  SetStatus("Ready")

  wait.make(function () map.load_map() end)
end


function gui_build_room_info()
  HALF_ROOM   = ROOM_SIZE / 2
  local THIRD_WAY   = DISTANCE_TO_NEXT_ROOM / 3
  local DISTANCE_LESS1 = DISTANCE_TO_NEXT_ROOM - 1

  -- how to draw a line from this room to the next one (relative to the center of the room)
  connectors = {
    north =  { x1 = 0,            y1 = - HALF_ROOM, x2 = 0,                             y2 = - HALF_ROOM - DISTANCE_LESS1, at = { 0, -1 } },
    south =  { x1 = 0,            y1 =   HALF_ROOM, x2 = 0,                             y2 =   HALF_ROOM + DISTANCE_LESS1, at = { 0,  1 } },
    east =  { x1 =   HALF_ROOM,  y1 = 0,           x2 =   HALF_ROOM + DISTANCE_LESS1,  y2 = 0,                            at = {  1,  0 }},
    west =  { x1 = - HALF_ROOM,  y1 = 0,           x2 = - HALF_ROOM - DISTANCE_LESS1,  y2 = 0,                            at = { -1,  0 }},

    northeast = { x1 =   HALF_ROOM,  y1 = - HALF_ROOM, x2 =   HALF_ROOM + DISTANCE_LESS1 , y2 = - HALF_ROOM - DISTANCE_LESS1, at = { 1, -1 } },
    southeast = { x1 =   HALF_ROOM,  y1 =   HALF_ROOM, x2 =   HALF_ROOM + DISTANCE_LESS1 , y2 =   HALF_ROOM + DISTANCE_LESS1, at = { 1,  1 } },
    northwest = { x1 = - HALF_ROOM,  y1 = - HALF_ROOM, x2 = - HALF_ROOM - DISTANCE_LESS1 , y2 = - HALF_ROOM - DISTANCE_LESS1, at = {-1, -1 } },
    southwest = { x1 = - HALF_ROOM,  y1 =   HALF_ROOM, x2 = - HALF_ROOM - DISTANCE_LESS1 , y2 =   HALF_ROOM + DISTANCE_LESS1, at = {-1,  1 } }
  }

  -- how to draw a stub line
  half_connectors = {
    north =  { x1 = 0,            y1 = - HALF_ROOM, x2 = 0,                        y2 = - HALF_ROOM - THIRD_WAY, at = { 0, -1 } },
    south =  { x1 = 0,            y1 =   HALF_ROOM, x2 = 0,                        y2 =   HALF_ROOM + THIRD_WAY, at = { 0,  1 } },
    east =  { x1 =   HALF_ROOM,  y1 = 0,           x2 =   HALF_ROOM + THIRD_WAY,  y2 = 0,                       at = {  1,  0 }},
    west =  { x1 = - HALF_ROOM,  y1 = 0,           x2 = - HALF_ROOM - THIRD_WAY,  y2 = 0,                       at = { -1,  0 }},

    northeast = { x1 =   HALF_ROOM,  y1 = - HALF_ROOM, x2 =   HALF_ROOM + THIRD_WAY , y2 = - HALF_ROOM - THIRD_WAY, at = { 1, -1 } },
    southeast = { x1 =   HALF_ROOM,  y1 =   HALF_ROOM, x2 =   HALF_ROOM + THIRD_WAY , y2 =   HALF_ROOM + THIRD_WAY, at = { 1,  1 } },
    northwest = { x1 = - HALF_ROOM,  y1 = - HALF_ROOM, x2 = - HALF_ROOM - THIRD_WAY , y2 = - HALF_ROOM - THIRD_WAY, at = {-1, -1 } },
    southwest = { x1 = - HALF_ROOM,  y1 =   HALF_ROOM, x2 = - HALF_ROOM - THIRD_WAY , y2 =   HALF_ROOM + THIRD_WAY, at = {-1,  1 } }
  }

  -- how to draw one-way arrows (relative to the center of the room)
  arrows = {
    north =  { - 2, - HALF_ROOM - 2,  2, - HALF_ROOM - 2,  0, - HALF_ROOM - 6 },
    south =  { - 2,   HALF_ROOM + 2,  2,   HALF_ROOM + 2,  0,   HALF_ROOM + 6 },
    east =  {   HALF_ROOM + 2, -2,   HALF_ROOM + 2, 2,   HALF_ROOM + 6, 0 },
    west =  { - HALF_ROOM - 2, -2, - HALF_ROOM - 2, 2, - HALF_ROOM - 6, 0 },

    northeast = {   HALF_ROOM + 3,  - HALF_ROOM,  HALF_ROOM + 3, - HALF_ROOM - 3,  HALF_ROOM, - HALF_ROOM - 3 },
    southeast = {   HALF_ROOM + 3,    HALF_ROOM,  HALF_ROOM + 3,   HALF_ROOM + 3,  HALF_ROOM,   HALF_ROOM + 3 },
    northwest = { - HALF_ROOM - 3,  - HALF_ROOM,  - HALF_ROOM - 3, - HALF_ROOM - 3,  - HALF_ROOM, - HALF_ROOM - 3 },
    southwest = { - HALF_ROOM - 3,    HALF_ROOM,  - HALF_ROOM - 3,   HALF_ROOM + 3,  - HALF_ROOM,   HALF_ROOM + 3 }
  }
end

function gui_init()
  WindowCreate(win, 0, 0, 0, 0, 0, 0, 0)
  WindowFont(win, FONT_ID, config.FONT.name, config.FONT.size)
  WindowFont(win, FONT_ID_UL, config.FONT.name, config.FONT.size, false, false, true)
  WindowFont(win, FONT_CONFIG_ID, config.FONT.name, 8)
  WindowFont(win, FONT_CONFIG_ID_UL, config.FONT.name, 8, false, false, true)

  font_height = WindowFontInfo(win, FONT_ID, 1)
  font_config_height = WindowFontInfo(win, FONT_CONFIG_ID, 1)

  gui_build_room_info()

  WindowCreate(win, 0, 0, config.WINDOW.width, config.WINDOW.height, 6, 0,
    config.BACKGROUND_COLOR.color)
  draw_3d_box(win, 0, 0, config.WINDOW.width, config.WINDOW.height)

  WindowShow(win, true)

  local cr = tonumber(GetVariable("sg1_map_current_room") or "0")
  if cr > 0 then
    current_room = cr
    gui_draw()
  end
end

function gui_build_hover_message(room)
  if not room or not room.name or not room.area then
    return ""
  end

  local env_name = environments[room.env] or tostring(room.env)
  local terrain = ""
  if env_name then
    terrain = "\nTerrain: " .. string.lower(env_name)
  end

  local info = ""
  if room.info and #room.info > 0 then
    info = "\nInfo: " .. room.info
  end

  local tags = ""
  if room.tags and #room.tags > 0 then
    tags = "\nTags: " .. string.lower(table.concat(room.tags, ", "))
  end

  local area = areas[room.area]
  if not area then
    if current_area_name then
      area = current_area_name
    else
      area = "<unknown>"
    end
  end

  return string.format(
      "%s\tRoom: %d\nArea: %s%s%s%s",
      php.strproper(room.name),
      room.vnum or 999999,
      php.strproper(area),
      terrain,
      info,
      tags
      )
end

function gui_config_room(vnum)
  if not vnum then
    for v in pairs(rooms) do
      gui_config_room(v)
    end
    return
  end

  if not rooms[vnum] then
    return
  end

  rooms[vnum].hovermessage = gui_build_hover_message(rooms[vnum])
  rooms[vnum].bordercolor = config.ROOM_COLOR.color
  rooms[vnum].borderpen = 0
  rooms[vnum].borderpenwidth = 1
  rooms[vnum].fillcolor = 0xff0000
  rooms[vnum].fillbrush = 1

  if rooms[vnum].info and #rooms[vnum].info > 3 then
    if string.match(rooms[vnum].info, "shop") then
      rooms[vnum].fillcolor = config.SHOP_FILL_COLOR.color
      rooms[vnum].fillbrush = 8
    elseif string.match(rooms[vnum].info, "postoffice") then
      rooms[vnum].fillcolor = config.POSTOFFICE_FILL_COLOR.color
      rooms[vnum].fillbrush = 8
    elseif string.match(rooms[vnum].info, "bank") then
      rooms[vnum].fillcolor = config.BANK_FILL_COLOR.color
      rooms[vnum].fillbrush = 8
    elseif string.match(rooms[vnum].info, "newsroom") then
      rooms[vnum].fillcolor = config.NEWSROOM_FILL_COLOR.color
      rooms[vnum].fillbrush = 8
    end
  elseif rooms[vnum].env > 0 then
    local env = environments[rooms[vnum].env] or ""
    if terrain_colors[env] then
      rooms[vnum].fillcolor = terrain_colors[env]
      rooms[vnum].fillbrush = 0
    end
  end
end

function unknown_room(vnum)
  rooms[vnum] = {
    ["unknown"] = true,
    ["vnum"] = vnum,
    ["area"] = 0,
    ["env"] = 0,
    ["exits"] = {},
    ["spexits"] = {},
    ["tags"] = {},
    ["visited"] = false,
    ["hovermessage"] = string.format("v%d\t<Unexplored>", vnum),
    ["bordercolor"] = config.ROOM_COLOR.color,
    ["borderpen"] = 0,
    ["borderpenwidth"] = 1,
    ["fillcolor"] = 0x000000,
    ["fillbrush"] = 1
  }
  return rooms[vnum]
end

local function add_another_room(vnum, path, x, y)
  local path = path or {}
  return {vnum=vnum, path=path, x=x, y=y}
end

local function gui_draw_room(vnum, path, x, y)
  local coords = string.format("%i,%i", math.floor(x), math.floor(y))
  drawn_coords[coords] = vnum

  if drawn[vnum] then
    return
  end
  drawn[vnum] = { coords = coords, path = path }

  local room = rooms[vnum] or unknown_room(vnum)

  local left, top, right, bottom = x - HALF_ROOM, y - HALF_ROOM, x + HALF_ROOM, y + HALF_ROOM

  -- Forget it, if off screen
  if x < HALF_ROOM or y < HALF_ROOM or
     x > config.WINDOW.width - HALF_ROOM or y > config.WINDOW.height - HALF_ROOM then
    return
  end

  for dir,exit_vnum in pairs(room.exits) do
    local exit_info = connectors[dir]
    local stub_exit_info = half_connectors[dir]
    local exit_line_color = config.EXIT_COLOR.color
    local arrow = arrows[dir]

    if dir == "in" or dir == "out" then
      exit_info = true
      stub_exit_info = true
      arrow = false
      exit_line_color = config.EXIT_COLOR_IN_OUT.color
    end

    next_room = rooms[exit_vnum] or unknown_room(exit_vnum)
    if exit_info and next_room then
      local linetype = 0 -- unbroken
      local linewidth = 1 -- not recent

      if next_room.unknown then
        linetype = 2 -- dots
      end

      local dist_x = 0
      local dist_y = 0

      local next_x = 0
      local next_y = 0

      if next_room.x and next_room.y and room.x and room.y then
        dist_x = next_room.x - room.x
        dist_y = next_room.y - room.y

        next_x = x + dist_x * (ROOM_SIZE + DISTANCE_TO_NEXT_ROOM)
        next_y = y - dist_y * (ROOM_SIZE + DISTANCE_TO_NEXT_ROOM)
      elseif exit_info ~= true then
        next_x = x + exit_info.at [1] * (ROOM_SIZE + DISTANCE_TO_NEXT_ROOM)
        next_y = y + exit_info.at [2] * (ROOM_SIZE + DISTANCE_TO_NEXT_ROOM)
      end

      local next_coords = string.format("%i,%i", math.floor(next_x), math.floor(next_y))

      -- remember if a zone exit (first one only)
      if show_area_exits and room.area ~= next_room.area then
        area_exits[next_room.area] = area_exits[next_room.area] or {x = x, y = y}
      end

      -- if another room (not where this one leads to) is already there, only draw "stub" lines
      if drawn_coords[next_coords] and drawn_coords[next_coords] ~= exit_vnum then
        exit_info = stub_exit_info
      elseif exit_vnum == vnum then
        -- room leads back to itself
        exit_info = stub_exit_info
        linetype = 1 -- dash
      else
        if (not show_other_areas and next_room.area ~= current_area) or
           (not show_up_down and (dir == "up" or dir == "down")) then
          exit_info = stub_exit_info    -- don't show other areas
        else
          -- if we are scheduled to draw the room already, only draw a stub this time
          if plan_to_draw[exit_vnum] and plan_to_draw[exit_vnum] ~= next_coords then
            -- room already going to be drawn
            exit_info = stub_exit_info
            linetype = 1 -- dash
          else
            -- remember to draw room next iteration
            local new_path = copytable.deep(path)
            table.insert(new_path, {dir = dir, vnum = exit_vnum})
            table.insert(rooms_to_be_drawn, add_another_room(exit_vnum, new_path, next_x, next_y))
            drawn_coords[next_coords] = exit_vnum
            plan_to_draw[exit_vnum] = next_coords
          end
        end
      end

      if exit_info ~= true then
        if dist_x and dist_y and room.area == next_room.area then
          local start = { x + exit_info.x1, y + exit_info.y1 }
          local finish = { next_x - exit_info.x1, next_y - exit_info.y1 }

          WindowLine(win, start[1], start[2], finish[1], finish[2], exit_line_color, linetype, linewidth)
        else
          WindowLine(win, x + exit_info.x1, y + exit_info.y1, x + exit_info.x2, y + exit_info.y2, exit_line_color, linetype, linewidth)
        end
      end

      -- one-way exit?
      if not next_room.unknown and arrow then
        local dest = rooms[exit_vnum] or unknown_room(exit_vnum)
        -- if inverse direction doesn't point back to us, this is one-way
        if tonumber(dest.exits[dir_reverse[dir]]) ~= tonumber(vnum) then

          -- turn points into string, relative to where the room is
          local points = string.format("%i,%i,%i,%i,%i,%i",
                                        x + arrow[1],
                                        y + arrow[2],
                                        x + arrow[3],
                                        y + arrow[4],
                                        x + arrow[5],
                                        y + arrow[6]
                                      )

          -- draw arrow
          WindowPolygon(win, points, exit_line_color, 0, 1, exit_line_color, 0, true, true)
        end
      end
    end
  end

  if room.unknown then
    WindowCircleOp(win, 2, left, top, right, bottom,
                    config.UNKNOWN_ROOM_COLOR.color, 2, 1,  --  dotted single pixel pen
                    -1, 1)  -- no brush
  else
    WindowCircleOp(win, 2, left, top, right, bottom,
                    0, 5, 0,  -- no pen
                    room.fillcolor, room.fillbrush)  -- brush

    local bc = room.bordercolor
    if not room.visited then
      bc = math.modf(room.bordercolor + 0x777777, 0xffffff)
    elseif room.area ~= current_area then
      bc = config.DIFFERENT_AREA_COLOR.color
    end
    WindowCircleOp(win, 2, left, top, right, bottom,
                    bc, room.borderpen, room.borderpenwidth,  -- pen
                    -1, 1)  -- no brush
  end

  if vnum == current_room then
    local cc = math.modf(room.fillcolor + 0x777777, 0xffffff)
    WindowCircleOp(win, 1, left + 2, top + 2, right - 2, bottom - 2, cc, 6, 1, cc, 0)
  end

  -- show up and down in case we can't get a line in
  if room.exits["up"] then  -- line at top
    WindowLine(win, left, top, left + ROOM_SIZE - 1, top, config.EXIT_COLOR_UP_DOWN.color, 0, 2)
  end
  if room.exits["down"] then  -- line at bottom
    WindowLine(win, left, bottom, left + ROOM_SIZE - 1, bottom, config.EXIT_COLOR_UP_DOWN.color, 0, 2)
  end
  if room.exits["in"] then  -- line at right
    WindowLine(win, left + ROOM_SIZE, top, left + ROOM_SIZE, bottom - 1, config.EXIT_COLOR_IN_OUT.color, 0, 2)
  end
  if room.exits["out"] then  -- line at left
    WindowLine(win, left, top, left, bottom - 1, config.EXIT_COLOR_IN_OUT.color, 0, 2)
  end

  WindowAddHotspot(win, vnum,
                 left, top, right, bottom,   -- rectangle
                 "",  -- mouseover
                 "",  -- cancelmouseover
                 "",  -- mousedown
                 "",  -- cancelmousedown
                 "map.mouseup_room",  -- mouseup
                 room.hovermessage,
                 1, 0)  -- hand cursor
end

function gui_draw(vnum)
  local vnum = vnum or current_room
  if not vnum then
    display.Warning("Your cartographer seems unsure.")
    return
  end

  local room = rooms[vnum] or unknown_room(vnum)

  WindowCreate(win, 0, 0, config.WINDOW.width, config.WINDOW.height, 6, 0,
               config.BACKGROUND_COLOR.color)

  drawn = {}
  drawn_coords = {}
  rooms_to_be_drawn = {}
  plan_to_draw = {}
  area_exits = {}
  depth = 0

  center_x = room.x
  center_y = room.y

  table.insert(rooms_to_be_drawn, add_another_room(vnum, {}, config.WINDOW.width / 2, config.WINDOW.height / 2))
  while #rooms_to_be_drawn > 0 do --and depth < config.SCAN.depth do
    local oldgen = rooms_to_be_drawn
    rooms_to_be_drawn = {}
    for _,part in ipairs(oldgen) do
      gui_draw_room(part.vnum, part.path, part.x, part.y)
    end
    depth = depth + 1
  end

  -- room name
  local room_name = string.format("[%d]%s", room.vnum, " " .. php.strproper((room.name or "")))
  local name_width = WindowTextWidth(win, FONT_ID, room_name, true)
  local add_dots = false

  -- truncate name if too long
  while name_width > (config.WINDOW.width - 10) do
    -- get rid of last word
    local s = string.match (" " .. room_name .. "...", "(%s%S*)$")
    if not s or #s == 0 then break end
    room_name = room_name:sub(1, - (#s - 2))  -- except the last 3 dots but add the space
    name_width = WindowTextWidth(win, FONT_ID, room_name .. " ...", true)
    add_dots = true
  end
  if add_dots then
    room_name = room_name .. " ..."
  end
  draw_text_box(win, FONT_ID,
                3,   -- left
                3,    -- top
                room_name, true,                -- what to draw, utf8
                config.ROOM_NAME_TEXT.color,   -- text color
                config.ROOM_NAME_FILL.color,   -- fill color
                config.ROOM_NAME_BORDER.color) -- border color

  draw_3d_box(win, 0, 0, config.WINDOW.width, config.WINDOW.height)

  -- area name
  local areaname = current_area_name
  if not current_area_name or #current_area_name < 1 and tonumber(room.area) then
    areaname = areas[room.area]
  end

  if areaname then
    areaname = string.format("[%d] %s", room.area, php.strproper(areaname))
    name_width = WindowTextWidth(win, FONT_ID, areaname, true)
    add_dots = false
    -- truncate name if too long
    while name_width > (config.WINDOW.width - 18) do
      -- get rid of last word
      local s = string.match (" " .. areaname .. "...", "(%s%S*)$")
      if not s or #s == 0 then break end
      areaname = areaname:sub(1, - (#s - 2))  -- except the last 3 dots but add the space
      name_width = WindowTextWidth(win, FONT_ID, areaname .. " ...", true)
      add_dots = true
    end
    if add_dots then
      areaname = areaname .. " ..."
    end
    draw_text_box(win, FONT_ID,
                  config.WINDOW.width - WindowTextWidth(win, FONT_ID, areaname, true) - 6,   -- left
                  config.WINDOW.height - 3 - font_height,    -- top
                  areaname, true,        -- what to draw, utf8
                  config.AREA_NAME_TEXT.color,   -- text color
                  config.AREA_NAME_FILL.color,   -- fill color
                  config.AREA_NAME_BORDER.color) -- border color
  end

  if draw_configure_box then
    gui_draw_configuration()
  else
    local x = 5
    local y = config.WINDOW.height - 2 - font_height
    local width = draw_text_box(win, FONT_ID,
                   x,   -- left
                   config.WINDOW.height - 3 - font_height,    -- top (ie. at bottom)
                   "*", true,                   -- what to draw, utf8
                   config.AREA_NAME_TEXT.color,   -- text color
                   config.AREA_NAME_FILL.color,   -- fill color
                   config.AREA_NAME_BORDER.color)     -- border color

    WindowAddHotspot(win, "<configure>",
                   x, y, x + width, y + font_height,   -- rectangle
                   "",  -- mouseover
                   "",  -- cancelmouseover
                   "",  -- mousedown
                   "",  -- cancelmousedown
                   "map.mouseup_configure",  -- mouseup
                   "Click to configure map",
                   1, 0)  -- hand cursor

  end

  WindowShow(win, not hidden)

  last_drawn = vnum
end

function gui_draw_configuration()
  local width =  max_text_width(win, FONT_CONFIG_ID, {"Configuration", "Font"}, true)
  local lines = 2  -- "Configuration", "Font"
  local GAP = 5
  local suppress_colors = false

  for k, v in pairs(config) do
    if v.color then
      width = math.max(width, WindowTextWidth(win, FONT_CONFIG_ID, v.name, true))
      lines = lines + 1
    end
  end

  if (config.WINDOW.height - 13 - font_config_height * lines) < 10 then
    suppress_colors = true
    lines = 6  -- forget all the colors
  end

  local x = 3
  local y = config.WINDOW.height - 13 - font_config_height * lines
  local box_size = font_config_height - 2
  local rh_size = math.max(box_size, max_text_width(win, FONT_CONFIG_ID,
    {config.FONT.name .. " " .. config.FONT.size,
     tostring(config.WINDOW.width),
     tostring(config.WINDOW.height)},
    true))
  local frame_width = GAP + width + GAP + rh_size + GAP  -- gap / text / gap / box / gap

  -- fill entire box with grey
  WindowRectOp(win, 2, x, y, x + frame_width, y + font_config_height * lines + 10, 0xDCDCDC)
  -- frame it
  draw_3d_box(win, x, y, frame_width, font_config_height * lines + 10)

  y = y + GAP
  x = x + GAP

  -- title
  WindowText(win, FONT_ID, "Configuration", x, y, 0, 0, 0x808080, true)

  -- close box
  WindowRectOp(win, 1, x + frame_width - box_size - GAP * 2, y + 1,
                       x + frame_width - GAP * 2, y + 1 + box_size, 0x808080)
  WindowLine(win, x + frame_width - box_size - GAP * 2 + 3, y + 4,
                  x + frame_width - GAP * 2 - 3, y - 2 + box_size, 0x808080, 0, 1)
  WindowLine(win, x - 4 + frame_width - GAP * 2, y + 4,
                  x - 1 + frame_width - box_size - GAP * 2 + 3, y - 2 + box_size, 0x808080, 0, 1)

  -- close configuration hotspot
  WindowAddHotspot(win, "$<close_configure>",
                   x + frame_width - box_size - GAP * 2, y + 1, x + frame_width - GAP * 2, y + 1 + box_size,   -- rectangle
                   "", "", "", "", "map.mouseup_close_configure",  -- mouseup
                   "Click to close",
                   1, 0)  -- hand cursor

  y = y + font_config_height

  if not suppress_colors then
    for k, v in pairsByKeys(config) do
      if v.color then
        WindowText(win, FONT_CONFIG_ID, v.name, x, y, 0, 0, 0x000000, true)
        WindowRectOp(win, 2, x + width + rh_size / 2, y + 1, x + width + rh_size / 2 + box_size, y + 1 + box_size, v.color)
        WindowRectOp(win, 1, x + width + rh_size / 2, y + 1, x + width + rh_size / 2 + box_size, y + 1 + box_size, 0x000000)

        -- color change hotspot
        WindowAddHotspot(win, "$color:" .. k,
                         x + GAP, y + 1, x + width + rh_size / 2 + box_size, y + 1 + box_size,   -- rectangle
                         "", "", "", "", "map.mouseup_change_color",  -- mouseup
                         "Click to change color",
                         1, 0)  -- hand cursor

        y = y + font_config_height
      end
    end
  end

  -- font
  WindowText(win, FONT_CONFIG_ID, "Font", x, y, 0, 0, 0x000000, true)
  WindowText(win, FONT_CONFIG_ID_UL, config.FONT.name .. " " .. config.FONT.size, x + width + GAP, y, 0, 0, 0x808080, true)

  -- change font hotspot
  WindowAddHotspot(win, "$<font>",
                   x + GAP, y, x + frame_width, y + font_config_height,   -- rectangle
                   "", "", "", "", "map.mouseup_change_font",  -- mouseup
                   "Click to change font",
                   1, 0)  -- hand cursor
  y = y + font_config_height
end


function mouseup_configure(flags, hotspot_id)
  draw_configure_box = true
  gui_draw()
end

function mouseup_close_configure(flags, hotspot_id)
  main.archive("mapper_config", config)
  draw_configure_box = false
  gui_config_room()
  gui_draw()
end

function mouseup_change_color(flags, hotspot_id)
  local which = string.match(hotspot_id, "^$color:([%a%d_]+)$")
  if not which then
    return
  end

  local newcolor = PickColour(config[which].color)
  if newcolor == -1 then
    return
  end

  config[which].color = newcolor
end

function mouseup_change_font(flags, hotspot_id)
  local newfont = utils.fontpicker(config.FONT.name, config.FONT.size, config.ROOM_NAME_TEXT.color)

  if not newfont then
    return
  end

  config.FONT.name = newfont.name

  if newfont.size > 12 then
    utils.msgbox("Maximum allowed font size is 12 points.", "Font too large", "ok", "!", 1)
  else
    config.FONT.size = newfont.size
  end

  display.Debug("New map font: " .. newfont.name .. ", " .. newfont.size .. "pt", "map")

  -- reload new font
  WindowFont(win, FONT_ID, config.FONT.name, config.FONT.size)
  WindowFont(win, FONT_ID_UL, config.FONT.name, config.FONT.size, false, false, true)
  WindowFont(win, FONT_CONFIG_ID, config.FONT.name, 8)
  WindowFont(win, FONT_CONFIG_ID_UL, config.FONT.name, 8, false, false, true)

  -- see how tall it is
  font_height = WindowFontInfo(win, FONT_ID, 1)  -- height
  font_config_height = WindowFontInfo(win, FONT_CONFIG_ID, 1)
end

function mouseup_room(flags, hotspot_id)
  local vnum = hotspot_id

  -- Right click
  if bit.band(flags, 0x20) ~= 0 then
    if bit.band(flags, 0x02) ~= 0 then
      display.Debug("Ctrl-Right click: " .. vnum)
      return
    end

    display.Debug("Right click: " .. vnum)
    if type(room_click) == "function" then
      room_click(vnum, flags)
    end
    return
  end

  -- Control-Left click
  if bit.band(flags, 0x02) ~= 0 then
    display.Debug("Ctrl-Left click: " .. vnum, "map")
    --cancel_speedwalk()
    return
  end -- if ctrl-LH click

  -- Left click
  display.Debug("Left click: " .. vnum, "map")
  Execute("go " .. vnum)
end


function room_edit_tags(room, vnum)
  local edit_tags = table.concat(room.tags, ", ")
  if #room.tags > 0 then
    newtags = utils.inputbox("Modify room tags (separated by commas)", room.name, edit_tags)
  else
    newtags = utils.inputbox("Enter room tags (separated by commas)", room.name, edit_tags)
  end

  if not newtags then
    return
  end

  if newtags == "" then
    if #room.tags < 1 then
      display.Info("No tags entered.")
      return
    else
      dbu:execute(string.format("DELETE FROM tags WHERE uid = %s;", fixsql(vnum)))
      display.Info("Tags for room " .. vnum .. " deleted. Was previously: " .. edit_tags)
      for _,tag in ipairs(room.tags) do
        tags[tag] = nil
      end
      rooms[vnum].tags = {}
      return
    end
  end

  if edit_tags == newtags then
    return
  end

  if #room.tags > 0 then
    dbu:execute(string.format("DELETE FROM tags WHERE uid = %s", fixsql(vnum)))
    for _,tag in ipairs(room.tags) do
      tags[tag] = nil
    end
  end

  room.tags = php.split(newtags, ",")
  for _,tag in ipairs(room.tags) do
    tag = php.trim(tag)
    dbu:execute(string.format("INSERT INTO tags (name, uid, date_added) VALUES (%s, %s, DATETIME('NOW'))", fixsql(tag), fixsql(vnum)))
    tags[tag] = vnum
  end
  display.Info("Tags for room " .. vnum .. " changed to: " .. table.concat(room.tags, ", "))

  rooms[vnum].tags = room.tags
  rooms[vnum].hovermessage = gui_build_hover_message(rooms[vnum])
  gui_draw()
end

function room_edit_terrain_color(room, vnum)
  if not room.env then
    utils.msgbox("This room does not have a terrain type.", "Unknown terrain!", "ok", "!", 1)
    return
  end

  local env_name = environments[room.env] or tostring(room.env)
  local color = terrain_colors[env_name]

  local newcolor = PickColour(color or 0x000000)
  if newcolor == -1 or newcolor == color then
    return
  end

  if user_terrain[env_name] then
    dbu:execute(string.format("UPDATE terrain SET color = %s, date_added = DATETIME('NOW') WHERE name = %s;", fixsql(newcolor), fixsql(env_name)))
    display.Info("Color for terrain '" .. env_name .. "' changed to " .. RGBColourToName(newcolor))
  else
    user_terrain[env_name] = true
    dbu:execute(string.format("INSERT INTO terrain (color, name, date_added) VALUES (%s, %s, DATETIME('NOW'));", fixsql(newcolor), fixsql(env_name)))
    display.Info("Color for terrain '" .. env_name .. "' is now " .. RGBColourToName(newcolor))
  end

  terrain_colors[env_name] = newcolor
  gui_config_room()

  gui_draw()
end

function room_click(vnum, flags)
  -- check we got room at all
  if not vnum or not tonumber(vnum) then
    return nil
  end

  local vnum = tonumber(vnum)
  local room = rooms[vnum]
  if not room then
    return
  end

  -- TODO: add/change special exits
  local handlers = {
    { name = "Edit tags", func = map.room_edit_tags}
  }

  if room.env and tonumber(room.env) and environments[room.env] then
    table.insert(handlers, { name = "Edit terrain color", func = map.room_edit_terrain_color})
  end

  local t, tf = {}, {}
  for _,v in ipairs(handlers) do
    table.insert(t, v.name)
    tf[v.name] = v.func
  end

  local choice = WindowMenu(map.win,
                            WindowInfo(map.win, 14),
                            WindowInfo(map.win, 15),
                            table.concat(t, "|"))

  local f = tf[choice]
  if f then
    f(room, vnum)
  end
end


function get_environment_id(name)
  for id,n in pairs(environments) do
    if string.lower(n) == string.lower(name) then
      return id
    end
  end

  return 0
end

function room_is_water(vnum)
  local vnum = vnum or current_room
  if not vnum then
    return false
  end

  local room = rooms[vnum]
  if not room then
    return false
  end

  local terrain = string.lower(environments[room.env or 1] or "")
  if terrain == "ocean" or
     terrain == "freshwater" or
     terrain == "deep ocean" or
     terrain == "reef" or          -- ??
     terrain == "river" then
    return true
  end

  return false
end

function room_is_underwater(uid)
  local vnum = vnum or current_room
  if not vnum then
    return false
  end

  local room = rooms[vnum]
  if not room then
    return false
  end

  local terrain = string.lower(environments[room.env or 1] or "")
  if terrain == "deep ocean" then
    return true
  end

  return false
end

function room_is_indoors(vnum)
  local vnum = vnum or current_room
  local rm = rooms[vnum]
  if not rm then
    return nil
  end

  return rm.indoors
end

function find_rooms(name, area, wcf, wcb, sameplane)
  if not db or not dbu then
    return nil
  end

  local area = area or {}
  if #area == 1 then
    -- Some areas need to be consolidated into a single area
    if area[1] == 187 then
      area[2] = 188
    elseif area[1] == 188 then
      area[2] = 187
    end
  end

  local name = name
  local query = "SELECT uid, name FROM rooms"
  if name and #name > 0 then
    name = string.gsub(name, "([%%%_])", "%%%1")
    if wcf then
      name = "%" .. name
    end
    if wcb then
      name = name .. "%"
    end
    query = query .. string.format(" WHERE name LIKE %s", fixsql(name))
  end

  local my_plane = get_room_plane(current_room)
  local found = {}
  local vnums = {}
  for row in db:nrows(query) do
    local vnum = tonumber(row.uid)
    if rooms[vnum] and
       (not sameplane or
        get_room_plane(vnum) == my_plane) then
      if #area < 1 then
        table.insert(found, vnum)
        vnums[vnum] = true
      else
        for _,a in ipairs(area) do
          if rooms[vnum].area == a then
            table.insert(found, vnum)
            vnums[vnum] = true
            break
          end
        end
      end
    end
  end

  for row in dbu:nrows(query) do
    local vnum = tonumber(row.uid)
    if rooms[vnum] and
       (not sameplane or
        get_room_plane(vnum) == my_plane) then
      if #area < 1 and not vnums[vnum] then
        table.insert(found, vnum)
      else
        for _,a in ipairs(area) do
          if rooms[vnum].area == a and not vnums[vnum] then
            table.insert(found, vnum)
            break
          end
        end
      end
    end
  end

  return found
end

function find_rooms_exact(name, area)
  if not db or not dbu then
    return nil
  end

  local area = area or {}
  if area and #area == 1 then
    -- Some areas need to be consolidated into a single area
    if area[1] == 187 then
      area[2] = 188
    elseif area[1] == 188 then
      area[2] = 187
    end
  end

  local query = string.format("SELECT uid, name FROM rooms WHERE name = %s", fixsql(name))

  local found = {}
  local vnums = {}
  for row in db:nrows(query) do
    local vnum = tonumber(row.uid)
    if rooms[vnum] then
      if #area < 1 then
        table.insert(found, vnum)
      else
        for _,a in ipairs(area) do
          if rooms[vnum].area == a then
            table.insert(found, vnum)
            vnums[vnum] = true
            break
          end
        end
      end
    end
  end

  for row in dbu:nrows(query) do
    local vnum = tonumber(row.uid)
    if rooms[vnum] then
      for _,a in ipairs(area) do
        if rooms[vnum].area == a and not vnums[vnum] then
          table.insert(found, vnum)
          break
        end
      end
    end
  end

  return found
end

function find_areas(name, wcf, wcb)
  if not db or not dbu then
    return
  end

  local name = string.gsub(name, "([%%%_])", "%%%1")
  if wcf then
    name = "%" .. name
  end
  if wcb then
    name = name .. "%"
  end
  local query = string.format("SELECT uid, name FROM areas WHERE name LIKE %s", fixsql(name))

  local found = {}
  local anums = {}
  for row in db:nrows(query) do
    table.insert(found, tonumber(row.uid))
    anums[found[#found]] = true
  end

  for row in dbu:nrows(query) do
    if not anums[tonumber(row.uid)] then
      table.insert(found, tonumber(row.uid))
    end
  end

  return found
end

function get_area_name(id)
  local id = id or current_area

  if id == 11 then
    return "New Celest"
  elseif id == 23 then
    return "the Etherwilde"
  elseif id == 25 then
    return "Faethorn"
  elseif id == 26 then
    return "Magnagora"
  elseif id == 28 then
    return "Etherglom"
  elseif id == 45 then
    return "the Tidal Flats"
  elseif id == 48 then
    return "the Moon Bubble"
  elseif id == 51 then
    return "the Night Bubble"
  elseif id == 65 then
    return "Nil"
  elseif id == 66 then
    return "Celestia"
  end

  if current_area_name then
    return current_area_name
  end

  if areas[id] then
    return areas[id]
  end

  return nil
end


function print_vnums(v, nocr)
  if #v > 0 then
    ColourTell("dimgray", "", " (")
    if not v[1] then
      ColourTell(colors.room_vnum, "", "<unknown>")
    else
      Hyperlink("go " .. v[1], v[1], "Run to " .. v[1], colors.room_vnum, "", 0)
    end
    if #v > 1 then
      ColourTell("dimgray", "", ",", "lime", "", "...")
    end
    ColourTell("dimgray", "", ")")
  end
  if not nocr then
    Note("")
  end
end

function print_vnums_area(v, nocr, noprefix)
  -- TODO: list first 3 rooms in an area and show multiple different area matches
  if #v > 0 then
    if not noprefix then
      ColourTell("silver", "", "Matching rooms:")
    end
    ColourTell("dimgray", "", " (")
    if not v[1] then
      ColourTell(colors.room_vnum, "", "<unknown>")
    else
      Hyperlink("go " .. v[1], v[1], "Run to " .. v[1], colors.room_vnum, "", 0)
    end
    if #v > 1 then
      ColourTell("dimgray", "", ",", "lime", "", "...")
    end
    ColourTell("dimgray", "", ")")

    ColourTell("dimgray", "", " (")
    if rooms[v[1]].area and areas[rooms[v[1]].area] then
      ColourTell(colors.area_name, "", php.strproper(areas[rooms[v[1]].area]))
    else
      ColourTell(colors.area_name, "", "<unknown>")
    end
    ColourTell("dimgray", "", ")")
  end
  if not nocr then
    Note("")
  end
end

function locate_scent(name, line, wildcards, styles)
  local c = ColourNameToRGB("silver")
  if names.is_member(wildcards[1], "celest") then
    c = GetTriggerOption("color_celestians__", "other_text_colour")
  elseif names.is_member(wildcards[1], "serenwilde") then
    c = GetTriggerOption("color_serens__", "other_text_colour")
  elseif names.is_member(wildcards[1], "glomdoring") then
    c = GetTriggerOption("color_gloms__", "other_text_colour")
  elseif names.is_member(wildcards[1], "magnagora") then
    c = GetTriggerOption("color_magnagorans__", "other_text_colour")
  elseif names.is_member(wildcards[1], "hallifax") then
    c = GetTriggerOption("color_hallifaxians__", "other_text_colour")
  elseif names.is_member(wildcards[1], "gaudiguch") then
    c = GetTriggerOption("color_gaudiguchites__", "other_text_colour")
  end
  ColourTell(RGBColourToName(c), "", string.format("%-20s", wildcards[1]), "silver", "", php.strproper(wildcards[2]))

  local rm = find_rooms_exact(wildcards[2], { current_area })
  print_vnums(rm)
end

function locate_far(name, line, wildcards, styles)
  failsafe.exec("mapper_who")

  local rm = find_rooms(wildcards[1])
  print_vnums_area(rm)
end

function locate_stone(name, line, wildcards, styles)
  failsafe.exec("mapper_who")
  EnableTrigger("map_locate_stone2__", false)

  for _,v in ipairs(styles) do
    ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), v.text)
  end

  local rm = find_rooms(wildcards[1])
  print_vnums_area(rm, false, true)
end

function locate_milestone(name, line, wildcards, styles)
  failsafe.exec("mapper_who")

  -- TODO: improve milestone tracking to note ID and vnum when first imbued

  Hyperlink("play majorsixth " .. wildcards[1], wildcards[1], "Travel to " .. wildcards[2], "dodgerblue", "", 0)
  Tell(string.rep(" ", 13 - string.len(wildcards[1])))
  ColourTell(colors.room_name, "", wildcards[2])

  local xlate = {
    ["Ackleberry Triple Junction"] = {294},
    ["Razine Mountains"] = {2609},
    ["Northern Mountains"] = {2523},
    ["Avechna's Peak"] = {132},
    ["Southern Mountains"] = {1925},
    ["The Grand Junction"] = {413},
    ["Avechna's Teeth"] = {2068},
    ["Ackleberry Junction"] = {328},
  }
  local rm = xlate[wildcards[2]] or find_rooms(wildcards[2])
  print_vnums_area(rm, false, true)
end

function handle_who(name, line, wildcards, styles)
  display.Debug("Handle who", "map")
  EnableTrigger("mapper_locate_who__", true)
  prompt.queue(function () EnableTrigger("mapper_locate_who__", false) end, "alwho")
end

function locate_who(name, line, wildcards, styles)
  if styles[2] and styles[2].text ~= " - " and styles[3] and styles[3].text ~= " - " then
    display.Debug("Ignore " .. wildcards[1], "map")
    return -- ignore Divine names
  end

  display.Debug("Locate " .. wildcards[1] .. " at " .. wildcards[2], "map")

  local title = wildcards[2]
  local rm = {}
  if #title < 48 then
    rm = find_rooms(title, nil, false, false, true)
  else
    rm = find_rooms(title, nil, false, true, true)
  end
  local person = wildcards[1]

  local c = names.person_color(person)

  if flags.get("area_who") then
    people_who = people_who or {}
    table.insert(people_who, { person = person, room = wildcards[2], where = rm, color = c })

    if #people_who == 1 then
      prompt.prequeue(function () map.show_who() failsafe.exec("mapper_who") end, "mapwho")
    end
  else
    Tell(string.format("%s", string.rep(" ", 13 - #person)))
    Hyperlink("getinfo " .. person, person, "Retrieve org info", c, "", 0)
    ColourTell("dimgray", "", " - ")
    local title = wildcards[2]
    if #rm > 0 then
      title = php.strproper(rooms[rm[1]].name)
    end
    ColourTell(colors.room_name, "", title)
    print_vnums_area(rm, false, true)
  end
end

function scent_target(name, line, wildcards, styles)
  local rm = find_rooms_exact(wildcards[1], {current_area})
  if #rm > 1 then
    display.Alert("Too many rooms match your target")
  elseif #rm == 1 then
    Execute("go " .. rm[1])
  end
end

function show_who()
  if not people_who or #people_who < 1 then
    return
  end

  local area_who = {}
  for _,pw in ipairs(people_who) do
    local v = false
    local a = "Unknown"
    local n = pw.room
    if #pw.where > 0 then
      v = pw.where[1]
      a = php.strproper(areas[rooms[v].area] or "Unknown")
      n = php.strproper(rooms[v].name or "Unknown")
    end
    area_who[a] = area_who[a] or {}
    area_who[a][n] = area_who[a][n] or {}
    table.insert(area_who[a][n], {person = php.trim(pw.person), more = #pw.where > 1, vnum = v, color = pw.color})
  end

  for a,v in pairs(area_who) do
    display.Prefix()
    ColourNote("dimgray", "", "(", colors.area_name, "", a, "dimgray", "", ")")
    for r,v2 in pairs(v) do
      display.Prefix()
      ColourTell(colors.room_name, "", "  " .. r)
      if v2[1].more then
        print_vnums({v2[1].vnum, v2[1].vnum})
      else
        print_vnums({v2[1].vnum})
      end
      display.Prefix()
      Tell("    ")
      for i,p in ipairs(v2) do
        if i > 1 then
          ColourTell("dimgray", "", ", ")
        end
        ColourTell(p.color, "", p.person)
      end
      Note()
    end
  end
end

function handle_following()
  ColourTell("silver", "", flags.get("follow_text"))

  if flags.get("follow_spexit") then
    ColourTell("red", "", " (", "yellow", "", "sp", "red", "", ")")
  end

  ColourTell("dimgray", "", " (", colors.room_vnum, "", current_room, "dimgray", "", ")")

  if flags.get("follow_area") ~= get_area_name() then
    ColourTell("dimgray", "", " (", colors.area_name, "", php.strproper(get_area_name()), "dimgray", "", ")")
  end

  Note("")
end

function followed(name, line, wildcards, styles)
  if not current_room or current_room < 1 then
    return
  end

  local dir = php.trim(wildcards[1] or "")
  if #dir < 1 or not dir_shorten[dir] then
    flags.set("follow_spexit", true)
  end

  flags.set("follow_text", line)
  flags.set("follow_area", get_area_name())

  prompt.prequeue(map.handle_following, "mapfollow")
end


function cmd_go(name, line, wildcards, styles)
  EnableTriggerGroup("Speedwalking", true)
  go_next()
end

function cmd_goto(name, line, wildcards, styles)
  cmd_path(name, line, wildcards, styles)
  cmd_go(name, line, wildcards, styles)
end

function cmd_stop(name, line, wildcards, styles)
  if autowalk and autowalk > 0 then
    autowalk = 0
    cancel_speedwalk("stopped")
    return
  end
  Send("stop")
end

function cmd_status(name, line, wildcards, styles)
  local room_count = 0
  local area_count = 0
  for _ in pairs(rooms) do
    room_count = room_count + 1
  end
  for _ in pairs(areas) do
    area_count = area_count + 1
  end

  display.Info("Map Status:")
  display.Prefix()
  ColourNote("silver", "", "  Rooms: ", "lime", "", room_count)
  display.Prefix()
  ColourNote("silver", "", "  Areas: ", "lime", "", area_count)
  if IsConnected() then
    Send("")
  end
end

function cmd_visited(name, line, wildcards, styles)
  local room_count = 0
  local visited = 0
  local area_visited = 0
  local area_unvisited = 0

  local area_charted = {}
  local count_ac = 0
  local count_auc = 0
  for n,a in pairs(areas) do
    area_charted[n] = false
    count_auc = count_auc + 1
  end

  for _,room in pairs(rooms) do
    room_count = room_count + 1
    if room.visited then
      if not area_charted[room.area] then
        area_charted[room.area] = true
        count_auc = count_auc - 1
        count_ac = count_ac + 1
      end

      visited = visited + 1
      if room.area == current_area then
        area_visited = area_visited + 1
      end
    elseif room.area == current_area then
      area_unvisited = area_unvisited + 1
    end
  end

  display.Info("Summary Report of Rooms Visited:")
  display.Prefix()
  ColourTell("silver", "", "  Visited:         ", "lime", "", string.format("%5d", visited),
             "silver", "", "  Unvisited:       ", "lime", "", string.format("%5d", room_count - visited))
  if room_count == 0 then
    ColourNote("darkcyan", "", string.format("    %5.2f%%", 0.0))
  else
    ColourNote("darkcyan", "", string.format("    %5.2f%%", visited / room_count * 100.0))
  end
  display.Prefix()
  ColourTell("silver", "", "  Local Visited:   ", "lime", "", string.format("%5d", area_visited),
             "silver", "", "  Local Unvisited: ", "lime", "", string.format("%5d", area_unvisited))
  if (area_unvisited + area_visited) == 0 then
    ColourNote("darkcyan", "", string.format("    %5.2f%%", 0.0))
  else
    ColourNote("darkcyan", "", string.format("    %5.2f%%", area_visited / (area_unvisited + area_visited) * 100.0))
  end
  display.Prefix()
  ColourTell("silver", "", "  Areas Visited:   ", "lime", "", string.format("%5d", count_ac),
             "silver", "", "  Areas Unvisited: ", "lime", "", string.format("%5d", count_auc))
  if (count_ac + count_auc) == 0 then
    ColourNote("darkcyan", "", string.format("    %5.2f%%", 0.0))
  else
    ColourNote("darkcyan", "", string.format("    %5.2f%%", count_ac / (count_ac + count_auc) * 100.0))
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_landmarks(name, line, wildcards, styles)
  display.Info("Map Landmarks:")
  local found = false
  for tag,vnum in pairs(tags) do
    found = true
    display.Prefix()
    ColourNote("dimgray", "", "  (", colors.room_vnum, "", string.format("%6d", vnum), "dimgray", "", ") [", "darkcyan", "", tag, "dimgray", "", "] ",
      colors.room_name, "", php.strproper(rooms[vnum].name), "dimgray", "", " (", colors.area_name, "", php.strproper(areas[rooms[vnum].area or 0] or "<unknown>"), "dimgray", "", ")")
  end

  if not found then
    display.Prefix()
    ColourNote("silver", "", "  None found. Add some by right-clicking rooms.")
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_show_rooms(name, line, wildcards, styles)
  local area = wildcard_to_area(wildcards[1])
  if not area or area < 1 or not areas[area] then
    display.Error("No room data available for area " .. tostring(area) .. ".")
    return
  end

  local count = 0
  local limit = tonumber(wildcards[2]) or 2000
  local arooms = find_rooms(nil, {area})

  display.Prefix()
  ColourNote("white", "", "Found " .. #arooms .. " rooms in ", colors.area_name, "", areas[area], "dimgray", "", " [", colors.area_vnum, "", area, "dimgray", "", "]", "white", "", ":")
  for _,v in pairs(arooms) do
    display.Prefix()
    Tell("  ")
    print_vnums({v}, true)

    local l = string.len(tostring(v))
    ColourTell("dimgray", "", string.rep(" ", 6 - l) .. "[")
    if rooms[v].visited then
      ColourTell("silver", "", "X")
    else
      Tell(" ")
    end
    ColourTell("dimgray", "", "] ")
    ColourNote(colors.room_name, "", rooms[v].name)

    count = count + 1
    if count >= limit then
      break
    end
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_spe_create(name, line, wildcards, styles)
  local cmd = string.lower(wildcards[1])
  local d = string.lower(wildcards[2] or "")
  if d and #d > 0 then
    d = dir_lengthen[d] or d
    if not dir_shorten[d] then
      display.Error("There is no '" .. tostring(d) .. "' direction among the cardinal choices.")
      return
    end
  end

  flags.set("spexit", { from = current_room, cmd = cmd, alias = d }, 1)
  Execute(cmd)
end

function cmd_spe_destroy(name, line, wildcards, styles)
  if not current_room then
    display.Warning("Your cartographer is lost again!")
    return
  end

  local cmd = string.lower(wildcards[1])
  if rooms[current_room].spexits[cmd] then
    rooms[current_room].spexits[cmd] = nil
    destroy_special_exit(cmd, current_room)
    display.Info("Successfully erased '" .. cmd .. "' from the map.")
  else
    display.Error("Your cartographer just gives you a puzzled look.")
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_area_visited(name, line, wildcards, styles)
  if string.lower(wildcards[1] or "") == "all" then
    table.insert(wildcards, 1, "")
  end

  local area_found = wildcard_to_area(wildcards[1])
  if not area_found then
    return
  end

  local visited = 0
  local unvisited = {}

  for _,room in pairs(rooms) do
    if room.area == area_found then
      if room.visited then
        visited = visited + 1
      else
        table.insert(unvisited, room)
      end
    end
  end

  display.Prefix()
  ColourNote("white", "", "Area Report of Rooms Visited for ",
             colors.area_name, "", php.strproper(areas[area_found] or "<unknown>"),
             "white", "", ":")
  display.Prefix()
  ColourTell("silver", "", "    Visited:   ", "lime", "", string.format("%4d", visited),
             "silver", "", "  Unvisited: ", "lime", "", string.format("%4d", #unvisited))
  if (visited + #unvisited) == 0 then
    ColourNote("darkcyan", "", string.format("    %5.2f%%", 0.0))
  else
    ColourNote("darkcyan", "", string.format("    %5.2f%%", visited / (visited + #unvisited) * 100.0))
  end

  if #unvisited > 0 then
    display.Prefix()
    if #unvisited > 20 and (not wildcards[2] or #wildcards[2] < 1) then
      ColourNote("cyan", "", "  Rooms Unvisited (first 20):")
    else
      ColourNote("cyan", "", "  Rooms Unvisited:")
    end

    local c = 0
    for i,r in ipairs(unvisited) do
      if c > 20 and (not wildcards[2] or #wildcards[2] < 1) then
        break
      end

      display.Prefix()
      Tell("  ")
      print_vnums({r.vnum}, true)
      local l = string.len(tostring(r.vnum))
      ColourNote(colors.room_name, "", string.rep(" ", 6 - l) .. r.name)

      c = c + 1
    end
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_areas_visited(name, line, wildcards, styles)
  local area_count = 0
  local visited = 0
  local area_visited = {}
  local area_unvisited = {}
  local area_charted = {}

  for _,room in pairs(rooms) do
    if not area_charted[room.area] then
      area_charted[room.area] = true
      area_count = area_count + 1
    end
    if room.visited then
      if not area_visited[room.area] then
        visited = visited + 1
      end
      area_visited[room.area] = (area_visited[room.area] or 0) + 1
    else
      area_unvisited[room.area] = (area_unvisited[room.area] or 0) + 1
    end
  end

  local partials = 0
  for a in pairs(area_unvisited) do
    if area_visited[a] then
      partials = partials + 1
    end
  end

  display.Info("Summary Report of Areas Visited:")
  display.Prefix()
  ColourNote("silver", "", "  Visited:   ", "lime", "", string.format("%4d", visited),
             "silver", "", "  Unvisited: ", "lime", "", string.format("%4d", area_count - visited),
             "silver", "", "  Partial:   ", "lime", "", string.format("%4d", partials))
  display.Info("")

  local col = 1
  local ncols = 2
  for a in pairs(area_unvisited) do
    if not area_visited[a] then
      if col == 1 then
        display.Prefix()
      end

      ColourTell("dimgray", "", "  (", colors.area_vnum, "", string.format("%3d", a), "dimgray", "", ") ")
      if area_off[a] then
        ColourTell("maroon", "", string.format("%-30s", php.strproper(string.sub(areas[a] or "<unknown>", 1, 30))))
      else
        ColourTell(colors.area_name, "", string.format("%-30s", php.strproper(string.sub(areas[a] or "<unknown>", 1, 30))))
      end

      col = col + 1
      if col > ncols then
        Note("")
        col = 1
      end
    end
  end
  if col == 1 then
    Note("")
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_area_toggle(name, line, wildcards, styles)
  local area_found = wildcard_to_area(wildcards[2])
  if not area_found then
    return
  end

  local mode = string.lower(wildcards[1])
  if mode == "off" or mode == "disable" then
    area_off[area_found] = true
    display.Info("You will now bypass '" .. areas[area_found] .. "' whenever possible.")
  else
    area_off[area_found] = nil
    display.Info("You are free to run through '" .. areas[area_found] .. "' now.")
  end
  SetVariable("sg1_map_area_off", json.encode(area_off))
  if IsConnected() then
    Send("")
  end
end

function cmd_area_list(name, line, wildcards, styles)
  local areas_to_show = {}
  if wildcards[1] and #wildcards[1] > 0 then
    areas_to_show = find_areas(wildcards[1], true, true)
    if #areas_to_show < 1 then
      display.Info("No areas were found matching your query.")
      if IsConnected() then
        Send("")
      end
      return
    end
    display.Info("Known Areas Matching '" .. wildcards[1] .. "':")
  else
    for a in pairs(areas) do
      table.insert(areas_to_show, a)
    end
    display.Info("Known Areas Status Report:")
  end

  local col = 1
  local ncols = 2
  for _,a in ipairs(areas_to_show) do
    if col == 1 then
      display.Prefix()
    end

    ColourTell("dimgray", "", "  (", colors.area_vnum, "", string.format("%3d", a), "dimgray", "", ") ")
    if area_off[a] then
      ColourTell("maroon", "", string.format("%-30s", string.sub(php.strproper(areas[a]), 1, 30)))
    else
      ColourTell(colors.area_name, "", string.format("%-30s", string.sub(php.strproper(areas[a]), 1, 30)))
    end

    col = col + 1
    if col > ncols then
      Note("")
      col = 1
    end
  end
  if col == 1 then
    Note("")
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_path(name, line, wildcards, styles)
  if string.lower(wildcards[1]) == "clear" then
    cancel_speedwalk("cleared")
    return
  end

  if not current_room then
    display.Warning("Your cartographer is lost again!")
    return
  end

  local dest = wildcards[1]
  local timer = GetInfo(232)

  local vnum = tonumber(dest)
  if vnum then
    if not rooms[vnum] then
      display.Warning("Your cartographer cannot see '" .. dest .. "' anywhere on the map.")
      return
    end
  elseif not tags or not tags[string.lower(dest)] then
    display.Warning("Your cartographer cannot see '" .. dest .. "' anywhere on the map.")
    return
  else
    vnum = tags[string.lower(dest)]
  end

  if vnum == current_room then
    display.Info("You're already there!")
    return
  end

  router(vnum)
  if not rooms[current_room].pathing then
    display.Warning("Your cartographer gives you a puzzled look, as if he doesn't know how reach your chosen destination.")
    return
  end

  timer = GetInfo(232) - timer
  display.Info("Path calculated in " .. string.format("%0.4f", timer * 1000000.0) .. " microseconds.")

  show_route()
end

function cmd_path_show(name, line, wildcards, styles)
  show_route()
end

function cmd_room_look(name, line, wildcards, styles)
  local uid = wildcards[1]
  local vnum = 0
  if #uid == 0 then
    vnum = current_room
    if not vnum then
      display.Info("Your cartographer is lost again!")
      if IsConnected() then
        Send("")
      end
      return
    end
  elseif tonumber(uid) then
    vnum = tonumber(uid)
  else
    vnum = tags[string.lower(uid)]
    if not vnum then
      display.Info("Tag not found: " .. uid)
      if IsConnected() then
        Send("")
      end
      return
    end
  end

  local room = rooms[vnum]
  if not room then
    display.Info("Your cartographer seems unsure.")
    if IsConnected() then
      Send("")
    end
    return
  end

  local indoors = room_is_indoors(vnum)
  if indoors == nil then
    indoors = "<unknown>"
  else
    indoors = tostring(indoors)
  end

  display.Prefix()
  ColourNote("red", "", "Room: ", "silver", "", php.strproper(room.name or "<unknown>"),
             "red", "", "  ID: ", "silver", "", vnum)
  display.Prefix()
  if room.plane then
    ColourNote("red", "", "Area: ", "silver", "", php.strproper(areas[room.area or 1] or "<unknown>"),
               "dimgray", "", " (", colors.area_name, "", room.area or 1, "dimgray", "", ")",
               "red", "", "  Plane: ", "silver", "", php.strproper(get_room_plane(vnum) or "<unknown>"))
  else
    ColourNote("red", "", "Area: ", "silver", "", php.strproper(areas[room.area or 1] or "<unknown>"),
               "dimgray", "", " (", colors.area_name, "", room.area or 1, "dimgray", "", ")",
               "red", "", "  Plane: ", "silver", "", php.strproper(get_room_plane(vnum) or "<unknown>"), "dimgray", "", " (", "yellow", "", "?", "dimgray", "", ")")
  end
  display.Prefix()
  ColourNote("red", "", "Type: ", "silver", "", environments[room.env or 1] or "<unknown>",
             "red", "", "  Water: ", "silver", "", tostring(room_is_water(vnum)),
             "red", "", "  Underwater: ", "silver", "", tostring(room_is_underwater(vnum)),
             "red", "", "  Indoors: ", "silver", "", indoors,
             "red", "", "  Visited: ", "silver", "", tostring(room.visited or false))

  if room.tags and #room.tags > 0 then
    display.Prefix()
    ColourNote("red", "", "Tags: ", "silver", "", table.concat(room.tags, ", "))
  end

  for k,v in pairs(room.exits or {}) do
    local name = "<unknown>"
    if rooms[v] then
      name = rooms[v].name or "<unknown>"
    end
    display.Prefix()
    ColourTell("blue", "", "  " .. (dir_lengthen[k] or k), "dimgray", "", ": (")
    Hyperlink(dir_lengthen[k] or k, v, "Move to " .. name, colors.room_vnum, "", 0)
    ColourNote("dimgray", "", ") ", colors.room_name, "", php.strproper(name))
  end

  for cmd,spe in pairs(room.spexits or {}) do
    display.Prefix()
    ColourTell("blue", "", "  " .. (cmd or "n/a"))
    if #spe.alias > 0 then
      ColourTell("dimgray", "", " [", "blue", "", spe.alias, "dimgray", "", "]")
    end
    ColourTell("dimgray", "", ": (")
    Hyperlink(cmd, spe.to, "Move to " .. rooms[spe.to].name, colors.room_vnum, "", 0)
    ColourNote("dimgray", "", ") ", colors.room_name, "", php.strproper(rooms[spe.to].name))
  end

  if IsConnected() then
    Send("")
  end
end

function cmd_room_area(name, line, wildcards, styles)
  local vnum = tonumber(wildcards[1] or "")
  if not vnum then
    vnum = current_room
  end

  if not rooms[vnum] then
    display.Error("No such room exists! Try ROOM FIND <name>, maybe.")
    return
  end
  
  local anum = tonumber(wildcards[2])
  if not anum then
    return
  end


  if not areas[anum] and anum ~= 0 then
    display.Error("No such area exists! Check AREA LIST.")
    return
  end

  if current_room == vnum then
    current_area = anum
  end
  rooms[vnum].area = anum
  save_room(rooms[vnum])
  gui_draw()
  if anum == 0 then
    display.Info("Cleared area for room " .. vnum)
  else
    display.Info("Changed area for room " .. vnum .. " to " .. areas[anum])
  end
  if IsConnected() then
    Send("")
  end
end

function cmd_room_find(name, line, wildcards, styles)
  local text = wildcards[1]
  local rm = find_rooms(text, {}, true, true)
  if not rm or #rm < 1 then
    display.Prefix()
    ColourNote("red", "", "No room matches found for '" .. text .. "'")
    if IsConnected() then
      Send("")
    end
    return
  end

  display.Prefix()
  ColourNote("red", "", "Rooms that match '" .. text .. "' ", "dimgray", "", "(" .. #rm .. ")")
  local c = 0
  for _,v in ipairs(rm) do
    c = c + 1
    if c > tonumber(GetVariable("sg1_option_map_find") or "50") then
      display.Info("Too many results to show them all. Consider narrowing down your search terms.")
      break
    end
    display.Prefix()
    ColourTell("dimgray", "", " (")
    Hyperlink("go " .. v, v, "Run to " .. rooms[v].name, colors.room_vnum, "", 0)
    ColourTell("dimgray", "", ") ", "silver", "", php.strproper(rooms[v].name))
    if not current_area or rooms[v].area ~= current_area then
      ColourNote("dimgray", "", " (", colors.area_name, "", php.strproper(areas[rooms[v].area] or "<unknown area>"), "dimgray", "", ")")
    else
      Note("")
    end
  end
  if IsConnected() then
    Send("")
  end
end


if not php.exists("map.db") then
  db = assert(sqlite3.open("map.db"))
  create_database()
else
  db = assert(sqlite3.open("map.db"))
end

local user_mapname = GetVariable("sg1_option_mapdb") or "map_user.db"
if not php.exists(user_mapname) then
  dbu = assert(sqlite3.open(user_mapname))
  create_user_database()
else
  dbu = assert(sqlite3.open(user_mapname))
end

if db and dbu then
--  clear_duplicate_rooms()
  wait.make(function () map.load_map() end)
end

gui_init()
