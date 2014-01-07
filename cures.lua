module (..., package.seeall)

dn = {}
nc = {}
fn = {}
map = {
  ablaze = "sip frost",
  achromatic = function () return cures.fn.achromatic() end,
  addiction = {"eat galingale", "focus mind"},
  aeon = function () return cures.fn.aeon() end,
  agoraphobia = {"eat wormwood", "focus mind"},
  allheale = "sip allheale",
  ancestralcurse = "focus mind",
  ankle_left = "apply regeneration to legs",
  ankle_right = "apply regeneration to legs",
  anorexia = {"smoke coltsfoot", "focus mind", "hunger"},
  antidote = "sip antidote",
  arnica_arms = "apply arnica to arms",
  arnica_chest = "apply arnica to chest",
  arnica_head = "apply arnica to head",
  arnica_legs = "apply arnica to legs",
  artery_head = "eat yarrow",
  artery_leftarm = "eat yarrow",
  artery_leftleg = "eat yarrow",
  artery_rightarm = "eat yarrow",
  artery_rightleg = "eat yarrow",
  asleep = "wake",
  asthma = "apply melancholic to chest",
  aurawarp = "eat reishi",
  avengingangel = "eat pennyroyal",

  baalphegar = "eat pennyroyal",
  beast_ego = "beast order heal ego",
  beast_health = "beast order heal health",
  beast_mana = "beast order heal mana",
  bedeviled = "eat horehound",
  bicep_left = "eat marjoram",
  bicep_right = "eat marjoram",
  binah_sphere = "focus spirit",
  black_lung = "apply melancholic to chest",
  blackout = "sip allheale",
  bleeding_clot = "clot",
  bleeding_chervil = "eat chervil",
  blindness = "eat myrtle",
  broken_arm = "apply mending to arms",
  broken_chest = "apply arnica to chest",
  broken_jaw = "apply mending to head",
  broken_leftwrist = "apply mending to arms",
  broken_leg = "apply mending to legs",
  broken_limbs1 = "restore",
  broken_limbs2 = "restore",
  broken_limbs3 = "restore",
  broken_limbs4 = "restore",
  broken_nose = "apply arnica to head",
  broken_rightwrist = "apply mending to arms",
  burns_first = "apply liniment",
  burns_fourth = "apply liniment",
  burns_second = "apply liniment",
  burns_third = "apply liniment",
  burst_organs = "apply regeneration to gut",
  burst_vessels_1 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_2 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_3 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_4 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_5 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_6 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_7 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_8 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_9 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_10 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_11 = {"touch medicinebag", "sip health", "eat sparkleberry"},
  burst_vessels_12 = {"touch medicinebag", "sip health", "eat sparkleberry"},

  calamus = "eat calamus",
  chervil = "eat chervil",
  chest_pain = function () return cures.fn.chest_pain() end,
  choleric = "sip choleric",
  clamped_left = {"contort clamp", "writhe clamp"},
  clamped_right = {"contort clamp", "writhe clamp"},
  claustrophobia = {"eat wormwood", "focus mind"},
  cleanse = {"scrub", "rub cleanse"},
  clot_leftarm = "eat yarrow",
  clot_leftleg = "eat yarrow",
  clot_rightarm = "eat yarrow",
  clot_rightleg = "eat yarrow",
  clot_unknown = "eat yarrow",
  clumsiness = "eat kombu",
  coils_1 = "smoke faeleaf",
  coils_2 = "smoke faeleaf",
  coils_3 = "smoke faeleaf",
  coils_4 = "smoke faeleaf",
  coils_5 = "smoke faeleaf",
  coils_6 = "smoke faeleaf",
  coils_7 = "smoke faeleaf",
  coils_8 = "smoke faeleaf",
  coils_9 = "smoke faeleaf",
  coils_10 = "smoke faeleaf",
  collapsed_lungs = "apply regeneration to chest",
  commanded_remove = "rewear",
  commanded_store = "retrieve stored items",
  concussion = {"eat myrtle", "apply regeneration to head"},
  confusion = {"sip sanguine", "eat pennyroyal", "focus mind"},
  crone = "focus mind",
  crotamine = "sip antidote",
  crowcaw = "eat pennyroyal",
  crucified = {"contort impale", "writhe impale"},
  crushed_chest = {"apply regeneration to chest", "sip allheale"},
  crushed_windpipe = {"apply arnica to head", "smoke myrtle"},

  damaged_head = "apply regeneration to head",
  damaged_head2 = "apply regeneration to head",
  dark = "eat pennyroyal",
  darkmoon = "focus spirit",
  daydreams = "eat kafe",
  deadening = "eat kombu",
  deafness = "eat myrtle",
  deathmarks = {"scrub", "rub cleanse"},
  debate_circuitous = function () return cures.fn.debate_circuitous() end,
  debate_hurry = function () return cures.fn.debate_hurry() end,
  debate_loophole = function () return cures.fn.debate_loophole() end,
  defup_bal = "defup bal",
  defup_elixir = "defup elixir",
  defup_free = "defup free",
  defup_herb = "defup herb",
  defup_id = "defup id",
  defup_sub = "defup sub",
  defup_super = "defup super",
  dementia = "eat pennyroyal",
  diagnose = {"succor", "diag"},
  disemboweled = "apply regeneration to gut",
  dislocated_leftarm = "eat marjoram",
  dislocated_leftleg = "eat marjoram",
  dislocated_rightarm = "eat marjoram",
  dislocated_rightleg = "eat marjoram",
  disoriented = {"sip sanguine", "eat pennyroyal", "focus mind"},
  disrupted = "concentrate",
  dissonance = "eat horehound",
  dizziness = {"apply melancholic to head", "focus mind", "eat kombu"},
  dysentery = "sip choleric",

  earwort = "eat earwort",
  ectoplasm = {"scrub", "rub cleanse"},
  ego_curse = "focus spirit",
  ego_high = "sip bromide",
  ego_mid = "sip bromide",
  ego_low = "sip bromide",
  ego_vice = function () return cures.fn.ego_vice() end,
  elbow_left = "apply regeneration to arms",
  elbow_right = "apply regeneration to arms",
  enfeebled = "sip allheale",
  entangled = {"contort entangle", "writhe entangle"},
  epilepsy = {"eat kombu", "focus mind"},
  eroee_ray = "apply melancholic to head",

  faeleaf = "eat faeleaf",
  fastwrithe = {"invoke summer", "evoke tipheret"},
  fear = {"compose", "focus mind"},
  fill_coltsfoot = "fill coltsfoot",
  fill_faeleaf = "fill faeleaf",
  fill_myrtle = "fill myrtle",
  fire = "sip fire",
  focus = "rub focus",
  focus_body = "focus body",
  focus_mind = "focus mind",
  focus_spirit = "focus spirit",
  foot_left = "apply arnica to legs",
  foot_right = "apply arnica to legs",
  fractured_leftarm = "apply arnica to arms",
  fractured_rightarm = "apply arnica to arms",
  fractured_head = {"apply mending to head", "apply arnica to head"},
  frost = "sip frost",
  frozen = "sip fire",
  furrowed_brow = "sip sanguine",

  galingale = "eat galingale",
  gashed_cheek = "eat marjoram",
  gluttony = "eat galingale",
  grappled = {"contort grapple", "writhe grapple"},
  gunk = {"scrub", "rub cleanse"},

  hallucinations = "eat pennyroyal",
  health_curse = "focus spirit",
  health_high = {"touch medicinebag", "sip health"},
  health_low = {"touch medicinebag", "sip health"},
  health_mid = {"touch medicinebag", "sip health"},
  healthleech = {"sip sanguine", "eat horehound"},
  hemi_prone = "smoke myrtle",
  hemiplegy = "smoke myrtle",
  hemiplegy_left = "smoke myrtle",
  hemiplegy_legs = "smoke myrtle",
  hemiplegy_right = "smoke myrtle",
  hemophilia = {"sip sanguine", "eat yarrow"},
  hidden_heretic = "focus mind",
  hidden_kombu = "eat kombu",
  hidden_mental = "focus mind",
  hidden_oracle = "eat wormwood",
  hoisted = {"contort hoist", "writhe hoist"},
  hold_breath = "hold breath",
  horehound = "eat horehound",
  hypersomnia = "sip choleric",
  hypochondria = "eat wormwood",

  illuminated = "focus spirit",
  impale_gut = {"contort impale", "writhe impale"},
  impale_antlers = {"contort impale", "writhe impale"},
  impatience = {"smoke coltsfoot", "focus mind"},
  in_pit = {"climb up", "climb rocks"},
  infidel = "focus spirit",
  insanity_1 = {"focus mind", "eat pennyroyal"},
  insanity_2 = {"focus mind", "eat pennyroyal"},
  insanity_3 = {"focus mind", "eat pennyroyal"},
  insanity_4 = {"focus mind", "eat pennyroyal"},
  insanity_5 = {"focus mind", "eat pennyroyal"},
  itch = "apply liniment",

  japhiel = "eat pennyroyal",
  jinx = "eat reishi",
  justice = "eat reishi",

  kafe = "eat kafe",
  kneecap_left = "apply regeneration to legs",
  kneecap_right = "apply regeneration to legs",
  kneeling = {"springup", "stand"},
  kombu = "eat kombu",

  lacerated_leftarm = "eat yarrow",
  lacerated_leftleg = "eat yarrow",
  lacerated_rightarm = "eat yarrow",
  lacerated_rightleg = "eat yarrow",
  leg_locked = "focus body",
  lethargy = {"sip sanguine", "eat yarrow"},
  lightheaded = {"eat reishi"},
  liniment = "apply liniment",
  loneliness = {"smoke coltsfoot", "focus mind"},
  lostear_left = "eat marjoram",
  lostear_right = "eat marjoram",
  losteye_left = "apply regeneration to head",
  losteye_right = "apply regeneration to head",
  love = "sip choleric",
  lovers = "eat galingale",

  mana_curse = "focus spirit",
  mana_high = "sip mana",
  mana_low = "sip mana",
  mana_mid = "sip mana",
  manabarbs = function () return cures.fn.manabarbs() end,
  mangled_arm = "apply regeneration to arms",
  mangled_leg = "apply regeneration to legs",
  marjoram = "eat marjoram",
  masochism = {"smoke coltsfoot", "focus mind"},
  melancholic_chest = "apply melancholic to chest",
  melancholic_head = "apply melancholic to head",
  mending_head = "apply mending to head",
  mending_arms = "apply mending to arms",
  mending_legs = "apply mending to legs",
  merbloom = "eat merbloom",
  mindset = "mindset",
  moon_ray = "eat pennyroyal",
  moon_tarot = "eat pennyroyal",
  mucous = {"scrub", "rub cleanse"},
  muddy = {"scrub", "rub cleanse"},
  myrtle = "eat myrtle",

  narcolepsy = "eat kafe",
  nerve_left = "apply regeneration to arms",
  nerve_right = "apply regeneration to arms",
  no_fire = "sip fire",
  no_frost = "sip frost",
  no_insomnia = {"insomnia", "eat merbloom"},
  no_kafe = "eat kafe",
  no_love = "sip love",
  no_metawake = "metawake on",
  no_moonwater = "sip moonwater",
  no_rebounding = "smoke faeleaf",
  no_selfish = "selfishness",
  no_sixthsense = "eat faeleaf",
  no_speed = {"adrenaline", "sip quicksilver"},
  no_tea = "auto tea",
  no_truehearing = "eat earwort",
  numb_chest = {"rub medicinebag on chest", "apply health to chest"},
  numb_gut = {"rub medicinebag on gut", "apply health to gut"},
  numb_head = {"rub medicinebag on head", "apply health to head"},
  numb_leftarm = {"rub medicinebag on arms", "apply health to arms"},
  numb_leftleg = {"rub medicinebag on legs", "apply health to legs"},
  numb_rightarm = {"rub medicinebag on arms", "apply health to arms"},
  numb_rightleg = {"rub medicinebag on legs", "apply health to legs"},

  omen = "focus spirit",
  omniphobia = "eat kombu",

  p5_tumble = "escape p5",
  pacifism = {"eat reishi", "focus mind"},
  paralysis = "focus body",
  paranoia = "eat pennyroyal",
  parry = "parry scan",
  peace = "eat reishi",
  pennyroyal = "eat pennyroyal",
  phlegmatic = "sip phlegmatic",
  phrenic_nerve = "smoke myrtle",
  pierced_leftarm = "smoke myrtle",
  pierced_leftleg = "smoke myrtle",
  pierced_rightarm = "smoke myrtle",
  pierced_rightleg = "smoke myrtle",
  pinned_left = {"contort impale", "writhe impale"},
  pinned_right = {"contort impale", "writhe impale"},
  power_cure = {"moondance full", "invoke green", "evoke gedulah"},
  power_spikes = function () return cures.fn.power_spikes() end,
  powersap = "sip antidote",
  powersink = {"sip phlegmatic", "eat reishi"},
  pox = "apply liniment",
  prone = {"springup", "stand"},
  punctured_chest = "eat marjoram",
  punctured_lung = "apply melancholic to chest",
  purplehaze = "eat pennyroyal",

  reality = "focus mind",
  recklessness = {"eat horehound", "focus mind"},
  regen_arms = "apply regeneration to arms",
  regen_chest = "apply regeneration to chest",
  regen_gut = "apply regeneration to gut",
  regen_head = "apply regeneration to head",
  regen_legs = "apply regeneration to legs",
  reishi = "eat reishi",
  repugnance = "sip love",
  relapsing = "eat yarrow",
  rewield = "rewield",
  rigormortis = "eat marjoram",
  roped = {"contort ropes", "writhe ropes"},
  ruptured_gut = "apply regeneration to gut",

  sanguine = "sip sanguine",
  sap = {"scrub", "rub cleanse"},
  scabies = "apply liniment",
  scalped = "sip sanguine",
  scrambled = "eat pennyroyal",
  scroll_heal = "read healing",
  sensitivity = "eat myrtle",
  severed_arm = "apply regeneration to arms",
  severed_leg = "apply regeneration to legs",
  severed_spine = "apply regeneration to gut",
  shackled = {"contort shackles", "writhe shackles"},
  shattered_jaw = "apply regeneration to head",
  shield_up = {"invoke circle", "sprinkle salt"},
  shivering = "sip fire",
  short_breath = "apply melancholic to chest",
  shyness = {"sip phlegmatic", "smoke coltsfoot", "focus mind"},
  sidiak_ray = {"eat pennyroyal", "focus mind"},
  sitting = "stand",
  sliced_chest = "eat marjoram",
  sliced_gut = "eat marjoram",
  sliced_tongue = "eat marjoram",
  slickness = {"eat calamus", "scrub", "rub cleanse"},
  slit_throat = "apply mending to head",
  smoke_coltsfoot = "smoke coltsfoot",
  smoke_faeleaf = "smoke faeleaf",
  smoke_myrtle = "smoke myrtle",
  snapped_rib = "apply arnica to chest",
  southwind = "eat pennyroyal",
  sparkleberry = "eat sparkleberry",
  spores = "eat pennyroyal",
  stance_arms = "stance arms",
  stance_chest = "stance chest",
  stance_gut = "stance gut",
  stance_head = "stance head",
  stance_left = "stance left",
  stance_legs = "stance legs",
  stance_lower = "stance lower",
  stance_middle = "stance middle",
  stance_right = "stance right",
  stance_upper = "stance upper",
  stance_vitals = "stance vitals",
  stiff_chest = "eat marjoram",
  stiff_gut = "eat marjoram",
  stiff_head = "eat marjoram",
  stiff_leftarm = "eat marjoram",
  stiff_rightarm = "eat marjoram",
  stupidity = {"eat pennyroyal", "focus mind"},
  succumbing = "eat reishi",
  sunallergy = "apply liniment",

  taint_sick = "focus spirit",
  telepathy = "focus mind",
  tendon_left = "apply regeneration to legs",
  tendon_right = "apply regeneration to legs",
  thigh_left = "eat marjoram",
  thigh_right = "eat marjoram",
  thorns_head = {"contort vines", "writhe vines"},
  thorns_leftarm = {"contort vines", "writhe vines"},
  thorns_rightarm = {"contort vines", "writhe vines"},
  thorns_leftleg = {"contort vines", "writhe vines"},
  thorns_rightleg = {"contort vines", "writhe vines"},
  thorns_ignite = "point ignite at me",
  throat_locked = "focus body",
  time_echo = "eat pennyroyal",
  timewarp_1 = {"focus mind", "eat horehound"},
  timewarp_2 = {"focus mind", "eat horehound"},
  timewarp_3 = {"focus mind", "eat horehound"},
  timewarp_4 = {"focus mind", "eat horehound"},
  timewarp_5 = {"focus mind", "eat horehound"},
  todo = "todo",
  transfixed = {"contort transfix", "writhe transfix"},
  treebane = "focus spirit",
  trembling = "apply melancholic to chest",
  trussed = {"contort truss", "writhe truss"},
  tumble = "auto tumble",
  twisted_leftarm = "apply mending to arms",
  twisted_leftleg = "apply mending to legs",
  twisted_rightarm = "apply mending to arms",
  twisted_rightleg = "apply mending to legs",

  undo_metawake = "metawake off",
  undo_selfish = "generosity",
  unlit_pipes = "pipes light",

  vapors = {"eat kombu", "apply melancholic to head"},
  vertigo = "eat myrtle",
  vestiphobia = "eat wormwood",
  violetvibrato = "eat kombu",
  void = {"eat pennyroyal", "focus mind"},
  vomiting = "sip choleric",
  vomiting_blood = "sip choleric",
  
  weakness = {"sip phlegmatic", "eat marjoram", "focus mind"},
  wormwood = "eat wormwood",
  worms = "sip choleric",
  wounded_arms_2500 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_arms_2000 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_arms_1500 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_arms_900 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_arms_300 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_arms_1 = {"rub medicinebag on arms", "apply health to arms"},
  wounded_chest_2500 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_chest_2000 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_chest_1500 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_chest_900 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_chest_300 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_chest_1 = {"rub medicinebag on chest", "apply health to chest"},
  wounded_gut_2500 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_gut_2000 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_gut_1500 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_gut_900 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_gut_300 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_gut_1 = {"rub medicinebag on gut", "apply health to gut"},
  wounded_head_2500 = {"rub medicinebag on head", "apply health to head"},
  wounded_head_2000 = {"rub medicinebag on head", "apply health to head"},
  wounded_head_1500 = {"rub medicinebag on head", "apply health to head"},
  wounded_head_900 = {"rub medicinebag on head", "apply health to head"},
  wounded_head_300 = {"rub medicinebag on head", "apply health to head"},
  wounded_head_1 = {"rub medicinebag on head", "apply health to head"},
  wounded_legs_2500 = {"rub medicinebag on legs", "apply health to legs"},
  wounded_legs_2000 = {"rub medicinebag on legs", "apply health to legs"},
  wounded_legs_1500 = {"rub medicinebag on legs", "apply health to legs"},
  wounded_legs_900 = {"rub medicinebag on legs", "apply health to legs"},
  wounded_legs_300 = {"rub medicinebag on legs", "apply health to legs"},
  wounded_legs_1 = {"rub medicinebag on legs", "apply health to legs"},
  writhe = {"contort", "writhe"},

  yarrow = "eat yarrow",
}

function get(name)
  local name = string.lower(name)
  local cure = map[name]
  if not cure then
    display.Error("Missing cure mapping: " .. name)
    return nil
  end

  if type(cure) == "function" then
    cure = cure()
  end

  return cure
end


function clear(name)
  if not name then
    return
  end

  local name = string.gsub(name, " ", "_")
  local func = nc[name]
  if not func then
    display.Error("Missing 'nocure' method: " .. name, "cures")
    return
  end

  display.Debug("** Nothing cured by " .. name, "cures")

  func()
end


function fn.aeon()
  if gear.sips("phlegmatic") > 0 then
    return "sip phlegmatic"
  end
  if main.has_ability("athletics", "adrenaline") and bals.can_act() then
    return "adrenaline"
  end
  return "eat reishi"
end

function fn.chest_pain()
  if affs.is_prone() then
    if able.to("sip allheale") then
      return "sip allheale"
    elseif able.to("moondance full") then
      return "moondance full"
    elseif able.to("invoke green") then
      return "invoke green"
    elseif able.to("evoke gedulah") then
      return "evoke gedulah"
    end
  end

  return "apply regeneration to chest"
end

function fn.debate_circuitous()
  if magic.charges("focus") > 0 then
    return "rub focus"
  end
  return "attitude zealotry"
end

function fn.debate_hurry()
  if magic.charges("focus") > 0 then
    return "rub focus"
  end
  return "attitude saintly"
end

function fn.debate_loophole()
  if magic.charges("focus") > 0 then
    return "rub focus"
  end
  return "attitude lawyerly"
end

local function cure_auric()
  if affs.has("earache") and
     flags.get("maestoso") then
    if able.to("sip allheale") then
      return "sip allheale"
    elseif defs.has("moonwater") then
      local mp = ((flags.get("mana_careful") and 1) or 0) * -0.35 + prompt.stat("mp") / prompt.stat("maxmp")
      local ep = ((flags.get("ego_careful") and 1) or 0) * -0.35 + prompt.stat("ego") / prompt.stat("maxego")
      local hp = prompt.stat("hp") / prompt.stat("maxhp")
      if hp <= mp and hp <= ep then
        return "sip health"
      elseif mp <= hp and mp <= ep then
        return "sip mana"
      else
        return "sip bromide"
      end
    elseif ((affs.has("achromatic") and 2) or 0) +
           ((affs.has("manabarbs") and 3) or 0) +
           ((affs.has("ego_vice") and 2) or 0) +
           ((affs.has("power_spikes") and 1) or 0) > 3 then
      if able.to("moondance full") then
        return "moondance full"
      elseif able.to("invoke green") then
        return "invoke green"
      elseif able.to("evoke gedulah") then
        return "evoke gedulah"
      end
    end
  end

  return "eat horehound"
end

function fn.achromatic()
  return cure_auric()
end

function fn.ego_vice()
  return cure_auric()
end

function fn.manabarbs()
  return cure_auric()
end

function fn.power_spikes()
  return cure_auric()
end


local function writhe(t)
  if flags.get("writhe_try") then
    flags.clear{"writhe_try", "writhing"}
    if t == "clamp" then
      affs.del{"clamped_left", "clamped_right"}
    elseif t == "entangle" then
      affs.del("entangled")
    elseif t == "grapple" then
      affs.grapple(nil, nil)
    elseif t == "hoist" then
      affs.del("hoisted")
    elseif t == "ropes" then
      affs.del("roped")
    elseif t == "shackles" then
      affs.del("shackled")
    elseif t == "transfix" then
      affs.del("transfixed")
    elseif t == "truss" then
      affs.del("trussed")
    elseif t == "vines" then
      affs.del{"thorns_head", "thorns_leftarm", "thorns_leftleg", "thorns_rightarm", "thorns_rightleg"}
    elseif t == "impale" then
      affs.del{"crucified", "impale_gut", "impale_antlers", "pinned_left", "pinned_right"}
    else
      affs.del{"clamped_left", "clamped_right", "crucified", "entangled", "hoisted",
           "roped", "shackled", "transfixed", "thorns_head", "thorns_leftarm", "thorns_leftleg",
           "thorns_rightarm", "thorns_rightleg", "writhe", "impale_gut", "impale_antlers",
           "crucified", "pinned_left", "pinned_right"}
    end
    failsafe.disable("writhe")
  end
end


function dn.afterimage(name, line, wildcards, styles)
  affs.del_queue("afterimage")
  flags.clear("waiting_for_sixthsense")
end

function dn.allcure(name, line, wildcards, styles)
  local lc = string.match(name, "^cure_([%a%_]-)__$")
  main.allcure(true)
  flags.set("last_cure", string.gsub(lc, "_", " "))
end

function dn.allergies(name, line, wildcards, styles)
  local amt = affs.has("allergies") or 0
  if amt < 2 then
    affs.add_queue("allergies", 3)
  else
    affs.add_queue("allergies", amt - 1)
  end
end

function dn.bleeding(name, line, wildcards, styles)
  affs.bleed(-40)
  if affs.has("blackout") then
    actions.ate_herb(name, line, "a sprig of chervil", styles)
  end
  flags.clear("last_cure")
end

function dn.bleeding_all(name, line, wildcards, styles)
  if flags.get("clot_try") then
    affs.del_queue("bleeding")
    flags.clear("clot_try")
  end
  prompt.gag = true
end

function dn.blindness(name, line, wildcards, styles)
  flags.clear("last_cure")
end

function dn.blood_clot(name, line, wildcards, styles)
  local side = wildcards[1]
  if wildcards[2] == "shoulder" then
    affs.del_queue("clot_" .. side .. "arm")
  else
    affs.del_queue("clot_" .. side .. "leg")
  end
  if not affs.has("burst_vessels") then
    affs.burst(2)
  end
  affs.del_queue("clot_unknown")
end

function dn.broken_limb(name, line, wildcards, styles)
  local side = wildcards[1]
  local limb = wildcards[2]
  affs.limb_queue(side, limb, "healthy")
  flags.clear{"last_cure", "scanned_broken_" .. limb, "stand_try"}
--  if affs.limb("right", "leg") == "broken" and side..limb == "leftleg" then
--    affs.limb_queue("right", "leg", "healthy")
--  end
end

function dn.broken_limb_fizzle(name, line, wildcards, styles)
  local side = "right"
  if affs.limb("left", "leg") == "broken" then
    side = "left"
  end
  affs.limb_queue(side, "leg", "mangled")
  flags.clear{"last_cure", "scanned_broken_leg", "stand_try"}
end

function dn.burns(name, line, wildcards, styles)
  EnableTrigger("cure_burned__", true)
  if not affs.has("bedeviled") then
    flags.clear("last_cure")
  end
  prompt.queue(function () EnableTrigger("cure_burned__", false) end)
end

function dn.burned(name, line, wildcards, styles)
  flags.clear{"scanned_burns_first", "scanned_burns_second", "scanned_burns_third", "scanned_burns_fourth"}
  affs.burned(wildcards[1])
end

function dn.burst_vessel(name, line, wildcards, styles)
  affs.burst(-1)
end

function dn.burst_vessels(name, line, wildcards, styles)
  affs.burst(0, true)
end

function dn.clamped(name, line, wildcards, styles)
  affs.del_queue("clamped_" .. wildcards[1])
end

function dn.cleansed_gunk(name, line, wildcards, styles)
  actions.scrubbed("cure_scrub_gunk__")
end

function dn.cleansed_ablaze(name, line, wildcards, styles)
  affs.del_queue{"cleanse", "mucous", "sap", "gunk", "muddy", "ectoplasm", "ablaze"}
  flags.clear{"slow_going", "slow_sent"}
end

function dn.coils(name, line, wildcards, styles)
  local coils = affs.has("coils") or 0
  if coils > 1 then
    affs.add_queue("coils", coils - 1)
  else
    affs.del_queue("coils")
  end
end

function dn.deafness(name, line, wildcards, styles)
  flags.clear("last_cure")
end

function dn.deathmark(name, line, wildcards, styles)
  affs.del_queue("deathmarks")
  flags.clear("deathmarked")
end

function dn.deepwounds(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  if wildcards[2] == "completely" then
    wounds.set(part, 0)
  else
    local heal = -800
    local current = wounds.get(part)
    local diff = current + heal
    if diff <= 0 then
      wounds.set(part, 700)
    else
      wounds.add(part, heal)
    end
  end
  flags.clear{"health_applying", "health_try", "last_cure"}
end

function dn.dislocated_limb(name, line, wildcards, styles)
  if wildcards[2] == "hip" then
    affs.del_queue("dislocated_" .. wildcards[1] .. "leg")
  else
    affs.del_queue("dislocated_" .. wildcards[1] .. "arm")
  end
end

function dn.displacement(name, line, wildcards, styles)
  affs.del_queue("displacement")
  EnableTrigger("aeonics_displaced__", false)
end

function dn.disrupted(name, line, wildcards, styles)
  if flags.get("concentrate_try") then
    affs.del_queue("disrupted")
    flags.clear{"lost_eq", "slow_going", "concentrate_try"}
    flags.set("eq_time", os.clock(), 0)
  end
end

function dn.focused_body(name, line, wildcards, styles)
  local aff = string.match(name, "^cure_([%a%_]-)__$")
  if flags.get("focusing") then
    flags.clear("focusing")
    affs.del_queue(aff)
    affs.del("focus_body", true)
    bals.gain("focus")
  elseif flags.get("allcure") then
    affs.del_queue(aff)
    affs.del("focus_body", true)
  end
end

function dn.focused_mind(name, line, wildcards, styles)
  if not bals.confirm("focus", 5) then
    return
  end

  flags.clear{"slow_sent", "slow_going"}

  local aff = string.match(name, "^cure_(%a-)__$")
  if not aff then
    aff = string.match(name, "^cure_(%a-)_focus__$")
  end
  if aff then
    affs.del_queue(aff)
  end
end

function dn.fastwrithe(name, line, wildcards, styles)
  if flags.get("fastwrithe") then
    for _,a in ipairs{"entangled", "roped", "shackled", "trussed"} do
      if affs.has(a) then
        affs.del_queue(a)
        flags.clear("scanned_" .. a)
      end
    end
    flags.clear{"fastwrithe", "writhing", "scanned_fastwrithe"}
  end
end

function dn.fear(name, line, wildcards, styles)
  affs.del_queue("fear")
  flags.clear("compose_try")
end

function dn.grapple(name, line, wildcards, styles)
  affs.grapple(nil, wildcards[1])
end

function dn.hoisted(name, line, wildcards, styles)
  flags.clear{"writhing", "writhing_try"}
  affs.del_queue("hoisted")
end

function dn.insanity(name, line, wildcards, styles)
  affs.insanity(-4, wildcards[1])
end

function dn.numb(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  affs.del_queue("numb_" .. part)
  flags.clear("health_applying")
end

function dn.phantomsphere(name, line, wildcards, styles)
  if string.find(line, "heave a sigh") then
    affs.del_queue("phantomsphere")
  else
    local count = math.min(affs.has("phantomsphere") or 2, 2)
    affs.add_queue("phantomsphere", count - 1)
  end
end

function dn.phrenic_nerve(name, line, wildcards, styles)
  affs.del_queue("phrenic_nerve")
  flags.clear("phrenic_smoke")
end

function dn.regenerate(name, line, wildcards, styles)
  local ac_regen = {
    chest_pain = true,
    crushed_chest = true,
    elbow_left = true,
    elbow_right = true,
    kneecap_left = true,
    kneecap_right = true,
    ruptured_gut = true,
    severed_spine = true,
  }

  local part, aff = string.match(name, "^cure_(%a-)_([%a%_]-)__$")
  if flags.get("regenerating") == part then
    if part == "arms" then
      aff = aff .. wildcards[1]
      flags.clear("parry_try")
    end
    if part == "legs" then
      aff = aff .. wildcards[1]
      flags.clear{"stand_try", "scanned_prone"}
    end
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue(aff)
  end

  if flags.get("allcure") and
     ac_regen[aff] then
    affs.del_queue(aff)
  end
end

function dn.regenerate_limb(name, line, wildcards, styles)
  local state = string.match(name, "^cure_[%a%_]-_(%a-)__$")
  local part = wildcards[2] .. "s"
  if flags.get("regenerating") == part then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.limb_queue(wildcards[1], wildcards[2], state)
  end
end

function dn.regenerate_collapsed_lungs(name, line, wildcards, styles)
  if flags.get("regenerating") == "chest" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue("collapsed_lungs")
    affs.add_queue("punctured_lung")
  end
end

function dn.regenerate_concussion1(name, line, wildcards, styles)
  if flags.get("regenerating") == "head" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue{"concussion", "damaged_head2"}
    affs.add_queue("damaged_head")
  end
end

function dn.regenerate_concussion2(name, line, wildcards, styles)
  if flags.get("last_cure") == "eat myrtle" or
    flags.get("last_cure") == "moon full" or
    flags.get("last_cure") == "invoke green" or
    flags.get("last_cure") == "evoke gedulah" then
    affs.del_queue("concussion")
  elseif flags.get("regenerating") == "head" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue("concussion")
  end
end

function dn.regenerate_damaged_head(name, line, wildcards, styles)
  if flags.get("regenerating") == "head" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue{"concussion", "damaged_head", "damaged_head2"}
  end
end

function dn.regenerate_lost_eye(name, line, wildcards, styles)
  if flags.get("regenerating") == "head" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue{"concussion", "damaged_head2", "damaged_head", "losteye_" .. wildcards[1]}
  end
end

function dn.regenerate_shattered_jaw(name, line, wildcards, styles)
  if flags.get("regenerating") == "head" then
    flags.clear("regenerating")
    failsafe.disable("regeneration")
    affs.del_queue("shattered_jaw")
    affs.add_queue("broken_jaw")
  end
end

function dn.scalped(name, line, wildcards, styles)
  affs.del_queue("scalped")
  affs.add_queue("artery_head")
end

function dn.scarab(name, line, wildcards, styles)
  affs.del_queue("scarab")
  flags.damaged_health()
end

function dn.side(name, line, wildcards, styles)
  local aff = string.match(name, "^cure_([%a%_]-)__$")
  local side = wildcards[1]
  affs.del_queue(aff .. "_" .. side)
end

function dn.side_limb(name, line, wildcards, styles)
  local aff = string.match(name, "^cure_([%a%_]-)_limb__$")
  local side = wildcards[1]
  local limb = wildcards[2]
  affs.del_queue(aff .. "_" .. side .. limb)
end

function dn.simple(name, line, wildcards, styles)
  local aff = string.match(name, "^cure_([%a%_]-)__$")
  affs.del_queue(aff)
end

function dn.sparkle(name, line, wildcards, styles)
  if affs.has("blackout") then
    actions.ate_herb("", "", "a sparkleberry", {})
  end
end

function dn.stiff(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  if part == "face" then
    part = "head"
  end
  affs.del_queue("stiff_" .. part)
end

function dn.stiff_non(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  if part == "face" then
    part = "head"
  end
  affs.add_queue("stiff_" .. part)
  flags.clear("last_cure")
  if not affs.is_ootangk(part) then
    affs.grapple(part, "Someone", "ootangk")
  end
end

function dn.thorns_ripped(name, line, wildcards, styles)
  affs.del_queue{"thorns_head", "thorns_leftarm", "thorns_leftleg", "thorns_rightarm", "thorns_rightleg"}
  affs.bleed(300)
end

function dn.thorns_ignited(name, line, wildcards, styles)
  flags.clear("ignite_try")
  prompt.unqueue("ignited")
  affs.del_queue("thorns_" .. string.gsub(wildcards[1], " ", ""))
  affs.bleed(150)
end

function dn.timewarp(name, line, wildcards, styles)
  affs.timewarp(-4, wildcards[1])
end

function dn.unimpaled(name, line, wildcards, styles)
  local msg = wildcards[1]
  if msg == "cross" then
    affs.del_queue("crucified")
  elseif msg == "antlers" then
    affs.del_queue("impale_antlers")
  elseif string.find(msg, "gut") then
    affs.del_queue("impale_gut")
  elseif string.find(msg, "left foot") then
    if string.find(msg, "second blade") then
      affs.add_queue("pinned_left", 1)
    else
      affs.del_queue("pinned_left")
    end
  elseif string.find(msg, "second blade") then
    affs.add_queue("pinned_right", 1)
  else
    affs.del_queue{"pinned_right", "pinned_left"}
  end

  flags.clear{"writhing", "writhing_try"}
end

function dn.unimpaled_antlers(name, line, wildcards, styles)
  dn.unimpaled(name, line, {"antlers"}, styles)
end

function dn.unimpaled_withdraw(name, line, wildcards, styles)
  local msg = wildcards[1]
  if msg == "left leg" then
    if affs.has("pinned_left") == 2 then
      dn.unimpaled(name, line, {"left foot second blade"}, styles)
    else
      dn.unimpaled(name, line, {"left foot"}, styles)
    end
  elseif msg == "right leg" then
    if affs.has("pinned_right") == 2 then
      dn.unimpaled(name, line, {"right foot second blade"}, styles)
    else
      dn.unimpaled(name, line, {"right foot"}, styles)
    end
  else
    dn.unimpaled(name, line, wildcards, styles)
  end
end

function dn.writhed(name, line, wildcards, styles)
  local wt = {
    ["ropes"] = "roped",
    ["tight bindings"] = "trussed",
    ["state of transfixion"] = "transfixed",
    ["entanglement"] = "entangled",
    ["thorny vines"] = "thorns_" .. (flags.get("thorny_limb") or "leftarm"),
    ["shackles"] = "shackled",
  }
  local form = wildcards[1]
  local thorns = #wildcards[2] > 0
  flags.clear{"writhing", "writhing_try"}
  affs.del_queue(wt[form])
  if thorns then
    affs.bleed(175)
  end
end

function dn.writhed_thorns(name, line, wildcards, styles)
  local part = string.gsub(wildcards[1], " ", "")
  if part == "scalp" then
    part = "head"
  end
  flags.set("thorny_limb", part)
  affs.bleed(200)
end


function nc.apply_arnica_to_arms()
  affs.del{"fractured_leftarm", "fractured_rightarm", "arnica_arms"}
  bals.gain("herb")
end

function nc.apply_arnica_to_legs()
  affs.del{"foot_left", "foot_right", "arnica_legs"}
  bals.gain("herb")
end

function nc.apply_arnica_to_head()
  affs.del{"broken_nose", "crushed_windpipe", "fractured_head", "arnica_head"}
  bals.gain("herb")
end

function nc.apply_arnica_to_chest()
  affs.del{"broken_chest", "snapped_rib", "arnica_chest"}
  bals.gain("herb")
end

function nc.apply_health_to_skin()
  for _,part in ipairs{"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
    if not affs.is_ninshi(part) then
      wounds.set(part, 0)
      affs.del("numb_" .. part)
    end
  end
end

function nc.apply_health_to_head()
  if not affs.is_ninshi("head") then
    wounds.set("head", 0)
    affs.del("numb_head")
  end
end

function nc.apply_health_to_chest()
  if not affs.is_ninshi("chest") then
    wounds.set("chest", 0)
    affs.del("numb_chest")
  end
end

function nc.apply_health_to_gut()
  if not affs.is_ninshi("gut") then
    wounds.set("gut", 0)
    affs.del("numb_gut")
  end
end

function nc.apply_health_to_arms()
  if not affs.is_ninshi("leftarm") then
    wounds.set("leftarm", 0)
    affs.del("numb_leftarm")
  end
  if not affs.is_ninshi("rightarm") then
    wounds.set("rightarm", 0)
    affs.del("numb_rightarm")
  end
end

function nc.apply_health_to_legs()
  if not affs.is_ninshi("leftleg") then
    wounds.set("leftleg", 0)
    affs.del("numb_leftleg")
  end
  if not affs.is_ninshi("rightleg") then
    wounds.set("rightleg", 0)
    affs.del("numb_rightleg")
  end
end

function nc.apply_liniment_to_skin()
  affs.del{"pox", "scabies", "sunallergy", "liniment",
           "burns_first", "burns_second", "burns_third", "burns_fourth"}
end

function nc.apply_dragonsblood_to_skin()
end

function nc.apply_jasmine_to_skin()
end

function nc.apply_musk_to_skin()
end

function nc.apply_sandalwood_to_skin()
end

function nc.apply_vanilla_to_skin()
end

function nc.apply_melancholic_to_head()
  affs.del{"dizziness", "eroee_ray", "sensitivity", "vapors", "melancholic_head"}
end

function nc.apply_melancholic_to_chest()
  affs.del{"asthma", "black_lung", "punctured_lung", "short_breath", "trembling", "melancholic_chest"}
end

function nc.apply_mending_to_arms()
  affs.del{"broken_leftwrist", "broken_rightwrist", "twisted_leftarm", "twisted_rightarm", "mending_arms"}
  local larm = affs.limb("left", "arm")
  local rarm = affs.limb("right", "arm")
  if larm ~= "mangled" and larm ~= "severed" then
    affs.limb("left", "arm", "healthy")
  end
  if rarm ~= "mangled" and rarm ~= "severed" then
    affs.limb("right", "arm", "healthy")
  end
end

function nc.apply_mending_to_head()
  affs.del{"broken_jaw", "fractured_head", "slit_throat", "mending_head"}
end

function nc.apply_mending_to_legs()
  affs.del{"twisted_leftleg", "twisted_rightleg", "mending_legs"}
  local lleg = affs.limb("left", "leg")
  local rleg = affs.limb("right", "leg")
  if lleg ~= "mangled" and lleg ~= "severed" then
    affs.limb("left", "leg", "healthy")
  end
  if rleg ~= "mangled" and rleg ~= "severed" then
    affs.limb("right", "leg", "healthy")
  end
end

function nc.apply_regeneration_to_arms()
  local larm = affs.limb("left", "arm")
  local rarm = affs.limb("right", "arm")
  if larm == "severed" or larm == "mangled" then
    affs.limb("left", "arm", "broken")
  elseif rarm == "severed" or rarm == "mangled" then
    affs.limb("right", "arm", "broken")
  end
  affs.del{"elbow_left", "elbow_right", "nerve_left", "nerve_right", "regen_arms"}
  flags.clear("regenerating_arms")
end

function nc.apply_regeneration_to_chest()
  affs.del{"chest_pain", "collapsed_lungs", "crushed_chest", "regen_chest"}
  flags.clear("regenerating_chest")
end

function nc.apply_regeneration_to_gut()
  affs.del{"burst_organs", "disemboweled", "ruptured_gut", "severed_spine", "regen_gut"}
  flags.clear("regenerating_gut")
end

function nc.apply_regeneration_to_head()
  affs.del{"concussion", "damaged_head", "losteye_left", "losteye_right", "shattered_jaw",
            "regen_head"}
  flags.clear("regenerating_head")
end

function nc.apply_regeneration_to_legs()
  local lleg = affs.limb("left", "leg")
  local rleg = affs.limb("right", "leg")
  if lleg == "severed" or lleg == "mangled" then
    affs.limb("left", "leg", "broken")
  elseif rleg == "severed" or rleg == "mangled" then
    affs.limb("right", "leg", "broken")
  end
  affs.del{"ankle_left", "ankle_right", "kneecap_left", "kneecap_right", "tendon_left",
            "tendon_right", "regen_legs"}
  flags.clear("regenerating_legs")
end

function nc.eat_calamus()
  affs.del{"slickness", "calamus"}
end

function nc.eat_chervil()
  affs.del{"bleeding", "chervil"}
end

function nc.eat_earwort()
  defs.add("truehearing")
  affs.del("earwort")
end

function nc.eat_faeleaf()
  defs.add("sixthsense")
  affs.del("faeleaf")
end

function nc.eat_galingale()
  affs.del{"addiction", "gluttony", "lovers", "galingale"}
end

function nc.eat_horehound()
  affs.del{"achromatic", "bedeviled", "dissonance", "ego_vice", "healthleech", "manabarbs", "power_spikes",
           "recklessness", "horehound", "timewarp"}
end

function nc.eat_kafe()
  affs.del{"daydreams", "narcolepsy", "kafe"}
end

function nc.eat_kombu()
  affs.del{"clumsiness", "deadening", "dizziness", "epilepsy", "hidden_kombu", "omniphobia", "southwind",
           "vapors", "violetvibrato", "kombu"}
end

function nc.eat_marjoram()
  affs.del{"bicep_left", "bicep_right", "dislocated_leftarm", "dislocated_leftleg", "dislocated_rightarm",
           "dislocated_rightleg", "gashed_cheek", "lostear_left", "lostear_right", "punctured_chest", "rigormortis",
           "sliced_chest", "sliced_gut", "sliced_tongue", "thigh_left", "thigh_right", "weakness", "marjoram"}

  for _,part in ipairs{"chest", "gut", "head", "leftarm", "rightarm"} do
    if not affs.is_ootangk(part) then
      affs.del("stiff_" .. part)
    end
  end
end

function nc.eat_merbloom()
  flags.clear("scanned_no_insomnia")
  defs.add("insomnia")
  affs.del("merbloom")
end

function nc.eat_myrtle()
  affs.del{"concussion", "eroee_ray", "sensitivity", "vertigo", "myrtle"}

  if affs.has("blindness") then
    defs.add("sixthsense")
    affs.del("blindness")
  end
  if affs.has("deafness") then
    defs.add("truehearing")
    affs.del("deafness")
  end
end

function nc.eat_pennyroyal()
  affs.del{"avengingangel", "baalphegar", "confusion", "crowcaw", "dark", "dementia",
           "disoriented", "hallucinations", "insanity", "japhiel", "moon_ray", "moon_tarot",
           "paranoia", "pennyroyal", "purplehaze", "scrambled", "sidiak_ray", "spores",
           "stupidity", "time_echo", "void"}
end

function nc.eat_reishi()
  if affs.has("succumbing") then
    flags.set("curing_succumb", true, 4)
    failsafe.exec("succumbing", 3)
  end
  affs.del{"aeon", "aurawarp", "justice", "lightheaded", "pacifism", "peace", "powersink",
           "reishi"}
  if not affs.is_mental() then
    affs.del("jinx")
  end
end

failsafe.fn.succumbing = function ()
  if affs.has("succumbing") and flags.get("curing_succumb") then
    affs.del("succumbing")
    flags.clear("curing_succumb")
  end
end

function nc.eat_wormwood()
  affs.del{"agoraphobia", "claustrophobia", "hidden_oracle", "hypochondria", "vestiphobia",
           "wormwood"}
end

function nc.eat_yarrow()
  affs.del{"artery_head", "artery_leftarm", "artery_leftleg", "artery_rightarm", "artery_rightleg",
           "clot_leftarm", "clot_leftleg", "clot_rightarm", "clot_rightleg", "clot_unknown",
           "lacerated_leftarm", "lacerated_leftleg", "lacerated_rightarm", "lacerated_rightleg",
           "hemophilia", "lethargy", "relapsing", "slit_throat", "yarrow"}
end

function nc.focus_body()
  affs.del{"leg_locked", "paralysis", "throat_locked", "focus_body"}
end

function nc.focus_mind()
  affs.del{"addiction", "agoraphobia", "ancestralcurse", "anorexia", "claustrophobia", "confusion", "crone",
           "disoriented", "dissonance", "dizziness", "epilepsy", "fear", "hallucinations", "hidden_mental",
           "impatience", "loneliness", "lovers", "masochism", "pacifism", "paranoia", "reality", "recklessness",
           "shyness", "sidiak_ray", "stupidity", "telepathy", "vertigo", "vestiphobia", "void", "weakness",
           "focus_mind", "insanity", "timewarp"}
end

function nc.focus_spirit()
  if flags.get("focus_spirit") then
    flags.clear("focus_spirit")
    affs.del{"achromatic", "binah_sphere", "darkmoon", "ego_curse", "ego_vice", "health_curse",
             "illuminated", "infidel", "inquisition", "lightheaded", "mana_curse", "manabarbs", "omen",
             "power_spikes", "taint_sick", "treebane", "focus_spirit"}
  else
    flags.set("focus_spirit", true, 15)
    affs.del("focus_spirit")
  end
end

function nc.holylight()
  nc.sip_allheale()
end

function nc.phial()
  nc.sip_allheale()
end

function nc.point_ignite_at_me()
  affs.del{"thorns_head", "thorns_leftarm", "thorns_leftleg", "thorns_rightarm", "thorns_rightleg"}
end

function nc.rub_focus()
  affs.del{"debate_circuitous", "debate_hurry", "debate_loophole", "focus"}
end

function nc.sip_allheale()
  affs.del{"ablaze", "achromatic", "addiction", "aeon", "agoraphobia", "ankle_left", "ankle_right",
           "anorexia", "artery_head", "asthma", "aurawarp", "bedeviled", "bicep_left",
           "bicep_right", "black_lung", "broken_jaw", "broken_nose", "broken_chest",
           "broken_leftwrist", "broken_rightwrist", "chest_pain", "claustrophobia", "clumsiness",
           "concussion", "confusion", "crotamine", "crushed_chest", "crushed_windpipe",
           "daydreams", "deadening", "dementia", "dislocated_leftarm", "dislocated_leftleg",
           "dislocated_rightarm", "dislocated_rightleg", "dissonance", "dizziness", "dysentery",
           "ego_vice", "enfeebled", "epilepsy", "fear", "foot_left", "foot_right",
           "fractured_leftarm", "fractured_rightarm", "fractured_head", "frozen", "furrowed_brow",
           "gashed_cheek", "gluttony", "generosity", "hallucinations", "healthleech", "hemiplegy",
           "hemiplegy_left", "hemiplegy_legs", "hemiplegy_right", "hemophilia", "hypersomnia",
           "hypochondria", "impatience", "jinx", "justice", "kneecap_left", "kneecap_right",
           "lacerated_leftarm", "lacerated_leftleg", "lacerated_rightarm", "lacerated_rightleg",
           "leg_locked", "lethargy", "lightheaded", "lostear_left", "lostear_right",
           "lovers", "manabarbs", "masochism", "narcolepsy", "nerve_left", "nerve_right",
           "numb_chest", "numb_gut", "numb_head", "numb_leftarm", "numb_leftleg", "numb_rightarm",
           "numb_rightleg", "omniphobia", "pacifism", "paralysis", "paranoia", "peace",
           "phrenic_nerve", "pierced_leftarm", "pierced_leftleg", "pierced_rightarm",
           "pierced_rightleg", "powersap", "powersink", "power_spikes", "pox", "punctured_chest",
           "recklessness", "relapsing", "rigormortis", "ruptured_gut", "scabies", "scalped",
           "scrambled", "sensitivity", "severed_spine", "shattered_jaw", "shivering",
           "short_breath", "shyness", "sliced_chest", "sliced_gut", "slickness", "slit_throat",
           "snapped_rib", "stupidity", "sunallergy", "thigh_left", "thigh_right", "throat_locked",
           "trembling", "twisted_leftarm", "twisted_leftleg", "twisted_rightarm",
           "twisted_rightleg", "unconscious", "unknown", "vapors", "vertigo", "vestiphobia",
           "void", "vomiting", "vomiting_blood", "weakness", "worms", "allheale"}

  if affs.limb("left", "arm") == "broken" then
    affs.limb("left", "arm", "healthy")
  end
  if affs.limb("right", "arm") == "broken" then
    affs.limb("right", "arm", "healthy")
  end
  if affs.limb("left", "leg") == "broken" then
    affs.limb("left", "leg", "healthy")
  end
  if affs.limb("right", "leg") == "broken" then
    affs.limb("right", "leg", "healthy")
  end

  if affs.has("punctured_lung") and
     not affs.has("collapsed_lungs") then
    affs.del("punctured_lung")
  end

  for _,part in ipairs{"chest", "gut", "head", "leftarm", "rightarm"} do
    if not affs.is_ootangk(part) then
      affs.del("stiff_" .. part)
    end
  end
end

function nc.sip_antidote()
  affs.del{"crotamine", "powersap", "antidote"}
end

function nc.sip_choleric()
  affs.del{"dysentery", "hypersomnia", "love", "vomiting", "vomiting_blood", "worms",
           "choleric"}
end

function nc.sip_fire()
  affs.del{"shivering", "frozen", "fire"}
  defs.add("fire")
end

function nc.sip_frost()
  affs.del{"ablaze", "frost"}
  defs.add("frost")
end

function nc.sip_galvanism()
  defs.add("galvanism")
  affs.del("galvanism")
end

function nc.sip_love()
  affs.add_queue("love")
end

function nc.sip_phlegmatic()
  affs.del{"aeon", "generosity", "powersink", "shyness", "weakness", "phlegmatic"}
end

function nc.sip_sanguine()
  affs.del{"confusion", "disoriented", "furrowed_brow", "healthleech", "hemophilia",
           "lethargy", "scalped", "sanguine"}
end

function nc.sip_health()
end

function nc.sip_mana()
end

function nc.sip_bromide()
end

function nc.smoke_coltsfoot()
  affs.del{"anorexia", "impatience", "loneliness", "masochism", "shyness", "smoke_coltsfoot"}
end

function nc.smoke_faeleaf()
  affs.del("coils")
end

function nc.smoke_myrtle()
  affs.del("smoke_myrtle")
  if affs.has("phrenic_nerve") then
    if (flags.get("phrenic_smoke") or 0) > 2 then
      affs.del("phrenic_nerve")
      flags.clear("phrenic_smoke")
    end
    flags.clear("herb_try")
    bals.gain("herb")
  else
    affs.del{"crushed_windpipe", "hemiplegy", "pierced_leftarm", "pierced_leftleg", "pierced_rightarm", "pierced_rightleg"}
    if not affs.has("nerve_left") then
      affs.del("hemiplegy_left")
    end
    if not affs.has("nerve_right") then
      affs.del("hemiplegy_right")
    end
  end
end

function nc.totem()
  nc.sip_allheale()
end

function nc.writhe()
  writhe()
end

function nc.writhe_clamp()
  writhe("clamp")
end

function nc.writhe_entangle()
  writhe("entangle")
end

function nc.writhe_grapple()
  writhe("grapple")
end

function nc.writhe_hoist()
  writhe("hoist")
end

function nc.writhe_ropes()
  writhe("ropes")
end

function nc.writhe_shackles()
  writhe("shackles")
end

function nc.writhe_transfix()
  writhe("transfix")
end

function nc.writhe_truss()
  writhe("truss")
end

function nc.writhe_vines()
  writhe("vines")
end

function nc.writhe_impale()
  writhe("impale")
end

function nc.beast_body()
  affs.del{"broken_chest", "broken_nose", "fractured_leftarm", "fractured_rightarm", "snapped_rib"}
end

function nc.beast_mind()
  nc.focus_mind()
end

function nc.beast_spirit()
  nc.eat_horehound()
  nc.eat_reishi()
end

function nc.exalt_aura()
  nc.sip_allheale()
end

function nc.invoke_green()
  nc.sip_allheale()
end

function nc.moon_full()
  nc.sip_allheale()
end

function nc.evoke_gedulah()
  nc.sip_allheale()
end

function nc.harmonics_mendingstone()
  nc.sip_allheale()
end

function nc.harmonics_emerald()
  nc.sip_allheale()
end

function nc.shrine()
  nc.sip_allheale()
end

function nc.westwind()
  nc.sip_allheale()
end


DeleteTrigger("cure_thorns_ignited__")
DeleteTrigger("cure_deadened__")