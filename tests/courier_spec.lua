-- tests/courier_spec.lua — news crosses distance. The card-122
-- courier delivers each event ceil(distance ÷ channel speed) ticks
-- after it happens, in id order within a tick, stamps every believed
-- copy with the tick it was learned — and at distance zero it is the
-- pass-through courier, bit for bit.

local Universe = require "sonder.universe"
local VOCAB = require "support.vocabulary"

-- A beacon: a system that emits one legal event (grain.hunger — the
-- vocabulary doesn't care that nobody is hungry) from a chosen place
-- at a chosen tick.
local function beacon(u, name, at, from)
   u:add_system(name, function(universe, _, tick)
      if tick == at then
         universe:emit{
            kind = "grain.hunger",
            location = from,
            magnitude = 1,
            loudness = "loud",
            payload = { shortfall = 1 },
            causes = { 1 },
         }
      end
   end)
end

-- A listener: a faction that never acts, only remembers. Returns the
-- per-tick count of hunger rows its store held at decide time, plus a
-- window into the store itself (specs may look; decision code never
-- could).
local function listener(u, home)
   local heard, store = {}, nil
   u:add_faction("listener", home, function(beliefs, _, tick)
      store = beliefs
      heard[tick] = #beliefs:recall("grain.hunger")
      return {}
   end)
   return heard, function() return store end
end

describe("the courier", function()
   it("delivers across distance: three days away is three days late", function()
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            return 3
         end,
      })
      beacon(u, "beacon", 1, "beacon-isle")
      local heard = listener(u, "far-shore")
      u:run(6)
      -- emitted at tick 1, arrives at tick 1 + 3 = 4, not a day sooner
      assert.same({ 0, 0, 0, 1, 1, 1 },
         { heard[1], heard[2], heard[3], heard[4], heard[5], heard[6] })
   end)

   it("channel speed divides the days, rounded up in integers", function()
      -- distance 5 at speed 2: ceil(5/2) = 3 ticks, no floats involved
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            return 5
         end,
         channel_speed = 2,
      })
      beacon(u, "beacon", 1, "beacon-isle")
      local heard = listener(u, "far-shore")
      u:run(5)
      assert.same({ 0, 0, 0, 1, 1 },
         { heard[1], heard[2], heard[3], heard[4], heard[5] })
   end)

   it("stamps the believed copy: tick is when it happened, learned is when the news landed", function()
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            return 3
         end,
      })
      beacon(u, "beacon", 1, "beacon-isle")
      local _, store = listener(u, "far-shore")
      u:run(5)
      local held = store():latest("grain.hunger")
      assert.equal(1, held.tick)
      assert.equal(4, held.learned)
   end)

   it("keeps id order when far news and fresh news land the same tick", function()
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to, _)
            if from == "beacon-isle" and to == "far-shore" then return 3 end
            return 0
         end,
      })
      beacon(u, "far-beacon", 1, "beacon-isle") -- arrives tick 4, older id
      beacon(u, "near-beacon", 4, "far-shore") -- arrives tick 4, newer id
      local _, store = listener(u, "far-shore")
      u:run(4)
      local rows = store():recall("grain.hunger")
      assert.equal(2, #rows)
      assert.is_true(rows[1].id < rows[2].id)
      assert.same({ 4, 4 }, { rows[1].learned, rows[2].learned })
   end)

   it("at distance zero it is the pass-through courier, bit for bit", function()
      local function world(opts)
         opts = opts or {}
         opts.vocabulary = VOCAB
         local u = Universe.new(1893, opts)
         beacon(u, "beacon", 2, "beacon-isle")
         local _, store = listener(u, "here")
         u:run(4)
         return store():recall("grain.hunger"), u.annals:len()
      end
      local adjacent, n1 = world(nil) -- no distance function at all
      local zeroed, n2 = world{ distance = function() return 0 end }
      assert.equal(n1, n2)
      assert.same(adjacent, zeroed) -- same rows, same order, same stamps
   end)

   it("rounds exact divisions exactly, and short hops still take a day", function()
      -- distance 4 at speed 2 is exactly 2 ticks; distance 1 at
      -- speed 2 is ceil(1/2) = 1 tick, never 0 — a fast channel
      -- doesn't make far places adjacent
      local function arrival(d, speed)
         local u = Universe.new(7, { vocabulary = VOCAB,
            distance = function(from, to)
               if from == to then return 0 end
               return d
            end,
            channel_speed = speed,
         })
         beacon(u, "beacon", 1, "beacon-isle")
         local heard = listener(u, "far-shore")
         u:run(6)
         for t = 1, 6 do
            if heard[t] > 0 then return t end
         end
         return nil
      end
      assert.equal(3, arrival(4, 2)) -- emitted 1, ceil(4/2) = 2 → tick 3
      assert.equal(2, arrival(1, 2)) -- emitted 1, ceil(1/2) = 1 → tick 2
   end)

   it("asks the map at the event's departure, not at the scan", function()
      -- The tick handed to distance() is the event's own tick: a
      -- moving map (card 125 and beyond) must see the geometry the
      -- news departed into. A faction registered before the emitter
      -- scans the event one tick after it happened — the lookup must
      -- still be dated to the departure.
      local asked = {}
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to, tick)
            if from == "far-isle" and to == "watch-post" then
               asked[#asked + 1] = tick
               return tick == 2 and 1 or 10
            end
            return 0
         end,
      })
      local heard = listener(u, "watch-post")
      u:add_faction("actor", "far-isle", function(_, _, tick)
         if tick ~= 2 then return {} end
         return { { kind = "grain.hunger", location = "far-isle",
            magnitude = 1, loudness = "loud",
            payload = { shortfall = 1 }, causes = { 1 } } }
      end)
      u:run(6)
      -- departure-time lookup: emitted tick 2, d = 1, arrives tick 3.
      -- A scan-time lookup would ask at tick 3, get 10, and deliver
      -- at tick 12.
      assert.equal(0, heard[2])
      assert.equal(1, heard[3])
      for i = 1, #asked do
         assert.equal(2, asked[i]) -- every ask is dated to departure
      end
   end)

   it("stamps learned with the hand-over tick, even past the computed arrival", function()
      -- An event emitted mid-tick by a later actor is only scanned a
      -- tick later; at distance zero its computed arrival is already
      -- past, and the honest stamp is when the courier actually
      -- handed it over.
      local u = Universe.new(7, { vocabulary = VOCAB })
      local _, store = listener(u, "here")
      u:add_faction("actor", "here", function(_, _, tick)
         if tick ~= 2 then return {} end
         return { { kind = "grain.hunger", location = "here",
            magnitude = 1, loudness = "loud",
            payload = { shortfall = 1 }, causes = { 1 } } }
      end)
      u:run(3)
      local held = store():latest("grain.hunger")
      assert.equal(2, held.tick) -- happened at 2
      assert.equal(3, held.learned) -- handed over at 3
   end)

   it("delivers one event to different homes at different ticks", function()
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            if to == "near-shore" then return 2 end
            if to == "far-shore" then return 6 end
            return 0
         end,
      })
      beacon(u, "beacon", 1, "beacon-isle")
      local near_heard, near = {}, nil
      u:add_faction("near", "near-shore", function(beliefs, _, tick)
         near_heard[tick] = #beliefs:recall("grain.hunger")
         return {}
      end)
      local far_heard = {}
      u:add_faction("far", "far-shore", function(beliefs, _, tick)
         far_heard[tick] = #beliefs:recall("grain.hunger")
         return {}
      end)
      u:run(8)
      assert.equal(0, near_heard[2])
      assert.equal(1, near_heard[3]) -- 1 + 2
      assert.equal(0, far_heard[6])
      assert.equal(1, far_heard[7]) -- 1 + 6
   end)

   it("keeps a private chronology: near news outruns older far news", function()
      -- Event A happens first, far away; event B happens later,
      -- nearby. B arrives before A, so the store's arrival order
      -- inverts id order — which is the store working, not failing.
      local u = Universe.new(7, { vocabulary = VOCAB,
         distance = function(from, to, _)
            if from == "far-isle" and to == "here" then return 5 end
            return 0
         end,
      })
      beacon(u, "far-beacon", 1, "far-isle") -- id lower, arrives tick 6
      beacon(u, "near-beacon", 3, "here") -- id higher, arrives tick 3
      local _, store = listener(u, "here")
      u:run(6)
      local rows = store():recall("grain.hunger")
      assert.equal(2, #rows)
      assert.is_true(rows[1].id > rows[2].id) -- arrival order, not id order
      assert.same({ 3, 6 }, { rows[1].learned, rows[2].learned })
      assert.same({ 3, 1 }, { rows[1].tick, rows[2].tick })
   end)

   it("insists distances are non-negative integers", function()
      local function world(d)
         local u = Universe.new(7, { vocabulary = VOCAB, distance = function() return d end })
         beacon(u, "beacon", 1, "beacon-isle")
         listener(u, "far-shore")
         u:run(1)
      end
      assert.has_error(function() world(1.5) end)
      assert.has_error(function() world(-1) end)
   end)

   it("insists on a lawful channel speed", function()
      assert.has_error(function() Universe.new(7, { vocabulary = VOCAB, channel_speed = 0 }) end)
      assert.has_error(function() Universe.new(7, { vocabulary = VOCAB, channel_speed = 1.5 }) end)
   end)

   it("insists a faction lives somewhere", function()
      local u = Universe.new(7, { vocabulary = VOCAB })
      assert.has_error(function() u:add_faction("drifter", nil, function() return {} end) end)
      assert.has_error(function() u:add_faction("drifter", "", function() return {} end) end)
   end)
end)
