-- src/main.lua — a terminal window onto the annals.
--
-- This file observes and prints; nothing here leaks back into the sim
-- (the core is headless). Run from the repo root:
--
--   ./lua src/main.lua --seed 1893 --ticks 10
--   ./lua src/main.lua --seed 1893 --ticks 10 --why 21
--   ./lua src/main.lua --seed 1893 --ticks 10 --db universe.db
--   ./lua src/main.lua --seed 1893 --ticks 10 --db none
--   ./lua src/main.lua --seed 1893 --ticks 1000 --audit
--
-- Same seed, same feed, on every machine. --why N walks event N's
-- cause links back to genesis. Every run is archived into a fresh
-- SQLite universe file: a uniquely named one under out/ (gitignored)
-- by default, the path you name with --db PATH (refusing to
-- overwrite one that exists), or nowhere with --db none.

package.path = "src/?.lua;" .. package.path

local Toyworld = require "worlds.toy"
local Chronicle = require "sonder.chronicle"
local Archive = require "sonder.archive"
local Seal = require "sonder.seal"
local Audit = require "sonder.audit"
local fnv = require "sonder.fnv"

-- Matches sonder-0.1.0-1.rockspec; got real at v0.1 (card 119).
local ENGINE_VERSION = "0.1.0"

local function parse_args(argv)
   local opts = { seed = 1893, ticks = 10 }
   local i = 1
   while i <= #argv do
      local flag, value = argv[i], argv[i + 1]
      if flag == "--seed" or flag == "--ticks" or flag == "--why" then
         local n = math.tointeger(value)
         if not n then
            io.stderr:write(("%s wants an integer, got %q\n"):format(flag, tostring(value)))
            os.exit(1)
         end
         opts[flag:sub(3)] = n
         i = i + 2
      elseif flag == "--db" then
         if type(value) ~= "string" or #value == 0 then
            io.stderr:write("--db wants a path\n")
            os.exit(1)
         end
         opts.db = value
         i = i + 2
      elseif flag == "--audit" then
         opts.audit = true
         i = i + 1
      elseif flag == "--believes" then
         if type(value) ~= "string" or #value == 0 then
            io.stderr:write("--believes wants a faction name\n")
            os.exit(1)
         end
         opts.believes = value
         i = i + 2
      elseif flag == "--as-of" then
         local n = math.tointeger(value)
         if not n then
            io.stderr:write(("--as-of wants an integer tick, got %q\n")
               :format(tostring(value)))
            os.exit(1)
         end
         opts.as_of = n
         i = i + 2
      else
         io.stderr:write(("unknown flag %q\n"):format(tostring(flag)))
         os.exit(1)
      end
   end
   if opts.as_of and not opts.believes then
      io.stderr:write("--as-of only means something with --believes\n")
      os.exit(1)
   end
   return opts
end

-- The host facts provenance demands and the sim must never reach for:
-- shelling out is legal here, on the viewer side of the law-4 line,
-- and only when an archive actually wants them.
local function git_commit()
   local pipe = io.popen("git describe --always --dirty 2>/dev/null")
   if not pipe then
      return "unknown"
   end
   local described = pipe:read("l")
   pipe:close()
   return (described and #described > 0) and described or "unknown"
end

local function exists(path)
   local f = io.open(path, "r")
   if f then
      f:close()
      return true
   end
   return false
end

-- The default archive path: out/universe-<when>-seed<seed>-<engine>.db.
-- The wall clock is banned from the sim, not from the host — and it
-- only ever touches the *name*. The bytes inside carry no timestamp,
-- so two runs of the same triple still produce identical databases,
-- just under different names (chronological ones, so out/ reads as a
-- lab notebook). Seed and engine version are in the name as a
-- courtesy; the file's own provenance table remains the authority.
local function default_db_path(seed)
   os.execute("mkdir -p out")
   local base = ("out/universe-%s-seed%d-%s")
      :format(os.date("%Y%m%d-%H%M%S"), seed, ENGINE_VERSION)
   local path = base .. ".db"
   local n = 1
   while exists(path) do -- same second, same seed: probe, never clobber
      n = n + 1
      path = ("%s-%d.db"):format(base, n)
   end
   return path
end

-- The toy world (card 118): the Vessari and the Khedrun, one grain
-- market, and wars nobody schedules. All the cast and physics live
-- in worlds/toy.lua — this file stays a window.
local opts = parse_args(arg)
local u = Toyworld(opts.seed)

local archive
if opts.db ~= "none" then
   opts.db = opts.db or default_db_path(u.seed)
   local ok, created = pcall(Archive.create, opts.db, u.annals, {
      engine_version = ENGINE_VERSION,
      git_commit = git_commit(),
      seed = u.seed,
      config = "{}", -- honestly: there is no config yet (card 118)
   })
   if not ok then
      io.stderr:write(tostring(created) .. "\n")
      os.exit(1)
   end
   archive = created
   archive:sync() -- genesis, foundings, opening price: tick 0's record
end

-- Fold the whole feed into one number, so two runs compare at a
-- glance instead of line by line.
local fingerprint = fnv.offset
local function fold(line)
   fingerprint = fnv.string(fingerprint, line)
end

local chronicle = Chronicle.new(u.annals)
local function render()
   local lines = chronicle:lines()
   for i = 1, #lines do
      fold(lines[i])
      print(lines[i])
   end
end

print(("universe %d — %d ticks"):format(opts.seed, opts.ticks))
-- With --believes, the live truth feed stays silent: the view is a
-- mind's picture, rendered after the run from its private
-- chronology. The fingerprint hashes whichever view was rendered —
-- run the same seed under --believes vessari, --believes khedrun,
-- and plain, and you get three fingerprints and one seal: three
-- pictures, one universe.
if not opts.believes then
   render() -- genesis is already in the annals
end
for _ = 1, opts.ticks do
   u:step()
   if not opts.believes then
      render()
   end
   if archive then
      archive:sync() -- the durability quantum is the tick
   end
end
if opts.believes then
   local store
   for i = 1, #u.factions do
      if u.factions[i].name == opts.believes then
         store = u.factions[i].store
      end
   end
   if not store then
      io.stderr:write(("--believes %s: no such faction\n")
         :format(opts.believes))
      os.exit(1)
   end
   -- Law 4 pointed the other way: a viewer subscribing to a mind's
   -- picture instead of the universe's. The as-of cut is Q7's "any
   -- actor at any given tick" — beliefs are a pure projection of
   -- deliveries, so every past state of the store is still in it.
   print(("the feed as the %s received it%s"):format(opts.believes,
      opts.as_of and (" — as of tick %d"):format(opts.as_of) or ""))
   local held = store:chronology(opts.as_of)
   for i = 1, #held do
      local believed = Chronicle.believed_line(held[i])
      fold(believed)
      print(believed)
   end
end
-- Two digests, deliberately both. The fingerprint hashes the *view*
-- (rendered feed bytes — reword a chronicle template and it changes).
-- The seal hashes the *state* (canonical event bytes — it changes
-- only if history itself does). "Same feed?" and "same universe?"
-- are different questions.
print(("fingerprint %016x"):format(fingerprint))
print(("seal %s"):format(Seal.of(u.annals):hex()))

if archive then
   archive:close()
   print(("annals archived to %s (%d events)"):format(opts.db, u.annals:len()))
end

-- The double-entry audit (card 120), on request: refold the whole
-- history into books and check the two conservation laws. A viewer
-- like everything else here — and a second copy of chronicle.lua's
-- comma(), which the rule of three says may stay a coincidence.
if opts.audit then
   local function comma(n)
      local s = tostring(n)
      local grouped = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
      return grouped
   end
   local report = Audit.of(u.annals,
      { distance = u.distance, channel_speed = u.channel_speed })
   print(("audit: %s¢ founded, %s¢ held; %s sacks founded, +%s "
      .. "harvested, −%s eaten, −%s burned, %s held")
      :format(comma(report.founded.cents), comma(report.held.cents),
         comma(report.founded.grain), comma(report.totals.harvested),
         comma(report.totals.eaten), comma(report.totals.burned),
         comma(report.held.grain)))
   for i = 1, #report.violations do
      print("audit violation: " .. report.violations[i])
   end
   if #report.violations == 0 then
      print("audit: the books balance")
   end
   if #report.mismatches > 0 then
      print(("audit: %d tally mismatches; %d explained by news still "
         .. "on the road, %d unexplained")
         :format(#report.mismatches,
            #report.mismatches - #report.unexplained,
            #report.unexplained))
   end
   for i = 1, #report.unexplained do
      local m = report.unexplained[i]
      print(("audit UNEXPLAINED: event %d, %s %s: reported %d, audited "
         .. "%d, in flight %d — no road accounts for this")
         :format(m.id, m.name, m.field, m.reported, m.audited,
            m.in_flight))
   end
   if #report.violations > 0 or #report.unexplained > 0 then
      os.exit(1)
   end
end

-- The annals records not just what happened but why. Walk the cause
-- links from event N down to the event that needs no cause.
if opts.why then
   local function trace(id, depth)
      local e = u.annals:get(id)
      if not e then
         io.stderr:write(("--why %d: no such event\n"):format(id))
         os.exit(1)
      end
      print(("%s%s"):format(("  "):rep(depth), Chronicle.line(e)))
      for i = 1, #e.causes do
         trace(e.causes[i], depth + 1)
      end
   end
   print(("\nwhy event %d:"):format(opts.why))
   trace(opts.why, 0)
end
