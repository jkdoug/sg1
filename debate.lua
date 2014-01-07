module (..., package.seeall)

local m2d = {
    pedantic = {
      good = "passion",
      minor = "pontification",
      bad = "pettifoggery",
    },
    cautious = {
      bad = "passion",
      good = "pontification",
      minor = "pettifoggery",
    },
    analytical = {
      minor = "passion",
      bad = "pontification",
      good = "pettifoggery",
    },
}

local d2m = {
    passion = {
      bad = "pedantic",
      good = "cautious",
      minor = "analytical",
    },
    pontification = {
      minor = "pedantic",
      bad = "cautious",
      good = "analytical",
    },
    pettifoggery = {
      good = "pedantic",
      minor = "cautious",
      bad = "analytical",
    },
}

local opp_mindset = {}

new_mindset = false

mindsets = { 3, 19 }
attacks = { 2, 19 }

function target(name)
  if name and #name > 0 then
    if string.lower(name) ~= target() then
      opp_mindset = {}
    end

    SetVariable("target_debate", name)
    display.Info("Targeting for debate: " .. name)

    main.info("target_debate")
    if IsConnected() then
      Send("")
    end
  end

  return string.lower(GetVariable("target_debate") or "nobody")
end

function mindset(ms)
  if ms then
    SetVariable("sg1_mindset", ms)
    if new_mindset and new_mindset == ms then
      new_mindset = nil
      flags.clear("mindset_try")
    end
  end

  return GetVariable("sg1_mindset") or "none"
end

function attacked(name, deb, ms)
  if not string.find(string.lower(name), target()) then
    Execute("dt " .. name)
  end

  display.Prefix()
  if d2m[deb].good == ms then
    ColourNote("black", "limegreen", "Debate Good")
  elseif d2m[deb].minor == ms then
    ColourNote("yellow", "peru", "Debate Okay")
  else
    ColourNote("white", "maroon", "Debate BAD")
  end

  local p1 = mindsets[1] or 10
  local p2 = mindsets[2] or 60

  local prob = math.random(100)
  display.Debug("Mindset probabilities are " .. p1 .. " and " .. p2 .. "; rolled " .. prob, "debate")
  if prob <= p1 then
    new_mindset = d2m[deb].bad
  elseif prob <= p2 then
    new_mindset = d2m[deb].minor
  else
    new_mindset = d2m[deb].good
  end

  display.Debug("New mindset will be " .. new_mindset .. " (Probability " .. prob .. ")", "debate")

  if new_mindset ~= mindset() then
    scan.process()
  end
end

function hit(name, deb, ms)
  opp_mindset = opp_mindset or {}
  table.insert(opp_mindset, ms)
  if #opp_mindset > 3 then
    table.remove(opp_mindset, 1)
  end

  display.Prefix()
  if d2m[deb].good == ms then
    ColourNote("white", "maroon", "Debate BAD")
  elseif d2m[deb].minor == ms then
    ColourNote("yellow", "peru", "Debate Okay")
  else
    ColourNote("black", "limegreen", "Debate Good")
  end

  if main.auto("debate") then
    flags.set("doing", true, 0.5)
    Execute("deb")
  end
end

function target_mindset()
  if not opp_mindset or #opp_mindset < 1 then
    return "pedantic"
  end

  local ms = { pedantic = 0, cautious = 0, analytical = 0 }
  for _,m in ipairs(opp_mindset) do
    ms[m] = ms[m] + 1 
  end

  if ms.pedantic >= ms.cautious and ms.pedantic >= ms.analytical then
    return "pedantic"
  elseif ms.cautious >= ms.pedantic and ms.cautious >= ms.analytical then
    return "cautious"
  else
    return "analytical"
  end
end

function attack(name)
  local oms = target_mindset()
  display.Debug("Opponent's mindset estimated to be " .. oms, "debate")

  local p1 = attacks[1] or 10
  local p2 = attacks[2] or 40

  local prob = math.random(100)
  local attack = ""
  display.Debug("Attack probabilities are " .. p1 .. " and " .. p2 .. "; rolled " .. prob, "debate")
  if prob <= p1 then
    attack = m2d[oms].bad
  elseif prob <= p2 then
    attack = m2d[oms].minor
  else
    attack = m2d[oms].good
  end

  local targ = name or GetVariable("target_debate") or "nobody"
  Execute("do1 debate " .. targ .. " with " .. attack)
end

function over()
  todo.del_match("^debate %w+ with %a+$")
  opp_mindset = {}
  SetVariable("target_debate", "nobody")
end


function handle_target(name, line, wildcards, styles)
  target(wildcards[1])
end

function handle_debate(name, line, wildcards, styles)
  local t = wildcards[1]
  if t and #t > 0 then
    target(t)
  end
  attack()
end

function handle_mindset(name, line, wildcards, styles)
  if new_mindset then
    Execute("mindset " .. new_mindset)
  end
end

function handle_attack(name, line, wildcards, styles)
  local a,m = string.match(name, "^debate_(%a+)_(%a+)__$")
  attacked(wildcards[1], a, m)
end

function handle_hit(name, line, wildcards, styles)
  local m,a = string.match(name, "^debate_(%a+)_(%a+)__$")
  hit(wildcards[1], a, m)
end

function handle_setmind(name, line, wildcards, styles)
  mindset(wildcards[1])
end

function handle_win(name, line, wildcards, styles)
  display.Info("** Congratulations! You won the debate! **")
  over()
end

function handle_loss(name, line, wildcards, styles)
  display.Info("** Well, you can't win 'em all! **")
  over()
  affs.add_queue("ego_shattered")
end

function handle_shattered(name, line, wildcards, styles)
  display.Info(wildcards[1] .. " is already shattered")
  over()
end

function handle_goblet(name, line, wildcards, styles)
  affs.del_queue("ego_shattered")
end
