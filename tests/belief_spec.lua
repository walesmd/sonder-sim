-- tests/belief_spec.lua — the store's contract: knows only what it
-- was told, hands out copies, and ignorance is a complete answer.

local Belief = require "sonder.belief"

local function drift(id, tick, n)
   return {
      id = id,
      tick = tick,
      kind = "market.drift",
      location = "the-void",
      magnitude = n < 0 and -n or n,
      loudness = "loud",
      payload = { drift = n },
      causes = { id - 1 },
   }
end

describe("Belief", function()
   it("starts knowing nothing", function()
      local b = Belief.new("vess")
      assert.equal(0, b:len())
      assert.is_nil(b:latest("market.drift"))
      assert.same({}, b:recall("market.drift"))
   end)

   it("ignorance is free: an unheard kind has no rows, not empty ones", function()
      local b = Belief.new("vess")
      b:receive(drift(2, 1, 3), 1)
      assert.is_nil(b:latest("war.muster"))
      assert.same({}, b:recall("war.muster"))
      -- and nothing was allocated to say so
      assert.is_nil(b.by_kind["war.muster"])
   end)

   it("remembers what it receives, in arrival order", function()
      local b = Belief.new("vess")
      b:receive(drift(2, 1, 3), 1)
      b:receive(drift(4, 2, -1), 2)
      assert.equal(2, b:len())
      local latest = b:latest("market.drift")
      assert.equal(4, latest.id)
      assert.equal(-1, latest.payload.drift)
      local all = b:recall("market.drift")
      assert.equal(2, #all)
      assert.same({ 2, 4 }, { all[1].id, all[2].id })
   end)

   it("copies on the way in: the courier's table is not kept", function()
      local b = Belief.new("vess")
      local e = drift(2, 1, 3)
      b:receive(e, 1)
      e.payload.drift = 999
      e.causes[1] = 999
      assert.equal(3, b:latest("market.drift").payload.drift)
      assert.same({ 1 }, b:latest("market.drift").causes)
   end)

   it("copies on the way out: scribbling on a memory changes nothing", function()
      local b = Belief.new("vess")
      b:receive(drift(2, 1, 3), 1)
      local recalled = b:latest("market.drift")
      recalled.payload.drift = 999
      recalled.magnitude = 999
      assert.equal(3, b:latest("market.drift").payload.drift)
      assert.equal(3, b:latest("market.drift").magnitude)
   end)

   it("tolerates kinds no vocabulary declares", function()
      -- The store has no vocabulary on purpose — it will one day be
      -- fed by couriers younger than it is, and a belief in a strange
      -- kind is still a belief.
      local b = Belief.new("vess")
      b:receive({
         id = 9, tick = 3, kind = "omen.comet", location = "the-sky",
         magnitude = 7, loudness = "loud", payload = { portent = "doom" },
         causes = { 1 },
      }, 3)
      assert.equal("doom", b:latest("omen.comet").payload.portent)
   end)

   it("stamps when it learned, and keeps the date on the copy", function()
      local b = Belief.new("vess")
      b:receive(drift(2, 1, 3), 9)
      local held = b:latest("market.drift")
      assert.equal(1, held.tick) -- when it happened
      assert.equal(9, held.learned) -- when the news landed
      -- and scribbling on the copy changes nothing, same discipline
      -- as every other field
      held.learned = 0
      assert.equal(9, b:latest("market.drift").learned)
   end)

   it("rejects a learned tick earlier than the event, or none at all", function()
      local b = Belief.new("vess")
      assert.has_error(function() b:receive(drift(2, 5, 3), 4) end)
      assert.has_error(function() b:receive(drift(2, 5, 3)) end)
   end)

   it("holds no road back to the world", function()
      -- The structural half of law 3, store edition: nothing in here
      -- references an annals, a universe, or an emit. The store can
      -- only be *told* things.
      local b = Belief.new("vess")
      b:receive(drift(2, 1, 3), 1)
      for key in pairs(b) do
         assert.is_true(key == "owner" or key == "received" or key == "by_kind",
            "unexpected field on a belief store: " .. tostring(key))
      end
      assert.is_nil(b.annals)
      assert.is_nil(b.emit)
   end)

   it("rejects things that are not events", function()
      local b = Belief.new("vess")
      assert.has_error(function() b:receive(nil) end)
      assert.has_error(function() b:receive("rumor") end)
      assert.has_error(function() b:receive({}) end)
   end)

   it("demands an owner", function()
      assert.has_error(function() Belief.new() end)
      assert.has_error(function() Belief.new("") end)
   end)
end)
