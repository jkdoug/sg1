module (..., package.seeall)

require "main"
local copytable = require "copytable"
local php = require "php"

local valid_orgs = {"celest", "glomdoring", "magnagora", "serenwilde", "hallifax", "gaudiguch"}
local divine_names = {"Estarra", "Roark", "Auseklis", "Isune", "Lacostian", "Fain", "Raezon", "Lisaera",
                      "Terentia", "Hajamin", "Viravain", "Shikari", "Elcyrion", "Charune", "Lyreth",
                      "Morgfyre", "Sior", "Elostian", "Ayridion", "Nocht", "Eventru", "Maylea", "Kalikai",
                      "Hoaracle", "Mysrai", "Iosai"}
local stupid_names = {"Near", "Trace"}
local people = main.bootstrap("names") or {}
local last_seen = main.bootstrap("last_seen") or {}

local function get(org)
  local org = string.lower(org)
  if not is_valid_org(org) then
    display.Error("Invalid organization: " .. org)
    return nil
  end

  return people[org]
end

local function set(org, n)
  local org = string.lower(org)
  if not is_valid_org(org) then
    display.Error("Invalid organization: " .. org)
    return false
  end

  people[org] = n or {}
  main.archive("names", people)
  EnableTimer("names_lists__", true)
  return true
end


function is_divine(name)
  for _,n in ipairs(divine_names) do
    if n == name then
      return true
    end
  end

  return false
end

function is_stupid(name)
  for _,n in ipairs(stupid_names) do
    if n == name then
      return true
    end
  end

  return false
end

function is_member(name, org)
  local op = get(org)

  if not op then
    return false
  end

  local person = string.lower(name)
  for k,v in pairs(op) do
    if string.lower(v) == person then
      return true
    end
  end

  return false
end

function is_valid_org(org)
  local o = string.lower(org)

  for _,v in ipairs(valid_orgs) do
    if o == v then
      return true
    end
  end

  return false
end

function is_ally_org(org)
  local o = string.lower(org)
  return o == "serenwilde" or o == "celest" or o == "hallifax"
end

function is_enemy_org(org)
  local o = string.lower(org)
  return o == "glomdoring" or o == "gaudiguch" or o == "magnagora"
end

function is_in_ally_org(name)
  return is_ally_org(member_of(name))
end

function is_in_enemy_org(name)
  return is_enemy_org(member_of(name))
end

function member_of(name)
  for _,o in ipairs(valid_orgs) do
    if is_member(name, o) then
      return o
    end
  end

  return ""
end


function mark(name)
  last_seen[name] = os.time()
  main.archive("last_seen", last_seen)
end

function unmark(name)
  last_seen[name] = nil
  main.archive("last_seen", last_seen)
end


function person_color(person, default)
  local c = default or ColourNameToRGB("silver")
  if is_member(person, "celest") then
    c = GetTriggerOption("color_celestians__", "other_text_colour")
  elseif is_member(person, "serenwilde") then
    c = GetTriggerOption("color_serens__", "other_text_colour")
  elseif is_member(person, "glomdoring") then
    c = GetTriggerOption("color_gloms__", "other_text_colour")
  elseif is_member(person, "magnagora") then
    c = GetTriggerOption("color_magnagorans__", "other_text_colour")
  elseif is_member(person, "hallifax") then
    c = GetTriggerOption("color_hallifaxians__", "other_text_colour")
  elseif is_member(person, "gaudiguch") then
    c = GetTriggerOption("color_gaudiguchites__", "other_text_colour")
  end
  return RGBColourToName(c)
end


function add(name, org)
  local person = php.strproper(name)
  local o = php.strproper(org)
  local p = get(org)

  if not p or GetAlphaOption("player") == person or is_divine(person) or is_stupid(person) then
    return
  elseif is_member(person, org) then
    display.Alert(person .. " is already in " .. o)
    return
  end

  for _,v in ipairs(valid_orgs) do
    if string.lower(org) ~= v and is_member(person, v) then
      del(person, v)
    end
  end

  table.insert(p, person)
  if set(org, p) then
    mark(person)
    display.Info(person .. " added to " .. o)
  end
end

function del(name, org)
  local person = php.strproper(name)
  local o = php.strproper(org)
  local p = get(org)

  if not p then
    return
  elseif not is_member(person, org) then
    display.Alert(person .. " is not in " .. o)
    return
  end

  for k,v in ipairs(p) do
    if v == person then
      table.remove(p, k)
      if set(org, p) then
        unmark(person)
        display.Info(person .. " removed from " .. o)
      end
    end
  end
end

function show(org)
  local p = get(org)
  local o = php.strproper(org)

  display.Prefix()
  ColourNote("cyan", "", "Known people in " .. o .. " (" .. #p .. ")")
  if not p then
    display.Info("  No one yet!")
    return
  end

  local col = 1
  local ncols = 7
  for k,v in ipairs(p) do
    if col == 1 then
      display.Prefix()
    end
    ColourTell("silver", "", string.format("  %-15s", v))
    col = col + 1
    if col == ncols + 1 then
      Note("")
      col = 1
    end
  end
  if col > 1 then
    Note("")
  end

  if IsConnected() then
    Send("")
  end
end

function handle(name, line, wildcards, styles)
  local orgs = {
    glom = "glomdoring",
    mag = "magnagora",
    seren = "serenwilde",
    halli = "hallifax",
    gaudi = "gaudiguch"
  }
  local org = string.lower(wildcards[2])
  org = orgs[org] or org
  if #wildcards[3] > 0 then
    if #wildcards[1] > 0 then
      del(wildcards[3], org)
    else
      add(wildcards[3], org)
    end
  else
    show(org)
  end
end

function lists(name, line, wildcards, styles)
  -- TODO: remove those not seen for X days/months
  for _,v in pairs(valid_orgs) do
    local n = copytable.shallow(people[v] or {})
    table.sort(n, function (x, y) return (last_seen[x] or 0) < (last_seen[y] or 0) end)
    set(v, n)
    SetVariable("sg1_people_" .. v, table.concat(n, "|"))
  end
  ResetTimer("names_lists__")
  EnableTimer("names_lists__", false)
end

function highmark(name, line, wildcards, styles)
  mark(wildcards[0])
end


for _,v in ipairs(valid_orgs) do
  local op = GetVariable("sg1_names_" .. v)
  if op then
    people[v] = php.explode("|", op)
    DeleteVariable("sg1_names_" .. v)
  end
end
main.archive("names", people)
EnableTimer("names_lists__", true)
