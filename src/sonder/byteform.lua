-- src/sonder/byteform.lua — the byte form of an event: there is one.
--
-- Everything that turns an event into bytes goes through here, so
-- the bytes can be a promise: envelope fields in fixed order, payload
-- fields in declaration order (the vocabulary's ordered arrays exist
-- so nothing ever walks pairs()), integers printed as integers, total
-- escaping. The archive stores these bytes (card 115); the seal
-- hashes them (card 116); if the two ever disagreed about what an
-- event "is", checkpoints would stop matching archives — so there is
-- exactly one answer, and this is its address.
--
-- The output happens to be valid JSON, which is a courtesy to
-- humans and SQL's json_extract — but the contract is the *bytes*,
-- not the format. Same event, same bytes, every machine, every era.

local byteform = {}

-- JSON string escaping, total: quote, backslash, and every control
-- character (as \u00xx), nothing else touched. No dependency gets to
-- decide what our history looks like.
function byteform.json_string(s)
   return '"' .. s:gsub('[%c\\"]', function(c)
      if c == '"' then return '\\"' end
      if c == '\\' then return '\\\\' end
      return ("\\u%04x"):format(c:byte())
   end) .. '"'
end

-- The payload object, fields in declaration order.
function byteform.payload(declared, payload)
   local parts = {}
   for i = 1, #declared do
      local name, want = declared[i][1], declared[i][2]
      local value = payload[name]
      parts[i] = byteform.json_string(name) .. ":"
         .. (want == "integer" and ("%d"):format(value) or byteform.json_string(value))
   end
   return "{" .. table.concat(parts, ",") .. "}"
end

-- The whole event, one line. Strict about kinds: canonical bytes for
-- an event require that era's vocabulary — a seal computed with the
-- wrong dialect would be quietly meaningless, and quiet is the one
-- thing a divergence detector must never be.
function byteform.event(vocabulary, e)
   local entry = vocabulary.kinds[e.kind]
   if not entry then
      error(("byteform: unregistered kind %q"):format(tostring(e.kind)))
   end
   return ('{"id":%d,"tick":%d,"kind":%s,"location":%s,"magnitude":%d,'
      .. '"visibility":%s,"payload":%s,"causes":[%s]}'):format(
      e.id, e.tick, byteform.json_string(e.kind), byteform.json_string(e.location),
      e.magnitude, byteform.json_string(e.visibility),
      byteform.payload(entry.payload, e.payload), table.concat(e.causes, ","))
end

return byteform
