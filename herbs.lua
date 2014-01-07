module (..., package.seeall)

local php = require "php"

hibernation = {
  horehound = "Vestian",
  wormwood = "Vestian",
  mistletoe = "Avechary",
  flax = "Estar",
  weed = "Estar",
  myrtle = "Estar",
  merbloom = "Estar",
  kafe = "Urlachmar",
  rawtea = "Urlachmar",
  colewort = "Kiani",
  sage = "Dioni",
  kombu = "Dioni",
  juniper = "Dioni",
  calamus = "Dioni",
  earwort = "Dioni",
  sparkleberry = "Dvarsh",
  sargassum = "Tzarin",
  reishi = "Tzarin",
  arnica = "Klangiary",
  pennyroyal = "Klangiary",
  galingale = "Shanthin",
  rosehips = "Shanthin",
  marjoram = "Shanthin",
  chervil = "Roarkian",
  yarrow = "Roarkian",
  faeleaf = "Juliary",
  coltsfoot = "Juliary",
}

local xlate = {
  ["an arnica bud"] = "arnica",
  ["a calamus root"] = "calamus",
  ["a sprig of chervil"] = "chervil",
  ["a colewort leaf"] = "colewort",
  ["a plug of coltsfoot"] = "coltsfoot",
  ["a piece of black earwort"] = "earwort",
  ["a stalk of faeleaf"] = "faeleaf",
  ["a bunch of flax"] = "flax",
  ["a stem of galingale"] = "galingale",
  ["a horehound blossom"] = "horehound",
  ["a juniper berry"] = "juniper",
  ["a kafe bean"] = "kafe",
  ["kombu seaweed"] = "kombu",
  ["a sprig of marjoram"] = "marjoram",
  ["a piece of merbloom seaweed"] = "merbloom",
  ["a sprig of mistletoe"] = "mistletoe",
  ["a bog myrtle leaf"] = "myrtle",
  ["a bunch of pennyroyal"] = "pennyroyal",
  ["raw tea leaves"] = "rawtea",
  ["a reishi mushroom"] = "reishi",
  ["a pile of rosehips"] = "rosehips",
  ["a sage branch"] = "sage",
  ["sargassum seaweed"] = "sargassum",
  ["a sparkleberry"] = "sparkleberry",
  ["a packet of spices"] = "spices",
  ["a sprig of cactus weed"] = "weed",
  ["a wormwood stem"] = "wormwood",
  ["a yarrow sprig"] = "yarrow",
}

local items = php.Table()
local room = {}
local count = 0
local tracker = {}


local function color(name, cnt)
  local fg = "greenyellow"
  if is_hibernating(name) then
    fg = "dimgray"
  elseif gear.inv(name) >= gear.maxrift() - tonumber(GetVariable("sg1_herb_pocket") or "0") then
    fg = "brown"
  elseif cnt <= 5 then
    fg = "darkorange"
  end
  ColourNote("silver", "", string.format("%-40s", string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2)),
             fg, "", string.format("%3d", cnt),
             "silver", "", " left")
end


function is_hibernating(name, month)
  if not month then
    month = calendar.month
  end

  local herb = xlate[name] or name
  return hibernation[herb] == month
end

function reset()
  count = 0
  items = php.Table()
  room = {}
  Execute("undo hpick")
end


function handle_plants(name, line, wildcards, styles)
  reset()
  EnableGroup("Plants", true)
  prompt.queue(function () EnableGroup("Plants", false) end)
end

function handle_room(name, line, wildcards, styles)
  local herb = wildcards[1]
  local cnt = tonumber(wildcards[2])

  color(herb, cnt)

  if not main.auto("harvest") then
    return
  end

  local ab = herb
  if ab == "rawtea" then
    ab = "tea"
  end

  if is_hibernating(herb) or not main.has_ability("herbs", ab) then
    return
  end

  room[herb] = cnt
  cnt = math.min(cnt - 5, gear.maxrift() - gear.rift("normal", herb) - tonumber(GetVariable("sg1_herb_pocket") or "0"))
  if cnt <= 0 then
    return
  end

  items[herb] = cnt
  count = count + cnt
  Execute("do1 hpick")

  display.Info("Queued up " .. cnt .. " " .. herb .. " for harvesting")
end

function handle_harvest(name, line, wildcards, styles)
  local herb = string.lower(wildcards[1])
  if not herb or #herb < 1 then
    herb = string.lower(GetVariable("sg1_harvesting") or "")
  end
  if #herb < 1 then
    display.Error("No current herb set for harvesting")
    return
  end
  SetVariable("sg1_harvesting", herb)
  Send("harvest " .. herb .. " single")
end

function handle_plant(name, line, wildcards, styles)
  local herb = GetVariable("sg1_harvesting")
  if not herb then
    display.Error("No current herb set for planting")
    return
  end
  Send("plant " .. herb)
end

function handle_pick(name, line, wildcards, styles)
  local herb = false
  for h in items:pairs() do
    herb = h
    break
  end
  if not herb then
    reset()
    return
  end
  SetVariable("sg1_harvesting", herb)
  SendNoEcho("harvest " .. herb)
end

function handle_spices(name, line, wildcards, styles)
  local herb = "spices"
  tracker[herb] = (tracker[herb] or 0) + 1

  if gear.rift("normal", "spices") < gear.maxrift() then
    SendNoEcho("inr spices")
  else
    SendNoEcho("combine spices")
  end

  herb = GetVariable("sg1_harvesting")
  if not herb or not items[herb] or not main.auto("harvest") then
    return
  end

  items[herb] = items[herb] - 1
  room[herb] = (room[herb] or 1) - 1
  count = count - 1
  if items[herb] <= 0 then
    items[herb] = nil
  end

  flags.set("doing", true)
  for h in items:pairs() do
    Execute("do1 hpick")
    return
  end
end

function handle_picked(name, line, wildcards, styles)
  local herb = GetVariable("sg1_harvesting")
  tracker[herb] = (tracker[herb] or 0) + 1

  if main.auto("harvest") then
    if gear.rift("normal", herb) < gear.maxrift() then
      SendNoEcho("inr " .. herb)
    end
  end

  if not items[herb] or not main.auto("harvest") then
    ColourNote("silver", "", wildcards[0])
    return
  else
    items[herb] = items[herb] - 1
    room[herb] = (room[herb] or 1) - 1
    count = count - 1
    if items[herb] <= 0 then
      items[herb] = nil
    end
    display.Info("Harvested " .. herb .. ", " .. (items[herb] or 0) .. " left (" .. (count or 0) .. " total)")
  end

  flags.set("doing", true)
  for h in items:pairs() do
    Execute("do1 hpick")
    return
  end
end

function handle_disappear(name, line, wildcards, styles)
  local herb = xlate[wildcards[1]] or wildcards[1]
  if not items[herb] then
    return
  end
  count = count - items[herb]
  items[herb] = nil
end

function handle_guarded(name, line, wildcards, styles)
  for h,c in items:pairs() do
    local r = room[h] or 0
    if r <= 10 then
      count = count - c
      items[h] = nil
    elseif r - c < 10 then
      local cnt = math.min(r - 10, gear.maxrift() - gear.rift("normal", h))
      count = count - c + cnt
      items[h] = cnt
    end
  end
  flags.clear("doing")
  Execute("do1 hpick")
end

function handle_reset(name, line, wildcards, styles)
  reset()
  display.Info("Harvesting ceased")
end


function show_almanac(name, line, wildcards, styles)
  local month = wildcards[1] or ""
  if #month > 0 then
    month = php.strproper(month)
  else
    month = calendar.month
  end
  if not month or not calendar.months[month] then
    display.Error("Invalid month passed to almanac (" .. tostring(month) .. ")")
    return
  end

  display.Info("Herb Almanac for " .. month .. ":")
  display.Prefix()
  ColourNote("silver", "", string.format("  %-12s  %7s  %7s  %4s", "Plant", "Harvest", "Replant", "Inv"))
  display.Prefix()
  ColourNote("silver", "", string.format("  %-12s  %7s  %7s  %4s", "-----", "-------", "-------", "---"))
  for _,k in pairs(gear.herb_list) do
    local v = hibernation[k]

    display.Prefix()
    ColourTell("darkcyan", "", string.format("  %-12s", k))

    local h = "Good"
    local r = "Good"
    local ch = "green"
    local cr = "green"
    local d = calendar.month_diff(month, v)
    if v == month then
      h = "Poor"
      ch = "dimgray"
      r = h
      cr = ch
    elseif d == 6 then
      h = "Great"
      ch = "lime"
    elseif d < 5 and d > 2 then
      h = "Okay"
      ch = "peru"
      r = h
      cr = ch
    elseif d <= 2 then
      h = "Fair"
      ch = "brown"
      local n1 = calendar.months[month]
      local n2 = calendar.months[v]
      if n2 == 12 then
        n1 = n1 + 12
      end
      local dm = n1 - n2
      if dm == 1 or dm == 2 then
        r = "Great"
        cr = "lime"
      elseif dm == 11 or dm == -1 then
        r = "Fair"
        cr = "brown"
      end
    end
    ColourTell(ch, "", string.format("  %7s", h),
               cr, "", string.format("  %7s", r))

      
    local d = gear.maxrift() - gear.inv(k)
    local c = "darkkhaki"
    if d > gear.maxrift() / 2 then
      c = "red"
    elseif d > gear.maxrift() / 4 then
      c = "orangered"
    elseif d <= 0 then
      c = "gray"
    end
    ColourTell(c, "", string.format("  %5d", gear.inv(k)))

    if calendar.next_month[month] == hibernation[k] then
      ColourNote("darkcyan", "", "  Next month")
    else
      Note()
    end
  end

  if IsConnected() then
    Send("")
  end
end

function show_tracker()
  display.Info("Herbs Picked:")

  local c = 0
  for _,h in pairs(xlate) do
    if tracker[h] then
      c = c + tracker[h]
      display.Prefix()
      ColourNote("silver", "", string.format("  %15s", h),
                 "white", "", string.format("  %d", tracker[h]))
    end
  end

  display.Prefix()
  if c < 1 then
    ColourNote("dimgray", "", "  Nothing today!")
  else
    ColourNote("dimgray", "", "  -----------------------")
    display.Prefix()
    ColourNote("tomato", "", string.format("  %15s  %d", "Total Count:", c))
  end

  if IsConnected() then
    Send("")
  end
end
