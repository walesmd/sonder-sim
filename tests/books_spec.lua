-- tests/books_spec.lua — the books contract (card 169): a
-- declaration is checked once against its world's vocabulary, and
-- the road grammar is the engine's to book, never a world's.

local Books = require "sonder.books"
local Vocabulary = require "sonder.vocabulary"
local Belief = require "sonder.belief"

local VOCAB = {
   kinds = Vocabulary.with_road_kinds{
      ["spec.founded"] = { doc = "an anchor that names its subject",
         payload = { { "name", "string" }, { "cents", "integer" } } },
      ["spec.tally"] = { doc = "an anchor that speaks from a home",
         payload = { { "stock", "integer" }, { "cents", "integer" } } },
      ["spec.gift"] = { doc = "a world's own leg",
         payload = { { "to", "string" }, { "units", "integer" } } },
   },
}

local function decl(overrides)
   local d = {
      columns = { "grain", "cents" },
      commodities = { grain = "grain" },
      money = "cents",
      anchors = {
         { kind = "spec.tally", by = "home",
            fields = { grain = "stock" } },
         { kind = "spec.founded", by = "name",
            defaults = { grain = 0 } },
      },
      legs = {
         { kind = "spec.gift", apply = function(b, e, owner)
            if e.payload.to == owner.name then
               b.grain = b.grain + e.payload.units
            end
         end },
      },
   }
   for k, v in pairs(overrides or {}) do
      d[k] = v
   end
   return d
end

local function event(id, tick, kind, location, payload)
   return { id = id, tick = tick, kind = kind, location = location,
      magnitude = 0, loudness = "loud", payload = payload, causes = {} }
end

describe("Books.check", function()
   it("passes a well-formed declaration and returns it", function()
      local d = decl()
      assert.equal(d, Books.check(d, VOCAB))
   end)

   it("refuses a leg that re-books road grammar (fork 1)", function()
      local d = decl{ legs = { { kind = "cargo.delivered",
         apply = function() end } } }
      assert.has_error(function() Books.check(d, VOCAB) end)
   end)

   it("refuses a default the anchor's payload now carries (fork 5)", function()
      local d = decl()
      d.anchors[2].defaults = { grain = 0, cents = 0 }
      assert.has_error(function() Books.check(d, VOCAB) end)
   end)

   it("refuses a column no anchor source can open", function()
      local d = decl()
      d.anchors[2].defaults = nil -- founding carries no grain
      assert.has_error(function() Books.check(d, VOCAB) end)
   end)

   it("refuses kinds the vocabulary never declared", function()
      local d = decl()
      d.anchors[1].kind = "spec.rumor"
      assert.has_error(function() Books.check(d, VOCAB) end)
   end)

   it("refuses unknown match shapes, money, and commodities", function()
      local d = decl()
      d.anchors[1].by = "seat"
      assert.has_error(function() Books.check(d, VOCAB) end)
      assert.has_error(function() Books.check(decl{ money = "gold" }, VOCAB) end)
      assert.has_error(function()
         Books.check(decl{ commodities = { iron = "iron" } }, VOCAB)
      end)
   end)
end)

describe("Books.believed", function()
   it("folds only a checked declaration", function()
      assert.has_error(function()
         Books.believed(Belief.new("vess"), decl(),
            { name = "vess", home = "vessar" })
      end)
   end)

   it("reads back exactly to the anchor, whatever the crowd (fork 0)", function()
      local d = Books.check(decl(), VOCAB)
      local b = Belief.new("vess")
      b:receive(event(1, 0, "spec.founded", "vessar",
         { name = "vess", cents = 100 }), 0)
      b:receive(event(2, 1, "spec.tally", "vessar",
         { stock = 10, cents = 100 }), 1)
      -- far more news than any count window would have held
      local id = 2
      for i = 1, 200 do
         id = id + 1
         b:receive(event(id, 2, "spec.tally", "elsewhere",
            { stock = 0, cents = 0 }), 2)
         id = id + 1
         b:receive(event(id, 2, "spec.gift", "vessar",
            { to = i % 2 == 0 and "vess" or "khed", units = 1 }), 2)
      end
      local books, since = Books.believed(b, d,
         { name = "vess", home = "vessar" })
      assert.equal(2, since) -- my own tally, not the founding
      assert.equal(10 + 100, books.grain) -- every gift to me, none missed
      assert.equal(100, books.cents)
   end)

   it("opens from a default where the anchor carries no column", function()
      local d = Books.check(decl(), VOCAB)
      local b = Belief.new("vess")
      b:receive(event(1, 0, "spec.founded", "vessar",
         { name = "vess", cents = 100 }), 0)
      local books, since = Books.believed(b, d,
         { name = "vess", home = "vessar" })
      assert.equal(1, since)
      assert.same({ grain = 0, cents = 100 }, books)
   end)
end)

describe("Books.ledger", function()
   it("refuses a world effect for a road kind (fork 1)", function()
      assert.has_error(function()
         Books.ledger({}, { columns = { "cents" }, commodities = {},
            money = "cents", roads = {},
            effects = { ["payment.delivered"] = function() end } })
      end)
   end)

   it("enrolls with zero-fill into .books", function()
      local led = Books.ledger({}, { columns = { "grain", "cents" },
         commodities = { grain = "grain" }, money = "cents", roads = {},
         effects = {} })
      led:enroll("vess", { cents = 5 })
      assert.same({ grain = 0, cents = 5 }, led.books.vess)
   end)
end)
