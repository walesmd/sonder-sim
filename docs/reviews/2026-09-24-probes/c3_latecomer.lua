package.path = "src/?.lua;" .. package.path
local world, seed, at, home = arg[1], tonumber(arg[2]), tonumber(arg[3]), arg[4]
local u = require("worlds." .. world)(seed)
u:run(at - 1)
local len_before = u.annals:len()
local first
u:add_faction("newcomer", home, function(b, _, tick)
  if not first then
    local ch = b:chronology()
    local old, max_age = 0, 0
    for i = 1, #ch do
      if ch[i].tick < tick then old = old + 1 end
      if tick - ch[i].tick > max_age then max_age = tick - ch[i].tick end
    end
    local all_learned_now = true
    for i = 1, #ch do if ch[i].learned ~= tick then all_learned_now = false end end
    first = { tick = tick, n = #ch, old = old, max_age = max_age, all_now = all_learned_now, annals = u.annals:len() }
  end
  return {}
end)
u:step()
print(("%s seed %d: enrolled after tick %d (annals %d); first morning tick %d, annals at its turn %d; store holds %d, of which %d from before today; oldest is %d days old; all learned=today: %s")
  :format(world, seed, at - 1, len_before, first.tick, first.annals, first.n, first.old, first.max_age, tostring(first.all_now)))
