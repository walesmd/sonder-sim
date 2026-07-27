-- tests/support/toy.lua — the placeholder universe, shared by specs.
--
-- The same arrangement main.lua runs (card 118 replaces all of this
-- with the real toy world). Kept in one place so specs can't drift
-- apart on what "the toy universe" means — a golden hash pinned by
-- one spec should be recomputable by any other.
--
-- The market is ambient physics: a system, drifting blindly. The war
-- office is the first believer (card 117): a faction whose decision
-- code is handed beliefs, a stream, and the tick — and musters what
-- it believes the market justifies, citing the drift it acted on.

local Universe = require "sonder.universe"

local function war_decide(beliefs, stream, tick)
   local drift = beliefs:latest("market.drift")
   if not drift then
      -- Ignorance is free, and visible: a war office that has heard
      -- nothing doesn't muster zero levies — it doesn't muster.
      return {}
   end
   local muster = drift.magnitude * 2 + stream:int(0, 3)
   return { {
      kind = "war.muster",
      location = "the-void",
      magnitude = muster,
      visibility = "regional",
      payload = { muster = muster },
      causes = { drift.id },
   } }
end

return function(seed)
   local u = Universe.new(seed)
   local last_market = 1
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
   u:add_faction("war", war_decide)
   return u
end
