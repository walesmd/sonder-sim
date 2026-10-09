-- Independent analytic count of the lines main.lua's trace() would
-- print for each event: lines(id) = 1 + sum(lines(c) for c in causes).
-- Also counts distinct ancestors (what a visited-set trace would print).
-- Usage: ./lua <this> WORLD SEED TICKS [THRESHOLD]
package.path = "src/?.lua;" .. package.path
local world, seed, ticks = arg[1], math.tointeger(arg[2]), math.tointeger(arg[3])
local threshold = tonumber(arg[4] or "10000")
local u = require("worlds." .. world)(seed)
for _ = 1, ticks do u:step() end
local n = u.annals:len()
local lines = {}
local ev = {}
for id = 1, n do
   local e = u.annals:get(id)
   ev[id] = e
   local c = 1.0
   for i = 1, #e.causes do
      c = c + lines[e.causes[i]]
   end
   lines[id] = c
end
local function distinct(id)
   local seen, stack, count = {}, { id }, 0
   while #stack > 0 do
      local x = table.remove(stack)
      if not seen[x] then
         seen[x] = true
         count = count + 1
         local e = ev[x]
         for i = 1, #e.causes do stack[#stack + 1] = e.causes[i] end
      end
   end
   return count
end
print(("%s seed %d ticks %d: %d events"):format(world, seed, ticks, n))
-- first event (by id) over threshold
local first
for id = 1, n do
   if lines[id] > threshold then first = id break end
end
if first then
   local e = ev[first]
   print(("first event over %g lines: id %d tick %d kind %s lines %.0f distinct %d")
      :format(threshold, first, e.tick, e.kind, lines[first], distinct(first)))
   -- smallest tick with any event over threshold (same as first by id if ids are tick-ordered)
end
-- report requested ids
for i = 5, #arg do
   local id = math.tointeger(arg[i])
   local e = ev[id]
   print(("id %d tick %d kind %s lines %.6g distinct %d causes %d")
      :format(id, e.tick, e.kind, lines[id], distinct(id), #e.causes))
end
-- max
local maxid, maxv = 1, 0
for id = 1, n do if lines[id] > maxv then maxid, maxv = id, lines[id] end end
print(("max: id %d tick %d kind %s lines %.6g distinct %d"):format(maxid, ev[maxid].tick, ev[maxid].kind, maxv, distinct(maxid)))
-- per-tick maximum for a range around threshold crossing
if first then
   local t0 = ev[first].tick
   for t = math.max(0, t0 - 3), t0 + 3 do
      local best, bid = 0, nil
      for id = 1, n do
         if ev[id].tick == t and lines[id] > best then best, bid = lines[id], id end
      end
      if bid then print(("  tick %d: max lines %.6g at id %d (%s)"):format(t, best, bid, ev[bid].kind)) end
   end
end
