# Notebook — 116-state-hash

Card 116: *Rolling state hash + golden-master replay test.*
Checkpoint a rolling state hash every N ticks. First busted test:
replay the same seed for N years and assert the same hash — the
regression net every later mechanic lands inside. Also the substrate
for first-divergence binary search (synopsis, forensic mode) and
integrity checks. Done when: the golden-master test passes twice in
a row and fails when a draw is deliberately perturbed.

## Session 1 (2026-07-26)

### What's already decided (inherited, not ours to relitigate)

- Day-one requirement, verbatim: rolling state hash checkpointed
  every N ticks (serves golden-master tests, first-divergence binary
  search, and integrity checks).
- Law 2: nothing "happens" except an append to the annals; all state
  views are projections of it. Whatever "state hash" means, it must
  answer to that.
- Post 0004 made two promises this card keeps: "card 116 is going to
  hash this file's contents, and two universes that differ only in
  key order must not hash apart" (the canonical-bytes argument), and
  "the history book gets a tamper seal."
- Scope fences: **123** owns the synopsis tool (116 lays checkpoint
  substrate, builds no binary search), **124** owns lineage (116
  doesn't hash across version boundaries), **118** owns real systems
  (the golden master seals placeholder drifts, and will be re-cut
  when the vocabulary churns — pre-0.1 that's cheap and expected).

### The design space (drafted; decisions marked, all awaiting Mike's
### interrogation)

**1. What is "state," exactly?** The sim's entire state today: the
tick counter, the RNG stream internals, and the annals. Law 2 says
the annals is the truth and everything else is derivable — so
**the state hash is a hash of the event log**, folded event by
event. A universe where an RNG stream wobbled but no event changed
is observationally identical; the first divergence that *matters* is
by definition an event divergence, and hashing the log catches
exactly that. (RNG-state divergence with no event consequence can't
exist for long anyway: a stream nobody draws from doesn't wobble,
and a draw that changes shows up in the next emitted payload.)

**2. Core or projection?** The universe could keep a running hash in
`emit` — but then the core carries a feature no law demands, and
every consumer must trust it. Instead the seal is a **projection**,
like the chronicle and the archive before it: a pure function from a
log prefix to 8 bytes. Anyone — the golden test, the archive, a
suspicious reader with someone else's universe file — recomputes it
from the events alone and gets the same answer on any machine.
The universe module ships this card unchanged.

**3. What bytes get hashed?** One canonical byte representation per
event, used by *everything*: new module `src/sonder/canon.lua`,
which renders an event as canonical JSON — envelope fields in fixed
order, payload fields in declaration order, our own total escaping;
the encoder card 115 built for the archive's payload column, promoted
to a shared home and extended to the whole event. The archive keeps
writing byte-identical payload columns (same function, new address);
the seal folds the full event line. One form, two consumers, zero
chances for them to drift apart.

**4. Which hash?** FNV-1a, 64-bit — the same function main.lua's
feed fingerprint already uses, now over state bytes instead of view
bytes. Pure Lua 5.4 integer arithmetic (wrapping overflow is exactly
what law 1's doctor checks certify), eight lines, zero dependencies.
It is *not cryptographic* and doesn't need to be: the seal defends
against divergence and accident, not adversaries — nobody is mining
collisions against their own save file. If apocrypha sharing ever
needs tamper-*proofing* rather than tamper-*evidence*, that's a
future card swapping the function, not this one.

**5. Where do checkpoints live?** In the universe file: a
`checkpoints` table (tick, events, hash) with the same RAISE(ABORT)
append-only triggers as everything else. The elegant part: the
archive is already walking every event at sync time, so it folds the
seal as it copies and drops a checkpoint row each time a tick
boundary crosses a multiple of N — **checkpoints are derivable purely
from the log**, no caller cooperation, which means any future tool
replaying an old file computes identical rows. `close()` writes a
final checkpoint at the last completed tick regardless of N, so
every file ends with a seal of its whole history (the integrity
check: recompute, compare one row).

**6. What is N?** `Archive.create` grows an opts table:
`checkpoint_every`, default 100. Placeholder scale for placeholder
systems; card 118's toy world can retune it when ticks mean
something.

**7. The golden master.** `tests/seal_spec.lua`: seed 1893, 500
ticks, assert the exact 16-hex-digit seal, hardcoded. Determinism
("passes twice in a row") is a second universe, same seed, same
assert. The perturbation half of the done-when: a *gremlin* — a
third universe, same seed, same systems, plus one system that makes
a single extra draw from the market's own named stream at one tick —
and the spec asserts its seal differs. One stolen random number,
different universe, different seal: post 0001's named-streams
argument, now executable.

**8. Shared toy universe for specs.** archive_spec grew its own toy
universe in 115; seal_spec needs one too. Third copy means drift, so:
`tests/support/toy.lua` — market + war systems mirroring main.lua —
and `.busted` gains `tests/?.lua` on lpath so specs can require it.
archive_spec refactors onto it (its counts change: the toy now
emits two events per tick).

**9. main.lua prints the seal.** The feed fingerprint stays (it
hashes the *view* — rendered lines; it would change if a chronicle
template were reworded). The seal hashes the *state* and wouldn't.
Printing both, labeled, makes the difference a thing you can see:
`fingerprint` answers "same feed?", `seal` answers "same universe?"
— post material, the view/state distinction in two lines of output.

### What we built

- `src/sonder/canon.lua` — one canonical byte form per event, the
  card-115 payload encoder promoted to a shared home and extended to
  the whole envelope. Output is valid JSON as a courtesy; the
  contract is the bytes. Strict about unknown kinds — a seal in the
  wrong dialect would be quietly meaningless, and quiet is the one
  thing a divergence detector must never be.
- `src/sonder/seal.lua` — the rolling hash as a projection: FNV-1a
  64 folded over each event's canonical line. `Seal.new(vocab)` +
  `:fold(e)` for followers, `Seal.of(annals)` for whole-log, `:hex()`
  for the sixteen digits everyone compares. The core shipped
  unchanged, as designed — universe.lua untouched this card.
- `src/sonder/archive.lua` — a `checkpoints` table (tick, events,
  hash) with the same append-only triggers; the archive folds the
  seal as it copies and writes a row whenever a later event completes
  a tick divisible by N (`opts.checkpoint_every`, default 100).
  `close()` completes the last tick by definition, so every file ends
  sealed — integrity check is recompute-and-compare-one-row. The
  tick-completion rule matters: a tick is only sealable once an event
  from a *later* tick proves nothing more is coming.
- `src/main.lua` — prints both digests, labeled: `fingerprint`
  (view bytes — rewording a chronicle template changes it) and `seal`
  (state bytes — only history itself changes it).
- `tests/support/toy.lua` + `.busted` lpath — the shared toy
  universe (market + war, mirroring main.lua); archive_spec
  refactored onto it, third copy averted.
- `tests/seal_spec.lua` — the golden master: seed 1893 × 500 ticks
  (1001 events) seals to `27e3e0a8080e04f8`, hardcoded; a second
  fresh universe must match it (passes twice in a row); the gremlin —
  one extra draw stolen from the market's own stream at tick 250 —
  must not (fails when perturbed); and the two universes agree
  through tick 250, diverge at 251 (divergence has a first moment —
  the property card 123's binary search leans on). Plus: projection
  self-agreement, incremental-vs-all-at-once, order sensitivity,
  unknown-kind refusal.
- archive_spec additions: checkpoint rows recomputed independently
  off the annals and matched; eager (per-tick) and lazy (once at
  close) syncing produce identical files; genesis-only files still
  end sealed; checkpoint triggers.
- Suite: 79 green (67 + 12), twice in a row. CLI: the 500-tick run's
  printed seal, its golden constant, and the file's final checkpoint
  row all read `27e3e0a8080e04f8`.

### What broke / what surprised us (post material)

- **Nothing broke.** First card with zero red-first specs — after
  two cards of test-side false alarms, the streak breaking is itself
  worth a line in the post.
- **Tick 500's checkpoint came from close(), not the periodic rule.**
  500 % 100 == 0, but the periodic writer only fires when a tick-501
  event arrives, and none ever did. The final-seal-at-close rule
  caught it, and the two writers can never collide (a periodic row
  needs a later event; close means there are none). Worth spelling
  out in the post — it's the tick-completion insight wearing its
  edge case.
- **The tick-completion rule is a watermark.** "A tick is complete
  when an event from a later tick arrives" is exactly how stream
  processors decide event-time windows can close. We got to the
  idea by asking when a checkpoint is safe to write; the CS section
  gets to name it properly.
- **Seal ≠ fingerprint made visible:** 500 ticks, fingerprint
  `70483ffb282aa288`, seal `27e3e0a8080e04f8` — different questions,
  different answers, two lines apart in the same output.

### Round 2 — Mike's review: the three FNVs

Mike spotted FNV-1a 64-bit referenced in multiple places and asked
whether it was duplicated or shared. It was duplicated — this card
had just added the third copy (rng.lua's stream_hash from 113,
main.lua's fingerprint from 114, seal.lua now), each the same two
magic numbers in a slightly different shape. Rule of three: two
copies was coincidence, three is a pattern.

- **Decision (Mike): full extraction.** `src/sonder/fnv.lua` —
  `fnv.offset` plus step functions `fnv.byte(h, b)` and
  `fnv.string(h, s)`; rng, seal, and main.lua all fold through it.
- **Decision (Mike): `tests/golden/reference.c` is not touched.**
  It is the oracle our implementation is checked against, and an
  oracle that shares code with its subject vouches for nothing. The
  refactor was proven safe by exactly that arrangement: the RNG's
  golden-vector specs re-ran green against the C oracle with
  stream_hash rebuilt on the shared module — one wrong bit and they
  would have failed loudly. Fingerprint and seal for seed 1893 × 500
  ticks came out unchanged (`70483ffb282aa288`, `27e3e0a8080e04f8`).

## Session 2 (2026-07-26, same day) — the post

Implementation committed (b105237) on Mike's word after the fnv
review. Drafted `docs/posts/0005-the-tamper-seal.md`. Shape: the
500-tick excerpt (seal printed twice — the claim is the *second*
number — plus the checkpoints table) → design (state hash = log hash
via law 2; the seal as a third projection; canon.lua and
one-event-one-byte-form; FNV-1a as tamper-evidence not
tamper-proofing; the watermark rule for when a tick is sealable;
close() sealing every file; the gremlin and the
divergence-has-a-first-moment property for card 123) → CS
(golden-master testing and why checkpoint trails fix its
opaque-failure weakness; avalanche and the birthday bound; watermarks
in stream processing, with card 122 as the future payoff) →
wrong-ledger (the three FNVs and the untouched oracle; tick 500's
checkpoint arriving via close, luck not skill; the
nothing-broke-and-we're-suspicious entry, prediction published so it
can embarrass us).

Docs sweep: README status (post 0005 added, state hash out of "still
ahead") and the seal-trail query added to Running; CLAUDE.md status
(116 done, next up starts at 117).

### Proving "done"

- Golden master: seed 1893 × 500 ticks → exact hardcoded seal;
  second universe, same seed → same seal (twice in a row); gremlin
  universe (one extra draw) → different seal.
- Seal is a projection: computing it twice over the same annals,
  and incrementally vs all-at-once, agrees.
- Archive: checkpoints land at every multiple of N with the hash of
  the log prefix through that tick (verified against an
  independently computed Seal); final checkpoint at close; triggers
  block UPDATE/DELETE; same seed → identical checkpoints tables.
- Canonical bytes: archive payload column unchanged from 115
  (byte-identical), canon's event line stable against payload key
  order by construction.
