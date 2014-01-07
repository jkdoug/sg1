module (..., package.seeall)

function reset(name, line, wildcards, styles)
  EnableTriggerGroup("Forging", false)
  todo.del_match{"^forge$", "^craft armour$", "^g .- from forge", "^temper .-$", "^forge for .-$"}
  if #wildcards[1] < 1 then
    display.Info("Forging reset")
  end
end


function fire(name, line, wildcards, styles)
  Send("outr 1 coal")
  Send("put coal in forge confirm")
  Send("fire forge")
end

function initiate(name, line, wildcards, styles)
  Execute("do1 forge for " .. wildcards[1])
  EnableTrigger("forging_refine__", true)
end

function craft(name, line, wildcards, styles)
  Execute("do1 craft armour " .. wildcards[1])
  EnableTrigger("forging_refine_leather__", true)
end

function smelt(name, line, wildcards, styles)
  Send("put " .. wildcards[1] .. " in forge confirm")
  Send("smelt " .. wildcards[1])
  EnableTrigger("forging_probe__", true)
  Send("p forge")
end

function temper(name, line, wildcards, styles)
  for x = 1,tonumber(wildcards[4]) do
    Execute("do temper " .. wildcards[1] .. " " .. wildcards[2] .. " " .. wildcards[3])
  end
end


function refine(name, line, wildcards, styles)
  Execute("do1 forge")
  EnableTrigger("forging_refine_done__", true)
end

function refine_leather(name, line, wildcards, styles)
  Execute("do1 craft armour")
  EnableTrigger("forging_refine_done_leather__", true)
end

function refined(name, line, wildcards, styles)
  display.Info("All done! Time for tempering.")
  todo.del("forge")
  EnableTrigger("forging_refine__", false)
  EnableTrigger("forging_refine_done__", false)
  EnableTrigger("forging_probe__", true)
  Execute("dofree1 p forge")
end

function refined_leather(name, line, wildcards, styles)
  display.Info("All done!")
  todo.del("craft armour")
  EnableTrigger("forging_refine_leather__", false)
  EnableTrigger("forging_refine_done_leather__", false)
end

function mercury(name, line, wildcards, styles)
  Execute("dofree g mercury from " .. wildcards[1] .. "|inr mercury")
end

function full(name, line, wildcards, styles)
  Send("p forge")
  todo.del_match("^temper .-$")
  EnableTrigger("forging_probe__", true)
end

function probed(name, line, wildcards, styles)
  prompt.queue(function () EnableTrigger("forging_probe__", false) end)	
  if not string.find(wildcards[0], "Nothing") then
    Execute("dofree1 g " .. wildcards[1] .. " from forge")
  end
end

function failed(name, line, wildcards, styles)
  Execute("reset forge quietly")
end

function failed_temper(name, line, wildcards, styles)
  todo.del_match("^temper .-$")
end
