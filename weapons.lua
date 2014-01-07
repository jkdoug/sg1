module (..., package.seeall)

require "main"

poisons = main.bootstrap("weapon_poisons") or {}

function wp_start(name, line, wildcards, styles)
  flags.set("weaponprobe", wildcards[1])
  poisons[wildcards[1]] = {}
  EnableTrigger("weaponprobe_poison__", true)
  prompt.queue(function () EnableTrigger("weaponprobe_poison__", false) end, "wpdone")
  prompt.queue(function () main.archive("weapon_poisons", weapons.poisons) end, "wppois")
end

function wp_poison(name, line, wildcards, styles)
  local weap = flags.get("weaponprobe")
  if not weap then
    return
  end

  poisons[weap] = poisons[weap] or {}
  table.insert(poisons[weap], wildcards[1], wildcards[2])
end

function wiped(name, line, wildcards, styles)
  local weap = wildcards[1]
  poisons[weap] = {}
  main.archive("weapon_poisons", poisons)
end

function envenomed(name, line, wildcards, styles)
  local ven = wildcards[1]
  local weap = wildcards[2]
  poisons[weap] = poisons[weap] or {}
  table.insert(poisons[weap], 1, ven)
  main.archive("weapon_poisons", poisons)
end

function keeneye(name, line, wildcards, styles)
  local pois = wildcards[1]
  local weap = wildcards[2]
  poisons[weap] = poisons[weap] or {}
  if #poisons[weap] < 1 then
    -- No knowledge of poisons on this weapon
    return
  end
  table.remove(poisons[weap], 1)
  main.archive("weapon_poisons", poisons)

  local success = not string.find(wildcards[3], "failed")
  if success then
    display.enemy_alert("Poisoned with " .. string.upper(pois))
  else
    ColourNote("silver", "", "With your keen eye, you notice that " .. pois .. " has been delivered from " .. weap .. ".")
  end
end


function next_poison(weap)
  local p = poisons[weap] or {}
  return p[1] or "none"
end
