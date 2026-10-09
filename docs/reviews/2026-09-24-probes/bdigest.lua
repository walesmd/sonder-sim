package.path = "src/?.lua;" .. package.path
local Carriage = require "sonder.carriage"
local Seal = require "sonder.seal"
local fnv = require "sonder.fnv"
local world, seed, ticks, mode, kind = arg[1], math.tointeger(tonumber(arg[2])), math.tointeger(tonumber(arg[3])), arg[4], arg[5]
local orig, touched = Carriage.arrival, 0
if mode ~= "none" then
  Carriage.arrival = function(self, e, name, home)
    local t, row = orig(self, e, name, home)
    if t ~= nil and e.kind == kind then
      touched = touched + 1
      if mode == "drop" then return nil end
      return t + 1, row
    end
    return t, row
  end
end
local u = require("worlds." .. world)(seed)
u:run(ticks)
local h, rows = fnv.offset, 0
for i = 1, #u.factions do
  local j = u.factions[i].store:chronology()
  for k = 1, #j do rows = rows + 1; h = fnv.string(h, ("%s:%d@%d;"):format(u.factions[i].name, j[k].id, j[k].learned)) end
end
print(("%s %s %s touched=%d events=%d seal=%s belief_rows=%d belief_digest=%016x"):format(world, mode, kind or "-", touched, u.annals:len(), Seal.of(u.annals):hex(), rows, h))
