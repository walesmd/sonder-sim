package.path = "src/?.lua;" .. package.path
local world, seed, ticks = arg[1], math.tointeger(tonumber(arg[2])), math.tointeger(tonumber(arg[3]))
local u = require("worlds." .. world)(seed)
u:run(ticks)
local N = u.annals:len()
local nobody = {}
for id = 1, N do nobody[id] = true end
local parts = {}
for _, f in ipairs(u.factions) do
  local ids, n, own = {}, 0, 0
  for _, b in ipairs(f.store:chronology()) do
    if not ids[b.id] then ids[b.id] = true; n = n + 1 end
    nobody[b.id] = nil
  end
  -- what share of the *other* civs' home events did it learn? 
  parts[#parts + 1] = ("%s %d/%d=%.1f%%"):format(f.name, n, N, 100 * n / N)
end
local cnt = 0 for _ in pairs(nobody) do cnt = cnt + 1 end
print(("%s seed=%d ticks=%d annals=%d known-to-nobody=%d :: %s"):format(world, seed, ticks, N, cnt, table.concat(parts, "; ")))
