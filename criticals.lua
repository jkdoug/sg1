module (..., package.seeall)

require "main"
local php = require "php"

local levels = php.Table()
levels["CRITICAL"] = "Normal"
levels["CRUSHING CRITICAL"] = "Crushing"
levels["OBLITERATING CRITICAL"] = "Obliterating"
levels["ANNIHILATINGLY POWERFUL CRITICAL"] = "Annihilating"
levels["WORLD-SHATTERING CRITICAL"] = "World"

local stats = main.bootstrap("criticals") or { misses = 0, attacks = 0, hits = {} }

function reset()
  stats = { misses = 0, attacks = 0, hits = {} }
  main.archive("criticals", stats)
  display.Info("Critical hits reset")
  if IsConnected() then
    Send("")
  end
end

function attack()
  stats.attacks = count("attacks") + 1
  main.archive("criticals", stats)
end

function miss()
  stats.misses = count("misses") + 1
  main.archive("criticals", stats)
end

function hit(name, line, wildcards, styles)
  local l = string.lower(levels[wildcards[1]])
  stats.hits[l] = count(l) + 1
  main.archive("criticals", stats)
end

function count(thing)
  local thing = string.lower(thing)
  if thing == "attacks" then
    return stats.attacks or 0
  elseif thing == "misses" then
    return stats.misses or 0
  elseif thing == "total" then
    local total = 0
    for _,crit in levels:pairs() do
      total = total + count(crit)
    end
    return total
  end

  return stats.hits[thing] or 0
end

function show()
  display.Info("Critical Hits Report:")
  local total = count("total")
  if total <= 0 then
    display.Prefix()
    ColourNote("silver", "black", "  No data yet!")
    return
  end

  if stats.attacks > 0 then
    display.Prefix()
    ColourNote("silver", "black", string.format("  %-25s  %6d", "Attacks", stats.attacks))

    if stats.misses > 0 then
      local pct = stats.misses / stats.attacks * 100.0

      display.Prefix()
      ColourNote("silver", "black", string.format("  %-25s  %6d  %6s%%", "Misses", stats.misses, string.format("%3.2f", pct)))
    end
  end

  display.Info("")

  for _,crit in levels:pairs() do
    local pct = 0
    local ct = count(crit)
    if total > 0 then
      pct = ct / total * 100.0
    end
    if crit == "World" then
      crit = "World-Shattering"
    end
    display.Prefix()
    ColourNote("silver", "black", string.format("  %-25s  %6d  %6s%%", crit, ct, string.format("%3.2f", pct)))
  end

  display.Prefix()
  ColourNote("gray", "black", string.format("  %-25s  %6s", string.rep("-", 25), string.rep("-", 6)))

  display.Prefix()
  ColourNote("silver", "black", string.format("  %-25s  %6d", "Total critical hits", total))

  if IsConnected() then
    Send("")
  end
end

if GetVariable("sg1_crit_misses") then
  stats.misses = tonumber(GetVariable("sg1_crit_misses") or "0")
  DeleteVariable("sg1_crit_misses")
end
if GetVariable("sg1_crit_attacks") then
  stats.attacks = tonumber(GetVariable("sg1_crit_attacks") or "0")
  DeleteVariable("sg1_crit_attacks")
end
for _,l in levels:pairs() do
  local lc = string.lower(l)
  stats.hits[lc] = tonumber(GetVariable("sg1_crit_" .. lc) or stats.hits[lc] or "0")
  DeleteVariable("sg1_crit_" .. lc)  
end
main.archive("criticals", stats)
