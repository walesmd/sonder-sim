# Verification — the seals, and how to check one

*What determinism promises and how to catch it lying (card 166).*

A `(code version, seed, intervention log)` triple defines exactly
one universe, bit for bit, on every machine. Three instruments
watch that promise:

- **The seal** — FNV-1a 64 folded over every event's canonical
  bytes. Two universes with the same seal lived the same history.
  Answers *"same universe?"*
- **The fingerprint** — the hash of a rendered feed. Rewording a
  chronicle template changes the fingerprint and not the seal.
  Answers *"same feed?"*
- **The audit** — double-entry books refolded from the log alone.
  Answers *"do the books balance?"*

## The golden seals

One per world, pinned in that world's spec beside its re-cut
ledger — the comment block recording every constant this project
has ever moved, and why. Constants are re-cut deliberately,
loudly, never casually; since card 150, a seal re-cut also bumps
the engine's minor version.

| world | seed × ticks | seal | ledger lives in |
|---|---|---|---|
| space | 1893 × 500 | `3475639d8f49678b` | `tests/seal_spec.lua` |
| continent | 7 × 200 | `c6dc5ef5b428aa85` (re-cut at card 151 — the roads can lose a letter) | `tests/continent_spec.lua` |
| office | 7 × 200 | `10fc9a5781a44136` | `tests/office_spec.lua` |

## Verifying a universe file

Every well-closed universe file ends with a checkpoint sealing its
entire history. To verify one:

1. Read the last checkpoint: `SELECT tick, events, hash FROM
   checkpoints ORDER BY tick DESC LIMIT 1`.
2. Recompute: replay the same `(engine version, seed)` from
   provenance for that many ticks — `./lua src/main.lua --world W
   --seed S --ticks T --db none` prints the seal — or fold the
   archived rows directly (the payload column stores the exact
   bytes the seal hashes).
3. Compare the sixteen hex digits. Equal means this file's history
   is the history that seed produces; different means the file was
   edited, the engine changed (check `engine_version` against the
   re-cut ledgers), or something is genuinely wrong — and the
   checkpoint trail will binary-search you to the first divergent
   tick.

The spec suite runs the same discipline continuously:
`./lua_modules/bin/busted` replays all three worlds against their
pinned seals on every run.
