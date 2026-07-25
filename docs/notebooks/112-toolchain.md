# Notebook — 112-toolchain

Card 112: *Pin the toolchain (Lua 5.4, LuaRocks, busted, lsqlite3).*
Done when a fresh clone on a second machine runs the same commands to the
same result.

## Session 1 (2026-07-25)

### What the machine already had

- Lua 5.4.8 via Homebrew's `lua@5.4` formula, linked as both `lua` and
  `lua5.4` in `/opt/homebrew/bin`.
- System sqlite3 3.51.0 at `/usr/bin/sqlite3`; Homebrew sqlite 3.53.3
  installed but keg-only (not on PATH). The CLT SDK ships `sqlite3.h`, so
  either can back lsqlite3.
- No LuaRocks. No busted.

### The trap that decided the enforcement question

The obvious move — `brew install luarocks` — is a trap: the formula
depends on Homebrew's `lua`, which is now **5.5.0**. Installing it would
put Lua 5.5 on the machine next to our pinned 5.4, fight over the `lua`
symlink, and leave LuaRocks defaulting to the wrong interpreter. ADR 0001
pinned 5.4 precisely because the ecosystem hasn't settled on 5.5; letting
the package manager smuggle 5.5 in through a dependency edge would be
losing that decision by accident.

So the pin is enforced by *not* trusting any system-global LuaRocks:

1. `tools/setup.sh` downloads a **pinned LuaRocks release** (version and
   SHA-256 hardcoded in the script), builds it against `lua@5.4`, and
   installs it into `.toolchain/` inside the repo (gitignored).
2. `luarocks init` makes the rocks tree **project-scoped**: dependencies
   land in `lua_modules/` (gitignored), and `./lua` / `./luarocks`
   wrapper scripts in the repo root always run 5.4 with that tree on the
   path. No global state, no version drift between projects.
3. Dependencies are declared in the rockspec and locked exactly in
   `luarocks.lock` (committed), via LuaRocks' `--pin` flag. *(That was
   the plan as written before running anything — `--pin` turned out to be
   broken; see "What broke" below for the lock we actually shipped.)*
4. `tools/doctor.lua` verifies the result — interpreter version, the
   integer subtype (the load-bearing reason for 5.4), lsqlite3, busted —
   and fails loudly on any mismatch.

Recorded as ADR 0002.

### What broke when we actually ran it

Two things, both worth keeping:

- **LuaRocks' `--pin` lockfile is broken for VM-provided Lua.** The plan
  was `luarocks build --only-deps --pin` → committed `luarocks.lock`,
  loose ranges in the rockspec, exact pins in the lock, package.json
  style. In practice `--pin` writes `lua 5.4-1` itself into the lock,
  then tries to satisfy the interpreter as an installable rock and dies:
  "Rock lua 5.4-1 is already provided by VM" … "Could not satisfy
  dependency lua 5.4-1". It fails even when every dependency is already
  installed. Reproduced on LuaRocks 3.13.0. So the lock is ours:
  `rocks.lock`, plain `name version` lines written by `tools/lock.sh`
  from `luarocks list --porcelain`, installed back with
  `--deps-mode=none` (resolver off — a locked machine never resolves
  anything). setup.sh diffs the installed tree against the lock afterward
  and fails on any mismatch, extra rocks included.
- **lsqlite3's upstream host was down.** Version 0.9.6 exists on
  luarocks.org only as a rockspec that fetches source from
  lua.sqlite.org — which served us a 503. 0.9.5 is the newest version
  with a self-contained src rock hosted on luarocks.org itself, so the
  rockspec pins `lsqlite3 == 0.9.5` (with a comment saying why). A
  supply-chain lesson on day one: a version you can't fetch is not a
  version you have.

### What the first real run resolved

busted `~> 2.2` resolved to **2.3.0-1**, bringing ten rocks total
(penlight, luassert, say, mediator_lua, lua_cliargs, lua-term,
luafilesystem, luasystem, dkjson). All eleven (with lsqlite3) are in
`rocks.lock`. Verified end to end: wiped `.toolchain/`, `lua_modules/`,
`.luarocks/`, and the wrappers, re-ran `./tools/setup.sh` — pinned
LuaRocks rebuilt (SHA-256 checked), locked installs, drift check clean,
doctor all green (Lua 5.4, integer subtype, 64-bit, wrapping overflow,
lsqlite3 against SQLite 3.53.3, busted 2.3.0). Second run is idempotent:
skips everything, doctor still green.

### Post material

- The brew-lua-5.5 trap: how a package manager's dependency edge can
  silently overturn an ADR.
- The `--pin` failure as the honest centerpiece: we planned to use the
  stock lockfile, it broke, we wrote a 30-line one and now understand
  exactly what a lockfile *is* (a claim about the closure of the
  dependency graph, checked by diff).
- Why doctor checks *properties* (overflow wraps) rather than *versions* —
  versions are proxies; the property is what determinism actually needs.

### Decisions and alternatives

- **Repo-local LuaRocks built from source** over `brew install luarocks`
  (drags in Lua 5.5, see above), over hererocks (a Python tool to build
  Lua+LuaRocks per-project — right shape, but it also *builds Lua*, and
  we'd rather have exactly one Lua on the machine and a smaller tool
  surface), and over asking contributors to hand-configure a global
  LuaRocks for 5.4 (works until the first machine where it doesn't).
- **Loose ranges in the rockspec, exact pins in the lockfile.** The
  rockspec says what Sonder is compatible with (`lua ~> 5.4`); the
  committed `luarocks.lock` says what we actually run, down to the exact
  rock versions. Same split as package.json vs package-lock.json — the
  rockspec is the claim, the lockfile is the fact.
- **`dev-1` rockspec version.** LuaRocks' convention for "the rockspec
  that lives in the source tree and tracks HEAD"; release rockspecs get
  real versions if we ever publish rocks (we have no plans to).
- **busted and lsqlite3 both as plain dependencies** rather than
  splitting test-only deps out: LuaRocks has no dev-dependency concept
  worth leaning on in a project-scoped tree, and everyone who builds this
  project also runs its tests. Revisit if a real runtime/dev split ever
  matters.
- **sqlite comes from Homebrew's keg** (`/opt/homebrew/opt/sqlite`),
  passed to the lsqlite3 build explicitly by setup.sh, rather than the
  OS's libsqlite3. Explicit and versioned beats whatever the OS shipped;
  the provenance table will record the version either way (ADR 0001).

### Questions Mike asked

- **"What is this VM-provided Lua? We're just running Lua from Homebrew,
  not in a VM."** — "VM" here is language-runtime jargon, not
  virtualization: the Lua interpreter *is* a virtual machine, in the same
  sense as the JVM — a program that executes Lua bytecode (Lua's is a
  small register-based one inside the `lua` binary). So "provided by VM"
  means "provided by the Homebrew-installed interpreter currently running
  LuaRocks." The deeper point: nearly every rock depends on `lua` itself
  (e.g. lsqlite3 wants `lua >= 5.1, < 5.5`), but `lua` is not an
  installable rock — it's the thing running the show. LuaRocks squares
  that circle with `rocks_provided`: the interpreter registers itself as
  a virtual rock (`lua 5.4-1`) that satisfies constraints without living
  in the rocks tree. The `--pin` bug is that pinning writes this virtual
  rock into the lock like a real one, and the pin-enforcement path then
  looks for it in the rocks tree — where it isn't and can never be. The
  contradictory error ("already provided by VM" / "could not satisfy")
  is two code paths disagreeing about what `lua` is. Our fix sidesteps
  the question entirely: `rocks.lock` holds only installable rocks, and
  `--deps-mode=none` means nobody ever asks the resolver about `lua`
  again.
