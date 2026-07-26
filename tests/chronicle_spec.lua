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
      visibility = "public",
      payload = { seed = 1893 },
      causes = {},
   }
   for k, v in pairs(overrides or {}) do
      e[k] = v
   end
   return e
end

-- The emitting universe main.lua wires, in miniature: one chained
-- placeholder system.
local function toy_universe(seed)
   local u = Universe.new(seed)
   local last = 1
   u:add_system("market", function(universe, stream)
      local d = stream:int(-3, 3)
      last = universe:emit{
         kind = "market.drift",
         location = "the-void",
         magnitude = d < 0 and -d or d,
         visibility = "public",
         payload = { drift = d },
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

   it("render drift, including the quiet day", function()
      assert.equal("tick   12 · the-void · the market drifts +3",
         Chronicle.line(event{ kind = "market.drift", tick = 12,
            magnitude = 3, payload = { drift = 3 } }))
      assert.equal("tick   12 · the-void · the market drifts -2",
         Chronicle.line(event{ kind = "market.drift", tick = 12,
            magnitude = 2, payload = { drift = -2 } }))
      assert.equal("tick   12 · the-void · the market holds steady",
         Chronicle.line(event{ kind = "market.drift", tick = 12,
            magnitude = 0, payload = { drift = 0 } }))
   end)

   it("render muster, including the lonely levy", function()
      assert.equal("tick    3 · the-void · the war office musters 7 levies",
         Chronicle.line(event{ kind = "war.muster", tick = 3,
            magnitude = 7, payload = { muster = 7 } }))
      assert.equal("tick    3 · the-void · the war office musters 1 levy",
         Chronicle.line(event{ kind = "war.muster", tick = 3,
            magnitude = 1, payload = { muster = 1 } }))
      assert.equal("tick    3 · the-void · the war office musters nobody",
         Chronicle.line(event{ kind = "war.muster", tick = 3,
            magnitude = 0, payload = { muster = 0 } }))
   end)
end)

describe("the unknown-kind fallback", function()
   it("renders kinds younger than this viewer from the envelope alone", function()
      local e = event{
         kind = "diplomacy.betrayal",
         tick = 512,
         location = "sector:7",
         magnitude = 8,
         visibility = "secret",
         payload = { traitor = "house-veyl", victim = "house-omast" },
      }
      assert.equal(
         "tick  512 · sector:7 · diplomacy.betrayal, magnitude 8, secret"
         .. " — traitor=house-veyl, victim=house-omast",
         Chronicle.line(e))
   end)

   it("survives an empty payload", function()
      local e = event{ kind = "void.hum", tick = 1, magnitude = 2,
         visibility = "public", payload = {} }
      assert.equal("tick    1 · the-void · void.hum, magnitude 2, public",
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
   it("seed 1893 reads the same on every machine", function()
      -- Hardcoded from a real run. If this fails, either rendering
      -- changed (update the lines, note it in the post's changelog)
      -- or determinism broke (stop everything).
      local u = toy_universe(1893)
      u:run(3)
      assert.same({
         "tick    0 · the-void · a universe begins (seed 1893)",
         "tick    1 · the-void · the market drifts -1",
         "tick    2 · the-void · the market drifts +3",
         "tick    3 · the-void · the market drifts -1",
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
