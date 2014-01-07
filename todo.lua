module (..., package.seeall)

local php = require "php"

local q = {}
fn = {}


function reset()
  q = {}
end

function count(name)
  if name then
    if not q[name] then
      return 0
    end
    return #q[name]
  end
  local c = 0
  for _,n in pairs(q) do
    c = c + #n
  end
  return c
end

function add(action, name, nodupe)
  if not action then
    display.Error("Attempted to queue a blank action.")
    return 0
  end

  if not name or type(name) ~= "string" then
    display.Error("Need to specify a todo queue for every action.")
    return 0
  end

  if type(action) == "table" then
    local i = 0
    for _,a in pairs(action) do
      i = i + add(a, name, nodupe)
    end
    return i
  end

  if nodupe then
    for _,a in pairs(q[name] or {}) do
      if a == action then
        display.Debug("Skipped '" .. tostring(action) .. "' adding to the '" .. tostring(name) .. "' queue", "todo")
        return 0
      end
    end
  end

  display.Debug("Put '" .. tostring(action) .. "' on the '" .. tostring(name) .. "' queue", "todo")

  q[name] = q[name] or {}
  table.insert(q[name], action)

  return 1
end

function del(action, first)
  if not action then
    display.Error("Attempted to delete a blank action.")
    return 0
  end

  if type(action) == "table" then
    local i = 0
    for _,a in pairs(action) do
      i = i + del(a, first)
      if first and i > 0 then
        return i
      end
    end
    return i
  end

  local j = 0
  for _,n in pairs(q) do
    for k = #n,1,-1 do
      if n[k] == action then
        table.remove(n, k)
        j = j + 1
        if first then
          return j
        end
      end
    end
  end

  return j
end

function del_match(action, first)
  if not action then
    display.Error("Attempted to delete a blank action.")
    return 0
  end

  if type(action) == "table" then
    local i = 0
    for _,a in pairs(action) do
      i = i + del_match(a, first)
      if first and i > 0 then
        return i
      end
    end
    return i
  end

  local j = 0
  for _,n in pairs(q) do
    for k = #n,1,-1 do
      if string.find(n[k], action) then
        table.remove(n, k)
        j = j + 1
        if first then
          return j
        end
      end
    end
  end

  return j
end

function exec(name)
  if not fn[name] then
    display.Error("Invalid todo queue name: " .. tostring(name))
    return false
  end

  return fn[name]()
end


function fn.free()
  if not able.to("todo", "free") or not q.free then
    return false
  end

  for _,a in ipairs(q.free) do
    Execute(a)
  end
  q.free = nil
  return true
end

function fn.bal()
  if not able.to("todo", "bal") or not q.bal then
    return false
  end

  local action = table.remove(q.bal, 1)
  if action then
    flags.set("doing", true, 0.5)
    Execute(action)
    return true
  end
  return false
end


function handle_add(name, line, wildcards, styles)
  local qn = wildcards[1]
  if not qn or #qn < 1 then
    qn = "bal"
  end
  add(php.explode("|", wildcards[3]), qn, wildcards[2] == "1")
  flags.clear("scanned_todo")
  scan.process()
end

function handle_del(name, line, wildcards, styles)
  del(php.explode("|", wildcards[2]), wildcards[1] == "1")
end

function handle_reset(name, line, wildcards, styles)
  reset()
  display.Info("Todo queues reset")
end

function handle_exec(name, line, wildcards, styles)
  exec("free")
  exec("bal")
end

function handle_show(name, line, wildcards, styles)
  display.Info("Todo Report:")
  local f = false
  for b,l in pairs(q) do
    f = true
    local i = 0
    display.Prefix()
    ColourNote("skyblue", "", "  Queue - " .. tostring(b) .. " [" .. #l .. "]")
    for _,t in ipairs(l) do
      i = i + 1
      if i > 10 then
        break
      end
      display.Prefix()
      ColourNote("dodgerblue", "", string.format("    %2d", i), "silver", "", "  " .. t)
    end

    if i == 0 then
      display.Prefix()
      ColourNote("dimgray", "", "    Empty")
    end
  end
  if not f then
    display.Prefix()
    ColourNote("dimgray", "", "  Your schedule is clear, for now.")
  end
  if IsConnected() then
    Send("")
  end
end
