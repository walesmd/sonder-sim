-- Synthetic belief-store probe against the working tree's books.lua.
-- Scenario A: more framework legs since the anchor than decl.window holds.
-- Scenario B: the owner's own tally pushed out of its anchor window by
--             foreign tallies (fallback to the founding).
-- Scenario C: a world leg overflowing its window.
-- Scenario D: control — everything within window, exact answer.
package.path = "src/?.lua;" .. package.path
local Belief = require "sonder.belief"
local Books = require "sonder.books"

local next_id = 0
local function ev(tick, kind, location, payload)
   next_id = next_id + 1
   return { id = next_id, tick = tick, kind = kind, location = location,
      magnitude = 1, loudness = 1, payload = payload, causes = {} }
end

local function decl(window, anchor_window)
   return {
      columns = { "grain", "cents" },
      window = window,
      commodities = { grain = "grain" },
      money = "cents",
      anchors = {
         { kind = "civ.tally", by = "seat", window = anchor_window },
         { kind = "civ.founded", by = "name" },
      },
      legs = {
         { kind = "war.spoils", window = window, apply = function(b, e, owner)
            if e.payload.target == owner.name then b.grain = b.grain - e.payload.seized end
         end },
      },
   }
end
local OWNER = { name = "alpha", seat = "alpha-home" }

local function show(label, s, d, truth)
   local ok, b, since = pcall(Books.believed, s, d, OWNER)
   if not ok then print(label, "ERROR", b) return end
   print(("%s: believed grain %d cents %d since id %d | truth grain %d cents %d | %s")
      :format(label, b.grain, b.cents, since, truth.grain, truth.cents,
         (b.grain == truth.grain and b.cents == truth.cents) and "EXACT" or "SILENTLY WRONG"))
end

-- Scenario A: founding (grain 50), tally day 5 (grain 100), then 4 deliveries of 10.
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   local t = ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 0 })
   s:receive(t, 5)
   for d = 6, 9 do
      s:receive(ev(d, "cargo.delivered", "alpha-home",
         { recipient = "alpha", commodity = "grain", units = 10 }), d)
   end
   show("A window=3, 4 deliveries after anchor", s, decl(3, 3), { grain = 140, cents = 0 })
   show("A window=4 (control)", s, decl(4, 3), { grain = 140, cents = 0 })
end

-- Scenario A2: payments (money leg) overflow
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   s:receive(ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 1000 }), 5)
   for d = 6, 10 do
      s:receive(ev(d, "payment.shipped", "alpha-home", { payer = "alpha", amount = 100 }), d)
   end
   show("A2 window=3, 5 payments after anchor", s, decl(3, 3), { grain = 100, cents = 500 })
end

-- Scenario A3: overflow by OTHER owners' legs (window counts arrivals across everyone)
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   s:receive(ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 0 }), 5)
   s:receive(ev(6, "cargo.delivered", "alpha-home",
      { recipient = "alpha", commodity = "grain", units = 10 }), 6)
   for d = 7, 9 do
      s:receive(ev(d, "cargo.delivered", "beta-home",
         { recipient = "beta", commodity = "grain", units = 10 }), d)
   end
   show("A3 window=3, 1 own + 3 foreign deliveries", s, decl(3, 3), { grain = 110, cents = 0 })
end

-- Scenario B: own tally evicted from the anchor window by 3 foreign tallies.
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   s:receive(ev(1, "cargo.delivered", "alpha-home",
      { recipient = "alpha", commodity = "grain", units = 5 }), 1)
   s:receive(ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 0 }), 5)
   for i = 1, 3 do
      s:receive(ev(5, "civ.tally", "beta-home", { grain = 999, cents = 999 }), 5 + i)
   end
   show("B anchor window=3, own tally + 3 foreign", s, decl(6, 3), { grain = 100, cents = 0 })
   show("B anchor window=4 (control)", s, decl(6, 4), { grain = 100, cents = 0 })
end

-- Scenario B2: evicted and no founding ever arrived -> error (not silent)
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 0 }), 5)
   for i = 1, 3 do
      s:receive(ev(5, "civ.tally", "beta-home", { grain = 999, cents = 999 }), 5 + i)
   end
   show("B2 evicted, no founding", s, decl(6, 3), { grain = 100, cents = 0 })
end

-- Scenario B3: founding itself evicted from the default window (decl.window) by others' foundings
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   for i = 1, 3 do
      s:receive(ev(0, "civ.founded", "x", { name = "other" .. i, grain = 1, cents = 1 }), 0)
   end
   show("B3 founding evicted by 3 foreign foundings (window 3)", s, decl(3, 3), { grain = 50, cents = 0 })
end

-- Scenario C: world leg overflow
do
   next_id = 0
   local s = Belief.new("alpha")
   s:receive(ev(0, "civ.founded", "alpha-home", { name = "alpha", grain = 50, cents = 0 }), 0)
   s:receive(ev(5, "civ.tally", "alpha-home", { grain = 100, cents = 0 }), 5)
   for d = 6, 9 do
      s:receive(ev(d, "war.spoils", "alpha-home", { target = "alpha", seized = 5 }), d)
   end
   show("C world leg window=3, 4 spoils", s, decl(3, 3), { grain = 80, cents = 0 })
end
