# ADR 0002 — Enforce the toolchain pin with a repo-local LuaRocks and our own lockfile

- **Date:** 2026-07-25
- **Status:** accepted

## Context

ADR 0001 pins Lua 5.4. Card 112 asks that the whole toolchain — LuaRocks,
lsqlite3, busted — be pinned so a fresh clone on a second machine runs the
same commands to the same result. Two facts on the ground decided the
shape:

1. **The package manager will smuggle in Lua 5.5.** Homebrew's `luarocks`
   formula depends on the `lua` formula, which is now 5.5.0. Installing it
   the obvious way puts a second Lua on the machine, fights `lua@5.4` for
   the `lua` symlink, and leaves LuaRocks defaulting to the wrong
   interpreter — ADR 0001 lost by accident, through a dependency edge.
2. **LuaRocks' own lockfile is broken for us.** `--pin` writes the
   interpreter itself (`lua 5.4-1`) into the lock, then tries to satisfy
   it as an installable rock and fails — even when every dependency is
   already present ("Rock lua 5.4-1 is already provided by VM" … "Could
   not satisfy dependency lua 5.4-1"). Reproduced with LuaRocks 3.13.0.

## Decision

Nothing global; everything pinned inside the repo, rebuilt by one script.

- `tools/setup.sh` downloads a **pinned LuaRocks release** (version and
  SHA-256 hardcoded), builds it against `lua@5.4`, and installs it into
  `.toolchain/` (gitignored). It refuses to run against any Lua that
  isn't 5.4.
- `luarocks init` makes the rocks tree **project-scoped**: rocks live in
  `lua_modules/`, and the `./lua` / `./luarocks` wrappers always run 5.4
  with that tree on the path.
- The lockfile is **ours**: `rocks.lock` (committed) lists every rock —
  transitive dependencies included — as exact `name version` lines,
  written by `tools/lock.sh` from `luarocks list --porcelain`. setup.sh
  installs from it with `--deps-mode=none`, so the resolver never runs on
  a locked machine and version drift is impossible. After installing,
  setup.sh diffs the tree against the lock and fails loudly on any
  mismatch.
- `tools/doctor.lua` verifies the properties determinism leans on, not
  just that programs exist: `_VERSION`, the integer subtype, 64-bit
  width, wrapping overflow, lsqlite3 loading and round-tripping, busted
  resolvable.

Regenerating the lock is deliberate: delete `rocks.lock`, run setup.sh
(fresh resolve from the rockspec), review the diff, commit.

## Consequences

- A fresh clone needs exactly one command, `./tools/setup.sh`, and it
  never modifies anything outside the repo.
- The SQLite *library* version still floats with the machine (Homebrew's
  keg); the provenance table records it per universe, per ADR 0001. The
  rocks do not float.
- lsqlite3 is pinned `== 0.9.5`: 0.9.6 exists on luarocks.org only as a
  rockspec pointing at lua.sqlite.org, which was serving 503s the day we
  tried; 0.9.5 is the newest self-contained src rock. Bump when upstream
  hosting improves.
- We maintain ~30 lines of lockfile tooling. If a future LuaRocks fixes
  `--pin` for VM-provided Lua, adopting it is a one-card cleanup.
- CI (when it exists) runs the same setup.sh — no separate install path
  to keep honest.
