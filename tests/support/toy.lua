-- tests/support/toy.lua — the placeholder universe, shared by specs.
--
-- The same market and war office main.lua runs (card 118 replaces
-- all three copies of this arrangement with the real toy world).
-- Kept in one place so specs can't drift apart on what "the toy
-- universe" means — a golden hash pinned by one spec should be
-- recomputable by any other.

local Universe = require "sonder.universe"

return function(seed)
   local u = Universe.new(seed)
   local last_market, last_war = 1, 1
   u:add_system("market", function(universe, stream)
      local drift = stream:int(-3, 3)
      last_market = universe:emit{
         kind = "market.drift",
         location = "the-void",
         magnitude = math.abs(drift),
         visibility = "public",
         payload = { drift = drift },
         causes = { last_market },
      }
   end)
   u:add_system("war", function(universe, stream)
      local muster = stream:int(0, 9)
      last_war = universe:emit{
         kind = "war.muster",
         location = "the-void",
         magnitude = muster,
         visibility = "regional",
         payload = { muster = muster },
         causes = { last_war },
      }
   end)
   return u
end
