-- src/main.lua — a terminal window onto the annals.
--
-- This file observes and prints; nothing here leaks back into the sim
-- (the core is headless). Run from the repo root:
--
--   ./lua src/main.lua --seed 1893 --ticks 10
--   ./lua src/main.lua --seed 1893 --ticks 10 --why 21
--   ./lua src/main.lua --seed 1893 --ticks 10 --db universe.db
--
-- Same seed, same feed, on every machine. --why N walks event N's
-- cause links back to genesis. --db PATH archives the run into a
-- fresh SQLite universe file (and refuses to overwrite one).

package.path = "src/?.lua;" .. package.path

local Universe = require "sonder.universe"
local Chronicle = require "sonder.chronicle"
local Archive = require "sonder.archive"

-- Matches sonder-dev-1.rockspec; versions get real at v0.1 (card 119).
local ENGINE_VERSION = "dev-1"

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
      else
         io.stderr:write(("unknown flag %q\n"):format(tostring(flag)))
         os.exit(1)
      end
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

local opts = parse_args(arg)
local u = Universe.new(opts.seed)

local archive
if opts.db then
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
   archive:sync() -- genesis, at the tick-0 boundary
end

-- Placeholder systems, standing where the market and the war machine
-- will stand (card 118). Instead of muttering into locals they now
-- emit, and each event cites the previous event in its own line of
-- causation, so every chain walks back to genesis: markets don't just
-- move, wars don't just start, asteroids don't just exist.
local last_market, last_war = 1, 1
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
u:add_system("war", function(universe, stream)
   local muster = stream:int(0, 9)
   last_war = universe:emit{
      kind = "war.muster",
      location = "the-void",
      magnitude = muster,
      visibility = "regional", -- you'd have to be nearby to count levies
      payload = { muster = muster },
      causes = { last_war },
   }
end)

-- Fold the whole feed into one number, so two runs compare at a
-- glance instead of line by line.
local fingerprint = 0xcbf29ce484222325
local function fold(line)
   for i = 1, #line do
      fingerprint = (fingerprint ~ line:byte(i)) * 0x100000001b3
   end
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
render() -- genesis is already in the annals
for _ = 1, opts.ticks do
   u:step()
   render()
   if archive then
      archive:sync() -- the durability quantum is the tick
   end
end
print(("fingerprint %016x"):format(fingerprint))

if archive then
   archive:close()
   print(("annals archived to %s (%d events)"):format(opts.db, u.annals:len()))
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
