module (..., package.seeall)

update = true

local multi = {}

prio_standard = {
  "asleep",
  "p5_tumble",
  "tumble",
  "sap",
  "impale_gut",
  "impale_antlers",
  "crucified",
  "pinned_left",
  "pinned_right",
  "power_cure",
  "prone",
  "sitting",
  "kneeling",
  {"chest_pain", "prone"},

  {"stance_left", "in_pit"},
  {"stance_right", "in_pit"},
  {"stance_arms", "in_pit"},
  {"stance_chest", "in_pit"},
  {"stance_head", "in_pit"},
  {"stance_middle", "in_pit"},
  {"stance_upper", "in_pit"},
  {"stance_vitals", "in_pit"},
  {"parry", "in_pit"},
  "in_pit",

  "shield_up",
  "ectoplasm",
  "thorns_head",
  "thorns_leftarm",
  "thorns_rightarm",
  "thorns_leftleg",
  "thorns_rightleg",
  "thorns_ignite",
  "gunk",
  "muddy",
  "debate_hurry",
  "debate_circuitous",
  "debate_loophole",
  "no_metawake",

  "paralysis",
  "throat_locked",
  "leg_locked",

  {"anorexia", "jinx"},
  {"void", "jinx"},
  {"stupidity", "jinx"},
  {"impatience", "jinx"},
  {"scrambled", "jinx"},
  {"lovers", "jinx"},
  {"epilepsy", "jinx"},
  {"addiction", "jinx"},
  {"hallucinations", "jinx"},
  {"masochism", "jinx"},
  {"dementia", "jinx"},
  {"gluttony", "jinx"},
  {"loneliness", "jinx"},
  {"paranoia", "jinx"},
  {"confusion", "jinx"},
  {"shyness", "jinx"},
  {"hypersomnia", "jinx"},

  "anorexia",
  "crushed_windpipe",
  "void",
  "jinx",
  "stupidity",
  "deathsong",
  "chest_pain",
  "disemboweled",
  "burst_organs",
  "slit_throat",
  "concussion",
  {"severed_leg", "prone"},
  {"mangled_leg", "prone"},
  "asthma",
  "severed_spine",
  "fractured_head",
  "coils_10",
  "coils_9",
  "coils_8",
  "coils_7",
  "coils_6",
  "coils_5",
  "slickness",
  "recklessness",
  "impatience",
  {"hemiplegy_legs", "prone"},
  {"hemiplegy_left", "prone"},
  {"hemiplegy_right", "prone"},
  "insanity_5",
  "timewarp_5",
  "insanity_4",
  "timewarp_4",
  "blindness",
  "power_spikes",
  "clot_unknown",
  "clot_leftarm",
  "clot_rightarm",
  "clot_leftleg",
  "clot_rightleg",
  "scrambled",
  "stiff_gut",
  "manabarbs",
  "no_kafe",
  "no_insomnia",
  "peace",
  "pacifism",
  "lovers",
  "ego_vice",
  "no_truehearing",
  "succumbing",
  "bedeviled",
  "aurawarp",
  "epilepsy",
  "gashed_cheek",
  "punctured_chest",
  "omniphobia",
  "stiff_head",
  "phrenic_nerve",
  "hemiplegy",
  "hemiplegy_left",
  "hemiplegy_right",
  "relapsing",
  "vestiphobia",
  "stiff_chest",
  "addiction",
  "narcolepsy",
  "timewarp_3",
  "insanity_3",
  "hypochondria",
  "thigh_left",
  "thigh_right",
  "rigormortis",
  "deadening",
  "violetvibrato",
  "hidden_kombu",
  "lightheaded",
  "hemiplegy_legs",
  "coils_4",
  "coils_3",
  {"pierced_leftleg", "sprawled"},
  {"pierced_rightleg", "sprawled"},
  "coils_2",
  "coils_1",
  "timewarp_2",
  "insanity_2",
  "insanity_1",
  "timewarp_1",
  "dislocated_leftleg",
  "dislocated_rightleg",
  "dislocated_leftarm",
  "dislocated_rightarm",
  "hallucinations",
  "spores",
  "baalphegar",
  "japhiel",
  "stiff_leftarm",
  "stiff_rightarm",
  "lostear_left",
  "lostear_right",
  "pierced_leftleg",
  "pierced_rightleg",
  "sensitivity",
  "achromatic",
  "dementia",
  "masochism",
  "vapors",
  "clumsiness",
  "southwind",
  "sliced_chest",
  "lacerated_leftleg",
  "lacerated_rightleg",
  "lacerated_leftarm",
  "lacerated_rightarm",
  "sliced_gut",
  "artery_head",
  "artery_leftleg",
  "artery_rightleg",
  "artery_leftarm",
  "artery_rightarm",
  "broken_nose",
  "pierced_leftarm",
  "pierced_rightarm",
  "snapped_rib",
  "broken_chest",
  "foot_left",
  "foot_right",
  "gluttony",
  "justice",
  "loneliness",
  "agoraphobia",
  "claustrophobia",
  "vertigo",
  "hidden_oracle",
  "paranoia",
  "hemophilia",
  "confusion",
  "avengingangel",
  "dark",
  "crowcaw",
  "moon_ray",
  "moon_tarot",
  "disoriented",
  "time_echo",
  "sidiak_ray",
  "purplehaze",
  "shyness",
  "telepathy",
  "ancestralcurse",
  "reality",
  "hidden_heretic",
  "crone",
  "weakness",
  "healthleech",
  "no_sixthsense",
  "fractured_leftarm",
  "fractured_rightarm",
  "bicep_left",
  "bicep_right",
  "deafness",
  "sliced_tongue",
  "bleeding_clot",
  "bleeding_chervil",
  "crotamine",
  "aeon",
  "scalped",
  "frozen",
  "powersap",
  "furrowed_brow",
  "dysentery",
  "shivering",
  "hypersomnia",
  "vomiting_blood",
  "vomiting",
  "ablaze",
  "repugnance",
  "no_fire",
  "no_frost",
  "worms",
  "no_love",
  "love",
  "no_speed",
  "enfeebled",
  "no_moonwater",
  "no_tea",

  "stance_legs",
  "stance_left",
  "stance_right",
  "stance_arms",
  "stance_gut",
  "stance_chest",
  "stance_head",
  "stance_lower",
  "stance_middle",
  "stance_upper",
  "stance_vitals",

  "fear",
  "disrupted",
  "fastwrithe",
  "no_rebounding",

  "beast_health",
  "beast_mana",
  "beast_ego",
  "scroll_heal",
  "sparkleberry",

  "health_low",
  "wounded_head_2500",
  "wounded_head_2000",
  "mana_low",
  "burst_vessels_12",
  "burst_vessels_11",
  "burst_vessels_10",
  "burst_vessels_9",
  "ego_low",
  "wounded_head_1500",
  "wounded_legs_2500",
  "wounded_gut_2500",
  "wounded_chest_2500",
  "wounded_arms_2500",
  "wounded_legs_2000",
  "wounded_gut_2000",
  "wounded_chest_2000",
  "wounded_arms_2000",
  "health_mid",
  "wounded_legs_1500",
  "wounded_gut_1500",
  "wounded_chest_1500",
  "wounded_arms_1500",
  "wounded_head_900",
  "wounded_legs_900",
  "wounded_gut_900",
  "wounded_chest_900",
  "wounded_arms_900",
  "mana_mid",
  "ego_mid",
  "health_high",
  "burst_vessels_8",
  "burst_vessels_7",
  "burst_vessels_6",
  "burst_vessels_5",
  "burst_vessels_4",
  "burst_vessels_3",
  "burst_vessels_2",
  "burst_vessels_1",
  "mana_high",
  "ego_high",
  "wounded_head_300",
  "wounded_legs_300",
  "wounded_chest_300",
  "wounded_gut_300",
  "wounded_arms_300",
  "numb_leftleg",
  "numb_rightleg",
  "numb_head",
  "numb_leftarm",
  "numb_rightarm",
  "numb_chest",
  "numb_gut",
  "wounded_head_1",
  "wounded_legs_1",
  "wounded_chest_1",
  "wounded_gut_1",
  "wounded_arms_1",

  "dissonance",
  "lethargy",

  "scabies",
  "itch",
  "punctured_lung",
  "severed_leg",
  "burns_fourth",
  "nerve_left",
  "nerve_right",
  "kneecap_left",
  "kneecap_right",
  "short_breath",
  "mangled_leg",
  {"ankle_left", "prone"},
  {"ankle_right", "prone"},
  "tendon_left",
  "tendon_right",
  {"broken_leg", "prone"},
  "severed_arm",
  "twisted_leftleg",
  "twisted_rightleg",
  "burns_third",
  "burns_second",
  "black_lung",
  "crushed_chest",
  "collapsed_lungs",
  "ruptured_gut",
  "mangled_arm",
  "eroee_ray",
  "twisted_leftarm",
  "twisted_rightarm",
  "broken_arm",
  "elbow_left",
  "elbow_right",
  "broken_leftwrist",
  "broken_rightwrist",
  "ankle_left",
  "ankle_right",
  "losteye_left",
  "losteye_right",
  "broken_leg",
  "sunallergy",
  "burns_first",
  "trembling",
  "pox",
  "shattered_jaw",
  "broken_jaw",
  "damaged_head2",
  "damaged_head",
  "commanded_store",
  "commanded_remove",
  "daydreams",
  "dizziness",

  "shackled",
  "entangled",
  "trussed",
  "roped",
  "hoisted",
  "transfixed",
  "clamped_left",
  "clamped_right",
  "grappled",

  -- Generic actions not tied to a specific affliction
  "focus",
  "cleanse",
  "diagnose",

  "phlegmatic",
  "choleric",
  "sanguine",
  "antidote",
  "fire",
  "frost",

  "focus_body",
  "focus_mind",
  "focus_spirit",

  "pennyroyal",
  "kombu",
  "galingale",
  "horehound",
  "smoke_myrtle",
  "arnica_arms",
  "arnica_legs",
  "arnica_head",
  "arnica_chest",
  "calamus",
  "marjoram",
  "merbloom",
  "reishi",
  "wormwood",
  "yarrow",
  "smoke_coltsfoot",
  "earwort",
  "faeleaf",
  "kafe",
  "myrtle",
  "smoke_faeleaf",
  "insanity",
  "timewarp",

  "writhe",

  "regen_head",
  "regen_legs",
  "regen_gut",
  "regen_chest",
  "regen_arms",
  "melancholic_head",
  "melancholic_chest",
  "mending_legs",
  "mending_arms",
  "mending_head",
  "liniment",

  "chervil",

  "fill_coltsfoot",
  "fill_faeleaf",
  "fill_myrtle",
  "unlit_pipes",

  "mindset",

  "defup_free",
  "defup_bal",
  "defup_elixir",
  "defup_herb",
  "defup_sub",
  "defup_super",
  "defup_id",

  "rewield",
  "todo",

  "parry",

  "blackout",
  "no_selfish",
  "undo_metawake",
  "undo_selfish",
  "hold_breath",
}

prio_aeon = {
  "asleep",
  "diagnose",
  "aeon",
  "crucified",

  "crushed_windpipe",
  {"fill_myrtle", "crushed_windpipe", "slickness"},
  "slit_throat",
  "throat_locked",

  "anorexia",
  {"impatience", "anorexia", "fill_coltsfoot"},

  {"asthma", "anorexia"},
  {"slickness", "asthma"},

  {"impatience", "anorexia", "slickness"},

  {"insanity_5", "anorexia", "asthma", "slickness"},
  {"insanity_4", "anorexia", "asthma", "slickness"},
  {"insanity_3", "anorexia", "asthma", "slickness"},
  {"insanity_2", "anorexia", "asthma", "slickness"},
  {"insanity_1", "anorexia", "asthma", "slickness"},

  {"timewarp_5", "anorexia", "asthma", "slickness"},
  {"timewarp_4", "anorexia", "asthma", "slickness"},
  {"timewarp_3", "anorexia", "asthma", "slickness"},
  {"timewarp_2", "anorexia", "asthma", "slickness"},
  {"timewarp_1", "anorexia", "asthma", "slickness"},

  {"impatience", "anorexia", "asthma"},
  "fill_coltsfoot",
  "fill_myrtle",

  "mana_high",
  "mana_mid",
}

prio_sap = 
{
  "asleep",
  "diagnose",
  "sap",
  "crucified",
  {"confusion", "disrupted"},
  "disrupted",

  "impale_antlers",
  "shackled",
  "entangled",
  "trussed",
  "roped",
  "transfixed",

  {"impatience", "paralysis"},

  {"anorexia", "asthma", "slickness", "severed_spine"},
  {"anorexia", "asthma", "slickness", "severed_leg", "prone"},
  {"anorexia", "asthma", "slickness", "nerve_left", "prone"},
  {"anorexia", "asthma", "slickness", "nerve_right", "prone"},
  {"anorexia", "asthma", "slickness", "mangled_leg", "prone"},
  {"anorexia", "asthma", "slickness", "ankle_left", "prone"},
  {"anorexia", "asthma", "slickness", "ankle_right", "prone"},
  {"anorexia", "asthma", "slickness", "tendon_left"},
  {"anorexia", "asthma", "slickness", "tendon_right"},
  {"anorexia", "asthma", "slickness", "collapsed_lungs", "hemiplegy", "prone"},
  {"anorexia", "asthma", "slickness", "collapsed_lungs", "hemiplegy_left", "prone"},
  {"anorexia", "asthma", "slickness", "collapsed_lungs", "hemiplegy_right", "prone"},
  {"anorexia", "asthma", "slickness", "collapsed_lungs", "hemiplegy_legs", "prone"},
  {"anorexia", "asthma", "slickness", "asthma", "hemiplegy", "prone"},
  {"anorexia", "asthma", "slickness", "asthma", "hemiplegy_left", "prone"},
  {"anorexia", "asthma", "slickness", "asthma", "hemiplegy_right", "prone"},
  {"anorexia", "asthma", "slickness", "asthma", "hemiplegy_legs", "prone"},
  {"anorexia", "asthma", "slickness", "broken_leg", "prone"},

  {"anorexia", "collapsed_lungs", "slickness", "severed_spine"},
  {"anorexia", "collapsed_lungs", "slickness", "severed_leg", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "nerve_left", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "nerve_right", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "mangled_leg", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "ankle_left", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "ankle_right", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "tendon_left"},
  {"anorexia", "collapsed_lungs", "slickness", "tendon_right"},
  {"anorexia", "collapsed_lungs", "slickness", "collapsed_lungs", "hemiplegy", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "collapsed_lungs", "hemiplegy_left", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "collapsed_lungs", "hemiplegy_right", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "collapsed_lungs", "hemiplegy_legs", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "asthma", "hemiplegy", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "asthma", "hemiplegy_left", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "asthma", "hemiplegy_right", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "asthma", "hemiplegy_legs", "prone"},
  {"anorexia", "collapsed_lungs", "slickness", "broken_leg", "prone"},

  "paralysis",
  {"leglock", "prone"},

  {"slickness", "severed_spine"},
  {"slickness", "severed_leg", "prone"},
  {"slickness", "nerve_left", "prone"},
  {"slickness", "nerve_right", "prone"},
  {"slickness", "mangled_leg", "prone"},
  {"slickness", "ankle_left", "prone"},
  {"slickness", "ankle_right", "prone"},
  {"slickness", "tendon_left"},
  {"slickness", "tendon_right"},
  {"slickness", "collapsed_lungs", "hemiplegy", "prone"},
  {"slickness", "collapsed_lungs", "hemiplegy_left", "prone"},
  {"slickness", "collapsed_lungs", "hemiplegy_right", "prone"},
  {"slickness", "collapsed_lungs", "hemiplegy_legs", "prone"},
  {"slickness", "asthma", "hemiplegy", "prone"},
  {"slickness", "asthma", "hemiplegy_left", "prone"},
  {"slickness", "asthma", "hemiplegy_right", "prone"},
  {"slickness", "asthma", "hemiplegy_legs", "prone"},
  {"slickness", "broken_leg", "prone"},

  "severed_spine",
  {"severed_leg", "prone"},
  {"nerve_left", "prone"},
  {"nerve_right", "prone"},
  {"mangled_leg", "prone"},
  {"ankle_left", "prone"},
  {"ankle_right", "prone"},
  "tendon_left",
  "tendon_right",

  {"collapsed_lungs", "hemiplegy", "prone"},
  {"collapsed_lungs", "hemiplegy_left", "prone"},
  {"collapsed_lungs", "hemiplegy_right", "prone"},
  {"collapsed_lungs", "hemiplegy_legs", "prone"},
  {"asthma", "hemiplegy", "prone"},
  {"asthma", "hemiplegy_left", "prone"},
  {"asthma", "hemiplegy_right", "prone"},
  {"asthma", "hemiplegy_legs", "prone"},

  {"fill_myrtle", "hemiplegy", "prone"},
  {"fill_myrtle", "hemiplegy_left", "prone"},
  {"fill_myrtle", "hemiplegy_right", "prone"},
  {"fill_myrtle", "hemiplegy_legs", "prone"},

  {"hemiplegy", "prone"},
  {"hemiplegy_left", "prone"},
  {"hemiplegy_right", "prone"},
  {"hemiplegy_legs", "prone"},

  {"broken_leg", "prone"},

  {"throat_locked", "slickness", "prone"},
  {"anorexia", "slickness", "prone"},

  "prone",

  "severed_leg",
  "nerve_left",
  "nerve_right",
  "mangled_leg",
  "ankle_left",
  "ankle_right",
  "broken_leg",

  {"asthma", "impatience"},
  "impatience",

  {"insanity_5", "anorexia", "asthma", "slickness"},
  {"insanity_4", "anorexia", "asthma", "slickness"},
  {"insanity_3", "anorexia", "asthma", "slickness"},
  {"insanity_2", "anorexia", "asthma", "slickness"},
  {"insanity_1", "anorexia", "asthma", "slickness"},

  {"timewarp_5", "anorexia", "asthma", "slickness"},
  {"timewarp_4", "anorexia", "asthma", "slickness"},
  {"timewarp_3", "anorexia", "asthma", "slickness"},
  {"timewarp_2", "anorexia", "asthma", "slickness"},
  {"timewarp_1", "anorexia", "asthma", "slickness"},

--  "scabies",
--  "epilepsy",
  "daydreams",
  "black_lung",
  "shivering",
  "dysentry",
--  "hallucinations",
  "narcolepsy",

  "crotamine",
  "hypochondria",

  "health_high",
  "mana_high",
  "ego_high",

  "health_mid",
  "mana_mid",
  "ego_mid",

  "pierced_leftleg",
  "pierced_rightleg",

  "fill_coltsfoot",
}


local function go_cure(aff, c)
  local c = c or cures.get(aff)
  if not c then
    display.Error("Unknown affliction cannot be cured: " .. tostring(aff))
    return true
  end

  if (is_curing(aff) and not multi[aff]) or affs.ignoring(aff) then
    return false
  end

  if type(c) == "table" then
    for _,cc in ipairs(c) do
      if go_cure(aff, cc) then
        return true
      end
    end
    return false
  end

  display.Debug("  check '" .. aff .. "' to cure with '" .. c .. "' [able = " .. tostring(able.to(c)) .. ", scanned = " .. tostring(flags.get("scanned_" .. aff)) .. ", multi = " .. tostring(multi[aff]) .. "]", "scan")
  if able.to(c) then
    display.Debug("  cure '" .. aff .. "' with '" .. c .. "'", "scan")
    Execute(c)
    is_curing(aff, c)

    if affs.slow() then
      flags.set("slow_sent", c, 1.5)
    end

    return true
  end

  return false
end


local function cure_by_priority(plist)
  if not plist or #plist < 1 then
    display.Error("No priority healing list configured")
    return
  end

  local meta_affs = meta()

  for _,aff in ipairs(plist) do
    if type(aff) == "table" then
      local cnt = 0
      for a in ipairs(aff) do
        if meta_affs[aff[a]] then
          cnt = cnt + 1
        end
      end
      if cnt == #aff then
        aff = aff[1]
      end
    end

    if meta_affs[aff] then
      go_cure(aff)
      if flags.get("slow_sent") or flags.get("slow_going") then
        return
      end
    end
  end
end


local function heal_beast(hdmg, mdmg, edmg, hmax, mmax, emax)
  if not bals.can_act() then
    return 0, 0, 0
  end

  local hbeast = hmax * tonumber(GetVariable("sg1_healing_beast_h") or "13") / 100
  local mbeast = mmax * tonumber(GetVariable("sg1_healing_beast_m") or "13") / 100
  local ebeast = emax * tonumber(GetVariable("sg1_healing_beast_e") or "13") / 100

  local heals = 850
--  display.Debug("Beast healing scan: H " .. hdmg .. "/" .. hbeast .. "  M " .. mdmg .. "/" .. mbeast .. "  E " .. edmg .. "/" .. ebeast, "scan")
  if main.auto("bhealth") and able.to("beast order heal health") and hdmg >= hbeast then
    return hmax * heals, 0, 0
  end
  if main.auto("bmana") and able.to("beast order heal mana") and mdmg >= mbeast then
    return 0, mmax * heals, 0
  end
  if main.auto("bego") and able.to("beast order heal ego") and edmg >= ebeast then
    return 0, 0, emax * heals
  end

  return 0, 0, 0
end


local function heal_scroll(hdmg, mdmg, edmg, hmax, mmax, emax)
  if not main.auto("scroll") or
     not able.to("read healing") then
    return 0, 0, 0
  end

  local hscroll = hmax * tonumber(GetVariable("sg1_healing_scroll_h") or "29") / 100
  local mscroll = mmax * tonumber(GetVariable("sg1_healing_scroll_m") or "31") / 100
  local escroll = emax * tonumber(GetVariable("sg1_healing_scroll_e") or "35") / 100

  local hwounds = wounds.get("heavy")
  for _,p in ipairs{"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
    if wounds.get(p) > hwounds then
      hscroll = hscroll * tonumber(GetVariable("sg1_healing_scroll_wounds") or "70") / 100
      mscroll = mscroll * tonumber(GetVariable("sg1_healing_scroll_wounds") or "70") / 100
      escroll = escroll * tonumber(GetVariable("sg1_healing_scroll_wounds") or "70") / 100
      break
    end
  end

  local heals = tonumber(GetVariable("sg1_healing_scroll_a") or "8") / 100
--  display.Debug("Scroll scan: H " .. hdmg .. "/" .. hscroll .. "  M " .. mdmg .. "/" .. mscroll .. "  E " .. edmg .. "/" .. escroll, "scan")
  if hdmg >= hscroll or
     mdmg >= mscroll or
     edmg >= escroll then
    return hmax * heals, mmax * heals, emax * heals
  end

  return 0, 0, 0
end

local function heal_sparkle(hdmg, mdmg, edmg, hmax, mmax, emax)
  if not main.auto("sparkle") or
     not able.to("eat sparkleberry") then
    return 0, 0, 0
  end

  local hsparkle = hmax * tonumber(GetVariable("sg1_healing_sparkle_h") or "30") / 100
  local msparkle = mmax * tonumber(GetVariable("sg1_healing_sparkle_m") or "30") / 100
  local esparkle = emax * tonumber(GetVariable("sg1_healing_sparkle_e") or "30") / 100

  local hwounds = wounds.get("heavy")
  for _,p in ipairs{"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"} do
    if wounds.get(p) > hwounds then
      hsparkle = hsparkle * tonumber(GetVariable("sg1_healing_sparkle_wounds") or "70") / 100
      msparkle = msparkle * tonumber(GetVariable("sg1_healing_sparkle_wounds") or "70") / 100
      esparkle = esparkle * tonumber(GetVariable("sg1_healing_sparkle_wounds") or "70") / 100
      break
    end
  end

  local heals = tonumber(GetVariable("sg1_healing_sparkle_a") or "13") / 100
--  display.Debug("Sparkle scan: H " .. hdmg .. "/" .. hsparkle .. "  M " .. mdmg .. "/" .. msparkle .. "  E " .. edmg .. "/" .. esparkle, "scan")
  local bv = affs.has("burst_vessels") or 0
  if hdmg >= hsparkle or
     mdmg >= msparkle or
     edmg >= esparkle or
     (bv > 0 and not affs.ignoring("burst_vessels_" .. bv)) then
    return hmax * heals, mmax * heals, emax * heals
  end

  return 0, 0, 0
end

local function heal_transmute(hdmg, hmax)
  if not main.auto("transmute") or
     not able.to("transmute") then
    return 0, 0
  end

  local htransmute = hmax * tonumber(GetVariable("sg1_healing_transmute") or "20") / 100
  if hdmg >= htransmute then
    local mtransmute = math.min(math.max(math.min(math.floor(hdmg / 0.85), 1000), 100), prompt.stat("mp") - 500)
    if mtransmute > 100 then
      Execute("transmute " .. mtransmute)
      return mtransmute / 0.85, -mtransmute
    end
  end

  return 0, 0
end

local function healing()
  local hmax = prompt.stat("maxhp")
  local mmax = prompt.stat("maxmp")
  local emax = prompt.stat("maxego")

  if hmax == 0 or mmax == 0 or emax == 0 then
    display.Debug("No HME max values set", "scan")
    return nil
  end

  local metas = {}

  local hdmg = math.max(hmax - prompt.stat("hp"), 0)
  local mdmg = math.max(mmax - prompt.stat("mp"), 0)
  local edmg = math.max(emax - prompt.stat("ego"), 0)

  local hadd, madd, eadd = heal_beast(hdmg, mdmg, edmg, hmax, mmax, emax)
  hdmg, mdmg, edmg = hdmg - hadd, mdmg - madd, edmg - eadd
  if hadd > 0 then
    metas["beast_health"] = true
  elseif madd > 0 then
    metas["beast_mana"] = true
  elseif eadd > 0 then
    metas["beast_ego"] = true
  end

  hadd, madd, eadd = heal_scroll(hdmg, mdmg, edmg, hmax, mmax, emax)
  hdmg, mdmg, edmg = hdmg - hadd, mdmg - madd, edmg - eadd
  if hadd > 0 then
    metas["scroll_heal"] = true
  end

  hadd, madd, eadd = heal_sparkle(hdmg, mdmg, edmg, hmax, mmax, emax)
  hdmg, mdmg, edmg = hdmg - hadd, mdmg - madd, edmg - eadd
  if hadd > 0 then
    metas["sparkleberry"] = true
  end

  hadd, madd = heal_transmute(hdmg, hmax)
  hdmg, mdmg = hdmg - hadd, mdmg - madd
  if hadd > 0 then
    metas["transmute"] = -madd
  end

  if not bals.get("health") or not main.auto("sipping") then
    return metas
  end

  local hsip = hmax * tonumber(GetVariable("sg1_healing_sip_h") or "15") / 100
  if able.to("touch medicinebag") then
    hsip = hsip * 1.5
  end
  if hdmg >= hsip * 3 then
    metas["health_low"] = true
  elseif hdmg >= hsip * 2 then
    metas["health_mid"] = true
  elseif hdmg >= hsip then
    metas["health_high"] = true
  end

  local msip = mmax * tonumber(GetVariable("sg1_healing_sip_m") or "15") / 100
  if mdmg >= msip * 3 then
    metas["mana_low"] = true
  elseif mdmg >= msip * 2 then
    metas["mana_mid"] = true
  elseif mdmg >= msip then
    metas["mana_high"] = true
  end

  local esip = emax * tonumber(GetVariable("sg1_healing_sip_e") or "15") / 100
  if edmg >= esip * 3 then
    metas["ego_low"] = true
  elseif edmg >= esip * 2 then
    metas["ego_mid"] = true
  elseif edmg >= esip then
    metas["ego_high"] = true
  end

  return metas
end


function process()
  if display.q or flags.get("slow_going") or flags.get("slow_sent") then
    return
  end

  display.Debug("Scanning personal status to decide next action...", "scan")

  if affs.has("aeon") then
    cure_by_priority(prio_aeon)
    display.Debug(" [aeon queue]", "scan")
  elseif affs.has("sap") then
    display.Debug(" [sap queue]", "scan")
    cure_by_priority(prio_sap)
  else
    cure_by_priority(prio_standard)
  end

  update = false
end


function is_curing(aff, c)
  if c then
    flags.set("scanned_" .. aff, c, 0.5)
  end
  return flags.get("scanned_" .. aff) ~= nil
end


function meta()
  local meta_affs = copytable.shallow(affs.mine())

  -- Defense
  for _,d in ipairs{"fire", "frost", "insomnia", "kafe", "moonwater",
                    "rebounding", "sixthsense", "speed", "tea", "truehearing"} do
    if main.auto(d) and not defs.has(d) then
      meta_affs["no_" .. d] = true
    end
  end
  for _,b in ipairs{"free", "bal", "herb", "elixir", "sub", "super", "id"} do
    if defs.wanted(b) > 0 and not flags.get("defs_" .. b) then
      meta_affs["defup_" .. b] = true
    end
  end
  for _,d in ipairs{"metawake", "selfish"} do
    if main.auto(d) and not defs.has(d) then
      meta_affs["no_" .. d] = true
    elseif not main.auto(d) and defs.has(d) then
      meta_affs["undo_" .. d] = true
    end
  end
  if main.auto("parry") and parry.check() then
    meta_affs.parry = true
  end
  if main.auto("stance") then
    local to_stance = stance.check()
    if to_stance then
      meta_affs["stance_" .. to_stance] = true
    end
  end
  if main.auto("lusting") then
    if not meta_affs.love then
      meta_affs.no_love = true
    else
      meta_affs.love = nil
    end
  end

  -- Curing
  local meta_heal = healing()
  for k,v in pairs(meta_heal or {}) do
    meta_affs[k] = v
  end
  local blood = meta_affs.bleeding or 0
  local chervil = 1
  meta_affs.bleeding = nil
  if main.auto("truehearing") and
     not defs.has("truehearing") and
     (os.clock() - (affs.has("earache") or os.clock())) >= 10 then
    chervil = 0.5
  end
  if blood >= tonumber(GetVariable("sg1_bleeding_chervil") or "150") * chervil then
    meta_affs.bleeding_chervil = true
  end
  if blood >= tonumber(GetVariable("sg1_bleeding_clot") or "20") then
    meta_affs.bleeding_clot = true
  end
  local bv = meta_affs.burst_vessels or 0
  if bv >= 12 then
    bv = 12
  end
  if bv > 0 then
    meta_affs["burst_vessels_" .. bv] = true
    meta_affs.burst_vessels = nil
  end
  if meta_affs.insanity then
    for i = 4,0,-1 do
      if meta_affs.insanity >= i * 10 then
        meta_affs["insanity_" .. (i + 1)] = true
        break
      end
    end
    meta_affs.insanity = nil
  end
  if meta_affs.timewarp then
    for i = 4,0,-1 do
      if affs.has("timewarp") >= i * 10 then
        meta_affs["timewarp_" .. (i + 1)] = true
        break
      end
    end
    meta_affs.timewarp = nil
  end
  if meta_affs.coils then
    for i = 10,1,-1 do
      if affs.has("coils") >= i then
        meta_affs["coils_" .. i] = true
        break
      end
    end
    meta_affs["coils"] = nil
  end
  local broken_limbs = 0
  if affs.limb("left", "arm") == "broken" then
    broken_limbs = broken_limbs + 1
  end
  if affs.limb("left", "leg") == "broken" then
    broken_limbs = broken_limbs + 1
  end
  if affs.limb("right", "arm") == "broken" then
    broken_limbs = broken_limbs + 1
  end
  if affs.limb("right", "leg") == "broken" then
    broken_limbs = broken_limbs + 1
  end
  if broken_limbs > 0 then
    meta_affs["broken_limbs" .. broken_limbs] = true
  end
  if (meta_affs.hemiplegy_left or meta_affs.hemiplegy_right or meta_affs.hemiplegy_legs or meta_affs.hemiplegy) and
     meta_affs.prone then
    meta_affs.hemi_prone = true
    meta_affs.hemiplegy = nil
    meta_affs.hemiplegy_left = nil
    meta_affs.hemiplegy_right = nil
    meta_affs.hemiplegy_legs = nil
  end
  local writhes = 0
  for _,w in ipairs{"entangled", "roped", "shackled", "trussed"} do
    if meta_affs[w] then
      writhes = writhes + 1
    end
  end
  if writhes >= tonumber(GetVariable("sg1_option_fastwrithe_n") or "2") or
     (writhes > 0 and meta_affs.ectoplasm) then
    meta_affs.fastwrithe = true
  end
  if prompt.stat("hp") > prompt.stat("maxhp") / 2 and
     magic.charges("ignite") > 1 then
    local thorns = 0
    local maxthorns = tonumber(GetVariable("sg1_option_thorns") or "3")
    for _,th in ipairs{"head", "leftarm", "leftleg", "rightarm", "rightleg"} do
      if affs.has("thorns_" .. th) then
        thorns = thorns + 1
      end
    end
    if maxthorns > 0 then
      if thorns > 0 then
        for _,th in ipairs{"head", "leftarm", "leftleg", "rightarm", "rightleg"} do
          meta_affs["thorns_" .. th] = nil
        end
      end
      if thorns >= maxthorns then
        meta_affs.thorns_ignite = true
      end
    end
  end
  if flags.get("deathsong") and
     not (defs.has("truehearing") or affs.has("deafness")) then
    meta_affs.deathsong = true
  end

  -- Non-curing
  if meta_affs.nerve_left then
    meta_affs.hemiplegy = nil
    meta_affs.hemiplegy_left = nil
  end
  if meta_affs.nerve_right then
    meta_affs.hemiplegy = nil
    meta_affs.hemiplegy_right = nil
  end
  for p in pairs(affs.grappled()) do
    if affs.is_ootangk(p) then
      meta_affs["stiff_" .. p] = nil
    end
    if affs.is_ninshi(p) then
      meta_affs["numb_" .. p] = nil
    end
  end
  if meta_affs.crushed_chest then
    meta_affs.broken_chest = nil
  end
  if meta_affs.jinx and affs.is_mental() then
    meta_affs.jinx = nil
  end
  if meta_affs.losteye_left and meta_affs.losteye_left then
    meta_affs.blindness = nil
  end
  if meta_affs.shattered_jaw then
    meta_affs.broken_jaw = nil
  end
  if flags.get("curing_succumb") then
    meta_affs.succumbing = nil
  end
  if meta_affs.aurawarp and
     flags.get("aurawarper") and
     enemy.is_shielded(string.lower(flags.get("aurawarper"))) ~= nil then
    meta_affs.aurawarp = nil
  end
  if meta_affs.bedeviled and flags.get("bedeviler") and
     enemy.is_shielded(string.lower(flags.get("bedeviler"))) ~= nil then
    meta_affs.bedeviled = nil
  end
  if (meta_affs.deathmarks or 0) < (tonumber(GetVariable("sg1_option_deathmarks") or "50")) then
    meta_affs.deathmarks = nil
  end

  -- Pipes
  for _,p in ipairs{"coltsfoot", "faeleaf", "myrtle"} do
    if pipes.puffs(p) < 1 then
      meta_affs["fill_" .. p] = true
    elseif not pipes.lit(p) and main.auto("pipes") then
      meta_affs.unlit_pipes = true
    end
  end

  -- Balance
  if todo.count() > 0 then
    meta_affs.todo = true
  end
  for _ in pairs(gear.rewield) do
    meta_affs.rewield = true
    break
  end
  if flags.get("tumble_dir") then
    if affs.has("perfect_fifth") then
      meta_affs.p5_tumble = true
    else
      meta_affs.tumble = true
    end
  end
  if map.elevation() == "pit" then
    meta_affs.in_pit = true
  end
  for _ in pairs(failsafe.items_unworn or {}) do
    meta_affs.commanded_remove = true
    break
  end
  for _ in pairs(failsafe.items_stored or {}) do
    meta_affs.commanded_store = true
    break
  end
  if flags.get("diagnose") then
    meta_affs.diagnose = true
  end
  if debate.new_mindset and main.auto("mindset") then
    meta_affs.mindset = true
  end
  if not able.to("apply eat smoke move") then
    meta_affs.power_cure = true
    meta_affs.slickness = nil
    meta_affs.asthma = nil
    meta_affs.paralysis = nil
    meta_affs.prone = nil
  end

  return meta_affs
end
