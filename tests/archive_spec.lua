-- tests/archive_spec.lua — the durable annals: same history on disk
-- as in memory, provenance at birth, append-only enforced by the
-- file itself, and byte-identical databases from identical runs.

local sqlite3 = require "lsqlite3"
local Universe = require "sonder.universe"
local Archive = require "sonder.archive"

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

-- The placeholder systems from main.lua, so archived universes have
-- some history worth querying.
local function toy_universe(seed)
   local u = Universe.new(seed)
   local last_market = 1
   u:add_system("market", function(universe, stream)
      local drift = stream:int(-3, 3)
      last_market = universe:emit{
         kind = "market.drift",
         location = "the-void",
         magnitude = math.abs(drift),
         visibility = "public",
         payload = { drift = drift },
         causes = { last_market },
      }
   end)
   return u
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
      SELECT 'annals', id, tick, kind, location, magnitude, visibility, payload
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
      assert.equal("1", rows.schema_version)
      assert.equal("[]", rows.interventions)
      assert.equal(_VERSION, rows.lua_version)
      assert.equal(sqlite3.version(), rows.sqlite_version)
      assert.same({ { 1 } }, query(path, "PRAGMA user_version"))
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
      local u = toy_universe(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      assert.equal(1, archive:sync()) -- genesis
      assert.equal(0, archive:sync()) -- nothing new
      u:run(3)
      assert.equal(3, archive:sync())
      archive:close()
      assert.same({ { 4 } }, query(path, "SELECT count(*) FROM annals"))
   end)

   it("archives the same history the memory holds", function()
      local u = toy_universe(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(5)
      archive:close() -- close syncs
      for id = 1, u.annals:len() do
         local e = u.annals:get(id)
         local row = query(path,
            ("SELECT tick, kind, location, magnitude, visibility FROM annals WHERE id = %d"):format(id))[1]
         assert.same({ e.tick, e.kind, e.location, e.magnitude, e.visibility }, row)
         local causes = {}
         for _, c in ipairs(query(path,
            ("SELECT cause_id FROM causes WHERE event_id = %d ORDER BY ord"):format(id))) do
            causes[#causes + 1] = c[1]
         end
         assert.same(e.causes, causes)
      end
   end)

   it("writes payloads as canonical JSON SQL can reach into", function()
      local u = toy_universe(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      u:run(1)
      archive:close()
      assert.same({ { '{"seed":1893}' } },
         query(path, "SELECT payload FROM annals WHERE id = 1"))
      local drift = u.annals:get(2).payload.drift
      assert.same({ { drift } },
         query(path, "SELECT json_extract(payload, '$.drift') FROM annals WHERE id = 2"))
   end)

   it("the file itself refuses UPDATE and DELETE", function()
      local u = toy_universe(1893)
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
         local u = toy_universe(1893)
         local archive = Archive.create(p, u.annals, provenance(1893))
         u:run(10)
         archive:close()
      end
      assert.equal(dump(path), dump(other))
      os.remove(other)
   end)

   it("a closed archive is spent", function()
      local u = toy_universe(1893)
      local archive = Archive.create(path, u.annals, provenance(1893))
      archive:close()
      assert.has_error(function() archive:sync() end, "archive: already closed")
      assert.has_error(function() archive:close() end, "archive: already closed")
   end)
end)
