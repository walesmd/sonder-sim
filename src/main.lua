-- src/main.lua — a terminal window onto the heartbeat.
--
-- This file observes and prints; nothing here leaks back into the sim
-- (the core is headless). Run from the repo root:
--
--   ./lua src/main.lua --seed 1893 --ticks 10
--
-- Same seed, same output, on every machine — that is the whole card.

package.path = "src/?.lua;" .. package.path

local Universe = require "sonder.universe"

local function parse_args(argv)
   local opts = { seed = 1893, ticks = 10 }
   local i = 1
   while i <= #argv do
      local flag, value = argv[i], argv[i + 1]
      if flag == "--seed" or flag == "--ticks" then
         local n = math.tointeger(value)
         if not n then
            io.stderr:write(("%s wants an integer, got %q\n"):format(flag, tostring(value)))
            os.exit(1)
         end
         opts[flag:sub(3)] = n
         i = i + 2
      else
         io.stderr:write(("unknown flag %q\n"):format(tostring(flag)))
         os.exit(1)
      end
   end
   return opts
end

local opts = parse_args(arg)
local u = Universe.new(opts.seed)

-- Two placeholder subsystems, standing where the market and the war
-- machine will stand. All they can do yet is draw — visibly.
local last = {}
u:add_system("market", function(_, stream)
   last.market = stream:int(-3, 3)
end)
u:add_system("war", function(_, stream)
   last.war = stream:int(0, 9)
end)

-- Fold every observed draw into one number, so two runs can be
-- compared at a glance instead of line by line.
local fingerprint = 0xcbf29ce484222325
local function fold(n)
   fingerprint = (fingerprint ~ n) * 0x100000001b3
end

print(("universe %d — %d ticks"):format(opts.seed, opts.ticks))
for _ = 1, opts.ticks do
   u:step()
   fold(last.market)
   fold(last.war)
   print(("tick %4d   market drift %+d   war muster %d")
      :format(u.tick, last.market, last.war))
end
print(("fingerprint %016x"):format(fingerprint))
