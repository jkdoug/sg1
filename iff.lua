module (..., package.seeall)

-- TODO: unkeep/unenemy by org name
-- TODO: enemy/ally from scent/scan results

require "main"
local php = require "php"
local http = require "socket.http"

enemies = main.bootstrap("iff_enemies") or {Current = {}}
allies = main.bootstrap("iff_allies") or {Current = {}}
lusted = main.bootstrap("iff_lusted") or {}
keepers = main.bootstrap("iff_keep") or {}

enemies.Current = enemies.Current or {}
allies.Current = allies.Current or {}

local qenemies = {}
local qallies = {}
local qlusted = {}
local memorized = main.bootstrap("iff_memory") or {}
local auto_enemy = false


local function tablify(list)
  local t = php.split(list, " ")
  local u = {}
  for _,v in ipairs(t) do
    local n = php.strproper(v)
    table.insert(u, n)
  end
  table.sort(u)
  return u
end


function is_lusted(name)
  local name = php.strproper(name)
  return lusted[name] == true
end

function is_ally(name)
  local name = php.strproper(name)
  return allies.Current[name] == true or is_lusted(name)
end

function is_enemy(name)
  local name = php.strproper(name)
  return enemies.Current[name] == true
end


function ally(name, list)
  local list = list or "Current"
  local names = tablify(name or "")
  allies[list] = allies[list] or {}
  for _,n in ipairs(names) do
    allies[list][n] = true
    display.Debug("Ally '" .. n .. "' added to '" .. list .. "'", "iff")
  end
  main.archive("iff_allies", allies)
end

function enemy(name, list)
  local list = list or "Current"
  local names = tablify(name or "")
  enemies[list] = enemies[list] or {}
  for _,n in ipairs(names) do
    enemies[list][n] = true
    display.Debug("Enemy '" .. n .. "' added to '" .. list .. "'", "iff")
  end
  main.archive("iff_enemies", enemies)
end

function lust(name)
  if not name then
    if flags.get("iff_target") then
      name = flags.get("iff_target")
      flags.clear("iff_target")
    else
      return
    end
  end

  local name = php.strproper(name)
  if allies.Current[name] then
    unally(name)
  end
  if is_enemy(name) then
    unenemy(name)
  end
  lusted[name] = true
  main.archive("iff_lusted", lusted)
  display.Debug("Lusted to '" .. name .. "'", "iff")
end

function unally(name, list)
  local list = list or "Current"
  if name then
    local names = tablify(name)
    allies[list] = allies[list] or {}
    for _,n in ipairs(names) do
      allies[list][n] = nil
      display.Debug("Ally '" .. n .. "' cleared from '" .. list .. "'", "iff")
    end
    for _ in pairs(allies[list]) do
      main.archive("iff_allies", allies)
      return
    end
  end

  if list == "Current" then
    allies[list] = {}
  else
    allies[list] = nil
  end
  main.archive("iff_allies", allies)
  display.Debug("Allies '" .. list .. "' cleared", "iff")
end

function unenemy(name, list)
  local list = list or "Current"
  if name then
    local names = tablify(name)
    enemies[list] = enemies[list] or {}
    for _,n in ipairs(names) do
      enemies[list][n] = nil
      display.Debug("Enemy '" .. n .. "' cleared from '" .. list .. "'", "iff")
    end
    for _ in pairs(enemies[list]) do
      main.archive("iff_enemies", enemies)
      return
    end
  end

  if list == "Current" then
    enemies[list] = {}
  else
    enemies[list] = nil
  end
  main.archive("iff_enemies", enemies)
  display.Debug("Enemies '" .. list .. "' cleared", "iff")
end

function unlust(name)
  if not name then
    if flags.get("iff_target") then
      name = flags.get("iff_target")
      flags.clear("iff_target")
    end
  end

  if name then
    local name = php.strproper(name)
    lusted[name] = nil
    display.Debug("Unlusted '" .. name .. "'", "iff")
    flags.clear("reject_try")
    if keepers[name] and able.to("enemy") then
      Execute("enemy " .. name)
    end
  else
    lusted = {}
    display.Debug("Lust list cleared", "iff")
  end
  main.archive("iff_lusted", lusted)
end

function reenemy()
  local en = {}
  for n in pairs(keepers) do
    if not is_ally(n) and not is_lusted(n) and not is_enemy(n) then
      table.insert(en, n)
    end
  end
  if #en > 0 then
    Execute("enemy " .. table.concat(en, " "))
  end
end


function declare_ally(name, line, wildcards, styles)
  local names = wildcards[1]
  local tn = php.split(names, " ")
  flags.set("ally_try", names, 2)
  for _,n in ipairs(tn) do
    if is_enemy(n) then
      Execute("unenemy " .. n)
    end
    Send("ally " .. n)
  end
end

function declare_enemy(name, line, wildcards, styles)
  local names = wildcards[1]
  local tn = php.split(names, " ")
  for _,n in ipairs(tn) do
    if is_lusted(n) then
      display.Alert(php.strproper(n) .. " is lusted!")
    elseif is_ally(n) then
      Execute("unally " .. n)
    end
  end
  flags.set("enemy_try", names, 2)
  Send("enemy " .. names)
end

function declare_unally(name, line, wildcards, styles)
  local names = wildcards[1]
  local tn = php.split(names, " ")
  for _,n in ipairs(tn) do
    if n == "all" or (is_ally(n) and not is_lusted(n)) then
      if not flags.get("unally_try") then
        flags.set("unally_try", names, 2)
      end
      Send("unally " .. n)
    end
  end
end

function declare_unenemy(name, line, wildcards, styles)
  local names = wildcards[1]
  local tn = php.split(names, " ")
  for _,n in ipairs(tn) do
    if n == "all" or is_enemy(n) then
      if not flags.get("unenemy_try") then
        flags.set("unenemy_try", names, 2)
      end
      Send("unenemy " .. n)
    end
  end
end

local function reject(name)
  if flags.get("reject_try") or not able.generic_spell() then
    Execute("do1 reject " .. name)
  else
    flags.set("reject_try", name, 2)
    Send("reject " .. name)
  end
end


function remember(name)
  local name = name or "default"
  memorized[name] = {
    allies = copytable.shallow(allies.Current or {}),
    enemies = copytable.shallow(enemies.Current or {}),
    keepers = copytable.shallow(keepers or {}),
  }
  main.archive("iff_memory", memorized)
end

function forget(name)
  local name = name or "default"
  memorized[name] = nil
  main.archive("iff_memory", memorized)
end

function restore(name)
  local name = name or "default"
  if not memorized[name] then
    return
  end
  local allies_prev = copytable.shallow(allies.Current or {})

  allies.Current = copytable.shallow(memorized[name].allies)
  enemies.Current = copytable.shallow(memorized[name].enemies)
  keepers = copytable.shallow(memorized[name].keepers)
  main.archive("iff_keep", keepers)

  Execute("unenemy all")
  local nn = {}
  for n in pairs(enemies.Current) do
    table.insert(nn, n)
  end
  if #nn > 0 then
    auto_enemy = main.auto("enemy")
    if auto_enemy then
      main.auto("enemy", false)
    end
    Execute("enemy " .. table.concat(nn, " "))
  end

  nn = {}
  for n in pairs(allies.Current) do
    if not allies_prev[n] then
      table.insert(nn, n)
    end
  end
  if #nn > 0 then
    Execute("ally " .. table.concat(nn, " "))
  end
end


function list_enemies()
  unenemy()
  for _,e in ipairs(qenemies) do
    enemy(e)
  end
  qenemies = {}
  if main.auto("enemy") then
    reenemy()
  end
end

function list_allies()
  unally()
  for _,a in ipairs(qallies) do
    ally(a)
  end
  qallies = {}

  unlust()
  for _,l in ipairs(qlusted) do
    lust(l)
  end
  qlusted = {}
end


function handle_ae(name, line, wildcards, styles)
  local person = wildcards[1]
  if wildcards[2] == "enemies" and flags.get("enemy_try") then
    enemy(person)
    if auto_enemy then
      prompt.queue(function () main.auto("enemy", true) end, "autoen")
      auto_enemy = false
    end
  elseif wildcards[2] == "allies" and flags.get("ally_try") then
    ally(person)
  end
end

function handle_uae(name, line, wildcards, styles)
  local person = wildcards[1]
  if wildcards[2] == "enemies" and flags.get("unenemy_try") then
    unenemy(person)
    if main.auto("enemy") and keepers[person] and able.to("enemy") then
      Execute("enemy " .. person)
    end
  elseif wildcards[2] == "allies" and flags.get("unally_try") then
    unally(person)
  end
end

function handle_lust(name, line, wildcards, styles)
  flags.set("iff_target", wildcards[1], 1)
  prompt.illqueue(function () iff.lust() end, "iff_lust")
end

function handle_rejection(name, line, wildcards, styles)
  if flags.get("reject_try") then
    flags.set("iff_target", wildcards[1], 1)
    prompt.illqueue(function () iff.unlust() end, "iff_reject")
  end
end

function handle_list(name, line, wildcards, styles)
  if wildcards[1] == "enemies" then
    qenemies = {}
    prompt.illqueue(function () iff.list_enemies() end, "iff_enemies")
    EnableTrigger("iff_enemy_line__", true)
    prompt.queue(function ()
      EnableTrigger("iff_enemy_line__", false)
    end)
  else
    qallies = {}
    qlusted = {}
    prompt.illqueue(function () iff.list_allies() end, "iff_allies")
    EnableTrigger("iff_ally_line__", true)
    EnableTrigger("iff_lust_line__", true)
    prompt.queue(function ()
      EnableTrigger("iff_ally_line__", false)
      EnableTrigger("iff_lust_line__", false)
    end)
  end
end

function handle_ally(name, line, wildcards, styles)
  table.insert(qallies, wildcards[1])
end

function handle_lusted(name, line, wildcards, styles)
  table.insert(qlusted, wildcards[1])
end

function handle_enemy(name, line, wildcards, styles)
  table.insert(qenemies, wildcards[1])
end

function handle_reject(name, line, wildcards, styles)
  local tn = php.split(string.lower(wildcards[1] or ""), " ")
  for _,n in ipairs(tn) do
    if n == "rogues" or n == "all" or names.is_valid_org(n) then
      local o = php.strproper(n)
      for l in pairs(lusted) do
        if n == "all" then
          reject(l)
        elseif n == "rogues" then
          if names.member_of(l) == "" then
            reject(l)
          end
        elseif names.is_member(l, o) then
          reject(l)
        end
      end
    else
      reject(n)
    end
  end
end

function handle_unally_all(name, line, wildcards, styles)
  flags.clear("unally_try")
  unally()
end

function handle_unenemy_all(name, line, wildcards, styles)
  flags.clear("unenemy_try")
  unenemy()
  if main.auto("enemy") and able.to("enemy") then
    reenemy()
  end
end

function handle_keep(name, line, wildcards, styles)
  local kn = tablify(wildcards[1])
  for _,nn in ipairs(kn) do
    keepers[nn] = true
  end
  display.Info("Added to enemies to keep: " .. table.concat(kn, ", "))
  main.archive("iff_keep", keepers)
  if IsConnected() then
    Send("")
  end
end

function handle_unkeep(name, line, wildcards, styles)
  if not wildcards[1] or #wildcards[1] < 1 then
    keepers = {}
    display.Info("Cleared out list of enemies to keep")
  else
    local kn = tablify(wildcards[1])
    for _,nn in ipairs(kn) do
      keepers[nn] = nil
    end
    display.Info("Removed from enemies to keep: " .. table.concat(kn, ", "))
  end
  main.archive("iff_keep", keepers)
  if IsConnected() then
    Send("")
  end
end


function show_keep()
  local limit = tonumber(GetVariable("sg1_option_maxenemies") or "30")
  local kn = {}
  for n in pairs(keepers) do
    table.insert(kn, n)
  end

  display.Info("Keep Enemied:")
  if #kn > limit then
    display.Warning("  You're over your limit of " .. limit .. " enemies.")
  elseif #kn < 1 then
    display.Prefix()
    ColourNote("dimgray", "", "  No lasting enemies on record, sir.")

    if IsConnected() then
      Send("")
    end
    return
  end

  table.sort(kn)
  local nn = php.wrap(table.concat(kn, ", "), 90)
  for _,n in ipairs(nn) do
    display.Prefix()
    ColourNote("silver", "", "  " .. n)
  end

  if IsConnected() then
    Send("")
  end
end

function show_allies()
  -- TODO: allow groups again?
  local list = "Current"

  if not list then
    display.Error("No such list of allies: " .. list)
    return
  end

  allies[list] = allies[list] or {}
  local en = {}
  for n in pairs(allies[list]) do
    table.insert(en, n)
  end

  display.Prefix()
  ColourTell("lightgreen", "", "Allies")
  --ColourTell("tan", "", " [" .. tostring(list) .. "]")
  ColourNote("dimgray", "", " (" .. #en .. ")")

  if #en > 0 then
    table.sort(en)
    en = php.wrap(table.concat(en, ", "), 100)
    for _,line in ipairs(en) do
      display.Prefix()
      ColourNote("silver", "", "  " .. php.trim(line))
    end
  else
    display.Prefix()
    ColourNote("dimgray", "", "  You don't love anyone.")
  end

  if IsConnected() then
    Send("")
  end
end

function show_enemies()
  -- TODO: allow groups again?
  local list = "Current"

  if not list then
    display.Error("No such list of enemies: " .. list)
    return
  end

  enemies[list] = enemies[list] or {}
  local en = {}
  for n in pairs(enemies[list]) do
    table.insert(en, n)
  end

  display.Prefix()
  ColourTell("crimson", "", "Enemies")
  --ColourTell("tan", "", " [" .. tostring(list) .. "]")
  ColourNote("dimgray", "", " (" .. #en .. ")")

  if #en > 0 then
    table.sort(en)
    en = php.wrap(table.concat(en, ", "), 100)
    for _,line in ipairs(en) do
      display.Prefix()
      ColourNote("silver", "", "  " .. php.trim(line))
    end
  else
    display.Prefix()
    ColourNote("dimgray", "", "  You don't hate anyone.")
  end

  if IsConnected() then
    Send("")
  end
end

function show_lusted()
  lusted = lusted or {}
  local en = {}
  for n in pairs(lusted) do
    table.insert(en, n)
  end

  display.Prefix()
  ColourNote("mediumvioletred", "", "Lusted", "dimgray", "", " (" .. #en .. ")")

  if #en > 0 then
    table.sort(en)
    en = php.wrap(table.concat(en, ", "), 100)
    for _,line in ipairs(en) do
      display.Prefix()
      ColourNote("silver", "", "  " .. php.trim(line))
    end
  else
    display.Prefix()
    ColourNote("dimgray", "", "  No one loves you.")
  end

  if IsConnected() then
    Send("")
  end
end

function get_info(name, line, wildcards, styles)
  local person = wildcards[1]
  local a = http.request("http://www.ironrealms.com/game/honors/Lusternia/" .. person)
  if not a then
    return
  end
   
  local person = string.match(a, "Name: (%a+)")
  if not person then
    return
  end
  local guild = string.match(a, "Guild: ([%a%']+)") or "no guild"
  local city = string.match(a, "City: (%a+)") or "exile"

  display.Info(person .. " is a member of " .. guild .. ", living in " .. city .. ".")

  local mo = php.strproper(names.member_of(person))
  if city ~= "exile" then
    if city ~= mo then
      names.add(person, city)
    end
  elseif mo ~= "" then
    names.del(person, mo)
  end

  if IsConnected() then
    Send("")
  end
end
