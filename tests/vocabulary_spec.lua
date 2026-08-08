-- tests/vocabulary_spec.lua — the public API's shape. These specs
-- don't test behavior; they hold the declaration to its own rules, so
-- a kind can't sneak in half-declared. Since card 171 the rules
-- themselves are code (sonder/vocabulary.lua, checked once per
-- universe at construction); the shape specs below stay as the
-- rules' own executable statement, and every world's declaration
-- passes through the checker here.

local Vocabulary = require "sonder.vocabulary"
local vocabulary = require "worlds.space_vocabulary"

describe("the vocabulary checker", function()
   it("accepts every world this project ships", function()
      Vocabulary.check(require "worlds.space_vocabulary")
      Vocabulary.check(require "worlds.continent_vocabulary")
      Vocabulary.check(require "worlds.office_vocabulary")
      Vocabulary.check(require "support.vocabulary")
   end)

   it("rejects half-shaped declarations, in one voice", function()
      local function lawful()
         return {
            schema_version = 1,
            loudnesses = { "loud", "local", "quiet" },
            kinds = {
               ["universe.genesis"] = { doc = "a beginning",
                  payload = { { "seed", "integer" } } },
            },
         }
      end
      Vocabulary.check(lawful()) -- the baseline passes
      local v = lawful(); v.schema_version = "one"
      assert.has_error(function() Vocabulary.check(v) end)
      v = lawful(); v.loudnesses = { "loud", "loud" }
      assert.has_error(function() Vocabulary.check(v) end)
      v = lawful(); v.kinds["universe.genesis"] = nil
      assert.has_error(function() Vocabulary.check(v) end)
      v = lawful(); v.kinds["x.y"] = { doc = "typed wrong",
         payload = { { "n", "float" } } }
      assert.has_error(function() Vocabulary.check(v) end)
      v = lawful(); v.kinds["x.y"] = { doc = "field twice",
         payload = { { "n", "integer" }, { "n", "integer" } } }
      assert.has_error(function() Vocabulary.check(v) end)
   end)

   it("merges the road grammar, and the world wins on collision", function()
      local kinds = Vocabulary.with_road_kinds{
         ["cargo.shipped"] = { doc = "the world's own reading",
            payload = { { "commodity", "string" }, { "units", "integer" },
               { "sender", "string" }, { "recipient", "string" } } },
      }
      assert.equal("the world's own reading", kinds["cargo.shipped"].doc)
      assert.is_not_nil(kinds["cargo.delivered"])
      assert.is_not_nil(kinds["payment.shipped"])
      assert.is_not_nil(kinds["payment.delivered"])
   end)
end)

describe("vocabulary", function()
   it("carries an integer schema version", function()
      assert.equal("integer", math.type(vocabulary.schema_version))
      assert.is_true(vocabulary.schema_version >= 1)
   end)

   it("declares a non-empty set of distinct loudnesses", function()
      assert.is_true(#vocabulary.loudnesses > 0)
      local seen = {}
      for i = 1, #vocabulary.loudnesses do
         local v = vocabulary.loudnesses[i]
         assert.equal("string", type(v))
         assert.is_nil(seen[v], tostring(v) .. " declared twice")
         seen[v] = true
      end
   end)

   it("declares every kind fully: a doc line, an ordered typed payload", function()
      for kind, entry in pairs(vocabulary.kinds) do
         assert.equal("string", type(entry.doc), kind .. ": doc")
         assert.is_true(#entry.doc > 0, kind .. ": doc is empty")
         assert.equal("table", type(entry.payload), kind .. ": payload")
         local seen = {}
         for i = 1, #entry.payload do
            local name, ftype = entry.payload[i][1], entry.payload[i][2]
            assert.equal("string", type(name), kind .. ": field name")
            assert.is_true(ftype == "integer" or ftype == "string",
               ("%s.%s: type %s is not integer|string"):format(kind, tostring(name), tostring(ftype)))
            assert.is_nil(seen[name], ("%s.%s declared twice"):format(kind, name))
            seen[name] = true
         end
      end
   end)
end)
