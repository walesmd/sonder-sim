-- src/sonder/travel.lua — the travel scheduler: one calendar, many
-- roads.
--
-- Card 153. The same scheduling shape kept getting rebuilt — the
-- courier's pending buckets, the battle system's march list, the
-- exchange's order arrivals — so it is extracted once, here, and
-- rebuilt never again. A Travel is a calendar queue: items are
-- scheduled for an arrival tick and drained at exactly that tick,
-- in scheduling order — schedule in event-id order and delivery
-- comes back in id order by construction, not by sort. Each owner
-- instantiates its own: the code is shared, the state never is,
-- and every owner keeps draining at its own turn in the tick, which
-- is where delivery order was always decided.
--
-- Determinism (law 1): the calendar is indexed by integer arrival
-- tick and only ever read at exactly one tick — no iteration, no
-- pairs(), no data structure with opinions about order. Nothing
-- here rolls dice, reads clocks, or knows what is being carried:
-- what arrival *means* — a belief delivered, a raid landing, grain
-- in a granary — belongs to the owner, per-cargo, forever.

local Travel = {}
Travel.__index = Travel

function Travel.new()
   return setmetatable({
      calendar = {}, -- arrival tick → items, in scheduling order
   }, Travel)
end

-- Put an item on the calendar. Arrivals already due belong to the
-- caller (deliver them now, at the call site, where "now" is
-- known); the calendar holds only the future.
function Travel:schedule(arrives, item)
   assert(math.type(arrives) == "integer",
      "travel: arrival must be an integer tick")
   local bucket = self.calendar[arrives]
   if not bucket then
      bucket = {}
      self.calendar[arrives] = bucket
   end
   bucket[#bucket + 1] = item
end

-- Everything due at exactly this tick, in scheduling order; the
-- day's page is torn out as it's read. Draining the same tick twice
-- yields nothing the second time, and ticks nothing was scheduled
-- for were never allocated at all.
function Travel:due(now)
   assert(math.type(now) == "integer",
      "travel: now must be an integer tick")
   local bucket = self.calendar[now]
   self.calendar[now] = nil
   return bucket or {}
end

return Travel
