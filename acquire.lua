module (..., package.seeall)

local items = {}

function add(item, nodupe)
  if not main.auto("acquire") then
    return
  end
  if flags.get("arena") then
    return
  end
  if nodupe then
    for _,v in ipairs(items) do
      if v == item then
        return
      end
    end
  end
  table.insert(items, item)
  prompt.queue("dofree1 acquire", "acq")
end

function del(item)
  if not item or #items == 0 then
    return
  end
  for k,v in ipairs(items) do
    if v == item then
      table.remove(items, k)
    end
  end
end

function reset()
  items = {}
  EnableGroup("Acquire", false)
end

function count()
  return #items
end

function get()
  if not main.auto("acquire") then
    reset()
    return
  end
  if #items == 0 then
    return
  end
  for _,v in ipairs(items) do
    Send("g " .. v)
  end
  items = {}
end

function killed(name, line, wildcards, styles)
  flags.set("doing", true, 0.5)
  if string.match(wildcards[1], "^%u%l+$") then
    add("body")
  else
    add(GetVariable("target") or "corpse")
  end
  EnableGroup("Acquire", true)
  prompt.queue(function () EnableGroup("Acquire", false) end, "acquisition")
end

function scooped(name, line, wildcards, styles)
  del(GetVariable("target") or "corpse")
end

function pickup(name, line, wildcards, styles)
  local xlate = {
    sovereign = "gold",
    sovereigns = "gold",
    keys = "key",
    journal = "book",
    tints = "tint",
  }
  local thing = xlate[wildcards[1]] or wildcards[1]
  add(thing, thing == "gold")
end

function distributed(name, line, wildcards, styles)
  del("gold")
end

function avarice(name, line, wildcards, styles)
  del("gold")
end
