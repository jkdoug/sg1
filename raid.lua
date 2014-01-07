module (..., package.seeall)

local leader = GetVariable("sg1_raid_leader")
if leader == "none" then
  leader = nil
end
local aether = GetVariable("sg1_raid_aether")
if aether == "none" then
  aether = nil
end

local specs_enter = {}
local specs_exit = {}
local meld_enter = {}
local meld_exit = {}

local cov_leader = ""
local cov_members = {}
local cov_present = {}
local cov_circle = {}

function announce(msg)
  if aether and able.to("speak") then
    Execute(aether .. " " .. msg)
  end
end


function coven_circle()
  return cov_circle
end

function coven_members()
  return cov_members
end

function coven_present()
  return cov_present
end

function coven_leader(name)
  if name then
    cov_leader = name
    if #name > 0 then
      coven_join(cov_leader)
    else
      coven_dissolve()
    end
  end

  return cov_leader
end

function is_coven_member(name)
  if not name then
    display.Error('Specify a real name for your coven members.')
    return
  end

  for _,n in ipairs(cov_members) do
    if name == n then
      return true
    end
  end

  return false
end

function is_coven_circled()
  return #cov_circle > 0
end


function coven_gone(name)
  for i,n in ipairs(cov_present) do
    if name == n then
      table.remove(cov_present, i)
      display.Info(name .. " walked away from the coven")
      break
    end
  end

  for i,n in ipairs(cov_circle) do
    if name == n then
      table.remove(cov_circle, i)
      break
    end
  end
end

function coven_returned(name)
  for i,n in ipairs(cov_present) do
    if name == n then
      return
    end
  end

  display.Info(name .. " returned to the coven")
  table.insert(cov_present, name)
  table.sort(cov_present)
end

function coven_join(name, circled)
  if not name then
    return
  end

  if not is_coven_member(name) then
    table.insert(cov_members, name)
    table.insert(cov_present, name)

    table.sort(cov_members)
    table.sort(cov_present)
  end

  if circled then
    table.insert(cov_circle, name)
    table.sort(cov_circle)
  end
end

function coven_leave(name)
  if not name then
    return
  end

  local removed = false
  for i,n in ipairs(cov_members) do
    if string.lower(name) == string.lower(n) then
      table.remove(cov_members, i)
      removed = true
      break
    end
  end

  for i,n in ipairs(cov_present) do
    if string.lower(name) == string.lower(n) then
      table.remove(cov_present, i)
      break
    end
  end

  for i,n in ipairs(cov_circle) do
    if string.lower(name) == string.lower(n) then
      table.remove(cov_circle, i)
      break
    end
  end

  if removed then
    display.Info(name .. " left the coven")
  end
end

function coven_dissolve()
  cov_leader = ""
  cov_members = {}
  cov_present = {}
  cov_circle = {}
end

function coven_sync()
  cov_circle = {}
  if affs.slow() or not able.generic() then
    return
  end
  EnableTrigger("coven_not_sync__", true)
  EnableTrigger("coven_members_sync__", true)
  SendNoEcho("mooncoven members")
end


-- TODO: re-sync coven when moving?

function handle_coven_sync(name, line, wildcards, styles)
  coven_sync()
end

function handle_coven_members_sync(name, line, wildcards, styles)
  coven_dissolve()
  coven_leader(wildcards[1])
  EnableTrigger("coven_members_sync_name__", true)
  EnableTrigger("coven_members_sync_total__", true)
  prompt.queue(function ()
    EnableTrigger("coven_not_sync__", false)
    EnableTrigger("coven_members_sync__", false)
    EnableTrigger("coven_members_sync_name__", false)
    EnableTrigger("coven_members_sync_total__", false)
  end, "covsync")
  prompt.gag = true
end

function handle_coven_members_sync_name(name, line, wildcards, styles)
  coven_join(wildcards[1], #wildcards[2] > 0)
end

function handle_coven_none(name, line, wildcards, styles)
  coven_dissolve()
  prompt.queue(function ()
    EnableTrigger("coven_not_sync__", false)
    EnableTrigger("coven_members_sync1__", false)
    EnableTrigger("coven_members_sync2__", false)
    EnableTrigger("coven_members_sync3__", false)
  end, "covsync")
  prompt.gag = true
end

function handle_coven_members(name, line, wildcards, styles)
  coven_dissolve()
  coven_leader(wildcards[1])
  EnableTrigger("coven_members_list__", true)
  prompt.queue(function () EnableTrigger("coven_members_list__", false) end)
end

function handle_coven_members_list(name, line, wildcards, styles)
  coven_join(wildcards[1], #wildcards[2] > 0)
end

function handle_coven_join(name, line, wildcards, styles)
  coven_join(wildcards[1])
end

function handle_coven_leave(name, line, wildcards, styles)
  coven_leave(wildcards[1])
end

function handle_coven_leader(name, line, wildcards, styles)
  coven_leader(wildcards[1])
  coven_sync()
end

function handle_coven_dissolve(name, line, wildcards, styles)
  coven_dissolve()
end

function show_coven()
  display.Info("Coven Status Report:")

  if coven_leader() == "" then
    display.Prefix()
    ColourNote("dimgray", "", "  You feel somewhat unpopular.")
  else
    display.Prefix()
    ColourNote("silver", "", "  Leader:     ", "darkcyan", "", coven_leader())

    display.Prefix()
    ColourNote("silver", "", "  Members:    ", "darkcyan", "", table.concat(coven_members(), ", "))

    display.Prefix()
    ColourNote("silver", "", "  Present:    ", "darkcyan", "", table.concat(coven_present(), ", "))

    display.Prefix()
    ColourNote("silver", "", "  In Circle:  ", "darkcyan", "", table.concat(coven_circle(), ", "))
  end

  if IsConnected() then
    Send("")
  end
end


function show_entering()
  local ns = ""
  local vs = ""
  local people = specs_enter
  local is_meld = false
  if #meld_enter > 0 then
    people = meld_enter
    is_meld = true
  end

  meld_enter = {}
  specs_enter = {}

  if #people < 1 then
    return
  elseif #people == 1 then
    ns = people[1]
    vs = " has"
  else
    ns = table.concat(people, ", ", 1, #people - 1) .. " and " .. people[#people]
    vs = " have"
  end

  if is_meld then
    announce(ns .. vs .. " entered my demesne") -- TODO: track meld area?
  else
    announce(ns .. vs .. " entered " .. map.get_area_name())
  end
end

function show_exiting()
  local ns = ""
  local vs = ""
  local people = specs_exit
  local is_meld = false
  if #meld_exit > 0 then
    people = meld_exit
    is_meld = true
  end

  meld_exit = {}
  specs_exit = {}

  if #people < 1 then
    return
  elseif #people == 1 then
    ns = people[1]
    vs = " has"
  else
    ns = table.concat(people, ", ", 1, #people - 1) .. " and " .. people[#people]
    vs = " have"
  end

  if is_meld then
    announce(ns .. vs .. " left my demesne") -- TODO: track meld area?
  else
    announce(ns .. vs .. " left " .. map.get_area_name())
  end
end

function handle_entering(name, line, wildcards, styles)
  local p = wildcards[1]
  if not names.is_in_enemy_org(p) then
    return
  end
  specs_enter = specs_enter or {}
  meld_enter = meld_enter or {}
  if string.find(line, "demesne") then
    table.insert(meld_enter, p)
  else
    table.insert(specs_enter, p)
  end
  prompt.queue(function () raid.show_entering() end, "raid_enters")
end

function handle_exiting(name, line, wildcards, styles)
  local p = wildcards[1]
  if not names.is_in_enemy_org(p) then
    return
  end
  specs_exit = specs_exit or {}
  meld_exit = meld_exit or {}
  if string.find(line, "demesne") then
    table.insert(meld_exit, p)
  else
    table.insert(specs_exit, p)
  end
  prompt.queue(function () raid.show_exiting() end, "raid_exits")
end


function handle_choking_friend(name, line, wildcards, styles)
  for i=1,3 do
    display.Prefix()
    ColourNote("black", "mediumpurple", wildcards[1] .. " CHOKING " .. wildcards[2] .. "! Target with CCC!")
  end
  announce(wildcards[1] .. " is choking " .. wildcards[2] .. "! Target " .. string.upper(wildcards[1]))
  enemy.rebound(wildcards[1], false)
  SetVariable("target_choker", wildcards[1])
end

function handle_ally_sapped(name, line, wildcards, styles)
  local p = wildcards[1]
  display.Alert(p .. " is Sapped!")
  if names.is_in_ally_org(p) then
    display.Alert("CLL to Cleanse!")
    SetVariable("target_cleanse", p)
  end
end


function handle_trap_bell(name, line, wildcards, styles)
  prompt.illqueue(function () raid.announce("Trap set off at " .. wildcards[1]) end, "trapalarm")
end


function alias_status(name, line, wildcards, styles)
  display.Info("Raid Group Status:")

  display.Prefix()
  ColourTell("silver", "", "  Leader:  ")
  if not leader then
    ColourNote("dimgray", "", "nobody")
  elseif leader == "me" then
    ColourNote("orangered", "", "YOU")
  else
    ColourNote("darkcyan", "", leader)
  end

  display.Prefix()
  ColourTell("silver", "", "  Aether:  ")
  if not aether then
    ColourNote("dimgray", "", "none")
  else
    ColourNote("darkcyan", "", aether)
  end

  display.Prefix()
  ColourTell("silver", "", "  Watcher: ")
  if GetVariable("sg1_watcher") == "1" then
    ColourNote("lime", "", "ON")
  else
    ColourNote("dimgray", "", "OFF")
  end

  display.Prefix()
  ColourTell("silver", "", "  Enemies: ")
  local names = {}
  for n in pairs(iff.keepers) do
    table.insert(names, n)
  end
  if #names > 0 then
    table.sort(names)
    local nn = php.wrap(table.concat(names, ", "), 70)
    for i,n in ipairs(nn) do
      if i > 1 then
        display.Prefix()
        Tell("           ")
      end
      ColourNote("darkcyan", "", n)
    end
  else
    ColourNote("dimgray", "", "none")
  end

  if IsConnected() then
    Send("")
  end
end

function alias_aether(name, line, wildcards, styles)
  local cmd = string.lower(wildcards[1])
  if cmd == "none" then
    aether = nil
    DeleteVariable("sg1_raid_aether")
    display.Info("Raid announcements disabled.")
  else
    aether = cmd
    SetVariable("sg1_raid_aether", aether)
    display.Info("Announcing raid orders to '" .. aether .. "' now. RAIDANNOUNCE NONE to stop.")
  end
  if IsConnected() then
    Send("")
  end
end

function alias_enemies()
  local names = ""
  for n in pairs(iff.keepers) do
    --if not iff.is_lusted(n) then
      names = names .. " " .. n
    --end
  end
  if #names > 0 then
    if leader == "me" then
      announce("Enemy this list:" .. names)
      return
    else
      display.Info("You are not the raid leader.")
    end
  else
    display.Info("You have no 'keep' enemies list.")
  end

  if IsConnected() then
    Send("")
  end
end

function alias_leader(name, line, wildcards, styles)
  local p = string.lower(wildcards[1])
  if p == "none" then
    leader = nil
    DeleteVariable("sg1_raid_leader")
    display.Info("Raid leader officially redacted.")
  elseif p == "me" then
    leader = "me"
    SetVariable("sg1_raid_leader", p)
    display.Info("You are now raid leader!")
    announce("I am leading.")
  else
    leader = php.strproper(p)
    display.Info(leader .. " is the raid leader now. RAIDLEADER NONE to clear.")
    SetVariable("sg1_raid_leader", leader)
  end

  if IsConnected() then
    Send("")
  end
end

function alias_target(name, line, wildcards, styles)
  local p = wildcards[1]
  Execute("t " .. p)
  if leader == "me" then
    announce("Target: " .. string.upper(p))
  else
    announce("Targeting: " .. string.upper(p))
  end
end

function alias_watch(name, line, wildcards, styles)
  local on = string.lower(wildcards[1]) == "on"
  EnableTrigger("watcher_enter__", on)
  EnableTrigger("watcher_exit__", on)
  if on then
    display.Info("Watching area traffic.")
    SetVariable("sg1_watcher", 1)
  else
    display.Info("No longer watching area traffic.")
    DeleteVariable("sg1_watcher")
  end

  if IsConnected() then
    Send("")
  end
end


if GetVariable("sg1_watcher") == "1" then
  EnableTrigger("watcher_enter__", true)
  EnableTrigger("watcher_exit__", true)
end
