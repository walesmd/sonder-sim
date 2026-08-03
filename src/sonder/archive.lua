-- src/sonder/archive.lua — the annals, made durable.
--
-- An archive is a follower, not a subsystem: like the chronicle it
-- keeps a cursor over annals:get() and copies whatever is new, so the
-- sim runs bit-identically whether its history is being written to
-- disk or not (law 4, doing double duty as a persistence seam). The
-- database is a projection of the log that happens to *be* the log's
-- durable form: same ids, same envelope, plus the provenance the
-- day-one requirements demand — because a universe file that can't
-- say what engine, commit, and seed made it is unreproducible, and
-- that can't be retrofitted onto files already in the wild.
--
-- Append-only is enforced by the database itself: UPDATE and DELETE
-- on history RAISE(ABORT) via triggers. Not by this module being
-- polite — anyone with a sqlite3 shell gets told no by the file.

local sqlite3 = require "lsqlite3"
local byteform = require "sonder.byteform"
local Seal = require "sonder.seal"

local Archive = {}
Archive.__index = Archive

-- The database layout's own version, stamped into PRAGMA user_version.
-- Distinct from the event vocabulary's schema_version (a provenance
-- row): tables can be rearranged without a single event kind changing
-- shape, and vice versa.
-- v2: the annals table's visibility column became loudness (card 122,
-- alongside vocabulary v3 — here the envelope change *is* a layout
-- change, because the envelope has a column).
local LAYOUT_VERSION = 2

local SCHEMA = [[
PRAGMA user_version = ]] .. LAYOUT_VERSION .. [[;

CREATE TABLE provenance (
   key   TEXT PRIMARY KEY,
   value TEXT NOT NULL
) WITHOUT ROWID;

CREATE TABLE annals (
   id         INTEGER PRIMARY KEY,  -- the event's position, same as in memory
   tick       INTEGER NOT NULL,
   kind       TEXT    NOT NULL,
   location   TEXT    NOT NULL,
   magnitude  INTEGER NOT NULL,
   loudness   TEXT    NOT NULL,
   payload    TEXT    NOT NULL      -- canonical JSON, fields in declaration order
);

CREATE TABLE causes (
   event_id INTEGER NOT NULL REFERENCES annals(id),
   ord      INTEGER NOT NULL,      -- position in the event's causes array
   cause_id INTEGER NOT NULL REFERENCES annals(id),
   PRIMARY KEY (event_id, ord)
) WITHOUT ROWID;

CREATE TABLE checkpoints (
   tick   INTEGER PRIMARY KEY,  -- the completed tick this seals
   events INTEGER NOT NULL,     -- how many events existed through it
   hash   TEXT    NOT NULL      -- the rolling seal, sixteen hex digits
) WITHOUT ROWID;

CREATE TRIGGER annals_no_update BEFORE UPDATE ON annals
BEGIN SELECT RAISE(ABORT, 'annals is append-only'); END;
CREATE TRIGGER annals_no_delete BEFORE DELETE ON annals
BEGIN SELECT RAISE(ABORT, 'annals is append-only'); END;
CREATE TRIGGER causes_no_update BEFORE UPDATE ON causes
BEGIN SELECT RAISE(ABORT, 'causes are append-only'); END;
CREATE TRIGGER causes_no_delete BEFORE DELETE ON causes
BEGIN SELECT RAISE(ABORT, 'causes are append-only'); END;
CREATE TRIGGER checkpoints_no_update BEFORE UPDATE ON checkpoints
BEGIN SELECT RAISE(ABORT, 'checkpoints are append-only'); END;
CREATE TRIGGER checkpoints_no_delete BEFORE DELETE ON checkpoints
BEGIN SELECT RAISE(ABORT, 'checkpoints are append-only'); END;
]]

-- Provenance the caller must supply, because only the host knows:
-- the archive sits with the viewers, where shells and git are legal,
-- but it still refuses to invent facts it can't verify.
local REQUIRED = { "engine_version", "git_commit", "seed", "config" }

local function fail(db, context)
   local msg = db:errmsg()
   db:close()
   error("archive: " .. context .. ": " .. msg)
end

-- Create a new universe database at path and stand ready to follow
-- the given annals. Refuses to touch a path that already exists:
-- overwriting a universe.db is burning a history book, and that is
-- the user's explicit act, never our default.
-- opts (all optional): checkpoint_every — write a seal checkpoint at
-- every tick divisible by this (default 100).
function Archive.create(path, annals, provenance, opts)
   assert(type(path) == "string" and #path > 0,
      "archive: path must be a non-empty string")
   assert(type(annals) == "table" and annals.get and annals.len,
      "archive: second argument must be an annals")
   assert(type(provenance) == "table", "archive: provenance must be a table")
   opts = opts or {}
   local checkpoint_every = opts.checkpoint_every or 100
   assert(math.type(checkpoint_every) == "integer" and checkpoint_every >= 1,
      "archive: checkpoint_every must be a positive integer")
   for i = 1, #REQUIRED do
      local key = REQUIRED[i]
      local value = provenance[key]
      if key == "seed" then
         assert(math.type(value) == "integer",
            "archive: provenance.seed must be an integer")
      else
         assert(type(value) == "string" and #value > 0,
            ("archive: provenance.%s must be a non-empty string"):format(key))
      end
   end

   local existing = io.open(path, "r")
   if existing then
      existing:close()
      error(("archive: %s already exists; refusing to overwrite history"):format(path))
   end

   local db = sqlite3.open(path)
   if not db then
      error(("archive: could not open %s"):format(path))
   end
   if db:exec("PRAGMA foreign_keys = ON;") ~= sqlite3.OK then
      fail(db, "enabling foreign keys")
   end
   if db:exec(SCHEMA) ~= sqlite3.OK then
      fail(db, "creating schema")
   end

   -- Rows the archive owns: facts about this file and the code that
   -- wrote it. The interventions log is present and empty from day
   -- one — canon has no interventions, and a reader should learn that
   -- from a row that says so, not from a missing key (card 121 makes
   -- it real). Written in sorted key order, like everything else that
   -- should produce the same bytes on every run.
   local rows = {
      config = provenance.config,
      engine_version = provenance.engine_version,
      git_commit = provenance.git_commit,
      interventions = "[]",
      lua_version = _VERSION,
      schema_version = ("%d"):format(annals.vocabulary.schema_version),
      seed = ("%d"):format(provenance.seed),
      sqlite_version = sqlite3.version(),
   }
   local keys = {}
   for k in pairs(rows) do
      keys[#keys + 1] = k
   end
   table.sort(keys)
   local insert = db:prepare("INSERT INTO provenance (key, value) VALUES (?, ?)")
   if not insert then
      fail(db, "preparing provenance insert")
   end
   for i = 1, #keys do
      insert:bind_values(keys[i], rows[keys[i]])
      if insert:step() ~= sqlite3.DONE then
         fail(db, "writing provenance")
      end
      insert:reset()
   end
   insert:finalize()

   local self = setmetatable({
      db = db,
      annals = annals,
      cursor = 0,
      -- The rolling seal, folded as events are copied. last_tick is
      -- the newest tick seen; a tick is only *complete* — sealable —
      -- once an event from a later tick proves nothing more is coming.
      seal = Seal.new(annals.vocabulary),
      last_tick = 0,
      checkpoint_every = checkpoint_every,
      insert_event = db:prepare([[
         INSERT INTO annals (id, tick, kind, location, magnitude, loudness, payload)
         VALUES (?, ?, ?, ?, ?, ?, ?)
      ]]),
      insert_cause = db:prepare([[
         INSERT INTO causes (event_id, ord, cause_id) VALUES (?, ?, ?)
      ]]),
      insert_checkpoint = db:prepare([[
         INSERT INTO checkpoints (tick, events, hash) VALUES (?, ?, ?)
      ]]),
   }, Archive)
   if not self.insert_event or not self.insert_cause or not self.insert_checkpoint then
      fail(db, "preparing event inserts")
   end
   return self
end

function Archive:write_checkpoint(tick, events)
   self.insert_checkpoint:bind_values(tick, events, self.seal:hex())
   if self.insert_checkpoint:step() ~= sqlite3.DONE then
      error("archive: writing checkpoint at tick " .. tick .. ": " .. self.db:errmsg())
   end
   self.insert_checkpoint:reset()
end

-- Copy everything appended since the last sync, in one transaction:
-- the durability quantum is the caller's to choose (main.lua chooses
-- the tick), and a crash loses at most the events since the last
-- boundary — never a torn half of one.
function Archive:sync()
   assert(self.db, "archive: already closed")
   local newest = self.annals:len()
   if self.cursor >= newest then
      return 0
   end
   if self.db:exec("BEGIN") ~= sqlite3.OK then
      error("archive: BEGIN failed: " .. self.db:errmsg())
   end
   local appended = 0
   while self.cursor < newest do
      self.cursor = self.cursor + 1
      local e = self.annals:get(self.cursor)

      -- An event from a later tick completes every tick before it:
      -- seal any newly completed tick divisible by N, with the hash
      -- as it stood *before* this event — checkpoint T covers exactly
      -- the events with tick <= T. Derivable purely from the log, so
      -- any tool replaying this file computes identical rows.
      if e.tick > self.last_tick then
         local first = ((self.last_tick + self.checkpoint_every - 1)
            // self.checkpoint_every) * self.checkpoint_every
         if first == 0 then
            first = self.checkpoint_every -- "every N ticks" starts at N
         end
         for t = first, e.tick - 1, self.checkpoint_every do
            self:write_checkpoint(t, e.id - 1)
         end
         self.last_tick = e.tick
      end
      self.seal:fold(e)

      local declared = self.annals.vocabulary.kinds[e.kind].payload
      self.insert_event:bind_values(e.id, e.tick, e.kind, e.location,
         e.magnitude, e.loudness, byteform.payload(declared, e.payload))
      if self.insert_event:step() ~= sqlite3.DONE then
         error("archive: writing event " .. e.id .. ": " .. self.db:errmsg())
      end
      self.insert_event:reset()
      for i = 1, #e.causes do
         self.insert_cause:bind_values(e.id, i, e.causes[i])
         if self.insert_cause:step() ~= sqlite3.DONE then
            error("archive: writing causes of event " .. e.id .. ": " .. self.db:errmsg())
         end
         self.insert_cause:reset()
      end
      appended = appended + 1
   end
   if self.db:exec("COMMIT") ~= sqlite3.OK then
      error("archive: COMMIT failed: " .. self.db:errmsg())
   end
   return appended
end

-- Final sync, then let go of the file. Closing completes the last
-- tick (nothing more is coming, by definition), so every file ends
-- with a checkpoint sealing its entire history — the integrity
-- check is recomputing the seal and comparing one row. A periodic
-- row can't already exist at this tick: those are only written when
-- a *later* tick's event arrives, and none did.
-- The archive is spent afterward: a new run means a new database,
-- never an append to an old one (lineage across runs and versions
-- is card 124's problem).
function Archive:close()
   assert(self.db, "archive: already closed")
   self:sync()
   self:write_checkpoint(self.last_tick, self.cursor)
   self.insert_event:finalize()
   self.insert_cause:finalize()
   self.insert_checkpoint:finalize()
   self.db:close()
   self.db = nil
end

return Archive
