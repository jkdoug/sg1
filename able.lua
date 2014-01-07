module (..., package.seeall)

fn = {}


function generic()
  if affs.has("stunned") or
     affs.has("unconscious") or
     affs.has("bubble") or
     affs.has("statue") or
     affs.has("displacement") or
     affs.has("inquisition") or
     flags.get("slow_sent") or
     flags.get("slow_going") or
     main.is_paused() then
    return false
  end

  return true
end

function generic_spell()
  if not bals.can_act() or
     affs.is_prone() or
     affs.has("clamped_left") or
     affs.has("clamped_right") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.has("severed_spine") or
     affs.has("pierced_leftleg") or
     affs.has("pierced_rightleg") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" or
     (flags.get("writhe_try") and affs.is_impaled()) or
     flags.get("diag_try") then
    return false
  end

  return generic()
end

function power_spell(amt)
  if prompt.stat("pow") < amt then
    return false
  end

  return generic_spell()
end

function generic_beast(ab)
  if not bals.can_act() or
     not bals.get("beast") or
     (beast.locate() ~= "following" and
      beast.locate() ~= "mounted") or
     not beast.has_ability(ab) or
     affs.is_impaled() or
     affs.has("repugnance") or
     affs.has("asleep") then
    return false
  end

  return generic()
end

local function empty_pipe()
  if flags.get("emptying") or
     affs.has("asleep") then
    return false
  end

  return generic()
end

local function free_defense()
  if affs.has("asleep") then
    return false
  end

  return generic()
end

local function enchantment_balance(enchant)
  if magic.charges(enchant) <= 1 then
    return false
  end

  return generic_spell()  
end

local function enchantment_free(enchant)
  if magic.charges(enchant) < 1 then
    return false
  end

  return free_defense()
end

local function fill_pipe(herb)
  if flags.get("filling_" .. herb) or
     gear.inv(herb) < 1 then
    return false
  end

  if not bals.can_act() or
     affs.is_impaled() or
     affs.has("crucified") or
     affs.has("paralysis") or
     affs.has("asleep") or
     (affs.limb("left", "arm") ~= "healthy" and
      affs.limb("right", "arm") ~= "healthy") or
     (affs.has("hemiplegy_left") and
      affs.has("hemiplegy_right")) then
    return false
  end

  return generic()
end

local function performing()
  if not defs.has("performance") then
    return false
  end

  return generic_spell()
end

local function power_cure(amt)
  if flags.get("power_cure_try") or
     affs.has("crucified") or
     prompt.stat("pow") < amt or
     main.is_paused() or
     not bals.can_act() then
    return false
  end

  return true
end

local function read()
  if affs.has("asleep") or
     (affs.has("blindness") and
      not defs.has("sixthsense")) or
     (affs.has("losteye_left") and
      affs.has("losteye_right")) or
     affs.has("impale_gut") or
     affs.has("impale_antlers") or
     affs.has("pinned_left") or
     affs.has("pinned_right") then
    return false
  end

  return generic()
end

local function sip_purgative()
  if not bals.get("purgative") or
     affs.has("crucified") then
    return false
  end

  return fn.eat()
end

local function stance()
  if flags.get("stance_try") or
     flags.get("climb_try") or
     not bals.can_act() or
     affs.is_prone() or
     affs.has("kneecap_left") or
     affs.has("kneecap_right") or
     affs.is_impaled() or
     affs.has("transfixed") or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" then
    return false
  end

  return generic()
end

local function tumble()
  if (affs.has("perfect_fifth") and
      not (affs.has("deafness") or defs.has("truehearing"))) or
     not bals.can_act() or
     defs.has("mounted") or
     affs.limb("left", "leg") == "severed" or
     affs.limb("right", "leg") == "severed" or
     affs.limb("left", "arm") == "severed" or
     affs.limb("right", "arm") == "severed" or
     defs.has("flying") or
     affs.is_impaled() or
     map.elevation() == "pit" or
     not main.has_ability("environment", "tumbling") then
    return false
  end

  return generic()
end

local function medicinebag()
  local uses = tonumber(GetVariable("sg1_medbag") or "0")
  if uses <= 0 then
    return false
  end

  if not bals.get("health") or
     affs.has("asleep") or
     affs.is_impaled() or
     affs.has("severed_spine") or
     affs.has("paralysis") or
     affs.has("entangled") or
     affs.has("roped") or
     (affs.limb("left", "arm") ~= "healthy" and
      affs.limb("right", "arm") ~= "healthy") then
    return false
  end

  return generic()
end


function to(action, params)
  local result = false
  if not action or action == "" then
    result = generic()
  else
    action = string.gsub(action, " ", "_")
    local func = fn[action]
    if not func then
      display.Error("Missing 'able' method: " .. action)
      return generic()
    end

    result = func(params)
  end

  return result
end


function fn.apply_eat_smoke_move()
  if affs.has("crucified") then
    return false
  end

  local cant_apply = affs.has("slickness") or
                     (affs.limb("left", "arm") == "severed" and
                      affs.limb("right", "arm") == "severed")
  local cant_eat = affs.has("anorexia") or
                   affs.has("slit_throat") or
                   affs.has("throat_locked") or
                   affs.has("crushed_windpipe") or
                   (affs.limb("left", "arm") == "severed" and
                    affs.limb("right", "arm") == "severed")
  local cant_smoke = affs.has("asthma") or
                     affs.has("collapsed_lungs") or
                     affs.has("black_lung")
  local cant_move = (affs.has("paralysis") and
                     not able.to("focus body")) or
                    (affs.has("prone") and
                     not able.to("stand"))

  if cant_apply and cant_eat and cant_move then
    if cant_smoke and affs.has("anorexia") then
      return false
    elseif affs.has("slit_throat") or
           affs.has("crushed_windpipe") or
           affs.has("throat_locked") then
      return false
    end
  end

  return true
end


function fn.adrenaline()
  if affs.has("asleep") or
     not bals.can_act() or
     affs.has("paralysis") or
     flags.get("speed_try") or
     flags.get("waiting_for_speed") or
     flags.get("diag_try") or
     (affs.has("aeon") and
      gear.sips("phlegmatic") > 0 and
      able.to("eat")) or
     not main.has_ability("athletics", "adrenaline") then
    return false
  end

  return generic()
end

function fn.adroitness()
  if not main.has_ability("acrobatics", "adroitness") then
    return false
  end

  return generic()
end

function fn.aethercraft(cmd)
  if not main.has_ability("aethercraft", aethercraft.ab[cmd] or "clarionblast") or
     (flags.get("aether_cmd") and cmd ~= "grid modules") or
     (aethercraft.is_docked() and
      cmd ~= "grid join" and
      cmd ~= "grid modules" and
      cmd ~= "grid remove" and
      cmd ~= "pilot forcefield" and
      cmd ~= "pilot launch" and
      cmd ~= "ship worldscan") then
    return false
  end

  return true
end

function fn.aethersight_on()
  if not main.has_ability("discernment", "aethersight") then
    return false
  end

  return power_spell(3)
end

local function apply_arnica(part)
  if not bals.get("herb") then
    return false
  end

  return fn.apply()
end

function fn.apply_arnica_to_head()
  return apply_arnica("head")
end

function fn.apply_arnica_to_chest()
  return apply_arnica("chest")
end

function fn.apply_arnica_to_arms()
  return apply_arnica("arms")
end

function fn.apply_arnica_to_legs()
  return apply_arnica("legs")
end

function fn.apply()
  if affs.has("asleep") or
     affs.has("slickness") or
     affs.has("crucified") or
     affs.has("homeostasis") or
     (affs.limb("left", "arm") == "severed" and
      affs.limb("right", "arm") == "severed") then
    return false
  end

  return generic()
end

function fn.apply_health()
  if not bals.get("health") or
     gear.sips("healing") < 1 then
    return false
  end

  return fn.apply()
end

function fn.apply_health_to_head()
  return fn.apply_health()
end

function fn.apply_health_to_chest()
  return fn.apply_health()
end

function fn.apply_health_to_gut()
  return fn.apply_health()
end

function fn.apply_health_to_arms()
  return fn.apply_health()
end

function fn.apply_health_to_legs()
  return fn.apply_health()
end

local function apply_salve()
  if not bals.get("salve") then
    return false
  end

  return fn.apply()
end

function fn.apply_liniment()
  if gear.sips("liniment") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_melancholic_to_head()
  if gear.sips("melancholic") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_melancholic_to_chest()
  if gear.sips("melancholic") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_mending_to_head()
  if gear.sips("mending") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_mending_to_arms()
  if gear.sips("mending") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_mending_to_legs()
  if gear.sips("mending") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_regeneration_to_head()
  if flags.get("regenerating") or
     gear.sips("regeneration") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_regeneration_to_gut()
  if flags.get("regenerating") or
     gear.sips("regeneration") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_regeneration_to_chest()
  if flags.get("regenerating") or
     gear.sips("regeneration") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_regeneration_to_arms()
  if flags.get("regenerating") or
     gear.sips("regeneration") < 1 then
    return false
  end

  return apply_salve()
end

function fn.apply_regeneration_to_legs()
  if flags.get("regenerating") or
     gear.sips("regeneration") < 1 then
    return false
  end

  return apply_salve()
end

function fn.attitude_lawyerly()
  if not main.has_ability("dramatics", "lawyerly") then
    return false
  end

  return performing()
end

function fn.attitude_saintly()
  if not main.has_ability("dramatics", "saintly") then
    return false
  end

  return performing()
end

function fn.attitude_zealotry()
  if not main.has_ability("dramatics", "zealotry") then
    return false
  end

  return performing()
end

function fn.aurasense_on()
  if not main.has_ability("healing", "aurasense") then
    return false
  end

  return generic_spell()
end

function fn.auto_tea()
  if not bals.get("brew") or
     flags.get("brew_off") then
    return false
  end

  return fn.eat()
end

function fn.avoid()
  if not main.has_ability("acrobatics", "avoid") then
    return false
  end

  return generic_spell()
end


function fn.balancing_on()
  if not main.has_ability("acrobatics", "balancing") then
    return false
  end

  return generic_spell()
end

function fn.bardicpresence_on()
  if not main.has_ability("music", "bardicpresence") then
    return false
  end

  return generic()
end

function fn.bash()
  if not main.auto("bash") then
    return false
  end

  if flags.get("bashing1") and
     flags.get("bashing2") then
    return false
  end

  if not bals.get("bal") or
     not bals.get("eq") then
    return false
  end

  if flags.get("diagnose") or
     flags.get("diag_try") or
     defs.wanted() > 0 or
     todo.count("free") > 0 then
    return false
  end

  if affs.is_prone() or
     affs.has("blindness") or
     affs.slow() then
    return false
  end

  return generic()
end

function fn.beast_order_heal_health()
  if beast.ego() < 500 then
    return false
  end

  return generic_beast("heal health")
end

function fn.beast_order_heal_mana()
  if beast.ego() < 500 then
    return false
  end

  return generic_beast("heal mana")
end

function fn.beast_order_heal_ego()
  if beast.ego() < 500 then
    return false
  end

  return generic_beast("heal ego")
end

function fn.beast_order_attack()
  return generic_beast("battle")
end

function fn.beast_order_gust()
  return generic_beast("gust")
end

function fn.beast_order_breathe_amnesiacloud()
  if beast.mana() < 1500 then
    return false
  end

  return generic_beast("breathe amnesiacloud")
end

function fn.beast_order_breathe_cold()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe cold")
end

function fn.beast_order_breathe_fire()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe fire")
end

function fn.beast_order_breathe_gas()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe gas")
end

function fn.beast_order_breathe_lightning()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe lightning")
end

function fn.beast_order_breathe_psionicblast()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe psionicblast")
end

function fn.beast_order_breathe_sleepcloud()
  if beast.mana() < 1500 then
    return false
  end

  return generic_beast("breathe sleepcloud")
end

function fn.beast_order_breathe_steam()
  if beast.mana() < 500 then
    return false
  end

  return generic_beast("breathe steam")
end

function fn.beast_order_cast_hypnoticgaze()
  if beast.mana() < 1500 then
    return false
  end

  return generic_beast("cast hypnoticgaze")
end

function fn.beast_order_cast_reflection()
  if beast.mana() < 1500 then
    return false
  end

  return generic_beast("cast reflection")
end

function fn.beast_order_cure_body()
  if beast.mana() < 1000 then
    return false
  end

  return generic_beast("cure body")
end

function fn.beast_order_cure_mind()
  if beast.mana() < 1000 then
    return false
  end

  return generic_beast("cure mind")
end

function fn.beast_order_cure_spirit()
  if beast.mana() < 1000 then
    return false
  end

  return generic_beast("cure spirit")
end

function fn.beast_order_spit_poison()
  if tonumber(beast.get("doses") or "0") < 1 then
    return false
  end

  return generic_beast("spit poison")
end

function fn.beast_order_trample()
  if beast.locate() ~= "mounted" then
    return false
  end

  return generic_beast("trample")
end

function fn.blow_avaricehorn()
  return enchantment_balance("avarice")
end

function fn.bolting_off()
  if not main.has_ability("stag", "bolting") then
    return false
  end

  return generic_spell()
end

function fn.bolting_on()
  if not main.has_ability("stag", "bolting") then
    return false
  end

  return generic_spell()
end

function fn.boost_regeneration()
  if not main.has_ability("athletics", "boosting") or
     not defs.has("regeneration") then
    return false
  end

  return free_defense()
end

function fn.breathe_deep()
  if not main.has_ability("athletics", "breathe") then
    return false
  end

  return generic_spell()
end


function fn.camouflage_on()
  if not main.has_ability("hunting", "camouflage") then
    return false
  end

  return generic_spell()
end

function fn.charismaticaura_on()
  if not main.has_ability("influence", "charismaticaura") then
    return false
  end

  return generic_spell()
end

function fn.climb()
  if not bals.can_act() or
     affs.is_prone() or
     affs.has("transfixed") or
     affs.has("clamped_right") or
     affs.has("clamped_left") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" then
    return false
  end

  return generic()
end

function fn.climb_down()
  if flags.get("climb_try") then
    return false
  end

  return fn.climb()
end

function fn.climb_rocks()
  if flags.get("climb_try") or
     flags.get("climbing_up") or
     GetVariable("sg1_option_norockclimbing") == "1" or
     not bals.can_act() or
     prompt.stat("pow") < 3 or
     affs.has("asleep") or
     not main.has_ability("environment", "rockclimbing") then
    return false
  end

  return generic()
end

function fn.climb_up()
  if flags.get("climb_try") or
     flags.get("climbing_up") or
     affs.has("mending_legs") then
    return false
  end

  return fn.climb()
end

function fn.clot()
  if affs.has("asleep") or
     flags.get("clot_try") or
     affs.has("hemophilia") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("crucified") or
     affs.has("manabarbs") or
     affs.slow() or
     not main.has_ability("discipline", "clotting") then
    return false
  end

  local blood = affs.has("bleeding") or 0
  if blood <= 40 and
     flags.get("eating_chervil") then
    return false
  end

  if (((flags.get("mana_careful") and
      prompt.stat("mp") <= prompt.stat("maxmp") / 2)) or
      prompt.stat("mp") <= prompt.stat("maxmp") / 3) and
     blood < prompt.stat("maxhp") / 4 then
    return false
  end

  return generic()
end

function fn.concentrate()
  if flags.get("concentrate_try") or
     affs.has("confusion") or
     affs.has("asleep") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("crucified") then
    return false
  end

  return generic()
end

function fn.compose()
  if flags.get("compose_try") or
     affs.has("asleep") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("crucified") then
    return false
  end

  return generic()
end

function fn.combatstyle_aggressive()
  if not main.has_ability("knighthood", "aggressive") then
    return false
  end

  return free_defense()
end

function fn.combatstyle_concentrated()
  if not main.has_ability("knighthood", "concentrated") then
    return false
  end

  return free_defense()
end

function fn.combatstyle_defensive()
  if not main.has_ability("knighthood", "defensive") then
    return false
  end

  return free_defense()
end

function fn.combatstyle_lightning()
  if not main.has_ability("knighthood", "lightning") then
    return false
  end

  return free_defense()
end

function fn.consciousness_off()
  if not main.has_ability("athletics", "consciousness") then
    return false
  end

  return generic_spell()
end

function fn.consciousness_on()
  if not main.has_ability("athletics", "consciousness") then
    return false
  end

  return generic_spell()
end

function fn.constitution()
  if not main.has_ability("athletics", "constitution") then
    return false
  end

  return generic_spell()
end

function fn.contort()
  if affs.has("asleep") or
     not main.has_ability("acrobatics", "contortion") or
     flags.get("writhing") or
     flags.get("writhe_try") or
     flags.get("fastwrithe_try") then
    return false
  end

  return generic()
end

function fn.contort_impale()
  if affs.has("asleep") or
     not main.has_ability("acrobatics", "contortion") or
     flags.get("writhing") or
     flags.get("writhe_try") or
     not (bals.get("bal") and bals.get("larm") and bals.get("rarm")) then
    return false
  end

  return generic()
end

function fn.contort_clamp()
  return fn.contort()
end

function fn.contort_entangle()
  return fn.contort()
end

function fn.contort_grapple()
  return fn.contort()
end

function fn.contort_hoist()
  return fn.contort()
end

function fn.contort_ropes()
  return fn.contort()
end

function fn.contort_shackles()
  return fn.contort()
end

function fn.contort_transfix()
  return fn.contort()
end

function fn.contort_truss()
  return fn.contort()
end

function fn.contort_vines()
  return fn.contort()
end


function fn.deathsense()
  if not main.has_ability("discernment", "deathsense") then
    return false
  end

  return generic_spell()
end

function fn.defup_bal()
  if flags.get("defs_bal") or
     todo.count() > 0 or
     flags.get("doing") then
    return false
  end

  return generic_spell()
end

function fn.defup_elixir()
  if flags.get("defs_elixir") or
     not bals.get("elixir") or
     not sip_purgative() then
    return false
  end

  return generic()
end

function fn.defup_free()
  if flags.get("defs_free") or
     todo.count() > 0 or
     flags.get("doing") then
    return false
  end

  return generic_spell()
end

function fn.defup_herb()
  if flags.get("defs_herb") or
     not bals.get("herb") or
     not fn.eat_herb() then
    return false
  end

  return generic()
end

function fn.defup_id()
  if not bals.get("id") or
     flags.get("defs_id") or
     todo.count() > 0 or
     flags.get("doing") then
    return false
  end

  return generic()
end

function fn.defup_sub()
  if not bals.get("sub") or
     flags.get("defs_sub") or
     todo.count() > 0 or
     flags.get("doing") then
    return false
  end

  return generic()
end

function fn.defup_super()
  if not bals.get("super") or
     flags.get("defs_super") or
     todo.count() > 0 or
     flags.get("doing") then
    return false
  end

  return generic()
end

function fn.diagnose()
  if not bals.can_act() or
     flags.get("diag_try") or
     affs.has("asleep") or
     not main.has_ability("discernment", "diagnose") then
    return false
  end

  return generic()
end

function fn.diag()
  return fn.diagnose()
end

function fn.drama_etiquette()
  if not main.has_ability("dramaturgy", "etiquette") then
    return false
  end

  return generic_spell()
end

function fn.drama_foppery()
  if not main.has_ability("dramaturgy", "foppery") then
    return false
  end

  return generic_spell()
end

function fn.dreamweave_control()
  if not main.has_ability("dreamweaving", "control") then
    return false
  end

  return generic_spell()
end


function fn.eat()
  if affs.has("asleep") or
     affs.has("anorexia") or
     affs.has("slit_throat") or
     affs.has("throat_locked") or
     affs.has("crushed_windpipe") or
     affs.has("scarab") or
     affs.has("crucified") or
     affs.has("homeostasis") or
     (affs.limb("left", "arm") == "severed" and
      affs.limb("right", "arm") == "severed") then
    return false
  end

  return generic()
end

function fn.eat_herb()
  if not bals.get("herb") or
     affs.has("darkfate") then
    return false
  end

  return fn.eat()
end

function fn.eat_calamus()
  return fn.eat_herb()
end

function fn.eat_chervil()
  local blood = affs.has("bleeding") or 0
  if blood <= 100 then
    return false
  end

  return fn.eat_herb()
end

function fn.eat_earwort()
  if affs.has("earache") then
    return false
  end

  return fn.eat_herb()
end

function fn.eat_faeleaf()
  if affs.has("afterimage") or
     flags.get("waiting_for_sixthsense") then
    return false
  end

  return fn.eat_herb()
end

function fn.eat_galingale()
  return fn.eat_herb()
end

function fn.eat_horehound()
  if flags.get("maestoso") and
     not (affs.has("deafness") or
          defs.has("truehearing")) then
    return false
  end

  if affs.has("bedeviled") and
     flags.get("bedeviler") then
    return false
  end

  return fn.eat_herb()
end

function fn.eat_kafe()
  return fn.eat_herb()
end

function fn.eat_kombu()
  return fn.eat_herb()
end

function fn.eat_marjoram()
  return fn.eat_herb()
end

function fn.eat_merbloom()
  if flags.get("insomnia_try") or
     affs.has("hypersomnia") then
    return false
  end

  return fn.eat_herb()
end

function fn.eat_myrtle()
  return fn.eat_herb()
end

function fn.eat_pennyroyal()
  return fn.eat_herb()
end

function fn.eat_reishi()
  return fn.eat_herb()
end

function fn.eat_sparkleberry()
  if not bals.get("sparkle") or 
     (affs.limb("left", "arm") == "severed" and
      affs.limb("right", "arm") == "severed") or
    gear.inv("sparkleberry") < 1 then
    return false
  end

  return fn.eat()
end

function fn.eat_wormwood()
  return fn.eat_herb()
end

function fn.eat_yarrow()
  return fn.eat_herb()
end

function fn.elasticity()
  if not main.has_ability("acrobatics", "elasticity") then
    return false
  end

  return generic()
end

function fn.empty_coltsfoot()
  return empty_pipe()
end

function fn.empty_faeleaf()
  return empty_pipe()
end

function fn.empty_myrtle()
  return empty_pipe()
end

function fn.enemy()
  if affs.slow() then
    return false
  end
  return generic()
end

function fn.escape_p5()
  if tumble() then
    return true
  end

  return fn.eat_earwort()
end

function fn.evoke_geburah()
  if not main.has_ability("highmagic", "geburah") then
    return false
  end

  return power_spell(3)
end

function fn.evoke_gedulah()
  if not main.has_ability("highmagic", "gedulah") or
     prompt.stat("mp") < main.mana_adjust(80) then
    return false
  end

  return power_cure(3)
end

function fn.evoke_greatpentagram()
  if not main.has_ability("highmagic", "greatpentagram") then
    return false
  end

  return power_spell(10)
end

function fn.evoke_hod()
  if not main.has_ability("highmagic", "hod") then
    return false
  end

  return power_spell(3)
end

function fn.evoke_malkuth()
  if not main.has_ability("highmagic", "malkuth") then
    return false
  end

  return generic_spell()
end

function fn.evoke_netzach()
  if not main.has_ability("highmagic", "netzach") then
    return false
  end

  return generic_spell()
end

function fn.evoke_pentagram()
  if not main.has_skill("highmagic") then
    return false
  end

  return generic_spell()
end

function fn.evoke_tipheret()
  if flags.get("fastwrithe") or
     affs.has("asleep") or
     not bals.can_act() or
     affs.has("paralysis") or
     not main.has_ability("highmagic", "tipheret") then
    return false
  end

  return generic()
end

function fn.evoke_yesod()
  if not main.has_ability("highmagic", "yesod") then
    return false
  end

  return generic_spell()
end


function fn.falling()
  if not main.has_ability("acrobatics", "falling") then
    return false
  end

  return generic()
end

function fn.fill_coltsfoot()
  return fill_pipe("coltsfoot")
end

function fn.fill_faeleaf()
  return fill_pipe("faeleaf")
end

function fn.fill_myrtle()
  return fill_pipe("myrtle")
end

function fn.flex()
  if not main.has_ability("athletics", "strength") then
    return false
  end

  return generic_spell()
end

function fn.focus()
  if affs.has("asleep") or
     not bals.get("focus") then
    return false
  end

  return generic()
end

function fn.focus_body()
  if affs.has("impatience") or
     prompt.stat("mp") < main.mana_adjust(250) then
    return false
  end

  return fn.focus()
end

function fn.focus_mind()
  if affs.has("crucified") or
     affs.has("darkfate") or
     ((affs.has("manabarbs") or
       affs.has("deadening") or
       (flags.get("mana_careful") and prompt.stat("mp") <= prompt.stat("maxmp") / 2) or
       (affs.has("bad_luck") and (affs.has("insanity") or 0) < 5)) and
      not (affs.has("anorexia") or affs.has("impatience"))) or
     prompt.stat("mp") < main.mana_adjust(250) or
     not main.has_ability("discipline", "focusmind") then
    return false
  end
  
  return fn.focus()
end

function fn.focus_poisons()
  if not main.has_ability("tracking", "poisonexpert") then
    return false
  end

  return power_spell(10)
end

function fn.focus_spirit()
  if affs.has("impatience") or
     affs.has("manabarbs") or
     affs.has("deadening") or
     flags.get("mana_careful") or
     prompt.stat("mp") < main.mana_adjust(prompt.stat("maxmp") / 4) or
     (flags.get("maestoso") and
      not (affs.has("deafness") or
           defs.has("truehearing"))) or
     not main.has_ability("discipline", "focusspirit")  then
    return false
  end

  return fn.focus()
end


function fn.generosity()
  if flags.get("generosity_try") or
     flags.get("selfishness_try") or
     not main.has_ability("discipline", "selfishness") or
     not fn.todo("bal") then
    return false
  end

  return true
end

function fn.grip()
  if not main.has_ability("knighthood", "gripping") and
     not main.has_ability("kata", "gripping") then
    return false
  end

  return generic_spell()
end

function fn.guard_self()
  if not main.has_ability("cavalier", "guard") or
     not defs.has("mounted") then
    return false
  end

  return generic_spell()
end


function fn.harvest()
  if flags.get("diag_try") or
     affs.has("asleep") or
     not bals.can_act() or
     affs.is_impaled() or
     affs.has("clamped_left") or
     affs.has("clamped_right") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.has("severed_spine") or
     affs.has("pierced_leftleg") or
     affs.has("pierced_rightleg") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" then
    return false
  end

  return generic()
end

function fn.hold_breath()
  if not main.has_ability("discipline", "breathing") or
     flags.get("hold_breath_try") or
     affs.has("hyperventilating") or
     not bals.can_act() then
    return false
  end

  return generic()
end

function fn.hunger()
  if not main.has_ability("athletics", "hunger") or
     not bals.can_act() or
     flags.get("hunger_try") or
     affs.has("asleep") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("paralysis") or
     (flags.get("nutrition") or 0) < -3 then
    return false
  end

  local cannot_focus_mind = affs.has("crucified") or
     ((affs.has("manabarbs") or
       affs.has("deadening") or
       (flags.get("mana_careful") and prompt.stat("mp") <= prompt.stat("maxmp") / 2) or
       (affs.has("bad_luck") and (affs.has("insanity") or 0) < 10)) and
      not affs.has("impatience")) or
     prompt.stat("mp") < main.mana_adjust(250) or
     not main.has_ability("discipline", "focusmind")

  local cannot_smoke_coltsfoot = affs.has("asthma") or
     affs.has("collapsed_lungs") or
     affs.has("black_lung") or
     affs.has("crucified") or
     affs.has("homeostasis")

  return generic() and cannot_focus_mind and cannot_smoke_coltsfoot
end

function fn.hyperventilate()
  if not main.has_ability("acrobatics", "hyperventilate") then
    return false
  end

  return generic_spell()
end


function fn.immunity()
  if not main.has_ability("athletics", "immunity") then
    return false
  end

  return power_spell(4)
end

function fn.insomnia()
  if affs.has("asleep") or
     flags.get("insomnia_try") or
     affs.has("narcolepsy") or
     affs.has("hypersomnia") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("crucified") or
     (flags.get("mana_careful") and
      prompt.stat("mp") <= prompt.stat("maxmp") / 2 and
      fn.eat_merbloom()) or
     prompt.stat("mp") < main.mana_adjust(100) or
     not main.has_ability("discipline", "insomnia") then
    return false
  end

  return generic()
end

function fn.invoke_circle()
  if flags.get("shield_try") or
     defs.has("shield") or
     prompt.stat("mp") < main.mana_adjust(30) or
     not main.has_ability("lowmagic", "circle") then
    return false
  end

  return generic_spell()
end

function fn.invoke_blue()
  if not main.has_ability("lowmagic", "blue") then
    return false
  end

  return generic_spell()
end

function fn.invoke_green()
  if not main.has_ability("lowmagic", "green") or
     prompt.stat("mp") < main.mana_adjust(80) then
    return false
  end

  return power_cure(3)
end

function fn.invoke_red()
  if not main.has_ability("lowmagic", "red") then
    return false
  end

  return generic_spell()
end

function fn.invoke_serpent()
  if not main.has_ability("lowmagic", "serpent") then
    return false
  end

  return power_spell(10)
end

function fn.invoke_summer()
  if flags.get("fastwrithe") or
     affs.has("asleep") or
     not bals.can_act() or
     affs.has("paralysis") or
     not main.has_ability("lowmagic", "summer") then
    return false
  end

  return generic()
end

function fn.invoke_yellow()
  if not main.has_ability("lowmagic", "yellow") then
    return false
  end

  return power_spell(3)
end


function fn.keeneye_on()
  if not main.has_ability("combat", "keeneye") then
    return false
  end

  return generic_spell()
end


function fn.limber()
  if not main.has_ability("acrobatics", "limber") then
    return false
  end

  return generic_spell()
end

function fn.lipread()
  if not main.has_ability("discernment", "lipread") then
    return false
  end

  return generic_spell()
end


function fn.manipulate_weatherguard()
  if not main.has_ability("shamanism", "weatherguard") then
    return false
  end

  return generic_spell()
end

function fn.metawake_off()
  if not main.has_ability("discipline", "metawake") or
     flags.get("metawake_try") then
    return false
  end

  return free_defense()
end

function fn.metawake_on()
  if not main.has_ability("discipline", "metawake") or
     flags.get("metawake_try") then
    return false
  end

  return fn.todo("bal")
end

function fn.mindset()
  if affs.has("asleep") or
     not bals.can_act() or
     flags.get("mindset_try") or
     affs.slow() or
     not main.has_skill("influence") then
    return false
  end

  return generic()
end

function fn.mindset_analytical()
  return fn.mindset()
end

function fn.mindset_cautious()
  return fn.mindset()
end

function fn.mindset_pedantic()
  return fn.mindset()
end

function fn.moondance_aura()
  if not main.has_ability("moon", "aura") then
    return false
  end

  return generic_spell()
end

function fn.moondance_drawdown()
  if not calendar.is_night() and
     map.current_room ~= 17117 or
     not main.has_ability("moon", "drawdown") then
    return false
  end

  return power_spell(10)
end

function fn.moondance_full()
  if not main.has_ability("moon", "full") or
     affs.has("paralysis") or
     affs.has("severed_spine") or
     prompt.stat("mp") < main.mana_adjust(250) then
    return false
  end

  return power_cure(4)
end

function fn.moondance_shine()
  if not calendar.is_night() and
     map.current_room ~= 17117 or
     not main.has_ability("moon", "shine") then
    return false
  end

  return power_spell(10)
end

function fn.moondance_harvest()
  -- TODO: check for coven
  return false
--[[
  if not main.has_ability("moon", "harvest") then
    return false
  end

  return generic_spell()
--]]
end

function fn.move()
  if not bals.can_act() or
     affs.is_prone() or
     affs.has("transfixed") or
     affs.has("clamped_right") or
     affs.has("clamped_left") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" or
     affs.has("mending_legs") then
    return false
  end

  return generic()
end


function fn.nature_barkskin()
  if not main.has_ability("nature", "barkskin") then
    return false
  end

  return generic_spell()
end

function fn.nature_blend_on()
  if not main.has_ability("nature", "blend") then
    return false
  end

  return generic_spell()
end

function fn.nature_rooting()
  if not main.has_ability("nature", "rooting") then
    return false
  end

  return generic_spell()
end

function fn.nightsight()
  if not main.has_skill("discernment") then
    return false
  end

  return free_defense()
end


function fn.open_channels()
  if not main.has_ability("wicca", "channels") then
    return false
  end

  return power_spell(10)
end


function fn.paint_face_greenman()
  if not main.has_ability("stag", "greenman") or
     defs.has("trueheart") or
     gear.inv("greentint") < 2 then
    return false
  end

  return generic_spell()
end

function fn.paint_face_lightning()
  if not main.has_ability("stag", "lightning") or
     defs.has("swiftstripes") or
     gear.inv("bluetint") < 2 then
    return false
  end

  return generic_spell()
end

function fn.paint_face_swiftstripes()
  if not main.has_ability("stag", "swiftstripes") or
     defs.has("lightning") or
     gear.inv("redtint") < 2 then
    return false
  end

  return generic_spell()
end

function fn.paint_face_trueheart()
  if not main.has_ability("stag", "trueheart") or
     defs.has("greenman") or
     gear.inv("yellowtint") < 2 then
    return false
  end

  return generic_spell()
end

function fn.parry()
  if affs.has("asleep") or
     flags.get("parry_try") or
     affs.slow() or
     affs.has("elbow_left") or
     affs.has("elbow_right") or
     affs.is_impaled() then
    return false
  end

  return generic()
end

function fn.parry_scan()
  return fn.parry()
end

function fn.pathfind()
  if not main.has_ability("hunting", "pathfinding") or
     GetVariable("sg1_map_no_pathfind") == "1" then
    return false
  end

  return true
end

function fn.performance_on()
  if not main.has_skill("dramatics") then
    return false
  end

  return generic_spell()
end

function fn.perform_bully()
  if not main.has_ability("dramatics", "bully") then
    return false
  end

  return performing()
end

function fn.perform_bureaucrat()
  if not main.has_ability("dramatics", "bureaucrat") then
    return false
  end

  return performing()
end

function fn.perform_diplomat()
  if not main.has_ability("dramatics", "diplomat") then
    return false
  end

  return performing()
end

function fn.perform_drunkard()
  if not main.has_ability("dramatics", "drunkard") then
    return false
  end

  return performing()
end

function fn.perform_gorgeous()
  if not main.has_ability("dramatics", "gorgeous") then
    return false
  end

  return performing()
end

function fn.perform_sober()
  if not main.has_ability("dramatics", "sober") then
    return false
  end

  return performing()
end

function fn.perform_sycophant()
  if not main.has_ability("dramatics", "sycophant") then
    return false
  end

  return performing()
end

function fn.perform_vagabond()
  if not main.has_ability("dramatics", "vagabond") then
    return false
  end

  return performing()
end

function fn.perform_wounded()
  if not main.has_ability("dramatics", "wounded") then
    return false
  end

  return performing()
end

function fn.pipes_light()
  if flags.get("pipe_light_try") or
     not bals.can_act() or
     affs.is_impaled() or
     affs.has("crucified") or
     affs.has("paralysis") or
     affs.has("asleep") or
     (affs.limb("left", "arm") ~= "healthy" and
      affs.limb("right", "arm") ~= "healthy") or
     (affs.has("hemiplegy_left") and
      affs.has("hemiplegy_right")) then
    return false
  end

  return generic()
end

function fn.point_ignite_at_me()
  if flags.get("ignite_try") then
    return false
  end

  return enchantment_balance("ignite")
end

function fn.powermask()
  if not main.has_ability("discernment", "powermask") then
    return false
  end

  return power_spell(10)
end


function fn.radiate_vitality()
  if not main.has_ability("healing", "vitality") then
    return false
  end

  return power_spell(10)
end

function fn.read_curses()
  if not bals.can_act() then
    return false
  end

  local charges = magic.charges("cursed", true)
  if charges < 1 then
    charges = magic.charges("cursed", false)
    if charges < 1 then
      return false
    end
  end

  return read()
end

function fn.read_disruption()
  if not bals.can_act() then
    return false
  end

  local charges = magic.charges("disruption", true)
  if charges < 1 then
    charges = magic.charges("disruption", false)
    if charges < 1 then
      return false
    end
  end

  return read()
end

function fn.read_healing()
  if not bals.get("scroll") or
     affs.slow() then
    return false
  end

  local charges = magic.charges("healing", true)
  if charges < 1 then
    charges = magic.charges("healing", false)
    if charges < 1 then
      return false
    end
  end

  return read()
end

function fn.read_protection()
  if not bals.can_act() or
     flags.get("protectorate") then
    return false
  end

  local charges = magic.charges("protection", true)
  if charges < 1 then
    charges = magic.charges("protection", false)
    if charges < 1 then
      return false
    end
  end

  return read()
end

function fn.regeneration_off()
  return generic()
end

function fn.regeneration_on()
  if not main.has_ability("athletics", "regeneration") then
    return false
  end

  return free_defense()
end

function fn.release_origami()
  return generic_spell()
end

function fn.resistance()
  if not main.has_ability("athletics", "resistance") then
    return false
  end

  return free_defense()
end

function fn.restore()
  if flags.get("restore_try") or
     not bals.can_act() or
     not main.has_ability("discipline", "restoration") then
    return false
  end

  return generic()
end

function fn.retrieve_stored_items()
  if flags.get("retrieve_try") or
     not fn.todo("free") then
    return false
  end

  return true
end

function fn.rewear()
  if flags.get("rewear_try") or
     affs.has("asleep") or
     affs.slow() then
    return false
  end

  return generic()
end

function fn.rewield()
  if flags.get("rewield_try") or
     not bals.can_act() or
     affs.has("entangled") or
     affs.has("transfixed") or
     affs.has("paralysis") or
     affs.has("severed_spine") or
     affs.is_impaled() or
     affs.has("roped") or
     affs.has("shackled") or
     affs.has("clamped_left") or
     affs.has("clamped_right") or
     affs.has("hemiplegy_left") or
     affs.has("hemiplegy_right") or
     affs.has("hemiplegy") or
     affs.has("broken_leftwrist") or
     affs.has("broken_rightwrist") or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" then
    return false
  end

  return generic()
end

function fn.ringwalk()
  if not main.has_ability("stag", "ringwalk") then
    return false
  end

  return generic_spell()
end

function fn.rub_acquisitio()
  return enchantment_balance("acquisitio")
end

function fn.rub_beauty()
  return enchantment_free("beauty")
end

function fn.rub_cleanse()
  if not bals.can_act() or
     flags.get("cleanse_try") or
     affs.has("prone") or
     affs.has("entangled") or
     affs.has("paralysis") or
     affs.has("severed_spine") or
     affs.is_impaled() or
     affs.has("roped") or
     affs.has("shackled") then
    return false
  end

  return enchantment_free("cleanse")
end

function fn.rub_deathsight()
  return enchantment_balance("deathsight")
end

function fn.rub_focus()
  if not bals.get("charm") or
     not bals.can_act() or
     magic.charges("focus") < 1 then
    return false
  end

  return generic()
end

function fn.rub_kingdom()
  return enchantment_free("kingdom")
end

function fn.rub_levitate()
  return enchantment_balance("levitate")
end

function fn.rub_medicinebag_on_head()
  return medicinebag()
end

function fn.rub_medicinebag_on_chest()
  return medicinebag()
end

function fn.rub_medicinebag_on_gut()
  return medicinebag()
end

function fn.rub_medicinebag_on_arms()
  return medicinebag()
end

function fn.rub_medicinebag_on_legs()
  return medicinebag()
end

function fn.rub_mercy()
  return enchantment_free("mercy")
end

function fn.rub_nimbus()
  return enchantment_balance("cosmic")
end

function fn.rub_perfection()
  return enchantment_free("perfection")
end

function fn.rub_surfboard()
  return generic_spell()
end

function fn.rub_waterbreathe()
  return enchantment_balance("waterbreathe")
end

function fn.rub_waterwalk()
  return enchantment_balance("waterwalk")
end


function fn.scrub()
  if not bals.can_act() or
     GetVariable("sg1_option_nosoap") == "1" or
     flags.get("cleanse_try") or
     affs.has("prone") or
     affs.has("entangled") or
     affs.has("paralysis") or
     affs.has("severed_spine") or
     affs.is_impaled() or
     affs.has("roped") or
     affs.has("shackled") then
    return false
  end

  return generic()
end

function fn.selfishness()
  if flags.get("selfishness_try") or
     flags.get("generosity_try") or
     not fn.todo("bal") or
     not main.has_ability("discipline", "selfishness") then
    return false
  end

  return true
end

function fn.sip_health()
  if not bals.get("health") or
     affs.has("crucified") then
    return false
  end

  return fn.eat()
end

function fn.sip_mana()
  return fn.sip_health()
end

function fn.sip_bromide()
  return fn.sip_health()
end

function fn.sip_bromides()
  return fn.sip_bromide()
end

function fn.sip_antidote()
  if gear.sips("antidote") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_choleric()
  if gear.sips("choleric") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_fire()
  if gear.sips("fire") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_frost()
  if gear.sips("frost") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_galvanism()
  if gear.sips("galvanism") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_love()
  if gear.sips("love") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_phlegmatic()
  if gear.sips("phlegmatic") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_sanguine()
  if gear.sips("sanguine") < 1 then
    return false
  end

  return sip_purgative()
end

function fn.sip_moonwater()
  if defs.has("pre_orgpotion") or
     flags.get("moonwater_try") or
     gear.sips("moonwater") < 1 then
    return false
  end

  return fn.eat()
end

function fn.sip_quicksilver()
  if affs.has("crucified") or
     gear.sips("quicksilver") < 1 or
     flags.get("speed_try") or
     flags.get("waiting_for_speed") then
    return false
  end

  return fn.eat()
end

function fn.sip_allheale()
  if not bals.get("allheale") or
     gear.sips("allheale") < 1 or
     affs.has("vapors") then
    return false
  end

  return fn.eat()
end

function fn.sit_on_throne()
  if not bals.can_act() or
     map.current_room ~= 17117 or
     defs.has("mounted") then
    return false
  end

  return generic()
end

function fn.throne()
  return fn.sit_on_throne()
end

function fn.smoke()
  if affs.has("asleep") or
     flags.get("smoking") or
     affs.has("asthma") or
     affs.has("collapsed_lungs") or
     affs.has("black_lung") or
     affs.has("crucified") or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("homeostasis") then
    return false
  end

  return generic()
end

function fn.smoke_coltsfoot()
  if not bals.get("herb") or
     pipes.puffs("coltsfoot") < 1 then
    return false
  end

  return fn.smoke()
end

function fn.smoke_faeleaf()
  if flags.get("aura_timer") or
     (affs.has("coils") and
      not bals.get("herb")) or
     pipes.puffs("faeleaf") < 1 then
    return false
  end

  return fn.smoke()
end

function fn.smoke_myrtle()
  if not bals.get("herb") or
     pipes.puffs("myrtle") < 1 then
    return false
  end

  return fn.smoke()
end

function fn.speak()
  if affs.has("crushed_windpipe") or
     affs.has("slit_throat") or
     affs.has("sliced_tongue") or
     affs.has("throat_locked") or
     affs.slow() then
    return false
  end

  return generic()
end

function fn.spiritbond_nature()
  if defs.has("nature") or
     not main.has_ability("totems", "nature") then
    return false
  end

  return power_spell(5)
end

function fn.springup()
  if flags.get("springup_try") or
     flags.get("stand_try") or
     not main.has_ability("acrobatics", "springup") or
     affs.has("asleep") or
     affs.has("paralysis") or
     affs.has("entangled") or
     affs.has("shackled") or
     affs.has("transfixed") or
     affs.has("roped") or
     affs.has("trussed") or
     affs.is_impaled() or
     affs.has("clamped_left") or
     affs.has("clamped_right") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.has("severed_spine") or
     affs.has("pierced_leftleg") or
     affs.has("pierced_rightleg") or
     affs.has("ankle_left") or
     affs.has("ankle_right") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" then
    return false
  end

  return generic()
end

function fn.sprinkle_salt()
  if flags.get("shield_try") or
     gear.sips("magical salt") < 1 then
    return false
  end

  return generic_spell()
end

function fn.stagform()
  if not main.has_ability("stag", "stagform") then
    return false
  end

  return power_spell(10)
end

function fn.staghide()
  if not main.has_ability("stag", "staghide") then
    return false
  end

  return generic_spell()
end

function fn.stance_legs()
  if not main.has_ability("combat", "legs") then
    return false
  end

  return stance()
end

function fn.stance_left()
  if not main.has_ability("combat", "left") then
    return false
  end

  return stance()
end

function fn.stance_right()
  if not main.has_ability("combat", "right") then
    return false
  end

  return stance()
end

function fn.stance_arms()
  if not main.has_ability("combat", "arms") then
    return false
  end

  return stance()
end

function fn.stance_gut()
  if not main.has_ability("combat", "gut") then
    return false
  end

  return stance()
end

function fn.stance_chest()
  if not main.has_ability("combat", "chest") then
    return false
  end

  return stance()
end

function fn.stance_head()
  if not main.has_ability("combat", "head") then
    return false
  end

  return stance()
end

function fn.stance_lower()
  if not main.has_ability("combat", "lower") then
    return false
  end

  return stance()
end

function fn.stance_middle()
  if not main.has_ability("combat", "middle") then
    return false
  end

  return stance()
end

function fn.stance_upper()
  if not main.has_ability("combat", "upper") then
    return false
  end

  return stance()
end

function fn.stance_vitals()
  if not main.has_ability("combat", "vitals") then
    return false
  end

  return stance()
end

function fn.stand()
  if flags.get("stand_try") or
     affs.has("asleep") or
     not bals.can_act() or
     affs.has("paralysis") or
     affs.has("entangled") or
     affs.has("shackled") or
     affs.has("transfixed") or
     affs.has("roped") or
     affs.has("trussed") or
     affs.is_impaled() or
     affs.is_grappled("body") or
     affs.is_grappled("leftleg") or
     affs.is_grappled("rightleg") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.has("severed_spine") or
     affs.has("pierced_leftleg") or
     affs.has("pierced_rightleg") or
     affs.has("ankle_left") or
     affs.has("ankle_right") or
     affs.has("hemiplegy_legs") or
     affs.has("broken_leg") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" then
    return false
  end

  return generic()
end

function fn.succor()
  if not bals.can_act() or
     flags.get("diag_try") or
     affs.has("asleep") or
     not main.has_ability("healing", "succor") then
    return false
  end

  return generic()
end

function fn.surge()
  if not main.has_ability("athletics", "surge") then
    return false
  end

  return power_spell(8)
end


function fn.thirdeye()
  if not main.has_ability("discernment", "thirdeye") or
     prompt.stat("mp") < main.mana_adjust(30) then
    return false
  end

  return free_defense()
end

function fn.todo(name)
  if not bals.can_act() or
     flags.get("diag_try") or
     affs.has("asleep") or
     affs.is_prone() or
     affs.is_impaled() or
     affs.has("clamped_left") or
     affs.has("clamped_right") or
     affs.has("tendon_left") or
     affs.has("tendon_right") or
     affs.has("severed_spine") or
     affs.has("pierced_leftleg") or
     affs.has("pierced_rightleg") or
     affs.limb("left", "leg") ~= "healthy" or
     affs.limb("right", "leg") ~= "healthy" or
     affs.limb("left", "arm") ~= "healthy" or
     affs.limb("right", "arm") ~= "healthy" then
    return false
  end

  if name and name ~= "free" and
     (flags.get("doing") or
     (bashing.count() > 0 and acquire.count() < 1)) then
    return false
  end

  return generic()
end

function fn.touch_medicinebag()
  return medicinebag()
end

function fn.transmute()
  if affs.is_prone() or
     not bals.can_act() or
     affs.slow() or
     affs.has("pinned_left") or
     affs.has("pinned_right") or
     affs.has("manabarbs") or
     flags.get("mana_careful") or
     flags.get("transmute_try") or
     not main.has_ability("athletics", "transmute") then
    return false
  end

  return generic()
end

function fn.tripleflash()
  if not main.has_ability("acrobatics", "tripleflash") then
    return false
  end

  return power_spell(10)
end

function fn.auto_tumble()
  return tumble()
end

for _,dir in ipairs{"n", "s", "e", "w", "nw", "ne", "sw", "se", "in", "out"} do
  fn["tumble_" .. dir] = function () return tumble() end
end

function fn.twirl_cudgel()
  if not main.has_ability("druidry", "cudgel") then
    return false
  end

  return generic_spell()
end


function fn.vitality()
  if prompt.stat("hp") < prompt.stat("maxhp") or
     prompt.stat("mp") < prompt.stat("maxmp") or
     prompt.stat("ego") < prompt.stat("maxego") or
     not main.has_ability("athletics", "vitality") then
    return false
  end

  return generic_spell()
end


function fn.wake()
  if flags.get("wake_try") or
     flags.get("waking") then
    return false
  end

  return generic()
end

function fn.weathering()
  if not main.has_skill("athletics") then
    return false
  end

  return free_defense()
end

function fn.weave_blur()
  if not main.has_ability("illusions", "blur") then
    return false
  end

  return generic_spell()
end

function fn.writhe()
  if affs.has("asleep") or
     flags.get("writhing") or
     flags.get("writhe_try") or
     flags.get("fastwrithe_try") then
    return false
  end

  return generic()
end

function fn.writhe_impale()
  if affs.has("asleep") or
     flags.get("writhing") or
     flags.get("writhe_try") or
     not (bals.get("bal") and bals.get("larm") and bals.get("rarm")) then
    return false
  end

  return generic()
end

function fn.writhe_clamp()
  return fn.writhe()
end

function fn.writhe_entangle()
  return fn.writhe()
end

function fn.writhe_grapple()
  return fn.writhe()
end

function fn.writhe_hoist()
  return fn.writhe()
end

function fn.writhe_ropes()
  return fn.writhe()
end

function fn.writhe_shackles()
  return fn.writhe()
end

function fn.writhe_transfix()
  return fn.writhe()
end

function fn.writhe_truss()
  return fn.writhe()
end

function fn.writhe_vines()
  return fn.writhe()
end
