module (..., package.seeall)

weapon_left = {id = 15653, name = "Thunderhart, a flail sparking with eldritch energies"}
weapon_right = {id = 1538, name = "Phlogiston, a flail surrounded by an arcane inferno"}
reserve_power = 5

function razing(targ, att)
  if not main.auto("raze") then
    return false
  end
  local aflag = false
  local sflag = false
  local raze = false
  if enemy.has_aura(targ) ~= false and
     not (string.find(att, "crush") or string.find(att, "staydown")) and
     not flags.get(targ .. "_razed_aura") then
    raze = true
    aflag = true
  end
  if enemy.is_shielded(targ) and
     not flags.get(targ .. "_razed_shield") then
    raze = true
    sflag = true
  end
  if aflag then
    flags.set(targ .. "_razed_aura", true, 0.5)
  elseif sflag then
    flags.set(targ .. "_razed_shield", true, 0.5)
  end
  return raze
end

function envenom(v)
  local pois = GetVariable("sg1_envenom")
  if pois then
    pois = json.decode(pois)
    v = {v[1] and pois[1], v[2] and (pois[2] or pois[1])}
  end

  if v[1] then
    local p = weapons.poisons[weapon_right.name]
    if p and p[1] ~= v[1] then
      if #p > 40 then
        Execute("wipe " .. weapon_right.id)
      end
      Execute("envenom " .. weapon_right.id .. " with " .. v[1])
    end
  end
  if v[2] then
    local p = weapons.poisons[weapon_left.name]
    if p and p[1] ~= v[2] then
      if #p > 40 then
        Execute("wipe " .. weapon_left.id)
      end
      Execute("envenom " .. weapon_left.id .. " with " .. v[2])
    end
  end
end

function attack_head(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "crush " .. targ .. " head"
  local pow = prompt.stat("power")
  if pow < 2 + reserve_power or
     enemy.is_prone(targ) or
     affs.has("power_spikes") then
    attack = "strike " .. targ .. " head"
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if main.auto("battack") and not enemy.is_shielded(targ) then
      if able.to("beast order spit poison") and beast.get("poison") == "mantakaya" then
        Execute("beast order spit " .. targ)
      end
    end

    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"chansu", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "senso"}
    end
  end

  Execute(attack)
end

function attack_brainbash(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "maneuver perform bb down " .. targ

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if main.auto("battack") and not enemy.is_shielded(targ) then
      if able.to("beast order spit poison") and beast.get("poison") == "mantakaya" then
        Execute("beast order spit " .. targ)
      end
    end

    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"ibululu", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "dulak"}
    end
  end

  Execute(attack)
end

function attack_chest(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "crush " .. targ .. " chest"
  local pow = prompt.stat("power")
  if pow < 2 + reserve_power or
     enemy.is_prone(targ) or
     affs.has("power_spikes") then
    attack = "strike " .. targ .. " chest"
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if main.auto("battack") and not enemy.is_shielded(targ) then
      if able.to("beast order cast hypnoticgaze") then
        Execute("beast order cast hypnoticgaze " .. targ)
      end
    end

    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"dulak", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "ibululu"}
    end
  end

  Execute(attack)
end

function attack_rleg(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "maneuver perform staydown " .. targ .. " rleg"
  local pow = prompt.stat("power")
  if enemy.is_prone(targ) then
    attack = "maneuver perform kdmang right " .. targ
  elseif pow < 2 + reserve_power or
          affs.has("power_spikes") then
    attack = "maneuver perform getdown " .. targ .. " rleg"
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if main.auto("battack") and not enemy.is_shielded(targ) then
      if able.to("beast order spit poison") and beast.get("poison") == "mantakaya" then
        Execute("beast order spit " .. targ)
      end
    end

    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"calcise", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "calcise"}
    end
  end

  Execute(attack)
end

function attack_lleg(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "maneuver perform staydown " .. targ .. " lleg"
  local pow = prompt.stat("power")
  if enemy.is_prone(targ) then
    attack = "maneuver perform kdmang left " .. targ
  elseif pow < 2 + reserve_power or
          affs.has("power_spikes") then
    attack = "maneuver perform getdown " .. targ .. " lleg"
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if main.auto("battack") and not enemy.is_shielded(targ) then
      if able.to("beast order spit poison") and beast.get("poison") == "mantakaya" then
        Execute("beast order spit " .. targ)
      end
    end

    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"calcise", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "calcise"}
    end
  end

  Execute(attack)
end

function attack_rarm(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "strike " .. targ .. " rarm"
  if math.random(5) == 3 then
    attack = "pound right " .. targ
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"dendroxin", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "dendroxin"}
    end
  end

  Execute(attack)
end

function attack_larm(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "strike " .. targ .. " larm"
  if math.random(5) == 3 then
    attack = "pound left " .. targ
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"dendroxin", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "dendroxin"}
    end
  end

  Execute(attack)
end

function attack_gut(targ)
  local targ = string.lower(targ or GetVariable("target") or "")
  local attack = "crush " .. targ .. " gut"
  local pow = prompt.stat("power")
  if pow < 2 + reserve_power or
     enemy.is_prone(targ) or
     affs.has("power_spikes") then
    attack = "strike " .. targ .. " gut"
  end

  local rt = razing(targ, attack)
  if rt then
    attack = "raze " .. targ
  elseif not affs.slow() then
    if bals.get("rarm") then
      bals.lose("rarm")
      envenom{"botulinum", false}
    elseif bals.get("larm") then
      bals.lose("larm")
      envenom{false, "dulak"}
    end
  end

  Execute(attack)
end


AcceleratorTo("Ctrl+Alt+Numpad1", "bonecrusher.attack_lleg()", 12)
AcceleratorTo("Ctrl+Alt+Numpad2", "bonecrusher.attack_gut()", 12)
AcceleratorTo("Ctrl+Alt+Numpad3", "bonecrusher.attack_rleg()", 12)
AcceleratorTo("Ctrl+Alt+Numpad4", "bonecrusher.attack_larm()", 12)
AcceleratorTo("Ctrl+Alt+Numpad6", "bonecrusher.attack_rarm()", 12)
AcceleratorTo("Ctrl+Alt+Numpad7", "bonecrusher.attack_chest()", 12)
AcceleratorTo("Ctrl+Alt+Numpad8", "bonecrusher.attack_head()", 12)
AcceleratorTo("Ctrl+Alt+Numpad9", "bonecrusher.attack_brainbash()", 12)
