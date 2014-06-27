module (..., package.seeall)

local php = require "php"
local copytable = require "copytable"

local wound_levels = php.Table()
wound_levels["2500"] = 2500
wound_levels["2000"] = 2000
wound_levels["1500"] = 1500
wound_levels["900"] = 900
wound_levels["300"] = 300
wound_levels["1"] = 1
--wound_levels["critical"] = 3751
--wound_levels["extra_heavy"] = 2484
--wound_levels["heavy"] = 1267
--wound_levels["medium"] = 423
--wound_levels["light"] = 282
--wound_levels["negligible"] = 95
--wound_levels["trifling"] = 1


local weapon_wounds = {
  ["shortsword"] = 100,
  ["club"] = 100,
  ["longsword"] = 200,
  ["broadsword"] = 200,
  ["flail"] = 250,
  ["mace"] = 250,
  ["rapier"] = 300,
  ["hammer"] = 300,
  ["scimitar"] = 400,
  ["morningstar"] = 400,

  ["Canidyne, the Savage Fang"] = 300,
  ["Scryptrx, the Venomous Mother"] = 300,
  ["Siberus"] = 500,
  ["Sobrus"] = 500,
  ["Greed"] = 500,
  ["Hatred"] = 500,
  ["Starblaze"] = 800,
  ["the lightning fang of the dark dragon"] = 900,
  ["the flame fang of the dark dragon"] = 1100,
  ["the sinuous claw of midnight storms"] = 1100,

  ["claymore"] = 700,
  ["bastard sword"] = 700,
  ["waraxe"] = 700,
  ["battleaxe"] = 700,
  ["klangaxe"] = 900,
  ["katana"] = 900,
  ["greataxe"] = 1000,
  ["greatsword"] = 1000,
  ["bardiche"] = 1000,

  ["1538"] = 300,
  ["15653"] = 300,
}
local weapon_hits = {
  ["Starblaze"] = 2,
  ["the lightning fang of the dark dragon"] = 2,
  ["the flame fang of the dark dragon"] = 2,
  ["the sinuous claw of midnight storms"] = 2,

  ["claymore"] = 2,
  ["bastard sword"] = 2,
  ["waraxe"] = 2,
  ["battleaxe"] = 2,
  ["klangaxe"] = 2,
  ["katana"] = 2,
  ["greataxe"] = 2,
  ["greatsword"] = 2,
}

local hits_weapon = {head = {}, chest = {}, gut = {}, leftarm = {}, leftleg = {}, rightarm = {}, rightleg = {}}
local hits_kata = {head = {}, chest = {}, gut = {}, leftarm = {}, leftleg = {}, rightarm = {}, rightleg = {}}

local current = {}
local qamt = {}
local wa = {}
local ka = {}

function check(part)
  if not part then
    for _,p in ipairs{"head", "chest", "gut", "leftarm", "leftleg", "rightarm", "rightleg"} do
      if current[p] and not affs.is_ninshi(p) then
        check(p)
      end
    end
  else
    local name = part
    if string.find(name, "arm") then
      name = "arms"
    elseif string.find(name, "leg") then
      name = "legs"
    end

    for lvl in wound_levels:pairs() do
      affs.del("wounded_" .. name .. "_" .. lvl)
    end

    local amt = 0
    if name == "arms" then
      amt = math.max(get("leftarm"), get("rightarm"))
    elseif name == "legs" then
      amt = math.max(get("leftleg"), get("rightleg"))
    else
      amt = get(part)
    end

    if amt == 0 then
      return
    end

    for lvl,dmg in wound_levels:pairs() do
      if amt >= dmg then
        affs.add("wounded_" .. name .. "_" .. lvl)
        break
      end
    end
  end
end

function set(part, amt)
  if amt <= 0 then
    current[part] = nil
  else
    current[part] = amt
  end

  display.Debug("Wounds for '" .. part .. "' set to " .. tostring(current[part]), "wounds")
  check(part)
end

function get(name)
  if wound_levels[name] then
    return wound_levels[name]
  end

  return current[name] or 0
end

function add(part, amt)
  local amt = amt or 800
  qamt[part] = (current[part] or 0) + amt
  display.Debug("Wounds queued for '" .. part .. "' to add " .. tostring(amt), "wounds")
end

function total()
  local t = 0
  for _,w in pairs(current) do
    t = t + w
  end
  return t
end

function reset()
  hits_weapon = {head = {}, chest = {}, gut = {}, leftarm = {}, leftleg = {}, rightarm = {}, rightleg = {}}
  hits_kata = {head = {}, chest = {}, gut = {}, leftarm = {}, leftleg = {}, rightarm = {}, rightleg = {}}
  current = {}
  qamt = {}
  display.Debug("Wounds cleared", "wounds")
end

function clear_queue()
  qamt = {}
  display.Debug("Wounds queue cleared", "wounds")
end


function sync()
  EnableTrigger("wound_status__", true)
  failsafe.exec("wounds", 5)
  Send("ws")
end

function synced()
  EnableTrigger("wound_status__", false)
  failsafe.disable("wounds")
  EnableGroup("Wounds", true)
  prompt.queue(function () EnableGroup("Wounds", false) end, "woundstatus")
end

function syncup(name, line, wildcards, styles)
  local part = string.lower(string.gsub(wildcards[1], " ", ""))
  local amt = tonumber(wildcards[2])
  set(part, amt)
end

failsafe.fn.wounds = function ()
  EnableTrigger("wound_status__", false)
end


function OnPrompt()
  for p,a in pairs(qamt) do
    set(p, a)
  end
  qamt = {}
end


local function bodyhit(part)
  if flags.get("rebounded") then
    return
  end

  -- TODO: queue for anti-illusion
  local hits = 1
  for k,v in pairs(weapon_hits) do
    if string.find(flags.get("hit_with") or "", k) then
      hits = v
      break
    end
  end

  hits_weapon[part] = hits_weapon[part] or {}
  for h = 1,hits do
    table.insert(hits_weapon[part], os.clock())
  end
  display.Debug("Weapon hits to " .. part .. " now " .. hitcount(part), "wounds")
  EnableTimer("warrior_hits_decrement__", true)

  scan.update = true
end

function hitcount(part)
  local hw = hits_weapon[part] or {}
  return #hw
end

function decrement_hits()
  local hw = copytable.shallow(hits_weapon)
  local ts = os.clock()
  for k,v in pairs(hw) do
    for _,t in ipairs(v) do
      if ts - t >= tonumber(GetVariable("sg1_option_hit_timeout") or "10") then
        table.remove(hits_weapon[k], 1)
        display.Debug("Weapon hits to " .. k .. " now " .. hitcount(k), "wounds")
      else
        break
      end
    end
  end
  for _,v in pairs(hits_weapon) do
    if #v > 0 then
      return
    end
  end
  EnableTimer("warrior_hits_decrement__", false)
  ResetTimer("warrior_hits_decrement__")
end


function attacked(attacker, sk, ab, weapon, dodged, line)
  local stumble = string.find(line, "e stumbles forward as")
  if ab == "rebounded" then
    local ww = gear.find_wielded()
    weapon = ww[1] or ""
    flags.set("rebounded", true)
  elseif not main.attacked(attacker, sk, ab) then
    display.Debug("* Illusion *", "wounds")
    return
  end

  if not dodged and not stumble then
    flags.set("hit_with", weapon)
    main.poisons_on()
  end

  EnableGroup("Wounding", true)
  prompt.queue(function () EnableGroup("Wounding", false) end, "unwound")
  display.Debug("Deep wounds attack: " .. line, "wounds")
  display.Debug("  " .. sk .. "/" .. ab .. " -> " .. weapon, "wounds")
end

local function hitted(part)
  local weapon = flags.get("hit_with")
  if not weapon then
    display.Debug("Ignoring possibly illusioned attack", "wounds")
    return
  end

  if not flags.get("counter_attacked") then
    local amt = 500
    for k,v in pairs(weapon_wounds) do
      if string.find(weapon, k) then
        amt = v
        break
      end
    end

    local mult = flags.get("wound_multiply") or 1.0
    bodyhit(part)
    add(part, amt * mult)
    display.Debug("Deep wounds hit: " .. part .. ", " .. amt .. " (" .. mult .. "x)", "wounds")
  end
  flags.damaged_health()
  return true
end

function hit(name, line, wildcards, styles)
  local part = string.match(name, "^%a-_(%a+)%d+__$")
  if part == "arm" then
    local re = rex.new(" (left|right) (?:arm|knuckles)")
    local _,_,m = re:match(wildcards[0])
    part = m[1] .. part
  elseif part == "leg" then
    local re = rex.new(" (left|right) (?:leg|thigh)")
    local _,_,m = re:match(wildcards[0])
    part = m[1] .. part
  end
  hitted(part)
end


function wa.artery(wc)
  local part = wc[1] .. (wc[2] or "")
  if hitted(part) then
    affs.add_queue("artery_" .. part)
  end
end

function wa.bicep(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue("bicep_" .. wc[1])
  end
end

function wa.blackeye()
  if hitted("head") then
    affs.blackout()
  end
end

function wa.bloodynose()
  if hitted("head") then
    affs.bleed(50)
  end
end

function wa.breakarm(wc)
  if hitted(wc[1] .. "arm") then
    affs.limb_queue(wc[1], "arm", "broken")
  end
end

function wa.breakchest()
  if hitted("chest") then
    affs.add_queue("broken_chest")
    affs.stunned()
  end
end

function wa.breakjaw()
  if hitted("head") then
    affs.add_queue("broken_jaw")
  end
end

function wa.breakleg(wc)
  if hitted(wc[1] .. "leg") then
    if affs.limb(wc[1], "leg") == "healthy" then
      affs.limb_queue(wc[1], "leg", "broken")
    end
  end
end

function wa.breaknose()
  hitted("head")
  affs.add_queue("broken_nose")
  affs.stunned()
end

function wa.breakwrist(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue("broken_" .. wc[1] .. "wrist")
  end
end

function wa.burstorgans()
  if hitted("gut") then
    affs.add_queue("burst_organs")
  end
end

function wa.collapsedlungs()
  if hitted("chest") then
    affs.add_queue("collapsed_lungs")
  end
end

function wa.concussion()
  if hitted("head") then
    affs.add_queue("concussion")
  end
end

function wa.crackelbow(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue("elbow_" .. wc[1])
  end
end

function wa.crushaorta()
  if hitted("chest") then
    affs.bleed(prompt.stat("maxhp") * 0.2)
  end
end

function wa.crusharm(wc)
  if hitted(wc[1] .. "arm") then
    affs.limb_queue(wc[1], "arm", "mangled")
  end
end

function wa.crushchest()
  if hitted("chest") then
    affs.add_queue("crushed_chest")
  end
end

function wa.crushleg(wc)
  if hitted(wc[1] .. "leg") then
    affs.limb_queue(wc[1], "leg", "mangled")
    if wc[2] and #wc[2] > 0 then
      affs.prone()
    end
  end
end

function wa.crushwindpipe()
  if hitted("head") then
    affs.add_queue("crushed_windpipe")
  end
end

function wa.disembowel()
  if hitted("gut") then
    affs.add_queue("disemboweled")
  end
end

function wa.dysentery()
  if hitted("gut") then
    affs.add_queue("dysentery")
  end
end

function wa.elbow(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue("elbow_" .. wc[1])
  end
end

function wa.fractured(wc)
  local part = wc[1] .. (wc[2] or "")
  if hitted(part) then
    affs.add_queue("fractured_" .. part)
  end
end

function wa.furrowbrow()
  if hitted("head") then
    affs.add_queue("furrowed_brow")
  end
end

function wa.gashcheek()
  if hitted("head") then
    affs.add_queue("gashed_cheek")
  end
end

function wa.gashchest()
  if hitted("chest") then
    affs.stunned()
    affs.bleed(175)
  end
end

function wa.hemiplegy(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue("hemiplegy_" .. wc[1])
  end
end

function wa.impale()
  hitted("gut")
  affs.prone("impale_gut")
end

function wa.jaggedwound(wc)
  if hitted(wc[1]) then
    affs.bleed(400)
  end
end

function wa.joust(wc)
  if main.attacked(wc[1], "cavalier", "joust") then
    flags.set("hit_with", wc[2])
    local part = string.gsub(wc[3], " ", "")
    hitted(part)
    affs.prone()
  end
end

function wa.kneecap(wc)
  if hitted(wc[1] .. "leg") then
    if affs.has("kneecap_" .. wc[1]) then
      affs.limb_queue(wc[1], "leg", "broken")
      affs.prone()
    else
      affs.add_queue("kneecap_" .. wc[1])
    end
  end
end

function wa.knockdown(wc)
  if hitted(wc[1] .. "leg") then
    affs.prone()
  end
end

function wa.lacerated(wc)
  local part = wc[1] .. wc[2]
  if hitted(part) then
    affs.add_queue("lacerated_" .. part)
  end
end

function wa.nerve(wc)
  if hitted(wc[1] .. "arm") then
    affs.add_queue{"nerve_" .. wc[1], "hemiplegy_" .. wc[1]}
  end
end

function wa.obstruction(wc)
  if main.attacked("", "cavalier", "obstruction") then
    local part = string.gsub(wc[1], " ", "")
    add(part, 500)
    affs.prone()
  end
end

function wa.obstruction2(wc)
  if main.attacked("", "cavalier", "obstruction") then
    affs.prone()
  end
end

function wa.opengut()
  if hitted("gut") then
    affs.add_queue("sliced_gut")
  end
end

function wa.phrenic()
  if hitted("chest") then
    affs.add_queue("phrenic_nerve")
  end
end

function wa.pierced(wc)
  local part = wc[1] .. wc[2]
  if hitted(part) then
    affs.add_queue("pierced_" .. part)
  end
end

function wa.pincharge(wc)
  if main.attacked(wc[1], "cavalier", "pincharge") then
    affs.prone{"prone", "impale_gut"}
  end
end

function wa.pinned(wc)
  if hitted(wc[1] .. "leg") then
    local pc = math.min(affs.has("pinned_" .. wc[1]) or 0, 2) + 1
    affs.add_queue("pinned_" .. wc[1], pc)
    affs.add_queue("pierced_" .. wc[1] .. "leg")
  end
end

function wa.puncturedchest()
  if hitted("chest") then
    affs.add_queue("punctured_chest")
  end
end

function wa.puncturedlung()
  if hitted("chest") then
    affs.add_queue("punctured_lung")
  end
end

function wa.rend(wc)
  main.attacked(wc[1], "knighthood", "rend")
  affs.bleed(200)
  main.poisons_on()
  if wc[2] == "gut" then
    affs.del_queue("impale_gut")
  elseif wc[2] == "left leg" then
    if affs.has("pinned_left") == 2 then
      affs.add_queue("pinned_left", 1)
    else
      affs.del_queue("pinned_left")
    end
  elseif wc[2] == "right leg" then
    if affs.has("pinned_right") then
      affs.add_queue("pinned_right", 1)
    else
      affs.del_queue("pinned_right")
    end
  end
end

function wa.ringingear()
  if hitted("head") then
    affs.prone(function () affs.hidden("disoriented", affs.has("disoriented"), 2) end)
    affs.stunned()
  end
end

function wa.rupturegut()
  if hitted("gut") then
    affs.add_queue("ruptured_gut")
  end
end

function wa.scalp()
  if hitted("head") then
    affs.add_queue("scalped")
  end
end

function wa.severed(wc)
  if hitted(wc[1] .. wc[2]) then
    affs.limb_queue(wc[1], wc[2], "severed")
    affs.stunned()
  end
end

function wa.severedspine()
  if hitted("gut") then
    affs.add_queue("severed_spine")
  end
end

function wa.shatterankle(wc)
  if hitted(wc[1] .. "leg") then
    affs.add_queue("ankle_" .. wc[1])
  end
end

function wa.shatterjaw()
  if hitted("head") then
    affs.add_queue("shattered_jaw")
  end
end

function wa.slicechest()
  if hitted("chest") then
    affs.prone("sliced_chest")
    affs.stunned()
  end
end

function wa.sliceear(wc)
  if hitted("head") then
    affs.prone("lostear_" .. wc[1])
    affs.stunned()
  end
end

function wa.slitthroat()
  if hitted("head") then
    affs.add_queue("slit_throat")
  end
end

function wa.snaprib()
  if hitted("chest") then
    affs.add_queue("snapped_rib")
  end
end

function wa.tendon(wc)
  if hitted(wc[1] .. "leg") then
    affs.prone{"prone", "tendon_" .. wc[1]}
  end
end

function wa.thigh(wc)
  if hitted(wc[1] .. "leg") then
    affs.add_queue("thigh_" .. wc[1])
  end
end

function wa.vomitblood()
  if hitted("gut") then
    affs.add_queue("vomiting_blood")
  end
end


function aff(name, line, wildcards, styles)
  local a = string.match(name, "^%a-_(%a+)%d*__$")
  if not a or not wa[a] then
    display.Error("System mismatch on trigger '" .. name .. "'")
    return
  end

  wa[a](wildcards)
end


local function katahit(part)
  if flags.get("rebounded") then
    return
  end

  -- TODO: queue for anti-illusion
  local hits = 1

  hits_kata[part] = hits_kata[part] or {}
  for h = 1,hits do
    table.insert(hits_kata[part], os.clock())
  end
  display.Debug("Kata hits to " .. part .. " now " .. katacount(part), "wounds")
  EnableTimer("kata_hits_decrement__", true)

  scan.update = true
end

function katacount(part)
  local hk = hits_kata[part] or {}
  return #hk
end

function decrement_kata()
  local hk = copytable.shallow(hits_kata)
  local ts = os.clock()
  for k,v in pairs(hk) do
    for _,t in ipairs(v) do
      if ts - t >= tonumber(GetVariable("sg1_option_hit_timeout") or "10") then
        table.remove(hits_kata[k], 1)
        display.Debug("Kata hits to " .. k .. " now " .. katacount(k), "wounds")
      else
        break
      end
    end
  end
  for _,v in pairs(hits_kata) do
    if #v > 0 then
      return
    end
  end
  EnableTimer("kata_hits_decrement__", false)
  ResetTimer("kata_hits_decrement__")
end

function kata(part, amt)
  if not amt then
    amt = 50
  end

  display.Debug("Kata wound -- " .. part .. " +" .. amt, "wounds")
  add(part, amt)
  flags.damaged_health()
end

function kata_attack(part, weapon)
  flags.set("kata_weapon", weapon)
  flags.set("kata_hit", part)
  katahit(part)
end

function kata_mods(skill)
  if not skill then
    display.Error("Invalid skill provided to kata_mods")
    return
  end

  if type(skill) == "table" then
    for _,sk in pairs(skill) do
      kata_mods(sk)
    end
    return
  end

  EnableTriggerGroup(skill .. "Mods", true)
  EnableTriggerGroup("KataMods", true)
  prompt.queue(function () EnableTriggerGroup(skill .. "Mods", false) end, "un" .. skill)
  prompt.queue(function () EnableTriggerGroup("KataMods", false) end, "unKata")
end


function kata_pk(name, line, wildcards, styles)
  local person = wildcards[1]
  local part = string.gsub(wildcards[2], " ", "")
  local attack = string.match(name, "^kata_(%a+)__")
  local wnds = {
    punch = 50,
    kick = 250,
  }
  if main.attacked(person, "kata", attack) then
    kata(part, wnds[attack] or 50)
    kata_attack(part, attack)
    kata_mods{"Nekotai", "Ninjakari", "Shofangi", "Tahtetso"}
    main.poisons_on()
  end
end


function handle_puer(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  if name == "highmagic_puer__" then
    flags.set("puer", part)
    local heal = -900
    local current = get(part)
    local diff = current + heal
    if diff <= 0 then
      set(part, 700)
    else
      add(part, heal)
    end
    EnableTrigger("highmagic_puer_healed__", true)
    prompt.queue(function () EnableTrigger("highmagic_puer_healed__", false) end)
  else
    if flags.get("puer") == part then
      set(part, 0)
    end
  end
end
