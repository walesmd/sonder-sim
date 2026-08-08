rockspec_format = "3.0"
package = "sonder"
version = "0.2.4-1"

source = {
   url = "git+https://github.com/walesmd/sonder-sim.git"
}

description = {
   summary = "A universe simulator you read.",
   homepage = "https://github.com/walesmd/sonder-sim",
   license = "MIT"
}

-- Compatibility claims live here; the exact versions we actually run are
-- locked in rocks.lock (committed). Regenerate the lock by deleting it
-- and re-running tools/setup.sh.
--
-- lsqlite3 is == rather than ~> because 0.9.6 exists only as a rockspec
-- pointing at lua.sqlite.org, which serves 503s; 0.9.5 is the newest
-- version with a self-contained src rock on luarocks.org. Bump when that
-- changes.
dependencies = {
   "lua ~> 5.4",
   "lsqlite3 == 0.9.5",
   "busted ~> 2.2"
}

build = {
   type = "builtin",
   modules = {}
}
