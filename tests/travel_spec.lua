-- tests/travel_spec.lua — the travel scheduler's contract: exactly
-- on time, in scheduling order, once, and nothing shared.

local Travel = require "sonder.travel"

describe("Travel", function()
   it("delivers at exactly the scheduled tick, not before or after", function()
      local t = Travel.new()
      t:schedule(5, "grain")
      assert.same({}, t:due(4))
      assert.same({ "grain" }, t:due(5))
      assert.same({}, t:due(6))
   end)

   it("keeps scheduling order within a tick", function()
      local t = Travel.new()
      t:schedule(3, "first")
      t:schedule(7, "elsewhere")
      t:schedule(3, "second")
      t:schedule(3, "third")
      assert.same({ "first", "second", "third" }, t:due(3))
      assert.same({ "elsewhere" }, t:due(7))
   end)

   it("tears the page out: a drained tick yields nothing twice", function()
      local t = Travel.new()
      t:schedule(2, "once")
      assert.same({ "once" }, t:due(2))
      assert.same({}, t:due(2))
      -- and the calendar holds nothing afterward — no leak, no
      -- reprocessing, nothing left to iterate
      assert.is_nil(next(t.calendar))
   end)

   it("instances share nothing", function()
      local a, b = Travel.new(), Travel.new()
      a:schedule(1, "mine")
      assert.same({}, b:due(1))
      assert.same({ "mine" }, a:due(1))
   end)

   it("insists ticks are integers", function()
      local t = Travel.new()
      assert.has_error(function() t:schedule(1.5, "x") end)
      assert.has_error(function() t:schedule("soon", "x") end)
      assert.has_error(function() t:due(1.5) end)
   end)
end)
