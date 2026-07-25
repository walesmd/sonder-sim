# ADR 0001 — Stay on Lua 5.4, deliberately not 5.5

- **Date:** 2026-07-25
- **Status:** accepted

## Context

Lua 5.5.0 is out (5.5.1 already at rc1). Its changes are real but modest
for us: `global` declarations, read-only for-loop control variables,
round-trippable float printing, ~60% more compact large arrays,
incremental major GC, `table.create`. Nothing in it changes integer
semantics, arithmetic, or anything else our determinism law leans on.

Meanwhile the ecosystem lags the release: lsqlite3 0.9.7 documents itself
as designed for 5.4 (tested with 5.5 in mind), many rockspecs still cap
`lua < 5.5`, and busted's transitive dependencies are unaudited under 5.5.
5.4 has had six years of patch releases; 5.5 is months old and still
churning. Day one should be boring.

## Decision

Pin Lua 5.4 for v0.1. Two supporting commitments that make the interpreter
version *not matter* to outcomes:

- Named RNG streams are our own PRNG in pure integer Lua — never
  `math.random` — so draws don't depend on interpreter internals.
- The provenance table records the Lua, lsqlite3, and SQLite versions for
  every universe, so any segment of a lineage stays reconstructable.

## Consequences

- We forgo 5.5's `global` declarations; accidental-global protection comes
  from a strict-mode module instead (a teachable Lua classic).
- Upgrading to 5.5 later is a deliberate lineage event: run canon to a
  snapshot, upgrade, continue. If the four laws hold, the universe should
  not diverge **at all** — the upgrade run doubles as an audit of the laws.
  Either outcome is a post: zero divergence proves the laws; any divergence
  gets hunted with the synopsis's forensic mode and named in public.
- Revisit when the rockspec caps lift and 5.5.x settles down.
