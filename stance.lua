module (..., package.seeall)

local function most_wounded()
  if map.elevation() == "pit" then
    return "upper"
  end

  local total_wounds = wounds.total()
  if total_wounds < 1 then
    return GetVariable("sg1_stance") or "legs"
  end

  local pct = {
    lleg = wounds.get("leftleg") * 100.0 / total_wounds,
    rleg = wounds.get("rightleg") * 100.0 / total_wounds,
    larm = wounds.get("leftarm") * 100.0 / total_wounds,
    rarm = wounds.get("rightarm") * 100.0 / total_wounds,
    head = wounds.get("head") * 100.0 / total_wounds,
    chest = wounds.get("chest") * 100.0 / total_wounds,
    gut = wounds.get("gut") * 100.0 / total_wounds,
  }

  if pct.lleg + pct.rleg > 50 then
    return "legs"
  elseif pct.head > 30 and main.has_ability("combat", "head") then
    return "head"
  elseif pct.gut > 30 and main.has_ability("combat", "gut") then
    return "gut"
  elseif pct.chest > 30 and main.has_ability("combat", "chest") then
    return "chest"
  elseif pct.larm + pct.rarm > 50 and main.has_ability("combat", "arms") then
    return "arms"
  elseif pct.gut + pct.head + pct.chest > 50 and main.has_ability("combat", "vitals") then
    return "vitals"
  elseif pct.lleg + pct.larm > 50 and main.has_ability("combat", "left") then
    return "left"
  elseif pct.rleg + pct.rarm > 50 and main.has_ability("combat", "right") then
    return "right"
  elseif pct.lleg + pct.rleg + pct.gut > 50 and main.has_ability("combat", "lower") then
    return "lower"
  elseif pct.larm + pct.rarm + pct.gut + pct.chest and main.has_ability("combat", "middle") then
    return "middle"
  elseif pct.chest + pct.head + pct.larm + pct.rarm > 50 and main.has_ability("combat", "upper") then
    return "upper"
  end

  return GetVariable("sg1_stance") or "legs"
end

function check()
  local sd = most_wounded()
  if sd ~= defs.has("stance") then
    return sd
  end
  return false
end
