-- Recompute a universe file's seal from its rows alone: no vocabulary, no engine run.
package.path = "src/?.lua;" .. package.path
local sqlite3 = require "lsqlite3"
local fnv = require "sonder.fnv"
local byteform = require "sonder.byteform"
local db = sqlite3.open(arg[1])
local causes = {}
for ev, cid in db:urows("SELECT event_id, cause_id FROM causes ORDER BY event_id, ord") do
   causes[ev] = causes[ev] or {}
   table.insert(causes[ev], cid)
end
local h, n = fnv.offset, 0
local cps = {}
for t, ev, hash in db:urows("SELECT tick, events, hash FROM checkpoints ORDER BY tick") do cps[#cps+1] = { t, ev, hash } end
local ci, ok, bad = 1, 0, 0
for id, tick, kind, loc, mag, loud, payload in db:urows("SELECT id, tick, kind, location, magnitude, loudness, payload FROM annals ORDER BY id") do
   while cps[ci] and cps[ci][2] == n do
      if ("%016x"):format(h) == cps[ci][3] then ok = ok + 1 else bad = bad + 1 end
      ci = ci + 1
   end
   local bytes = ('{"id":%d,"tick":%d,"kind":%s,"location":%s,"magnitude":%d,"loudness":%s,"payload":%s,"causes":[%s]}')
      :format(id, tick, byteform.json_string(kind), byteform.json_string(loc), mag, byteform.json_string(loud), payload,
         table.concat(causes[id] or {}, ","))
   h = fnv.string(h, bytes); n = n + 1
end
while cps[ci] do if cps[ci][2] == n and ("%016x"):format(h) == cps[ci][3] then ok = ok + 1 else bad = bad + 1 end ci = ci + 1 end
local prov = {}
for k, v in db:urows("SELECT key, value FROM provenance ORDER BY key") do prov[#prov+1] = k .. "=" .. v end
print(("%s: %d events, %d checkpoints verified from rows alone, %d bad; final %016x"):format(arg[1]:match("[^/]+$"), n, ok, bad, h))
print("  provenance: " .. table.concat(prov, " | "))
local uv; for v in db:urows("PRAGMA user_version") do uv = v end; print("  user_version " .. uv)
