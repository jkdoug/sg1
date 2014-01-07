module(..., package.seeall)

day = 0
month = 0
year = 0
months = {
  Estar = 1,
  Urlachmar = 2,
  Kiani = 3,
  Dioni = 4,
  Vestian = 5,
  Avechary = 6,
  Dvarsh = 7,
  Tzarin = 8,
  Klangiary = 9,
  Juliary = 10,
  Shanthin = 11,
  Roarkian = 12,
}
next_month = {
  Estar = "Urlachmar",
  Urlachmar = "Kiani",
  Kiani = "Dioni",
  Dioni = "Vestian",
  Vestian = "Avechary",
  Avechary = "Dvarsh",
  Dvarsh = "Tzarin",
  Tzarin = "Klangiary",
  Klangiary = "Juliary",
  Juliary = "Shanthin",
  Shanthin = "Roarkian",
  Roarkian = "Estar",
}

local watch_hour = false
local watch_minute = false
local first_tick = false

local function calc_time()
  if not watch_hour or not watch_minute then
    return nil, nil
  end

  local this_tick = os.clock()
  local diff = (this_tick - first_tick) / 2.5

  local minute = watch_minute + diff
  local hour = watch_hour
  if minute >= 60 then
    hour = hour + minute / 60
    minute = minute % 60
    if hour >= 24 then
      hour = 0
    end
  end
  
  return hour, minute
end

local function calc_diff(h1, m1, h2, m2)
  return (h2 - h1) * 60 + m2 - m1
end

function set_watch(hr, min, force)
  local h, m = calc_time()
  if force or not m or math.abs(calc_diff(h, m, hr, min)) >= 20 then
    watch_hour = hr
    watch_minute = min
    first_tick = os.clock()
    main.info("clock")
  end
end

function tick()
  if not watch_minute or not first_tick then
    return
  end

  main.info("clock")
end

function get_clock()
  local h, m = calc_time()
  if not h or not m then
    return "Unknown"
  end

  return string.format("%02d:%02d", h, m)
end

function get_date()
  if day == 0 then
    return "Unknown"
  end

  return string.format("%d %s %d", day, month, year)
end

function get_tod()
  if not watch_hour then
    return "Unknown"
  elseif is_night() then
    return "Nighttime"
  else
    return "Daytime"
  end
end

function date(d, m, y)
  day = d
  month = m
  year = y

  main.info("date")
end

function time(tod)
  local was_night = is_night()
  local new_hour
  local new_minute = 0
  local s2n = {
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve"
  }

  if string.find(tod, "midnight") then
    new_hour = 0
  elseif string.find(tod, "noon") and not string.find(tod, "afternoon") then
    new_hour = 12
  else
    for n,s in ipairs(s2n) do
      if string.find(tod, s) then
        new_hour = n + 12
      end
    end
  end
  if string.find(tod, "morning") then
    new_hour = new_hour - 12
  end
  if string.find(tod, "half past") then
    new_minute = 30
  end

  set_watch(new_hour, new_minute)

  if was_night ~= true and is_night() then
    display.Info("Nighttime")
  elseif was_night ~= false and not is_night() then
    display.Info("Daytime")
  end
end

function is_night()
  local h, m = calc_time()
  if not h then
    return nil
  end

  return h <= 5 or h >= 19
end

function is_day()
  if not watch_hour then
    return nil
  end

  return not is_night()
end

function month_diff(m1, m2)
  if not months[m1] then
    display.Error("Invalid month name passed to month_diff - " .. tostring(m1))
    return
  elseif not months[m2] then
    display.Error("Invalid month name passed to month_diff - " .. tostring(m2))
    return
  end

  local n1 = months[m1]
  local n2 = months[m2]

  local diff = math.abs(n1 - n2)
  if diff > 6 then
    return 12 - diff
  end

  return diff
end
