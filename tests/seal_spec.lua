-- tests/seal_spec.lua — the golden master: the regression net every
-- later mechanic lands inside. Seed 1893's first 500 ticks hash to
-- one exact value, on every machine, until the vocabulary churns —
-- and any change to what happens (not how it's displayed) must show
-- up here as a different seal.

local Seal = require "sonder.seal"
local toy = require "support.toy"

-- The pinned seal of seed 1893 × 500 ticks (1001 events). If this
-- fails and you didn't mean to change history, you changed history.
-- If you did mean to (vocabulary churn, new system, card 118), this
-- constant is re-cut deliberately, in its own commit, with the reason
-- in the message.
--
-- Re-cut ledger:
--   27e3e0a8080e04f8 — first cut (card 116); war office was a blind
--                      system drawing its own musters
--   ae08cb9d02bd99c1 — card 117: the war office became a believer,
--                      mustering on believed drifts and citing them
local GOLDEN_SEED = 1893
local GOLDEN_TICKS = 500
local GOLDEN_SEAL = "ae08cb9d02bd99c1"

describe("the golden master", function()
   it("seed 1893, 500 ticks, one exact seal", function()
      local u = toy(GOLDEN_SEED)
      u:run(GOLDEN_TICKS)
      assert.equal(GOLDEN_SEAL, Seal.of(u.annals):hex())
   end)

   it("passes twice in a row: a fresh universe, same seed, same seal", function()
      local u = toy(GOLDEN_SEED)
      u:run(GOLDEN_TICKS)
      assert.equal(GOLDEN_SEAL, Seal.of(u.annals):hex())
   end)

   it("fails when a draw is deliberately perturbed", function()
      -- The gremlin: same seed, same systems, plus one extra draw
      -- stolen from the market's own stream at tick 250. One number
      -- nobody even looked at — and history forks.
      local u = toy(GOLDEN_SEED)
      u:add_system("gremlin", function(universe, _, tick)
         if tick == 250 then
            universe.rng:stream("market"):int(-3, 3)
         end
      end)
      u:run(GOLDEN_TICKS)
      assert.not_equal(GOLDEN_SEAL, Seal.of(u.annals):hex())
   end)

   it("the gremlin's damage starts exactly where it struck", function()
      -- Everything through tick 250 is untouched — the stolen draw
      -- can only bend the future. Divergence has a first moment;
      -- checkpoint tables exist so tools can binary-search for it
      -- (card 123's synopsis), and this is the property they lean on.
      local clean, bent = toy(GOLDEN_SEED), toy(GOLDEN_SEED)
      bent:add_system("gremlin", function(universe, _, tick)
         if tick == 250 then
            universe.rng:stream("market"):int(-3, 3)
         end
      end)
      clean:run(250)
      bent:run(250)
      assert.equal(Seal.of(clean.annals):hex(), Seal.of(bent.annals):hex())
      clean:run(1)
      bent:run(1)
      assert.not_equal(Seal.of(clean.annals):hex(), Seal.of(bent.annals):hex())
   end)
end)

describe("Seal", function()
   it("is a projection: recomputing agrees with itself", function()
      local u = toy(7)
      u:run(10)
      assert.equal(Seal.of(u.annals):hex(), Seal.of(u.annals):hex())
   end)

   it("incremental folding agrees with all-at-once", function()
      local u = toy(7)
      local rolling = Seal.new(u.annals.vocabulary)
      local folded = 0
      local function catch_up()
         while folded < u.annals:len() do
            folded = folded + 1
            rolling:fold(u.annals:get(folded))
         end
      end
      catch_up() -- genesis
      for _ = 1, 10 do
         u:step()
         catch_up() -- one tick at a time, like the archive does
      end
      assert.equal(Seal.of(u.annals):hex(), rolling:hex())
   end)

   it("order matters: a history is a sequence, not a set", function()
      local u = toy(7)
      u:run(2)
      local forward, backward = Seal.new(), Seal.new()
      for id = 1, u.annals:len() do
         forward:fold(u.annals:get(id))
      end
      for id = u.annals:len(), 1, -1 do
         backward:fold(u.annals:get(id))
      end
      assert.not_equal(forward:hex(), backward:hex())
   end)

   it("refuses kinds the vocabulary has never heard of", function()
      assert.has_error(function()
         Seal.new():fold{
            id = 1, tick = 0, kind = "future.mystery", location = "x",
            magnitude = 0, visibility = "public", payload = {}, causes = {},
         }
      end, 'canon: unregistered kind "future.mystery"')
   end)
end)
