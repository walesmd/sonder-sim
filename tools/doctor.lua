-- tools/doctor.lua — verify the pinned toolchain, loudly.
-- Run as: ./lua tools/doctor.lua   (tools/setup.sh runs it for you)
--
-- Checks the properties the four laws lean on, not just that programs
-- exist: Lua 5.4's integer subtype must behave exactly as determinism
-- assumes on every machine that runs a universe.

local failures = 0

local function check(label, ok, detail)
   local mark = ok and "ok" or "FAIL"
   io.write(("  %-44s %s%s\n"):format(label, mark, detail and ("  (" .. detail .. ")") or ""))
   if not ok then failures = failures + 1 end
end

check("interpreter is Lua 5.4", _VERSION == "Lua 5.4", _VERSION)
check("integers are a real subtype", math.type(1) == "integer")
check("integers are 64-bit", math.maxinteger == 0x7fffffffffffffff)
check("integer overflow wraps, never rounds", math.maxinteger + 1 == math.mininteger)
check("floor division of integers stays integer", math.type(7 // 2) == "integer")

local ok, sqlite = pcall(require, "lsqlite3")
check("lsqlite3 loads", ok, ok and ("SQLite " .. sqlite.version()) or tostring(sqlite))
if ok then
   local db = sqlite.open_memory()
   db:exec("CREATE TABLE t (n INTEGER); INSERT INTO t VALUES (42);")
   local n
   for row in db:urows("SELECT n FROM t") do n = row end
   db:close()
   check("sqlite in-memory round trip", n == 42)
end

check("busted is on package.path",
   package.searchpath("busted.runner", package.path) ~= nil)

if failures > 0 then
   io.write(("doctor: %d check(s) failed\n"):format(failures))
   os.exit(1)
end
io.write("doctor: all checks passed\n")
