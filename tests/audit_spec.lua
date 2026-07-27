-- tests/audit_spec.lua — the double-entry audit held to its own
-- standard: it must classify every kind the vocabulary can utter,
-- balance every universe the toy world can produce, and catch the
-- counterfeits the annals has no grounds to refuse.

local toy = require "support.toy"
local Audit = require "sonder.audit"
local vocabulary = require "sonder.vocabulary"

local function assert_clean(report)
   assert.equal(0, #report.violations,
      table.concat(report.violations, "\n"))
   assert.equal(0, #report.mismatches)
end

describe("coverage", function()
   it("classifies every kind in the vocabulary", function()
      -- The audit refuses to default a kind to "touches nothing";
      -- this spec is what makes that refusal safe to rely on. Add a
      -- kind, teach the audit its ledger legs (or its neutrality),
      -- or go no further.
      local kinds = {}
      for kind in pairs(vocabulary.kinds) do
         kinds[#kinds + 1] = kind
      end
      table.sort(kinds) -- pairs() order is nobody's friend, even here
      for _, kind in ipairs(kinds) do
         assert.is_true(Audit.classified(kind),
            kind .. " has no ledger classification")
      end
   end)

   it("does not pretend to know foreign kinds", function()
      assert.is_false(Audit.classified("diplomacy.betrayal"))
   end)
end)

describe("conservation", function()
   it("balances a thousand days of seed 1893", function()
      local u = toy(1893)
      u:run(1000)
      local report = Audit.of(u.annals)
      assert_clean(report)
      assert.equal(report.founded.cents, report.held.cents)
      assert.equal(report.founded.grain + report.totals.harvested
         - report.totals.eaten - report.totals.burned,
         report.held.grain)
   end)

   it("balances other seeds too", function()
      for _, seed in ipairs({ 7, 40412 }) do
         local u = toy(seed)
         u:run(300)
         assert_clean(Audit.of(u.annals))
      end
   end)
end)

describe("the counterfeiter", function()
   -- The annals checks shape, not arithmetic: an event with typed,
   -- declared fields is admitted even when its numbers are lies.
   -- Catching the lies is the audit's whole job, so each spec here
   -- forges one economically-false-but-grammatically-valid event and
   -- demands the audit name it.

   local function forge(seed, payload)
      local u = toy(seed)
      u:add_system("counterfeiter", function(universe, _, tick)
         if tick == 5 then
            universe:emit{
               kind = "market.trade",
               location = "the-exchange",
               magnitude = payload.units,
               visibility = "public",
               payload = payload,
               causes = { 1 },
            }
         end
      end)
      u:run(10)
      return Audit.of(u.annals)
   end

   it("catches a trade whose total is not units × price", function()
      local report = forge(7, { buyer = "khedrun", seller = "vessari",
         units = 5, price = 80, total = 0 })
      local caught = false
      for _, v in ipairs(report.violations) do
         if v:find("is not 5 units × 80¢", 1, true) then
            caught = true
         end
      end
      assert.is_true(caught, "the free-grain trade went unflagged")
   end)

   it("catches a trade that drives a treasury negative", function()
      local report = forge(7, { buyer = "khedrun", seller = "vessari",
         units = 1, price = 10000000, total = 10000000 })
      local caught = false
      for _, v in ipairs(report.violations) do
         if v:find("negative treasury", 1, true) then
            caught = true
         end
      end
      assert.is_true(caught, "the impossible purchase went unflagged")
   end)
end)

describe("the report", function()
   it("is the same fold main.lua and the specs both see", function()
      -- Determinism of the report itself: same log, same report,
      -- field for field — the audit is a projection, so two folds of
      -- one history may not disagree.
      local u1 = toy(1893)
      u1:run(200)
      local a = Audit.of(u1.annals)
      local u2 = toy(1893)
      u2:run(200)
      local b = Audit.of(u2.annals)
      assert.equal(#a.violations, #b.violations)
      assert.equal(a.held.cents, b.held.cents)
      assert.equal(a.held.grain, b.held.grain)
      assert.equal(a.totals.burned, b.totals.burned)
   end)
end)
