module (..., package.seeall)

require "main"
require "prompt"

local copytable = require "copytable"

vial_map = {}

herb_list = {
  "arnica",
  "calamus",
  "colewort",
  "chervil",
  "coltsfoot",
  "earwort",
  "faeleaf",
  "flax",
  "galingale",
  "horehound",
  "juniper",
  "kafe",
  "kombu",
  "marjoram",
  "merbloom",
  "mistletoe",
  "myrtle",
  "pennyroyal",
  "rawtea",
  "reishi",
  "rosehips",
  "sage",
  "sargassum",
  "sparkleberry",
  "weed",
  "wormwood",
  "yarrow"
}

artifact_vials = main.bootstrap("gear_artifact_vials") or {}
potions = main.bootstrap("gear_potions") or {}
empties = main.bootstrap("gear_empties") or {}
rewield = {}
inventory = main.bootstrap("gear_inventory") or {}

xlate_potion = {
  ["elixir vitae"] = "vitae",

  ["the poison aleutian"] = "aleutian",
  ["the poison anatine"] = "anatine",
  ["the poison anerod"] = "anerod",
  ["the poison botulinum"] = "botulinum",
  ["the poison calcise"] = "calcise",
  ["the poison chansu"] = "chansu",
  ["the poison charybdon"] = "charybdon",
  ["the poison contortrin"] = "contortrin",
  ["the poison crotamine"] = "crotamine",
  ["the poison dendroxin"] = "dendroxin",
  ["the poison dulak"] = "dulak",
  ["the poison escozul"] = "escozul",
  ["the poison hadrudin"] = "hadrudin",
  ["the poison haemotox"] = "haemotox",
  ["the poison ibululu"] = "ibululu",
  ["the poison inyoka"] = "inyoka",
  ["the poison mactans"] = "mactans",
  ["the poison mantakaya"] = "mantakaya",
  ["the poison mellitin"] = "mellitin",
  ["the poison morphite"] = "morphite",
  ["the poison niricol"] = "niricol",
  ["the poison pyrotoxin"] = "pyrotoxin",
  ["the poison saxitin"] = "saxitin",
  ["the poison senso"] = "senso",
  ["the poison tetrodin"] = "tetrodin",

  ["a potion of allheale"] = "allheale",
  ["a potion of bromides"] = "bromides",
  ["a potion of fire"] = "fire",
  ["a potion of frost"] = "frost",
  ["a potion of galvanism"] = "galvanism",
  ["a potion of healing"] = "healing",
  ["a potion of mana"] = "mana",

  ["an antidote potion"] = "antidote",
  ["a love potion"] = "love",

  ["a choleric purgative"] = "choleric",
  ["a melancholic purgative"] = "melancholic",
  ["a melancholic purgativ"] = "melancholic",
  ["a phlegmatic purgative"] = "phlegmatic",
  ["a sanguine purgative"] = "sanguine",

  ["oil of invisibility"] = "invisibility",
  ["oil of musk"] = "musk",
  ["oil of preservation"] = "preservation",
  ["oil of sharpness"] = "sharpness",

  ["dragonsblood oil"] = "dragonsblood",
  ["jasmine oil"] = "jasmine",
  ["musk oil"] = "musk",
  ["sandalwood oil"] = "sandalwood",
  ["vanilla oil"] = "vanilla",

  ["liniment salve"] = "liniment",
  ["a mending salve"] = "mending",
  ["a regeneration salve"] = "regeneration",

  ["absinthe"] = "absinthe",
  ["glowing ink"] = "magicink",
  ["magical salt"] = "salt",
  ["magical sulfur"] = "sulfur",
  ["quicksilver"] = "quicksilver",
  ["liniment"] = "liniment",
  ["empty"] = "empty",
  ["moonwater"] = "moonwater",
  ["black tea"] = "blacktea",
  ["green tea"] = "greentea",
  ["white tea"] = "whitetea",
  ["oolong tea"] = "oolongtea",
  ["pale beer"] = "palebeer",
  ["amber beer"] = "amberbeer",
  ["dark beer"] = "darkbeer",

  ["apricot brandy"] = "apricotbrandy",
  ["red wine"] = "redwine",
  ["melon liqueur"] = "melonliqueur",
}

contents_rift = main.bootstrap("gear_rift") or {}

local function set_rift(name, item, count)
  if count < 0 then
    count = 0
    prompt.queue("gmcp rift")
  end

  contents_rift[name] = contents_rift[name] or {}
  contents_rift[name][item] = count
  main.archive("gear_rift", contents_rift)
end

function rift(name, item)
  if not item or not contents_rift[name] then
    return 0
  end
  return contents_rift[name][item] or 0
end

function inv(item)
  return rift("normal", item)
end

function maxrift()
  return tonumber(GetVariable("sg1_maxrift") or "2000")
end


function liquid(item)
  return rift("liquid", item)
end

function maxliquid()
  return tonumber(GetVariable("sg1_maxliquid") or "2000")
end


function wield(id, name)
  local id = tostring(id)
  if is_wielded(id) then
    return
  end

  if rewield[id] then
    flags.clear("rewield_try")
    rewield[id] = nil
  end
  display.Debug("Wielded " .. tostring(id) .. ", " .. tostring(name), "gear")
end

function wield_item(name, line, wildcards, styles)
  local id = wildcards[1]
  local name = wildcards[2]
  wield(id, name)
end

function unwield(id, name, dropped)
  if not id and name then
    local items = find_wielded(name)
    if #items > 0 then
      id = items[1]
    else
      display.Alert("No idea what you just unwielded...")
      return
    end
  end

  local id = tostring(id)
  if is_wielded(id) then
    display.Debug("Unwielded " .. id .. ", " .. tostring(inventory[id].name), "gear")
    local un = (flags.get("unwielding") or 0) - 1
    if un <= 0 then
      flags.clear("unwielding")
    else
      flags.set("unwielding", un, 2)
    end
    if un < 0 and not dropped and main.auto("rewield") then
      rewield[id] = true
    end
  end
end

function is_wielded(id)
  for i,w in pairs(inventory) do
    if string.find(w.attrib or "", "l") and i == tostring(id) then
      return true
    end
  end

  return false
end

function find_wielded(name)
  local items = {}
  for id,w in pairs(inventory) do
    if string.find(w.attrib or "", "l") and (not name or string.find(w.name, name)) then
      table.insert(items, tonumber(id))
    end
  end

  return items
end

function find_herb(name)
  if name == "sparkleberry" then
    name = "sparkleberr"
  end
  for _,item in pairs(inventory) do
    if string.find(item.name, name) then
      return true
    end
  end
  return false
end

function find_items(pat, attr)
  local attr = attr or false
  local items = {}
  local re = rex.new(pat)
  for id,item in pairs(inventory) do
    local _,_,m = re:match(item.name)
    if m then
      if not attr or (attr and string.find(item.attrib or "", attr)) then
        table.insert(items, tonumber(id))
      end
    end
  end
  return items
end


function items_list(name, line, wildcards, styles)
  display.q = true
  local wc = string.gsub(wildcards[1] or "", "bearing the name \"(%w+)\"", "bearing the name '%%1'")
  --display.Debug("Items list: '" .. tostring(wc) .. "'", "gear")
  local stuff = json.decode(wc)
  if stuff.location == "inv" then
    inventory = {}

    for _,item in ipairs(stuff.items) do
      inventory[tostring(item.id)] = {name = item.name, attrib = item.attrib or ""}

      if string.find(item.attrib or "", "l") then
        wield(item.id, item.name)
      elseif is_wielded(item.id) then
        unwield(item.id)
      end
    end
  end

  main.archive("gear_inventory", inventory)
  display.q = false
end

function items_add(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "inv" then
    if string.find(stuff.item.attrib or "", "l") then
      wield(stuff.item.id, stuff.item.name)
    end
    display.Debug("Adding " .. stuff.item.id .. " (" .. (stuff.item.name or "<unknown>") .. ") to inventory", "gear")
    inventory[tostring(stuff.item.id)] = {name = stuff.item.name, attrib = stuff.item.attrib or ""}
    main.archive("gear_inventory", inventory)
  end
  display.q = false
end

function items_remove(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "inv" then
    if is_wielded(stuff.item.id) then
      unwield(stuff.item.id, nil, true)
    end
    local herb = flags.get("maybe_ate")
    if herb and inventory[tostring(stuff.item.id)] then
      if string.find(inventory[tostring(stuff.item.id)].name, herb) then
        display.Debug("Ate herb, " .. inventory[tostring(stuff.item.id)].name, "gear")
        actions.ate_herb_checked()
      end
    end
    display.Debug("Removing " .. stuff.item.id .. " from inventory", "gear")
    inventory[tostring(stuff.item.id)] = nil
    main.archive("gear_inventory", inventory)
  end
  display.q = false
end

function items_update(name, line, wildcards, styles)
  display.q = true
  local stuff = json.decode(wildcards[1])
  if stuff.location == "inv" and string.find(stuff.item.attrib or "", "l") then
    wield(stuff.item.id, stuff.item.name)
  elseif is_wielded(stuff.item.id) then
    unwield(stuff.item.id)
  end
  if stuff.location == "inv" then
    display.Debug("Updating " .. stuff.item.id .. " (" .. (stuff.item.name or "<unknown>") .. ") in inventory [" .. (stuff.item.attrib or "") .. "]", "gear")
    inventory[tostring(stuff.item.id)] = {name = stuff.item.name, attrib = stuff.item.attrib or ""}
  end
  main.archive("gear_inventory", inventory)
  display.q = false
end


function rift_list(name, line, wildcards, styles)
  display.q = true
  local rl = json.decode(wildcards[1])
  local maxn = maxrift()
  local maxl = maxliquid()
  contents_rift = {}
  for _,ri in ipairs(rl) do
    local amt = tonumber(ri.amount)
    local n = ri.name
    local t = string.match(ri.desc, "^(%a+): ")

    display.Debug("Rift list '" .. n .. "' (" .. t .. ") : " .. amt, "gear")
    contents_rift[t] = contents_rift[t] or {}
    contents_rift[t][n] = amt

    if t == "normal" and amt > maxn then
      maxn = math.ceil(amt / 1000) * 1000
    elseif t == "liquid" and amt > maxl then
      maxl = math.ceil(amt / 1000) * 1000
    end
  end
  SetVariable("sg1_maxrift", maxn)
  SetVariable("sg1_maxliquid", maxl)
  main.archive("gear_rift", contents_rift)
  display.q = false
end

function rift_change(name, line, wildcards, styles)
  display.q = true
  local rc = json.decode(wildcards[1])
  local n = rc.name
  local t = false
  if rc.desc == "a bag of salt" then
    t = "normal"
  elseif rc.desc == "magical salt" then
    t = "liquid"
  else
    for rn,rt in pairs(contents_rift) do
      if rt[n] then
        t = rn
        break
      end
    end
    if not t then
      return
    end
  end

  local old = rift(t, n)
  display.Debug("Rift change '" .. n .. "' (" .. t .. ") : " .. rc.amount .. " (was " .. old .. ")", "gear")

  set_rift(t, n, tonumber(rc.amount))

  if t == "liquid" then
    local ps = liquid(n)
    if ps < 1 then
      display.Alert("Out of " .. n .. "!")
    elseif ps <= tonumber(GetVariable("sg1_option_sips_low") or "15") then
      display.Alert("Only " .. ps .. " sips of " .. n .. " left")
    end
  elseif t == "normal" then
    if old > rift("normal", n) then
      flags.clear("outr_try")
    end
  end
  display.q = false
end


vial_xlate = {
  ["a smoke-hued, fragment-wrought"] = "a smoke-hued, fragment-wrought vial",
  ["a cubic vial of polished cherr"] = "a cubic vial of polished cherrywood",
  ["an ethereal vial etched with t"] = "an ethereal vial etched with the lunar cycle",
  ["a wooden vial fitted with an a"] = "a wooden vial fitted with an acorn cap",
  ["an iron vial of fire elemental"] = "an iron vial of fire elementals",
  ["a rune-inscribed vial of gleam"] = "a rune-inscribed vial of gleaming emerald",
  ["a polished vial carved from a "] = "a polished vial carved from a rib",
  ["a convoluted blue lampwork via"] = "a convoluted blue lampwork vial",
  ["a crystal vial of budding orch"] = "a crystal vial of budding orchids",
  ["a silver and sapphire leaf via"] = "a silver and sapphire leaf vial",
  ["an adumbral vial entwined by s"] = "an adumbral vial entwined by serpentine gold",
}

function add_potion(name, line, wildcards, styles)
  local id = tonumber(wildcards[1])
  local vial = wildcards[2]
  local linked = string.find(wildcards[3], "%(") ~= nil
  local potion = php.trim(wildcards[3])
  if linked then
    potion = string.match(wildcards[3], "^%((.-)%)*$")
  end
  potion = xlate_potion[potion] or potion
  local sips = tonumber(wildcards[4])
  local months = wildcards[5]

  potions[potion] = potions[potion] or {}
  local vial = php.trim(vial_xlate[vial] or vial)

  display.Debug("Container (" .. vial .. ") of " .. potion .. " with " .. sips .. " sips", "gear")
  table.insert(potions[potion], {id = id, vial = vial, sips = sips, months = months, linked = linked})

  if months == "*" then
    artifact_vials = artifact_vials or {}
    artifact_vials[id] = potion
    main.archive("gear_artifact_vials", artifact_vials)
  end
  if potion == "empty" then
     if (months == "*" or tonumber(months) >= 10) and
        (actions.vial_map[vial] or vial_map[id]) then
      empties[tostring(id)] = vial_map[id] or actions.vial_map[vial] or empties[tostring(id)]
    end
  else
    empties[tostring(id)] = nil
  end

  main.archive("gear_empties", empties)
  main.archive("gear_potions", potions)
end

function decrement_potion(potion, emptied)
  if flags.get("arena") or
     potion == "unknown" or
     potion == "teapot" then
    return
  end

  local potion = xlate_potion[potion] or potion

  if not potions[potion] or #potions[potion] < 1 then
    display.Error("No data on file for potion: " .. potion)
    return
  end

  if potions[potion][1].linked then
    return
  end

  potions[potion][1].sips = potions[potion][1].sips - 1
  if potions[potion][1].sips <= 0 and not emptied then
    display.Error("Sips of '" .. potion .. "' are out of sync. Check PL again.")
  elseif emptied then
    display.Debug("Emptied vial of '" .. potion .. "' (" .. potions[potion][1].id .. ")", "gear")
    display.Alert("Vial of " .. potion .. " emptied")
    empties[tostring(potions[potion][1].id)] = actions.vial_map[potions[potion][1].vial] or potion
    potions["empty"] = potions["empty"] or {}
    table.insert(potions["empty"], potions[potion][1])
    main.archive("gear_empties", empties)
    table.remove(potions[potion], 1)
  else
    display.Debug("Decremented vial of '" .. potion .. "' (" .. potions[potion][1].id .. ") to " .. potions[potion][1].sips .. " sips left", "gear")
    local ps = sips(potion)
    if ps <= tonumber(GetVariable("sg1_option_sips_low") or "10") then
      display.Alert("Only " .. ps .. " sips of " .. potion .. " left")
    end
  end

  main.archive("gear_potions", potions)
end

function is_poison(liquid)
  return string.find(GetVariable("sg1_fluid_poison") or "", liquid) ~= nil
end

function decrement_application(potion)
  local potion = xlate_potion[potion] or potion
  if not potions[potion] or #potions[potion] < 1 then
    display.Error("No data on file for potion: " .. potion)
    return
  end

  decrement_potion(potion, potions[potion][1].sips == 1)
end

function decrement_poison(poison)
  if flags.get("arena") then
    return
  end

  if not potions[poison] or #potions[poison] < 1 then
    display.Error("No data on file for poison: " .. poison)
    return
  end

  if potions[poison][1].linked then
    return
  end

  potions[poison][1].sips = potions[poison][1].sips - 1
  if potions[poison][1].sips <= 0 then
    empties[tostring(potions[poison][1].id)] = actions.vial_map[potions[poison][1].vial] or poison
    potions["empty"] = potions["empty"] or {}
    table.insert(potions["empty"], potions[poison][1])
    main.archive("gear_empties", empties)
    table.remove(potions[poison], 1)
  end

  main.archive("gear_potions", potions)
end

function sips(potion)
  local potion = xlate_potion[potion] or potion

  if not potions[potion] then
    return 0
  end

  local s = 0
  for _,p in ipairs(potions[potion]) do
    if p.linked then
      s = s + rift("liquid", potion)
    else
      s = s + p.sips
    end
  end

  return s
end

function vials(potion)
  local potion = xlate_potion[potion] or potion

  if not potions[potion] then
    return 0
  end

  return #potions[potion]
end

function reset_potions()
  potions = {}
  empties = {}
  DeleteVariable("sg1_gear_potions")
  DeleteVariable("sg1_gear_empties")
end

function show_potion(name, col)
  if col == 1 then
    display.Prefix()
  end
  local s = sips(name)
  local clr = "silver"
  if s < 1 then
    s = liquid(name)
    if s < 1 then
      clr = "red"
    else
      clr = "royalblue"
      if not flags.get("unlinked") then
        flags.set("unlinked", true)
      end
    end
  end
  ColourTell("silver", "", string.format("    %-13s", name))
  if GetVariable("sg1_option_no_vial_count") ~= "1" then
    ColourTell("silver", "", string.format(" %3d", vials(name)))
  end
  ColourTell(clr, "", string.format("  %4d ", s))
  if col > 2 then
    Note("")
  end
  col = (col % 3) + 1
  return col
end

function show_potions(nocr)
  local plist = copytable.shallow(potions)

  local oils = { "dragonsblood", "invisibility", "jasmine", "musk", "preservation", "sandalwood", "sharpness", "vanilla" }
  local poisons = { "aleutian", "anatine", "anerod", "botulinum", "calcise", "chansu",
                    "charybdon", "contortrin", "crotamine", "dendroxin", "dulak", "escozul",
                    "hadrudin", "haemotox", "ibululu", "inyoka", "mactans", "mantakaya",
                    "mellitin", "morphite", "niricol", "pyrotoxin", "saxitin", "senso", "tetrodin" }
  local elixirs = { "allheale", "antidote", "bromides", "choleric", "fire", "frost",
                    "galvanism", "healing", "love", "mana", "phlegmatic", "quicksilver",
                    "sanguine", "vitae" }
  local salves = { "liniment", "melancholic", "mending", "regeneration" }

  display.Info("Vial Summary Report:")

  local col = 1
  display.Prefix()
  ColourNote("yellow", "", "  Potions")
  for _,name in ipairs(elixirs) do
    col = show_potion(name, col)
    plist[name] = nil
  end
  if col ~= 1 then
    Note("")
  end

  col = 1
  display.Prefix()
  ColourNote("yellow", "", "  Salves")
  for _,name in ipairs(salves) do
    col = show_potion(name, col)
    plist[name] = nil
  end
  if col ~= 1 then
    Note("")
  end

  col = 1
  display.Prefix()
  ColourNote("yellow", "", "  Poisons")
  for _,name in ipairs(poisons) do
    col = show_potion(name, col)
    plist[name] = nil
  end
  if col ~= 1 then
    Note("")
  end

  col = 1
  display.Prefix()
  ColourNote("yellow", "", "  Oils")
  for _,name in ipairs(oils) do
    if sips(name) > 0 then
      col = show_potion(name, col)
    end
    plist[name] = nil
  end
  if col ~= 1 then
    Note("")
  end

  col = 1
  display.Prefix()
  ColourNote("yellow", "", "  Miscellaneous")
  for name in pairs(plist) do
    if sips(name) > 0 then
     col = show_potion(name, col)
   end
  end
  if col ~= 1 then
    Note("")
  end

  if plist["empty"] and #plist["empty"] > 0 then
    display.Prefix()
    ColourNote("yellow", "", "  Empty")
    local evt = {}
    for _,v in pairs(plist["empty"]) do
      display.Prefix()
      if v.months == "*" or tonumber(v.months) >= 10 then
        ColourTell("silver", "", string.format("    %7d", v.id))
      else
        ColourTell("dimgray", "", string.format("    %7d", v.id))
      end
      if empties[tostring(v.id)] then
        ColourTell("darkkhaki", "", string.format("  %-15s", empties[tostring(v.id)]))
      elseif actions.vial_map[v.vial] then
        ColourTell("darkkhaki", "", string.format("  %-15s", actions.vial_map[v.vial]))
      end
      Note("")
    end
  end

  if flags.get("unlinked") then
    display.Prefix()
    ColourNote("royalblue", "", "                     nnn", "silver", "", " = unlinked liquids")
  end

  if IsConnected() and nocr ~= true then
    Send("")
  end
end

function show_herbs(nocr)
  display.Info("Herb Summary Report:")
  display.Prefix()
  ColourNote("silver", "", string.format("  %-12s  %4s  %6s", "Plant", "Inv", "Demand"))
  display.Prefix()
  ColourNote("silver", "", string.format("  %-12s  %4s  %6s", "-----", "---", "------"))
  for _,k in ipairs(herb_list) do
    if k ~= "spices" then
      display.Prefix()
      ColourTell("darkcyan", "", string.format("  %-12s", k))
      local i = inv(k)
      ColourTell("blue", "", string.format("  %4d", i))
      
      local d = maxrift() - i
      local c = "orange"
      if d > 1000 then
        c = "red"
      elseif d <= 0 then
        c = "gray"
      end
      ColourNote(c, "", string.format("  %5d", d))
    end
  end

  if IsConnected() and nocr ~= true then
    Send("")
  end
end


local rift_req = true
for _ in pairs(contents_rift) do
  rift_req = false
  break
end
if rift_req then
  prompt.queue("gmcp rift")
end
