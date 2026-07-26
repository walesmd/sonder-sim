-- tests/universe_spec.lua — the heartbeat's contract.

local Universe = require "sonder.universe"

describe("Universe", function()
   it("starts at tick 0 and counts by one", function()
      local u = Universe.new(1)
      assert.equal(0, u.tick)
      u:step()
      assert.equal(1, u.tick)
      u:run(9)
      assert.equal(10, u.tick)
   end)

   it("rejects non-integer seeds", function()
      assert.has_error(function() Universe.new(1.5) end)
   end)

   it("runs systems in registration order, every tick", function()
      local u = Universe.new(1)
      local calls = {}
      u:add_system("market", function() calls[#calls + 1] = "market" end)
      u:add_system("war", function() calls[#calls + 1] = "war" end)
      u:run(2)
      assert.same({ "market", "war", "market", "war" }, calls)
   end)

   it("hands each system its own named stream and the tick", function()
      local u = Universe.new(1)
      local got_stream, got_tick
      u:add_system("market", function(universe, stream, tick)
         assert.equal(u, universe)
         got_stream, got_tick = stream, tick
      end)
      u:step()
      assert.equal(u.rng:stream("market"), got_stream)
      assert.equal(1, got_tick)
   end)

   it("begins with genesis: event 1, tick 0, the seed on record", function()
      local u = Universe.new(1893)
      assert.equal(1, u.annals:len())
      local e = u.annals:get(1)
      assert.equal("universe.genesis", e.kind)
      assert.equal(0, e.tick)
      assert.equal(1893, e.payload.seed)
      assert.same({}, e.causes)
   end)

   it("emit stamps the current tick and returns the id", function()
      local u = Universe.new(1)
      local id
      u:add_system("market", function(universe)
         id = universe:emit{
            kind = "market.drift",
            location = "the-void",
            magnitude = 0,
            visibility = "public",
            payload = { drift = 0 },
            causes = { 1 },
         }
      end)
      u:step()
      assert.equal(2, id)
      assert.equal(1, u.annals:get(2).tick)
   end)

   it("same seed → the same universe, draw for draw", function()
      local function trace(seed, ticks)
         local u = Universe.new(seed)
         local draws = {}
         u:add_system("market", function(_, stream)
            draws[#draws + 1] = stream:int(-3, 3)
         end)
         u:add_system("war", function(_, stream)
            draws[#draws + 1] = stream:int(0, 9)
         end)
         u:run(ticks)
         return draws
      end
      assert.same(trace(1893, 100), trace(1893, 100))
      assert.not_same(trace(1893, 100), trace(1894, 100))
   end)
end)
