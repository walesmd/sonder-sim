-- tests/archive_spec.lua — the durable annals: same history on disk
-- as in memory, provenance at birth, append-only enforced by the
-- file itself, and byte-identical databases from identical runs.

local sqlite3 = require "lsqlite3"
local Universe = require "sonder.universe"
local Archive = require "sonder.archive"
local Seal = require "sonder.seal"
local toy = require "support.toy"

-- A fresh path in the OS temp dir that no file occupies yet.
-- os.tmpname() pre-creates the file and Archive.create refuses paths
-- that exist, which here is the feature under test, not a nuisance.
local function fresh_path()
   local path = os.tmpname()
   os.remove(path)
   return path
end

local function provenance(seed)
   return {
      engine_version = "dev-1",
      git_commit = "deadbeef",
      seed = seed,
      config = "{}",
   }
end

-- The seal of every event through a given tick, plus how many there
-- were — computed independently of the archive, which is the point:
-- checkpoints must be recomputable from the log by anyone.
local function seal_through(annals, tick_limit)
   local seal = Seal.new(annals.vocabulary)
   local events = 0
   for id = 1, annals:len() do
      local e = annals:get(id)
      if e.tick <= tick_limit then
         seal:fold(e)
         events = events + 1
      end
   end
   return seal:hex(), events
end

-- Run a query against the db file and collect every row as an array
-- of arrays — plain values, easy to assert.same against.
local function query(path, sql)
   local db = sqlite3.open(path)
   local rows = {}
   for row in db:rows(sql) do
      rows[#rows + 1] = row
   end
   db:close()
   return rows
end

-- One string for the whole database's logical content, for comparing
-- two files: every table, every row, deterministic order.
local function dump(path)
   local out = {}
   local db = sqlite3.open(path)
   for row in db:rows([[
      SELECT 'annals', id, tick, kind, location, magnitude, loudness, payload
      FROM annals ORDER BY id
   ]]) do
      out[#out + 1] = table.concat(row, "|")
   end
   for row in db:rows("SELECT 'causes', event_id, ord, cause_id FROM causes ORDER BY event_id, ord") do
      out[#out + 1] = table.concat(row, "|")
   end
   for row in db:rows("SELECT 'provenance', key, value FROM provenance ORDER BY key") do
      out[#out + 1] = table.concat(row, "|")
   end
   for row in db:rows("SELECT 'checkpoints', tick, events, hash FROM checkpoints ORDER BY tick") do
      out[#out + 1] = table.concat(row, "|")
   end
   db:close()
   return table.concat(out, "\n")
end

describe("Archive", function()
   local path

   before_each(function()
      path = fresh_path()
   end)

   after_each(function()
      os.remove(path)
   end)

   it("creates the file with provenance at birth", function()
      local u = Universe.new(7)
      local archive = Archive.create(path, u.annals, provenance(7))
      archive:close()
      local rows = {}
      for _, row in ipairs(query(path, "SELECT key, value FROM provenance ORDER BY key")) do
         rows[row[1]] = row[2]
      end
      assert.equal("dev-1", rows.engine_version)
      assert.equal("deadbeef", rows.git_commit)
      assert.equal("7", rows.seed)
      assert.equal("{}", rows.config)
      assert.equal("3", rows.schema_version)
      assert.equal("[]", rows.interventions)
      assert.equal(_VERSION, rows.lua_version)
      assert.equal(sqlite3.version(), rows.sqlite_version)
      assert.same({ { 2 } }, query(path, "PRAGMA user_version"))
   end)

   it("demands the host facts it cannot invent", function()
      local u = Universe.new(7)
      assert.has_error(function()
         Archive.create(path, u.annals, { seed = 7, config = "{}" })
      end)
      assert.has_error(function()
         local p = provenance(7)
         p.seed = "7" -- a string is not a seed
         Archive.create(path, u.annals, p)
      end)
   end)

   it("refuses to overwrite an existing file", function()
      local touched = assert(io.open(path, "w"))
      touched:close()
      local u = Universe.new(7)
      assert.has_error(function()
         Archive.create(path, u.annals, provenance(7))
      end, ("archive: %s already exists; refusing to overwrite history"):format(path))
   end)

   it("sync copies exactly the new suffix, and says how much", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      assert.equal(4, archive:sync()) -- genesis, two foundings, the price
      assert.equal(0, archive:sync()) -- nothing new
      u:run(3)
      assert.equal(u.annals:len() - 4, archive:sync())
      archive:close()
      assert.same({ { u.annals:len() } }, query(path, "SELECT count(*) FROM annals"))
   end)

   it("archives the same history the memory holds", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(5)
      archive:close() -- close syncs
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         local row = query(path,
            ("SELECT tick, kind, location, magnitude, loudness FROM annals WHERE id = %d"):format(id))[1]
         assert.same({ e.tick, e.kind, e.location, e.magnitude, e.loudness }, row)
         local causes = {}
         for _, c in ipairs(query(path,
            ("SELECT cause_id FROM causes WHERE event_id = %d ORDER BY ord"):format(id))) do
            causes[#causes + 1] = c[1]
         end
         assert.same(e.causes, causes)
      end
   end)

   it("writes payloads as canonical JSON SQL can reach into", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(1)
      archive:close()
      assert.same({ { '{"seed":1893}' } },
         query(path, "SELECT payload FROM annals WHERE id = 1"))
      assert.same({ { '{"name":"vessari","grain":160,"cents":10000}' } },
         query(path, "SELECT payload FROM annals WHERE id = 2"))
      assert.same({ { 160 } },
         query(path, "SELECT json_extract(payload, '$.grain') FROM annals WHERE id = 2"))
   end)

   it("the file itself refuses UPDATE and DELETE", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(2)
      archive:close()
      local db = sqlite3.open(path)
      assert.not_equal(sqlite3.OK, db:exec("UPDATE annals SET magnitude = 999 WHERE id = 2"))
      assert.matches("append%-only", db:errmsg())
      assert.not_equal(sqlite3.OK, db:exec("DELETE FROM annals WHERE id = 2"))
      assert.not_equal(sqlite3.OK, db:exec("UPDATE causes SET cause_id = 1"))
      assert.not_equal(sqlite3.OK, db:exec("DELETE FROM causes"))
      db:close()
   end)

   it("same seed, same database, logically byte for byte", function()
      local other = fresh_path()
      for _, p in ipairs({ path, other }) do
         local u = toy(1893)
         local archive = Archive.create(p, u.annals, provenance(1893))
         u:run(10)
         archive:close()
      end
      assert.equal(dump(path), dump(other))
      os.remove(other)
   end)

   it("a closed archive is spent", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      archive:close()
      assert.has_error(function() archive:sync() end, "archive: already closed")
      assert.has_error(function() archive:close() end, "archive: already closed")
   end)

   it("checkpoints every N ticks, each recomputable from the log", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893),
         { checkpoint_every = 2 })
      u:run(5)
      archive:close()
      -- Periodic seals at ticks 2 and 4, and the final seal at 5
      -- (close completes the last tick). Each row must match a seal
      -- computed here, independently, straight off the annals.
      local rows = query(path, "SELECT tick, events, hash FROM checkpoints ORDER BY tick")
      assert.equal(3, #rows)
      for _, row in ipairs(rows) do
         local hash, events = seal_through(u.annals, row[1])
         assert.same({ row[1], events, hash }, row)
      end
      assert.same({ 2, 4, 5 }, { rows[1][1], rows[2][1], rows[3][1] })
   end)

   it("syncing mid-tick or per-tick lands the same checkpoints", function()
      -- Checkpoints derive from the log alone; how often the follower
      -- happens to look must not change what it writes down.
      local eager, lazy = fresh_path(), fresh_path()
      local u = toy(1893)
      local a = Archive.create(eager, u.annals, provenance(1893), { checkpoint_every = 2 })
      for _ = 1, 5 do
         u:step()
         a:sync() -- looks every tick
      end
      a:close()
      local v = toy(1893)
      local b = Archive.create(lazy, v.annals, provenance(1893), { checkpoint_every = 2 })
      v:run(5)
      b:close() -- looks exactly once
      assert.equal(dump(eager), dump(lazy))
      os.remove(eager)
      os.remove(lazy)
   end)

   it("every file ends sealed, even one that never ran", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      archive:close()
      local hash, events = seal_through(u.annals, 0)
      assert.same({ { 0, events, hash } },
         query(path, "SELECT tick, events, hash FROM checkpoints"))
   end)

   it("checkpoints refuse UPDATE and DELETE like everything else", function()
      local u = toy(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(2)
      archive:close()
      local db = sqlite3.open(path)
      assert.not_equal(sqlite3.OK, db:exec("UPDATE checkpoints SET hash = 'improved'"))
      assert.matches("append%-only", db:errmsg())
      assert.not_equal(sqlite3.OK, db:exec("DELETE FROM checkpoints"))
      db:close()
   end)
end)
