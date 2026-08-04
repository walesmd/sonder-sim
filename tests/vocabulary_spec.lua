-- tests/vocabulary_spec.lua — the public API's shape. These specs
-- don't test behavior; they hold the declaration to its own rules, so
-- a kind can't sneak in half-declared.

local vocabulary = require "worlds.toy_vocabulary"

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
