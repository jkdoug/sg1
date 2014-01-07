module (..., package.seeall)

local shield = {}
local aura = {}
local prone = {}
local asleep = {}
local crucified = {}
local prismatic = {}
local pitted = {}

lv = {} -- leaving
rt = {} -- returned


local function normalize(name)
  if not name then
    display.Error("Invalid enemy target name: " .. tostring(name))
    return "", false
  end

  local en = string.lower(name)
  local targ = string.lower(GetVariable("target_name") or GetVariable("target") or "")
  if #targ > 0 and string.find(en, targ) then
    return targ, true
  end
  return en, false
end

function reset(name)
  display.Debug("Enemy statuses reset (" .. tostring(name) .. ")", "enemy")
  if name then
    local en = normalize(name)

    shield[en] = nil
    aura[en] = nil
    prone[en] = nil
    asleep[en] = nil
    crucified[en] = nil
    prismatic[en] = nil
    pitted[en] = nil

    if string.lower(flags.get("maestoso_caster") or "") == en then
      failsafe.disable("maestoso")
      flags.clear{"maestoso", "maestoso_caster"}
    end
    if string.lower(flags.get("aurawarper") or "") == en then
      failsafe.disable("aurawarp")
      flags.clear{"aurawarper", "scanned_aurawarp"}
    end
    if string.lower(flags.get("bedeviler") or "") == en then
      failsafe.disable("bedevil")
      flags.clear{"bedeviler", "scanned_bedeviled"}
    end
  else
    shield = {}
    aura = {}
    prone = {}
    asleep = {}
    crucified = {}
    prismatic = {}
    pitted = {}
  end
end


function leaving(msg, name)
  local en, tf = normalize(name)
  if tf then
    display.enemy_alert(msg)
  end
end

function gone(msg, name)
  local en, tf = normalize(name)
  if tf then
    display.enemy_gone(msg)
  end

  reset(en)

  en = php.strproper(en)
  if raid.is_coven_member(en) then
    raid.coven_gone(en)
  end
end

function returned(msg, name)
  local en, tf = normalize(name)
  if tf then
    display.enemy_returned(msg)
  end

  reset(en)

  en = php.strproper(en)
  if raid.is_coven_member(en) then
    raid.coven_returned(en)
  end
end


function lv.name_dir(name, line, wildcards, styles)
  gone(string.upper(wildcards[2]), wildcards[1])
end

function lv.dir_name(name, line, wildcards, styles)
  gone(string.upper(wildcards[1]), wildcards[2])
end

function lv.arco(name, line, wildcards, styles)
  gone("Arco took target", wildcards[1])
end

function lv.barreled(name, line, wildcards, styles)
  returned("Charged from the " .. string.upper(wildcards[2]), wildcards[1])
  flags.set("barreler", wildcards[1])
  EnableTrigger("enemy_barreling__", true)
  prompt.queue(function () EnableTrigger("enemy_barreling__", false) end)
end

function lv.barreling(name, line, wildcards, styles)
  if wildcards[1] == flags.get("barreler") then
    gone("Charged to the " .. string.upper(wildcards[3]), wildcards[1])
    gone("Barged to the " .. string.upper(wildcards[3]), wildcards[2])
  end
end

function lv.beckoned(name, line, wildcards, styles)
  gone("Beckoned", wildcards[1])
end

function lv.bolted(name, line, wildcards, styles)
  gone("Bolted " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.bond_uniting(name, line, wildcards, styles)
  leaving("Bond Uniting", wildcards[1])
end

function lv.bond_united(name, line, wildcards, styles)
  gone("Bond United", wildcards[1])
end

function lv.bullkick(name, line, wildcards, styles)
  EnableTrigger("enemy_bullkicked_out__", true)
  prompt.queue(function () EnableTrigger("enemy_bullkicked_out__", false) end)
end

function lv.bullkicked(name, line, wildcards, styles)
  gone("Bullkicked " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.burrowed(name, line, wildcards, styles)
  gone("Burrowed", wildcards[1])
end

function lv.dead(name, line, wildcards, styles)
  gone("Dead", wildcards[1])
end

function lv.editor(name, line, wildcards, styles)
  gone("Editor", wildcards[1])
end

function lv.empress(name, line, wildcards, styles)
  gone("Empress by " .. wildcards[1], wildcards[2])
end

function lv.fear(name, line, wildcards, styles)
  gone("Fear", wildcards[1])
end

function lv.flying(name, line, wildcards, styles)
  gone("Flying", wildcards[1])
end

function lv.geyser(name, line, wildcards, styles)
  gone("Geyser - GROUND", wildcards[1])
end

function lv.ghost(name, line, wildcards, styles)
  gone("Ghost", wildcards[1])
end

function lv.glide(name, line, wildcards, styles)
  gone("Glided " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.gravity(name, line, wildcards, styles)
  leaving("Leaving to the " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.gusted(name, line, wildcards, styles)
  gone("Gusted " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.headbutt(name, line, wildcards, styles)
  gone("Headbutted " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.hobbled(name, line, wildcards, styles)
  gone("Hobbled " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.jumpkick(name, line, wildcards, styles)
  gone("Jumpkicked " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.leaped(name, line, wildcards, styles)
  gone("Leaped " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.leftarea(name, line, wildcards, styles)
  gone("Left Area", wildcards[1])
end

function lv.mantrawind(name, line, wildcards, styles)
  gone("Mantra Wind " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.moonbeamed(name, line, wildcards, styles)
  gone("Moonbeam", wildcards[1])
end

function lv.mountjumped(name, line, wildcards, styles)
  gone("Mountjumped " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.news(name, line, wildcards, styles)
  gone("News", wildcards[1])
end

function lv.pogo(name, line, wildcards, styles)
  gone("Pogo'd " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.polevault(name, line, wildcards, styles)
  gone("Polevaulted " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.rolling(name, line, wildcards, styles)
  leaving("Rolling " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.rolled(name, line, wildcards, styles)
  gone("Rolled " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.rubble(name, line, wildcards, styles)
  leaving("Leaving over Rubble", wildcards[1])
end

function lv.scissorflip(name, line, wildcards, styles)
  EnableTrigger("enemy_scissorflipped_out__", true)
  prompt.queue(function () EnableTrigger("enemy_scissorflipped_out__", false) end)
end

function lv.scissorflipped(name, line, wildcards, styles)
  gone("Scissorflipped " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.shadowflight(name, line, wildcards, styles)
  gone("Shadow Flight", wildcards[1])
end

function lv.somersaulting(name, line, wildcards, styles)
  leaving("Somersaulting " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.somersaulted(name, line, wildcards, styles)
  gone("Somersaulted " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.starleap(name, line, wildcards, styles)
  gone("Starleap", wildcards[1])
end

function lv.summoning(name, line, wildcards, styles)
  leaving("Being Summoned", wildcards[1])
end

function lv.summoned(name, line, wildcards, styles)
  gone("Summoned", wildcards[1])
end

function lv.swam(name, line, wildcards, styles)
  gone("Swam " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.tackled(name, line, wildcards, styles)
  gone("Tackled " .. string.upper(wildcards[3]), wildcards[2])
  gone("Tackled " .. string.upper(wildcards[3]), wildcards[1])
end

function lv.teleport(name, line, wildcards, styles)
  gone("Teleport", wildcards[1])
end

function lv.tornado(name, line, wildcards, styles)
  gone("Flying (Tornado)", wildcards[1])
end

function lv.treefall(name, line, wildcards, styles)
  gone("Tree Fall", wildcards[1])
end

function lv.treelift(name, line, wildcards, styles)
  if map.elevation() == "trees" then
    returned("Trees", wildcards[1])
  else
    gone("Trees", wildcards[1])
  end
end

function lv.trees(name, line, wildcards, styles)
  gone("Trees", wildcards[1])
end

function lv.trees_climb(name, line, wildcards, styles)
  gone("Climbed Down", wildcards[1])
end

function lv.tumbling(name, line, wildcards, styles)
  leaving("Tumbling " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.tumbled(name, line, wildcards, styles)
  gone("Tumbled " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.whirlwind(name, line, wildcards, styles)
  EnableTrigger("enemy_whirlwinded_out__", true)
  prompt.queue(function () EnableTrigger("enemy_whirlwinded_out__", false) end)
end

function lv.whirlwinded(name, line, wildcards, styles)
  gone("Whirlwind " .. string.upper(wildcards[2]), wildcards[1])
end

function lv.willowisp(name, line, wildcards, styles)
  gone("Wisped", wildcards[1])
end


function rt.name_dir(name, line, wildcards, styles)
  returned(string.upper(wildcards[2]), wildcards[1])
end

function rt.dir_name(name, line, wildcards, styles)
  returned(string.upper(wildcards[1]), wildcards[2])
end

function rt.air_wind(name, line, wildcards, styles)
  returned("Air Wind", wildcards[1])
end

function rt.beckoned(name, line, wildcards, styles)
  gone("Beckoned", wildcards[1])
end

function rt.bond_united(name, line, wildcards, styles)
  returned("Bond United", wildcards[1])
end

function rt.burrowed(name, line, wildcards, styles)
  returned("Burrowed", wildcards[1])
end

function rt.currents(name, line, wildcards, styles)
  returned("Currents", wildcards[1])
end

function rt.empressed(name, line, wildcards, styles)
  returned("Empressed", wildcards[1])
end

function rt.followed(name, line, wildcards, styles)
  returned(string.upper(wildcards[2]), wildcards[1])
end

function rt.headbutted(name, line, wildcards, styles)
  returned("Headbutted from the " .. string.upper(wildcards[2]), wildcards[1])
end

function rt.jumpkicked(name, line, wildcards, styles)
  returned("Jumpkicked from the " .. string.upper(wildcards[2]), wildcards[1])
end

function rt.landed(name, line, wildcards, styles)
  returned("Landed", wildcards[1])
end

function rt.leaped(name, line, wildcards, styles)
  returned("Leaped from the " .. string.upper(wildcards[2]), wildcards[1])
end

function rt.levitated(name, line, wildcards, styles)
  returned("Levitated", wildcards[1])
end

function rt.moonbeamed(name, line, wildcards, styles)
  returned("Moonbeam", wildcards[1])
end

function rt.news(name, line, wildcards, styles)
  returned("News", wildcards[1])
end

function rt.ozuye(name, line, wildcards, styles)
  returned("Ozuye found an enemy!", wildcards[1])
end

function rt.somersaulted(name, line, wildcards, styles)
  returned("Somersaulted from " .. string.upper(wildcards[2]), wildcards[1])
end

function rt.spring_trap(name, line, wildcards, styles)
  returned("Spring Trap", wildcards[1])
end

function rt.summoned(name, line, wildcards, styles)
  returned("Summoned", wildcards[1])
end

function rt.swam(name, line, wildcards, styles)
  returned("Swam", wildcards[1])
end

function rt.teleported(name, line, wildcards, styles)
  returned("Teleported", wildcards[1])
end

function rt.tumbled(name, line, wildcards, styles)
  returned("Tumbled from " .. string.upper(wildcards[2]), wildcards[1])
end

function rt.unghosted(name, line, wildcards, styles)
  returned("Unghosted", wildcards[1])
end


function has_aura(name)
  local en = normalize(name or "nobody")
  return aura[en]
end

function is_target(name)
  local _, tf = normalize(name or "nobody")
  return tf
end

function is_shielded(name)
  local en = normalize(name or "nobody")
  return shield[en]
end

function is_prone(name)
  local en = normalize(name or "nobody")

  if prone[en] == true or
     crucified[en] == true then
    return true
  end

  return false
end


function proned(name, flag)
  local en, tf = normalize(name)

  if flag == nil then
    flag = true
  end

  local prev = prone[en]
  prone[en] = flag
  if prone[en] then
    display.Debug("Enemy is prone [" .. en .. "]", "enemy")
  else
    display.Debug("Enemy stood up [" .. en .. "]", "enemy")
  end

  if tf and prone[en] ~= prev then
    if prone[en] then
      prompt.prequeue(function () display.enemy_alert("PRONE") end, "enprone")
    elseif not prompt.unqueue("enprone") then
      display.enemy_alert("STANDING")
    end
  end
end

function rebound(name, flag)
  local en, tf = normalize(name)

  if flag == nil then
    flag = true
  end

  if flag then
    flags.clear(en .. "_razed_aura")
  end

  local prev = aura[en]
  aura[en] = flag
  if aura[en] then
    display.Debug("Enemy has aura [" .. en .. "]", "enemy")
  else
    display.Debug("Enemy has no aura [" .. en .. "]", "enemy")
  end

  if tf and aura[en] ~= prev then
    if aura[en] then
      display.enemy_aura()
    else
      display.enemy_unaura()
    end
  end
end

function shielded(name, flag)
  local en, tf = normalize(name)

  if flag == nil then
    flag = true
  end

  if flag and tf then
    flags.clear(en .. "_razed_shield")
  end

  local prev = shield[en]
  shield[en] = flag
  if shield[en] then
    display.Debug("Enemy shielded [" .. en .. "]", "enemy")
  else
    display.Debug("Enemy unshielded [" .. en .. "]", "enemy")
  end

  if tf and shield[en] ~= prev then
    if shield[en] then
      display.enemy_alert("SHIELD UP")
    else
      display.enemy_alert("SHIELD DOWN")
    end
  end
end

function no_target(name, line, wildcards, styles)
  display.Prefix()
  ColourNote(display.standard_colors.en_gone_tx, display.standard_colors.en_gone_bg, "NO TARGET")

  local enchant = flags.get("used_enchant")
  if enchant == "window" or enchant == "scry" then
    prompt.preillqueue(function () actions.activated_enchantment(enchant) end)
  end
end

function handle_shielding(name, line, wildcards, styles)
  shielded(wildcards[1], true)
end

function handle_unshielding(name, line, wildcards, styles)
  shielded(wildcards[1], false)
end

function handle_aura(name, line, wildcards, styles)
  local en = wildcards[1]
  if not en or #en < 1 then
    en = GetVariable("target") or ""
  end
  if #en < 1 then
    return
  end
  rebound(en, true)
end

function handle_unaura(name, line, wildcards, styles)
  rebound(wildcards[1], false)
  shielded(wildcards[1], false)
end

function handle_rebounded(name, line, wildcards, styles)
  rebound(wildcards[1], false)
  rebound(wildcards[2], true)
  shielded(wildcards[2], false)
end

function handle_razing(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])
  if string.find(line, "to no effect") or wildcards[2] == "speed defence" then
    shield[en] = false
    aura[en]  = false
    if string.lower(wildcards[1]) == en and tf then
      display.enemy_noaura()
    end
  end

  if wildcards[2] == "magical shield" then
    shielded(wildcards[1], false)
    flags.clear{en .. "_razed_shield", en .. "_razed_aura"}
  elseif wildcards[2] == "aura of rebounding" then
    rebound(wildcards[1], false)
    flags.clear(en .. "_razed_aura")
  else
    rebound(wildcards[1], false)
    shielded(wildcards[1], false)
    flags.clear{en .. "_razed_shield", en .. "_razed_aura"}
  end
end

function handle_fallen(name, line, wildcards, styles)
  local en = wildcards[1]
  if not en or #en < 1 then
    en = GetVariable("target") or ""
  end
  if #en < 1 then
    return
  end
  proned(en, true)
end

function handle_unfallen(name, line, wildcards, styles)
  proned(wildcards[1], false)
end

function handle_nonfallen(name, line, wildcards, styles)
  local en = wildcards[1]
  if not en or #en < 1 then
    return
  end

  local en, tf = normalize(en)

  prone[en] = false
  display.Debug("Enemy not prone [" .. en .. "]", "enemy")
  if tf then
    prompt.unqueue("enprone")
  end
end

function handle_hypnoticgaze(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])

  if tf then
    local col = wildcards[2]
    local colors = {
      azure = "DIZZINESS",
      cerulean = "CONFUSION",
      crimson = "PARALYSIS",
      emerald = "VERTIGO",
      fuchsia = "DAYDREAMS",
      lavender = "PACIFISM",
      magenta = "BLINDNESS",
      mauve = "VAPORS",
      pink = "HALLUCINATIONS",
      purple = "BLACKOUT",
      scarlet = "FEAR",
      sapphire = "DEMENTIA",
      topaz = "STUPIDITY",
    }
    local text = {}
    for c,a in pairs(colors) do
      if string.find(col, c) then
        table.insert(text, a)
      end
    end
    display.enemy_alert("Beast hit with " .. table.concat(text, ", "))
  end
end

function handle_pitfall_announce(name, line, wildcards, styles)
  local person = wildcards[1]
  local vnum = tonumber(wildcards[2])

  for _,v in ipairs(styles) do
    if v.text == person and names.is_in_enemy_org(person) then
      SetVariable("target_pitted", person)
      Hyperlink("ppp", person, "Change target", RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), 0)
    else
      s,e = string.find(v.text, wildcards[2])
      if s then
        ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), string.sub(v.text, 1, s - 1))
        Hyperlink("go " .. vnum, vnum, "Run to the pit", map.colors.room_vnum, "", 0)
        ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), string.sub(v.text, e + 1))
      else
        ColourTell(RGBColourToName(v.textcolour), RGBColourToName(v.backcolour), v.text)
      end
    end
  end
  Note("")
end

function handle_pitfall(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])

  pitted[en] = true
  if tf then
    display.enemy_alert("FELL IN PIT")
  end

  if pitted[en] and names.is_in_enemy_org(en) then
    SetVariable("target_pitted", wildcards[1])
    prompt.unqueue("trapalarm")
    if not affs.has("dementia") and map.current_room and map.rooms[map.current_room] then
      raid.announce(string.upper(string.sub(en, 1, 1)) .. string.sub(en, 2) .. " has fallen into a pit by me: " .. map.rooms[map.current_room].name .. " (" .. map.current_room .. ")")
    else
      raid.announce(string.upper(string.sub(en, 1, 1)) .. string.sub(en, 2) .. " has fallen into a pit by me!")
    end
  end
end

function handle_unpit(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])

  pitted[en] = false
  if tf then
    display.enemy_alert("CLIMBED OUT OF PIT")
  end
end


function handle_sleep(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])

  asleep[en] = true
  prone[en] = true
  if tf then
    display.enemy_alert("ASLEEP")
  end
end

function handle_unsleep(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1])

  asleep[en] = false
  if tf then
    display.enemy_alert("AWAKE")
  end
end

function handle_vitae(name, line, wildcards, styles)
  local en, tf = normalize(wildcards[1] or "")

  if tf then
    display.enemy_alert("Alive Again")
  end
  rebound(en, false)
  shielded(en, false)
end

function handle_toaded(name, line, wildcards, styles)
  if names.is_member(wildcards[1], "Serenwilde") and not flags.get("arena") then
    if main.auto("stomp") then
      Execute("do1 stt")
    else
      display.Alert(wildcards[2] .. " is Toaded!")
      display.Alert("STT to Stomp!")
    end
  end
end

function handle_toadstomping(name, line, wildcards, styles)
  if names.is_in_ally_org(wildcards[1]) and not flags.get("arena") then
    if main.auto("stomp") then
      Execute("do1 stt")
    else
      display.Alert(wildcards[1] .. " is Stomping a Toad!")
      display.Alert("STT to Stomp!")
    end
  end
end

function handle_toadstomped(name, line, wildcards, styles)
  if not string.find(wildcards[1], "warty toad") then
    if main.auto("stomp") then
      Execute("do1 stt")
    else
      display.Alert("That toad's still not dead!")
      display.Alert("STT to Stomp!")
    end
  end
end
