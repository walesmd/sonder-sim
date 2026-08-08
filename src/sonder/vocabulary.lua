-- src/sonder/vocabulary.lua — the vocabulary contract, validated
-- once (card 171; a card-166 finding).
--
-- The event vocabulary is a public API a world supplies and four
-- engine modules consume: the annals validates events against it,
-- byteform walks its declaration order, the seal hashes what
-- byteform makes, and the archive writes its version into
-- provenance. Before this module, each consumer checked the piece
-- it touched, in its own error voice, and a half-shaped vocabulary
-- failed at whichever module it reached first. Now the shape rules
-- live here — one check, one voice, run once per universe at
-- construction — and the consumers keep only the cheap asserts
-- that protect their own direct use.
--
-- Also here: the framework road grammar. The four cargo/payment
-- kinds are engine-consumed (roads.lua emits them; the audit's
-- framework legs book them) and were copy-declared in all three
-- worlds — two of which predicted this extraction in their own
-- comments. with_road_kinds() merges them into a world's kind
-- table; a world that declares its own version of one keeps it
-- (worlds may override, because the vocabulary is theirs).

local Vocabulary = {}

local FIELD_TYPES = { integer = true, string = true }

-- Hold a declaration to its own rules. Raises with one voice on
-- the first violation; returns the declaration untouched otherwise
-- (this is a check, not a copy — the world's table is the
-- vocabulary, not a source for one).
function Vocabulary.check(v)
   assert(type(v) == "table",
      "vocabulary: a declaration must be a table")
   assert(math.type(v.schema_version) == "integer"
      and v.schema_version >= 1,
      "vocabulary: schema_version must be a positive integer")
   assert(type(v.loudnesses) == "table" and #v.loudnesses > 0,
      "vocabulary: declare a non-empty loudness set")
   local seen = {}
   for i = 1, #v.loudnesses do
      local l = v.loudnesses[i]
      assert(type(l) == "string" and #l > 0,
         "vocabulary: loudnesses must be non-empty strings")
      assert(not seen[l],
         ("vocabulary: loudness %q declared twice"):format(l))
      seen[l] = true
   end
   assert(type(v.kinds) == "table",
      "vocabulary: declare a kinds table")
   assert(v.kinds["universe.genesis"],
      "vocabulary: every vocabulary must declare universe.genesis"
      .. " — every universe begins")
   for kind, entry in pairs(v.kinds) do
      -- pairs() is legal here, narrowly: validation only accepts
      -- or raises — no outcome depends on visit order.
      local where = ("vocabulary: %s"):format(tostring(kind))
      assert(type(kind) == "string" and #kind > 0,
         "vocabulary: kind names must be non-empty strings")
      assert(type(entry) == "table", where .. " must be a table")
      assert(type(entry.doc) == "string" and #entry.doc > 0,
         where .. ": every kind carries a doc line")
      assert(type(entry.payload) == "table",
         where .. ": payload must be an ordered field list")
      local fields = {}
      for i = 1, #entry.payload do
         local field = entry.payload[i]
         local name, ftype = field[1], field[2]
         assert(type(name) == "string" and #name > 0,
            where .. ": payload field names must be strings")
         assert(FIELD_TYPES[ftype],
            ("%s.%s: type %s is not integer|string")
            :format(where, name, tostring(ftype)))
         assert(not fields[name],
            ("%s.%s declared twice"):format(where, name))
         fields[name] = true
      end
   end
   return v
end

-- The framework road grammar: the kinds roads.lua emits and the
-- audit's framework legs book. Declared once, here, so three
-- worlds stop spelling them independently. Payload shapes are the
-- public API; the docs are the shared developer-facing baseline
-- (a world's chronicle templates own its prose voice).
function Vocabulary.road_kinds()
   return {
      ["cargo.shipped"] = {
         doc = "matter departs one holder for another (framework "
            .. "grammar: the roads price the trip, the audit books "
            .. "the embarkation)",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["cargo.delivered"] = {
         doc = "matter arrives; cites its cargo.shipped (framework "
            .. "grammar)",
         payload = { { "commodity", "string" }, { "units", "integer" },
            { "sender", "string" }, { "recipient", "string" } },
      },
      ["payment.shipped"] = {
         doc = "money departs payer for payee (framework grammar)",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
      },
      ["payment.delivered"] = {
         doc = "money arrives; cites its payment.shipped (framework "
            .. "grammar)",
         payload = { { "amount", "integer" },
            { "payer", "string" }, { "payee", "string" } },
      },
   }
end

-- Merge the road grammar into a world's kind table. The world's
-- own declaration wins on collision — the vocabulary is the
-- world's, and overriding a doc (or, carefully, a payload) is its
-- right; the framework only refuses to be *absent*.
function Vocabulary.with_road_kinds(kinds)
   local road = Vocabulary.road_kinds()
   for kind, entry in pairs(road) do
      if kinds[kind] == nil then
         kinds[kind] = entry
      end
   end
   return kinds
end

return Vocabulary
