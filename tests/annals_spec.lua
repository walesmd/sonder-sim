-- tests/annals_spec.lua — the log's contract: strict at the door,
-- append-only behind it, copies out the window.

local Annals = require "sonder.annals"

local function genesis(seed)
   return {
      kind = "universe.genesis",
      location = "the-void",
      magnitude = 0,
      loudness = "loud",
      payload = { seed = seed or 1 },
      causes = {},
   }
end

local function hunger(cause, n)
   n = n or 0
   return {
      kind = "grain.hunger",
      location = "the-void",
      magnitude = n < 0 and -n or n,
      loudness = "loud",
      payload = { shortfall = n },
      causes = { cause },
   }
end

-- A log with genesis in it: the smallest annals a non-genesis event
-- can legally join.
local function begun()
   local a = Annals.new()
   a:append(0, genesis())
   return a
end

describe("Annals", function()
   it("ids are positions: the nth append is event n", function()
      local a = begun()
      assert.equal(2, a:append(1, hunger(1)))
      assert.equal(3, a:append(1, hunger(2)))
      assert.equal(3, a:len())
   end)

   it("stamps id and tick and stores the envelope", function()
      local a = Annals.new()
      a:append(0, genesis(1893))
      local e = a:get(1)
      assert.equal(1, e.id)
      assert.equal(0, e.tick)
      assert.equal("universe.genesis", e.kind)
      assert.equal("the-void", e.location)
      assert.equal(0, e.magnitude)
      assert.equal("loud", e.loudness)
      assert.equal(1893, e.payload.seed)
      assert.same({}, e.causes)
   end)

   it("time does not flow backwards", function()
      local a = begun()
      a:append(5, hunger(1))
      assert.has_error(function() a:append(4, hunger(2)) end)
      assert.has_error(function() a:append(5.5, hunger(2)) end)
      assert.has_error(function() a:append(-1, hunger(2)) end)
   end)

   it("keeps no reference to the caller's tables", function()
      local a = begun()
      local spec = hunger(1, 3)
      a:append(1, spec)
      spec.magnitude = 99
      spec.payload.shortfall = 99
      spec.causes[1] = 99
      local e = a:get(2)
      assert.equal(3, e.magnitude)
      assert.equal(3, e.payload.shortfall)
      assert.same({ 1 }, e.causes)
   end)

   it("hands out copies, never rows — history cannot be edited in place", function()
      local a = begun()
      local e = a:get(1)
      e.magnitude = 99
      e.payload.seed = 99
      e.causes[1] = 99
      assert.equal(0, a:get(1).magnitude)
      assert.equal(1, a:get(1).payload.seed)
      assert.same({}, a:get(1).causes)
   end)

   it("returns nil for events history hasn't reached", function()
      local a = begun()
      assert.is_nil(a:get(0))
      assert.is_nil(a:get(2))
      assert.is_nil(a:get("1"))
      assert.is_nil(a:get(1.0))
   end)

   describe("strictness at the door", function()
      it("rejects unregistered kinds", function()
         local a = begun()
         local spec = hunger(1)
         spec.kind = "market.hunch"
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects a missing envelope field", function()
         local a = begun()
         local spec = hunger(1)
         spec.location = nil
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects strangers in the envelope", function()
         local a = begun()
         local spec = hunger(1)
         spec.mood = "hopeful"
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects float magnitudes — outcomes are integers, law 1", function()
         local a = begun()
         local spec = hunger(1)
         spec.magnitude = 1.0
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects loudnesses outside the declared set", function()
         local a = begun()
         local spec = hunger(1)
         spec.loudness = "classified"
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects a mistyped payload field", function()
         local a = begun()
         local spec = hunger(1)
         spec.payload.shortfall = "up"
         assert.has_error(function() a:append(1, spec) end)
         spec.payload.shortfall = 2.5
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects a missing payload field", function()
         local a = begun()
         local spec = hunger(1)
         spec.payload = {}
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects strangers in the payload", function()
         local a = begun()
         local spec = hunger(1)
         spec.payload.momentum = 2
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects nothing it accepted: a failed append appends nothing", function()
         local a = begun()
         local spec = hunger(1)
         spec.payload.momentum = 2
         pcall(function() a:append(1, spec) end)
         assert.equal(1, a:len())
      end)
   end)

   describe("causes", function()
      it("requires every event except genesis to cite at least one", function()
         local a = begun()
         local spec = hunger(1)
         spec.causes = {}
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("rejects causes that are not past events", function()
         local a = begun()
         for _, bad in ipairs({ 0, 2, 99, 1.5, "1" }) do
            local spec = hunger(1)
            spec.causes = { bad }
            assert.has_error(function() a:append(1, spec) end)
         end
      end)

      it("an event cannot cause itself — its id doesn't exist until it's in", function()
         local a = begun()
         local spec = hunger(1)
         spec.causes = { 2 } -- the id this very append would receive
         assert.has_error(function() a:append(1, spec) end)
      end)

      it("genesis happens once, first, uncaused", function()
         -- once:
         local a = begun()
         assert.has_error(function() a:append(1, genesis()) end)
         -- first: nothing else can open a log (its causes can't resolve)
         local b = Annals.new()
         assert.has_error(function() b:append(0, hunger(1)) end)
         -- uncaused:
         local c = Annals.new()
         local spec = genesis()
         spec.causes = { 1 }
         assert.has_error(function() c:append(0, spec) end)
      end)
   end)

   it("two identically driven logs are the same log", function()
      local function build()
         local a = Annals.new()
         a:append(0, genesis(7))
         local last = 1
         for t = 1, 5 do
            last = a:append(t, hunger(last, t - 3))
         end
         return a
      end
      local x, y = build(), build()
      assert.equal(x:len(), y:len())
      for id = 1, x:len() do
         assert.same(x:get(id), y:get(id))
      end
   end)
end)
