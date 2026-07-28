-- tests/chronicle_spec.lua — the first viewer's contract: a sentence
-- for every kind it knows, a safe line for every kind it doesn't, and
-- no fingerprints on the sim.

local Chronicle = require "sonder.chronicle"
local vocabulary = require "sonder.vocabulary"
local Universe = require "sonder.universe"

-- A hand-built event, bypassing the annals on purpose: the chronicle
-- renders event tables, wherever they came from — including logs
-- written by vocabularies this repo has never heard of.
local function event(overrides)
   local e = {
      id = 1,
      tick = 0,
      kind = "universe.genesis",
      location = "the-void",
      magnitude = 0,
      loudness = "loud",
      payload = { seed = 1893 },
      causes = {},
   }
   for k, v in pairs(overrides or {}) do
      e[k] = v
   end
   return e
end

-- A minimal emitting universe for cursor and law-4 specs: one chained
-- system, one integer payload. (The full toy world has its own spec;
-- this fixture stays deliberately tiny.)
local function toy_universe(seed)
   local u = Universe.new(seed)
   local last = 1
   u:add_system("famine", function(universe, stream)
      local n = stream:int(0, 3)
      last = universe:emit{
         kind = "grain.hunger",
         location = "the-void",
         magnitude = n,
         loudness = "loud",
         payload = { shortfall = n },
         causes = { last },
      }
   end)
   return u
end

describe("templates", function()
   it("cover every kind in this repo's vocabulary", function()
      for kind in pairs(vocabulary.kinds) do
         assert.equal("function", type(Chronicle._templates[kind]),
            "no chronicle sentence for " .. kind)
      end
   end)

   it("render genesis", function()
      assert.equal("tick    0 · the-void · a universe begins (seed 1893)",
         Chronicle.line(event()))
   end)

   it("render a founding, thousands separated", function()
      assert.equal("tick    0 · vessar-reaches · the vessari enter history"
         .. " with 160 sacks of grain and 10,000¢",
         Chronicle.line(event{ kind = "civ.founded",
            location = "vessar-reaches", magnitude = 160,
            payload = { name = "vessari", grain = 160, cents = 10000 } }))
   end)

   it("render the day's books", function()
      assert.equal("tick   40 · khedrun-holds · the day's books: 96 sacks"
         .. " in the granary (+7, −10), 1,390¢ in the treasury",
         Chronicle.line(event{ kind = "civ.tally", tick = 40,
            location = "khedrun-holds", magnitude = 96,
            payload = { harvested = 7, eaten = 10, stock = 96,
               cents = 1390 } }))
   end)

   it("render hunger, singular and plural", function()
      assert.equal("tick    9 · khedrun-holds · hunger — the granaries"
         .. " came up 2 sacks short",
         Chronicle.line(event{ kind = "grain.hunger", tick = 9,
            location = "khedrun-holds", magnitude = 2,
            payload = { shortfall = 2 } }))
      assert.equal("tick    9 · khedrun-holds · hunger — the granaries"
         .. " came up 1 sack short",
         Chronicle.line(event{ kind = "grain.hunger", tick = 9,
            location = "khedrun-holds", magnitude = 1,
            payload = { shortfall = 1 } }))
   end)

   it("render both sides of an order", function()
      assert.equal("tick    2 · khedrun-holds · a bid for 12 sacks at up to 105¢",
         Chronicle.line(event{ kind = "market.order", tick = 2,
            location = "khedrun-holds", magnitude = 12,
            payload = { side = "buy", units = 12, limit = 105 } }))
      assert.equal("tick    2 · vessar-reaches · 15 sacks on offer at 98¢ or better",
         Chronicle.line(event{ kind = "market.order", tick = 2,
            location = "vessar-reaches", magnitude = 15,
            payload = { side = "sell", units = 15, limit = 98 } }))
   end)

   it("render a trade", function()
      assert.equal("tick    3 · the-exchange · 12 sacks pass from the"
         .. " vessari to the khedrun at 101¢ (1,212¢ paid)",
         Chronicle.line(event{ kind = "market.trade", tick = 3,
            location = "the-exchange", magnitude = 12,
            payload = { buyer = "khedrun", seller = "vessari",
               units = 12, price = 101, total = 1212 } }))
   end)

   it("render the price, including the quiet day", function()
      assert.equal("tick    3 · the-exchange · grain settles at 103¢ (+2)",
         Chronicle.line(event{ kind = "market.price", tick = 3,
            location = "the-exchange", magnitude = 2,
            payload = { price = 103, delta = 2 } }))
      assert.equal("tick    0 · the-exchange · grain holds at 100¢",
         Chronicle.line(event{ kind = "market.price",
            location = "the-exchange",
            payload = { price = 100, delta = 0 } }))
   end)

   it("render both flavors of declaration", function()
      assert.equal("tick   86 · khedrun-holds · the khedrun declare war on"
         .. " the vessari — grain at 151¢ was the last insult",
         Chronicle.line(event{ kind = "war.declared", tick = 86,
            location = "khedrun-holds", magnitude = 151,
            payload = { aggressor = "khedrun", target = "vessari",
               reason = "price", measure = 151 } }))
      assert.equal("tick   86 · khedrun-holds · the khedrun declare war on"
         .. " the vessari — 4 hungry days were the last insult",
         Chronicle.line(event{ kind = "war.declared", tick = 86,
            location = "khedrun-holds", magnitude = 4,
            payload = { aggressor = "khedrun", target = "vessari",
               reason = "hunger", measure = 4 } }))
   end)

   it("render a raid", function()
      assert.equal("tick   87 · vessar-reaches · a khedrun war party rides"
         .. " against the vessari granaries (force 8)",
         Chronicle.line(event{ kind = "war.raid", tick = 87,
            location = "vessar-reaches", magnitude = 8,
            payload = { raider = "khedrun", target = "vessari",
               force = 8 } }))
   end)

   it("render spoils: laden, unburned, and bare", function()
      assert.equal("tick   88 · vessar-reaches · the khedrun raiders carry"
         .. " off 8 sacks and 400¢ from the vessari and put 4 to the torch",
         Chronicle.line(event{ kind = "war.spoils", tick = 88,
            location = "vessar-reaches", magnitude = 12,
            payload = { raider = "khedrun", target = "vessari",
               seized = 8, plunder = 400, burned = 4 } }))
      assert.equal("tick   88 · vessar-reaches · the khedrun raiders carry"
         .. " off 8 sacks and 400¢ from the vessari",
         Chronicle.line(event{ kind = "war.spoils", tick = 88,
            location = "vessar-reaches", magnitude = 8,
            payload = { raider = "khedrun", target = "vessari",
               seized = 8, plunder = 400, burned = 0 } }))
      assert.equal("tick   88 · vessar-reaches · the khedrun raiders find"
         .. " the vessari stores bare",
         Chronicle.line(event{ kind = "war.spoils", tick = 88,
            location = "vessar-reaches", magnitude = 0,
            payload = { raider = "khedrun", target = "vessari",
               seized = 0, plunder = 0, burned = 0 } }))
   end)

   it("render peace", function()
      assert.equal("tick   96 · khedrun-holds · the khedrun sheathe —"
         .. " grain at 79¢ buys more than blood",
         Chronicle.line(event{ kind = "war.peace", tick = 96,
            location = "khedrun-holds", magnitude = 79,
            payload = { name = "khedrun", price = 79 } }))
   end)
end)

describe("the unknown-kind fallback", function()
   it("renders kinds younger than this viewer from the envelope alone", function()
      local e = event{
         kind = "diplomacy.betrayal",
         tick = 512,
         location = "sector:7",
         magnitude = 8,
         loudness = "quiet",
         payload = { traitor = "house-veyl", victim = "house-omast" },
      }
      assert.equal(
         "tick  512 · sector:7 · diplomacy.betrayal, magnitude 8, quiet"
         .. " — traitor=house-veyl, victim=house-omast",
         Chronicle.line(e))
   end)

   it("survives an empty payload", function()
      local e = event{ kind = "void.hum", tick = 1, magnitude = 2,
         loudness = "loud", payload = {} }
      assert.equal("tick    1 · the-void · void.hum, magnitude 2, loud",
         Chronicle.line(e))
   end)
end)

describe("the cursor", function()
   it("returns only what it hasn't yet rendered", function()
      local u = toy_universe(1893)
      local c = Chronicle.new(u.annals)
      assert.equal(1, #c:lines()) -- genesis
      assert.same({}, c:lines())
      u:run(3)
      assert.equal(3, #c:lines())
      assert.same({}, c:lines())
   end)

   it("a fresh chronicle replays the whole log to the same lines", function()
      local u = toy_universe(1893)
      local live = Chronicle.new(u.annals)
      local seen = {}
      for _ = 1, 5 do
         u:step()
         local lines = live:lines()
         table.move(lines, 1, #lines, #seen + 1, seen)
      end
      assert.same(seen, Chronicle.new(u.annals):lines())
   end)
end)

describe("the golden feed", function()
   it("the toy world's first days read the same on every machine", function()
      -- Hardcoded from a real run of the real world. If this fails,
      -- either rendering changed (update the lines, note it in the
      -- post's changelog) or determinism broke (stop everything).
      local toy = require "support.toy"
      local u = toy(1893)
      u:run(2)
      assert.same({
         "tick    0 · the-void · a universe begins (seed 1893)",
         "tick    0 · vessar-reaches · the vessari enter history with 160 sacks of grain and 10,000¢",
         "tick    0 · khedrun-holds · the khedrun enter history with 80 sacks of grain and 14,000¢",
         "tick    0 · the-exchange · grain holds at 100¢",
         "tick    1 · vessar-reaches · the day's books: 165 sacks in the granary (+13, −8), 10,000¢ in the treasury",
         "tick    1 · vessar-reaches · 12 sacks on offer at 98¢ or better",
         "tick    1 · khedrun-holds · the day's books: 78 sacks in the granary (+8, −10), 14,000¢ in the treasury",
         "tick    1 · khedrun-holds · a bid for 15 sacks at up to 103¢",
         "tick    2 · the-exchange · 12 sacks pass from the vessari to the khedrun at 100¢ (1,200¢ paid)",
         "tick    2 · the-exchange · grain settles at 101¢ (+1)",
         "tick    2 · vessar-reaches · the day's books: 157 sacks in the granary (+12, −8), 11,200¢ in the treasury",
         "tick    2 · vessar-reaches · 12 sacks on offer at 99¢ or better",
         "tick    2 · khedrun-holds · the day's books: 87 sacks in the granary (+7, −10), 12,800¢ in the treasury",
         "tick    2 · khedrun-holds · a bid for 13 sacks at up to 104¢",
      }, Chronicle.new(u.annals):lines())
   end)
end)

describe("law 4, executable", function()
   it("watching changes nothing", function()
      -- With projection this passes by construction — that is the
      -- point of projection. The spec pins it so a future
      -- "optimization" can't unpin it.
      local watched, bare = toy_universe(99), toy_universe(99)
      local c = Chronicle.new(watched.annals)
      for _ = 1, 20 do
         watched:step()
         c:lines()
         bare:step()
      end
      assert.equal(bare.annals:len(), watched.annals:len())
      for id = 1, bare.annals:len() do
         assert.same(bare.annals:get(id), watched.annals:get(id))
      end
   end)
end)
