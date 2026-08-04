-- tests/audit_spec.lua — the double-entry audit held to its own
-- standard: it must classify every kind the vocabulary can utter,
-- balance every universe the space world can produce, and catch the
-- counterfeits the annals has no grounds to refuse.

local space = require "support.space"
local Audit = require "sonder.audit"
local vocabulary = require "worlds.space_vocabulary"
local legs = require "worlds.space_audit"

-- The world's road, as the audit wants it: the same map and divisor
-- the courier reads.
local function road(u)
   return { distance = u.distance, channel_speed = u.channel_speed }
end

-- Clean, in the card-122 sense: the arithmetic of truth is perfect
-- (no violations), and every tally's drift is exactly the news still
-- on the road (no unexplained mismatches). Plain mismatches stopped
-- being asserted away the day news got slow — drift is the product
-- now, and the audit accounts for it instead of forbidding it.
local function assert_honest(report)
   assert.equal(0, #report.violations,
      table.concat(report.violations, "\n"))
   assert.equal(0, #report.unexplained)
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
         assert.is_true(Audit.classified(legs, kind),
            kind .. " has no ledger classification")
      end
   end)

   it("does not pretend to know foreign kinds", function()
      assert.is_false(Audit.classified(legs, "diplomacy.betrayal"))
   end)
end)

describe("conservation", function()
   it("balances a thousand days of seed 1893", function()
      local u = space(1893)
      u:run(1000)
      local report = Audit.of(u.annals, legs, road(u))
      assert_honest(report)
      -- Card 122's drift died at card 153, and honestly: every
      -- event that moves a civ's books now happens at its own
      -- gates, so self-knowledge is exact again — the drift was a
      -- symptom of action at a distance, and matter made honest
      -- cured it. Ignorance lives on in what civs believe about
      -- each other, which tallies never claimed to know.
      assert.equal(0, #report.mismatches)
      -- and the conservation identities carry their road terms:
      -- some of what exists is between places
      assert.equal(report.world.founded.cents,
         report.held.cents + report.on_road.cents)
      assert.equal(report.world.founded.grain + report.world.totals.harvested
         - report.world.totals.eaten - report.world.totals.burned,
         report.held.grain + report.on_road.grain)
   end)

   it("balances other seeds too", function()
      for _, seed in ipairs({ 7, 40412 }) do
         local u = space(seed)
         u:run(300)
         local report = Audit.of(u.annals, legs, road(u))
         assert_honest(report)
         assert.equal(report.world.founded.cents,
            report.held.cents + report.on_road.cents)
      end
   end)

   it("without the road, mismatches go uncertified, not clean", function()
      -- The space world no longer drifts, so a liar provides the mismatch:
      -- detection works roadless, certification doesn't.
      local u = space(1893)
      u:add_system("liar", function(universe, _, tick)
         if tick == 5 then
            universe:emit{
               kind = "civ.tally",
               location = "vessar-reaches",
               magnitude = 9999,
               loudness = "local",
               payload = { harvested = 0, eaten = 0,
                  stock = 9999, cents = 9999 },
               causes = { 1 },
            }
         end
      end)
      u:run(10)
      local report = Audit.of(u.annals, legs)
      assert.is_true(#report.mismatches > 0)
      assert.is_nil(report.unexplained) -- unchecked is not "none"
   end)
end)

describe("the counterfeiter", function()
   -- The annals checks shape, not arithmetic: an event with typed,
   -- declared fields is admitted even when its numbers are lies.
   -- Catching the lies is the audit's whole job, so each spec here
   -- forges one economically-false-but-grammatically-valid event and
   -- demands the audit name it.

   local function forge(seed, payload)
      local u = space(seed)
      u:add_system("counterfeiter", function(universe, _, tick)
         if tick == 5 then
            universe:emit{
               kind = "market.trade",
               location = "the-exchange",
               magnitude = payload.units,
               loudness = "loud",
               payload = payload,
               causes = { 1 },
            }
         end
      end)
      u:run(10)
      return Audit.of(u.annals, legs)
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

   it("catches a payment that drives a treasury negative", function()
      -- Since card 153 a trade moves no books — the money moves on
      -- its road legs — so the impossible purchase is now an
      -- impossible *dispatch*: a payment.shipped for more cents
      -- than the payer ever held.
      local u = space(7)
      u:add_system("counterfeiter", function(universe, _, tick)
         if tick == 5 then
            universe:emit{
               kind = "payment.shipped",
               location = "khedrun-holds",
               magnitude = 10000000,
               loudness = "local",
               payload = { amount = 10000000,
                  payer = "khedrun", payee = "vessari" },
               causes = { 1 },
            }
         end
      end)
      u:run(10)
      local report = Audit.of(u.annals, legs)
      local caught = false
      for _, v in ipairs(report.violations) do
         if v:find("negative treasury", 1, true) then
            caught = true
         end
      end
      assert.is_true(caught, "the impossible dispatch went unflagged")
   end)
end)

describe("the liar", function()
   -- Ignorance is legitimate drift: reported + in-flight == audited,
   -- to the cent. A lie is drift no road accounts for. The annals
   -- admits both — grammar at the door — and card 120's structural
   -- separation finishes here as three bins: violations (impossible
   -- arithmetic), explained mismatches (ignorance, the product), and
   -- unexplained mismatches (somebody's books are lying).
   it("catches a forged tally the road cannot explain", function()
      local u = space(7)
      u:add_system("liar", function(universe, _, tick)
         if tick == 5 then
            universe:emit{
               kind = "civ.tally",
               location = "vessar-reaches",
               magnitude = 9999,
               loudness = "local",
               -- harvested/eaten zero: the fold's books stay true,
               -- so nothing trips a violation — the lie lives
               -- purely in the claim
               payload = { harvested = 0, eaten = 0,
                  stock = 9999, cents = 9999 },
               causes = { 1 },
            }
         end
      end)
      u:run(10)
      local report = Audit.of(u.annals, legs, road(u))
      assert.equal(0, #report.violations)
      assert.is_true(#report.unexplained > 0,
         "a 9,999-sack lie passed as ignorance")
   end)
end)

describe("the report", function()
   it("is the same fold main.lua and the specs both see", function()
      -- Determinism of the report itself: same log, same report,
      -- field for field — the audit is a projection, so two folds of
      -- one history may not disagree.
      local u1 = space(1893)
      u1:run(200)
      local a = Audit.of(u1.annals, legs)
      local u2 = space(1893)
      u2:run(200)
      local b = Audit.of(u2.annals, legs)
      assert.equal(#a.violations, #b.violations)
      assert.equal(a.held.cents, b.held.cents)
      assert.equal(a.held.grain, b.held.grain)
      assert.equal(a.world.totals.burned, b.world.totals.burned)
   end)
end)
