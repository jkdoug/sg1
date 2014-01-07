module (..., package.seeall)

local current = {}
local pending = {}
local desired = {}
local xlate = {
  leftarm = "larm",
  leftleg = "lleg",
  rightarm = "rarm",
  rightleg = "rleg",
}


function set(part, amt)
  if amt and amt < 1 then
    amt = nil
  end
  current[part] = amt
  display.Debug("Parry on '" .. part .. "' set to " .. tostring(amt), "defs")
end

function get(part)
  if not part then
    return current
  end
  return current[part] or 0
end

function queue(pcts)
  desired = {}
  for p,w in pairs(pcts) do
    if get(p) ~= w and pending[p] ~= w then
      desired = copytable.shallow(pcts)
      return true
    end
  end
  return false
end

local function most_wounded()
  local wts = {
    leftleg = 1.4,
    rightleg = 1.4,
    head = 1.2,
    gut = 1.1,
    chest = 1.0,
    leftarm = 0.8,
    rightarm = 0.8,
  }
  if map.elevation() == "pit" then
    wts.leftleg = 0
    wts.rightleg = 0
  end
  local parts = {"leftarm", "rightarm", "chest", "gut", "leftleg", "rightleg", "head"}
  local wnds = {}
  local pos = 1
  for _,p in ipairs(parts) do
    local w = wounds.get(p) * wts[p]
    for iw,pw in ipairs(wnds) do
      if w >= pw.weight then
        pos = iw
        break
      end
    end
    table.insert(wnds, pos, {part = xlate[p] or p, weight = w})
  end
  local dw = wnds[1].weight - wnds[2].weight
  if wnds[1].weight > 0 and wnds[2].weight > 0 and dw > 0 and dw < 800 then
    return {[wnds[1].part] = 50, [wnds[2].part] = 50}
  end
  return {[wnds[1].part] = 100}
end

function check()
  local pd = most_wounded()
  return queue(pd)
end


function reset(name, line, wildcards, styles)
  current = {}
  display.Debug("Parry values cleared", "defs")
end

function sync(name, line, wildcards, styles)
  reset()
  EnableTrigger("parry_sync_part__", true)
  prompt.queue(function () EnableGroup("parry_sync_part__", false) end, "parrysync")
end

function sync_part(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  set(part, tonumber(wildcards[2]))
  desired[part] = nil
  pending[part] = nil
end

function track(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  local wt = tonumber(wildcards[2]) or 100
  pending = pending or {}
  pending[part] = wt
  if not flags.get("parry_try") then
    flags.set("parry_try", true, 1)
  else
    ResetTimer("parry_try_flag__")
  end
  Send("parry " .. part .. " " .. wt)
end

function exec(name, line, wildcards, styles)
  for _ in pairs(current) do
    Execute("unparry")
    break
  end
  for p,w in pairs(desired) do
    Execute("parry " .. p .. " " .. w)
  end
end


function changed(name, line, wildcards, styles)
  local part = string.lower(wildcards[1])
  part = part:gsub("left ", "l")
  part = part:gsub("right ", "r")
  set(part, pending[part] or 100)
  desired[part] = nil
  pending[part] = nil
  flags.clear("parry_try")
end
