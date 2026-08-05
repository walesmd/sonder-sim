-- tests/carriage_spec.lua — mechanism rows carry the news (card 150).
--
-- The unit half drives sonder/carriage.lua directly: rows are data,
-- arrival is integer arithmetic, and nil is a complete answer (the
-- witness rule — nothing carried it, so for this faction it never
-- happened). The integration half builds little universes and
-- proves the courier honors the rows: earshot ends where the range
-- says, letters reach their addressee and nobody else, and the
-- field row is the old arithmetic bit for bit.

local Carriage = require "sonder.carriage"
local Universe = require "sonder.universe"
local VOCAB = require "support.vocabulary"

-- A raw event, the shape the annals hands the courier. The unit
-- tests need no universe: arrival() is a pure computation.
local function event(over)
   local e = {
      id = 2, tick = 5, kind = "grain.hunger", location = "here",
      magnitude = 1, loudness = "loud", payload = { shortfall = 1 },
      causes = { 1 },
   }
   for k, v in pairs(over or {}) do
      e[k] = v
   end
   return e
end

describe("carriage rows", function()
   it("the field row reaches everywhere at the old arithmetic", function()
      local c = Carriage.new({ Carriage.field(2) },
         function() return 7 end)
      -- ceil(7 ÷ 2) = 4 days after tick 5
      assert.equal(9, c:arrival(event(), "anyone", "anywhere"))
   end)

   it("without a map, everywhere is adjacent and news is instant", function()
      local c = Carriage.new({ Carriage.field(1) }, nil)
      assert.equal(5, c:arrival(event(), "anyone", "anywhere"))
   end)

   it("radiated range is read at the event's loudness", function()
      local c = Carriage.new({
         { name = "earshot", shape = "radiated", speed = 1,
            range = { loud = 2, ["local"] = 0, quiet = 0 } },
      }, function() return 2 end)
      assert.equal(7, c:arrival(event{ loudness = "loud" }, "n", "near"))
      assert.is_nil(c:arrival(event{ loudness = "local" }, "n", "near"))
      assert.is_nil(c:arrival(event{ loudness = "quiet" }, "n", "near"))
   end)

   it("range zero still reaches the event's own location", function()
      -- self-knowledge is exact: distance 0 is inside every range
      local c = Carriage.new({
         { name = "earshot", shape = "radiated", speed = 1,
            range = { loud = 2, ["local"] = 0, quiet = 0 } },
      }, function(from, to) return from == to and 0 or 9 end)
      assert.equal(5, c:arrival(event{ loudness = "quiet",
         location = "here" }, "n", "here"))
   end)

   it("addressed rows deliver to the named payload field, only", function()
      local c = Carriage.new({
         { name = "letters", shape = "addressed", speed = 1,
            to = { ["grain.hunger"] = "shortfall" } },
      }, function() return 3 end)
      local letter = event{ payload = { shortfall = "korrag" } }
      assert.equal(8, c:arrival(letter, "korrag", "korrag-height"))
      assert.is_nil(c:arrival(letter, "selm", "selm-water"))
   end)

   it("addressed rows ignore kinds they never declared", function()
      local c = Carriage.new({
         { name = "letters", shape = "addressed", speed = 1,
            to = { ["some.other"] = "buyer" } },
      }, function() return 3 end)
      assert.is_nil(c:arrival(event(), "anyone", "anywhere"))
   end)

   it("the earliest arrival wins when several rows reach", function()
      local c = Carriage.new({
         { name = "slow-word", shape = "radiated", speed = 1,
            range = "everywhere" },
         { name = "fast-wire", shape = "addressed", speed = 6,
            to = { ["grain.hunger"] = "shortfall" } },
      }, function() return 6 end)
      local wired = event{ payload = { shortfall = "korrag" } }
      -- wire: ceil(6 ÷ 6) = 1 day; word: 6 days. The wire wins.
      assert.equal(6, c:arrival(wired, "korrag", "korrag-height"))
      -- everyone else gets the slow word
      assert.equal(11, c:arrival(wired, "selm", "selm-water"))
   end)

   it("insists on lawful rows", function()
      local d = function() return 0 end
      assert.has_error(function() Carriage.new({}, d) end)
      assert.has_error(function()
         Carriage.new({ { name = "x", shape = "teleport", speed = 1 } }, d)
      end)
      assert.has_error(function()
         Carriage.new({ { name = "x", shape = "radiated", speed = 0,
            range = "everywhere" } }, d)
      end)
      assert.has_error(function()
         Carriage.new({ { name = "x", shape = "radiated", speed = 1,
            range = { loud = 2 } } }, d) -- local and quiet missing
      end)
      assert.has_error(function()
         Carriage.new({ { name = "x", shape = "addressed", speed = 1 } }, d)
      end)
   end)
end)

describe("the courier on declared rows", function()
   -- A beacon at a chosen loudness, and a listener who only remembers.
   local function beacon(u, at, loudness)
      u:add_system("beacon", function(universe, _, tick)
         if tick == at then
            universe:emit{
               kind = "grain.hunger", location = "beacon-isle",
               magnitude = 1, loudness = loudness,
               payload = { shortfall = 1 }, causes = { 1 },
            }
         end
      end)
   end
   local function listener(u, name, home)
      local store
      u:add_faction(name, home, function(beliefs)
         store = beliefs
         return {}
      end)
      return function() return store end
   end

   it("enforces the witness rule: out of earshot is never, not late", function()
      local u = Universe.new(7, {
         vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            return 3 -- one day past earshot
         end,
         mechanisms = { { name = "earshot", shape = "radiated",
            speed = 1, range = { loud = 2, ["local"] = 0, quiet = 0 } } },
      })
      beacon(u, 1, "loud")
      local store = listener(u, "far-civ", "far-shore")
      u:run(50) -- long past any conceivable delay
      assert.equal(0, #store():recall("grain.hunger"))
      -- genesis was at the-void, distance 3 from far-shore under
      -- this map: out of earshot too. The far civ knows nothing at
      -- all — ignorance is free, and now it is also earned.
      assert.equal(0, store():len())
   end)

   it("delivers within earshot at road pace", function()
      local u = Universe.new(7, {
         vocabulary = VOCAB,
         distance = function(from, to)
            if from == to then return 0 end
            return 2
         end,
         mechanisms = { { name = "earshot", shape = "radiated",
            speed = 1, range = { loud = 2, ["local"] = 0, quiet = 0 } } },
      })
      beacon(u, 1, "loud")
      local store = listener(u, "near-civ", "near-shore")
      u:run(5)
      local heard = store():recall("grain.hunger")
      assert.equal(1, #heard)
      assert.equal(1, heard[1].tick)
      assert.equal(3, heard[1].learned) -- two days away, two days late
   end)

   it("the declared field row is the old courier, bit for bit", function()
      local map = function(from, to)
         if from == to then return 0 end
         return 3
      end
      local declared = Universe.new(7, { vocabulary = VOCAB,
         distance = map, mechanisms = { Carriage.field(1) } })
      local assumed = Universe.new(7, { vocabulary = VOCAB,
         distance = map })
      beacon(declared, 1, "loud")
      beacon(assumed, 1, "loud")
      local a = listener(declared, "listener", "far-shore")
      local b = listener(assumed, "listener", "far-shore")
      declared:run(6)
      assumed:run(6)
      assert.same(b():chronology(), a():chronology())
   end)
end)
