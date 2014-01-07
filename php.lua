module (..., package.seeall)

function Table(...)
    local newTable,keys,values={},{},{}
    newTable.pairs=function(self) -- pairs iterator
        local count=0
        return function()
            count=count+1
            return keys[count],values[keys[count]]
        end
    end
    setmetatable(newTable,{
        __newindex=function(self,key,value)
            if not self[key] then table.insert(keys,key)
            elseif value==nil then -- Handle item delete
                local count=1
                while keys[count]~=key do count = count + 1 end
                table.remove(keys,count)
            end
            values[key]=value -- replace/create
        end,
        __index=function(self,key) return values[key] end
    })
    return newTable
end

function explode(div, str)
  if div == "" then
    return false
  end

  local pos = 0
  local arr = {}
  for st,sp in function() return string.find(str, div, pos, true) end do
    table.insert(arr, string.sub(str, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(str, pos))
  return arr
end

function split(str, pat)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

function wrap(line, length)
  local lines = {}
  while #line > length do
    -- find a space not followed by a space, or a , closest to the end of the line
    local col = string.find (line:sub (1, length), "[%s,][^%s,]*$")
    if col and col > 2 then
--      col = col - 1  -- use the space to indent
    else
      col = length  -- just cut off at wrap_column
    end -- if

    table.insert(lines, line:sub (1, col))
    line = line:sub(col + 1)
  end
  table.insert(lines, line)
  return lines
end

function trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

function strjoin(delimiter, list)
  local len = #list
  if len == 0 then 
    return "" 
  end
  local s = list[1]
  for i = 2, len do 
    s = s .. delimiter .. list[i] 
  end
  return s
end

function strproper(s)
  return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
end

function exists(filename)
  local file = io.open(filename)
  if file then
    io.close(file)
    return true
  end
  return false
end

function commas(num)
  assert(type(num) == "number" or type(num) == "string")
  
  local result = ""
  local sign, before, after = string.match (tostring (num), "^([%+%-]?)(%d*)(%.?.*)$")

  while string.len(before) > 3 do
    result = "," .. string.sub(before, -3, -1) .. result
    before = string.sub(before, 1, -4)
  end

  return sign .. before .. result .. after
end
