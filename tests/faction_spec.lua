-- tests/faction_spec.lua — law 3 as mechanics: factions decide on
-- beliefs, return intents, and are handed no road to the truth.

local Universe = require "sonder.universe"
local toy = require "support.toy"

local function null_decide()
   return {}
end

describe("factions", function()
   it("decide is handed beliefs, a stream, a tick — and nothing else", function()
      -- The capability spec. Everything law 3 means, structurally, is
      -- on this argument list: if the universe isn't in your hands,
      -- no code path reaches it.
      local u = Universe.new(7)
      local seen
      u:add_faction("spy", "the-void", function(...)
         seen = table.pack(...)
         return {}
      end)
      u:step()
      assert.equal(3, seen.n)
      local beliefs, stream, tick = seen[1], seen[2], seen[3]
      assert.not_equal(u, beliefs)
      assert.not_equal(u, stream)
      assert.is_nil(beliefs.annals)
      assert.is_nil(beliefs.emit)
      assert.is_function(beliefs.latest)
      assert.is_function(stream.int)
      assert.equal(1, tick)
   end)

   it("the pass-through courier delivers everything, including genesis", function()
      local u = Universe.new(1893)
      local counted
      u:add_faction("census", "the-void", function(beliefs)
         counted = beliefs:len()
         return {}
      end)
      u:step()
      assert.equal(1, counted) -- genesis reached the store
      assert.equal(u.annals:len(), counted)
   end)

   it("intents are emitted in order, ticks stamped centrally", function()
      local u = Universe.new(7)
      u:add_faction("herald", "the-void", function(beliefs, _, tick)
         if tick > 1 then
            return {}
         end
         local genesis = beliefs:latest("universe.genesis")
         return {
            { kind = "grain.hunger", location = "the-void", magnitude = 1,
              loudness = "loud", payload = { shortfall = 1 },
              causes = { genesis.id } },
            { kind = "grain.hunger", location = "the-void", magnitude = 2,
              loudness = "loud", payload = { shortfall = 2 },
              causes = { genesis.id } },
         }
      end)
      u:step()
      assert.equal(3, u.annals:len())
      assert.same({ 1, 1, 2 }, {
         u.annals:get(2).tick,
         u.annals:get(2).payload.shortfall,
         u.annals:get(3).payload.shortfall,
      })
   end)

   it("factions run after systems, in registration order", function()
      local u = Universe.new(7)
      local order = {}
      u:add_faction("second", "the-void", function()
         order[#order + 1] = "second"
         return {}
      end)
      u:add_faction("third", "the-void", function()
         order[#order + 1] = "third"
         return {}
      end)
      u:add_system("first", function()
         order[#order + 1] = "first"
      end)
      u:step()
      assert.same({ "first", "second", "third" }, order)
   end)

   it("returning nothing is an error; an empty table is a decision", function()
      local u = Universe.new(7)
      u:add_faction("mute", "the-void", function() end)
      assert.has_error(function() u:step() end,
         "universe: mute: decide must return an array"
         .. " of intents (perhaps empty), not nil")
      local v = Universe.new(7)
      v:add_faction("idle", "the-void", null_decide)
      v:step()
      assert.equal(1, v.annals:len()) -- just genesis; idling is legal
   end)

   it("names are unique across systems and factions alike", function()
      local u = Universe.new(7)
      u:add_system("war", function() end)
      assert.has_error(function() u:add_faction("war", "the-void", null_decide) end,
         'universe: the name "war" is already taken')
      assert.has_error(function() u:add_system("war", function() end) end,
         'universe: the name "war" is already taken')
   end)

   it("bad intents die at the same door as every bad event", function()
      local u = Universe.new(7)
      u:add_faction("liar", "the-void", function()
         return { { kind = "war.victory", location = "the-void", magnitude = 1,
            loudness = "loud", payload = {}, causes = { 1 } } }
      end)
      assert.has_error(function() u:step() end,
         'annals: unregistered kind "war.victory"')
   end)
end)

describe("factions in the toy world", function()
   it("same seed, same beliefs, same decisions, twice", function()
      local a, b = toy(4242), toy(4242)
      a:run(30)
      b:run(30)
      assert.equal(a.annals:len(), b.annals:len())
      for id = 1, a.annals:len() do
         assert.same(a.annals:get(id), b.annals:get(id))
      end
   end)
end)
