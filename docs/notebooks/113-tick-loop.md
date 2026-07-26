# Notebook — 113-tick-loop

Card 113: *Deterministic tick loop + named RNG streams.*
Done when: same seed → bit-identical draw sequence across runs and
machines. Ships with post 0001 *Ticks & Determinism*, tag `post/0001`.

## Session 1 (2026-07-25)

### What's already decided (inherited, not ours to relitigate)

- ADR 0001: named streams are **our own PRNG in pure integer Lua** —
  never `math.random` — so draws don't depend on interpreter internals.
  This card is where that commitment becomes code.
- The four laws give the constraints: no wall-clock, integer outcomes,
  no `pairs()` where order matters, one stream per subsystem so a new
  feature never shifts another's draws.

### The design space (drafted for discussion, nothing decided yet)

**1. Which PRNG?** Three serious candidates, all implementable in ~30
lines of pure Lua 5.4 integer ops (which wrap on overflow — exactly what
these algorithms assume of uint64):

- **xoshiro256\*\*** — what Lua 5.4's own `math.random` uses under the
  hood. 256-bit state (four integers), excellent statistical quality,
  the current general-purpose recommendation from its authors. Nice
  teachable tie-in: we'd be reimplementing the exact algorithm the
  interpreter already carries, and can test ours against a known-good
  reference.
- **PCG32** — 64-bit LCG state + output permutation. Elegant paper,
  great pedagogy (the "bad generator + good hash = good generator"
  idea), but 32-bit output means two calls per 64-bit draw, and the
  reference implementation leans on 128-bit multiply tricks we'd have
  to adapt.
- **splitmix64** — a single 64-bit counter hashed through three
  xor-shift-multiply rounds. ~10 lines. Passes BigCrush. It's what
  xoshiro's authors recommend *for seeding* xoshiro. Weakest
  equidistribution guarantees of the three, but far beyond anything a
  civilization sim will notice.

Either way, **splitmix64 shows up regardless** as the seeder: it's the
standard way to expand one 64-bit seed into a larger state.

**2. Deriving a stream from a name.** `(universe seed, "market")` →
stream state, via a deterministic string hash (FNV-1a 64 is the classic
teachable one) mixed with the seed through splitmix64. Properties we
need: same name+seed → same stream everywhere; different names →
independent streams; adding a new stream never touches existing ones
(no shared sequence to shift — this is the law-2 guarantee, by
construction instead of by discipline).

**3. Draw API.** Integer-only surface (law 1). Sketch: `stream:next()`
raw 64-bit; `stream:int(lo, hi)` unbiased range via rejection sampling
(modulo bias is a post-worthy lesson). Anything fancier (shuffle, pick,
weighted choice) waits until a subsystem needs it.

**4. Tick loop scope.** No subsystems exist yet (event bus is 114, toy
world is 118). Proposal: `Universe.new(seed)` holding the tick counter
(integer, starts at 0) and the RNG registry; `:tick()` advances the
counter and runs registered systems in **array order** (insertion
order, never `pairs()`). A tiny demo script draws from two named
streams for N ticks and prints the sequence — the thing post 0001's
excerpt shows running identically twice.

**5. Proving "done".** Busted specs: (a) golden values — known seed,
known first draws, hardcoded expected integers; (b) two universes, same
seed, N ticks → identical draw sequences; (c) stream independence —
adding draws on a new stream doesn't change an existing stream's
sequence. Golden values catch cross-machine drift in CI someday; the
independence test *is* law-2 as an executable claim.

### Questions Mike asked

- **"What's actually different between xoshiro256\*\* and splitmix64,
  and why recommend xoshiro?"** — splitmix64 is a *counter plus a hash*:
  one 64-bit state, advanced by adding a constant, output = state
  scrambled through three xorshift-multiply rounds. xoshiro256\*\* is a
  *shift register plus a scrambler*: 256 bits of state stirred with
  xor/shift/rotate each step. Three differences matter here: (1) every
  splitmix64 seed starts at a different offset on the **same** 2^64
  cycle, so two named streams are the same sequence shifted — stream
  independence becomes a probability argument (`draws × streams² /
  2^64`), whereas xoshiro's 2^256 states make it structural; (2)
  splitmix64 is a bijection of a counter, so it never repeats an output
  within its period — real randomness collides after ~2^32 draws
  (birthday), a fingerprint a decades-long sim could plausibly reach;
  (3) xoshiro256\*\* is what Lua 5.4's `math.random` runs, with
  published reference code — our *port* is golden-testable. And xoshiro
  needs splitmix64 anyway (the authors' recommended state expander), so
  we learn both, each in the seat it was designed for.
- **"Do we have a case for not just using `math.random`, beyond
  education? Pinning Lua already fixes implementation drift."** — Yes,
  and it's about the interface, not the randomness: (1) `math.random`
  is **one global stream** — named streams can't be built on it (no
  second instance, no state read/write), and one shared sequence is
  precisely what "a new feature never shifts another subsystem's draws"
  forbids; (2) its state can't be **saved, restored, or copied** —
  checkpoints, resume-from-snapshot, and apocrypha forks all need RNG
  state as plain data; (3) global state means **anything in the
  process** (busted, a dependency, a REPL) can shift the sim's draws —
  we want law-2 structurally, not politely; a stream object is a
  capability. Footnote conceded: within pinned 5.4, `math.random` *is*
  cross-machine deterministic — but ADR 0001 wants the 5.4→5.5 lineage
  upgrade to diverge zero, which only works if draws don't depend on
  interpreter internals.

### Decisions

- **Decision (Mike): xoshiro256\*\* generates draws; splitmix64 expands
  `(seed, stream name)` into its 256-bit starting state.** Stream
  derivation: FNV-1a 64 over the seed's 8 bytes then the name's bytes →
  splitmix64 ×4 → xoshiro state. splitmix64-only rejected for the
  shared-cycle and no-collision fingerprints above; PCG32 rejected as
  more friction (32-bit output, 128-bit multiply tricks) for the same
  lesson.
- **Golden vectors come from an independent C implementation** (the
  authors' public-domain reference plus the same FNV/derivation),
  committed under `tests/golden/` so the numbers are regenerable —
  the spec then proves the Lua port bit-for-bit against C, which is
  the cross-machine claim in miniature.

### What we built

- `src/sonder/rng.lua` — splitmix64, FNV-1a 64, xoshiro256** stream
  objects (`:next()` raw 64-bit, `:int(lo, hi)` unbiased via
  mask-and-reject, `:state()` for future checkpoints/forks), and the
  per-universe registry `Rng.new(seed):stream(name)`. Internals
  exported under `_`-prefixed names for the spec only.
- `src/sonder/universe.lua` — `Universe.new(seed)`, systems in an
  array run by index in registration order, `:step()`/`:run(n)`.
  Systems receive `(universe, their_stream, tick)` — a stream is the
  only chance a system is handed, capability-style.
- `src/main.lua` — terminal observer: two placeholder systems (market
  drift, war muster), per-tick lines, and a run fingerprint (FNV fold
  of every observed draw) so two runs compare at a glance.
- `tests/golden/reference.c` — the C oracle; `tests/rng_spec.lua` and
  `tests/universe_spec.lua` — 23 specs, all green. `.busted` config
  points busted at `tests/` with `src/` on the path.
- Verified: `./lua src/main.lua --seed 1893 --ticks 10` twice →
  identical output, fingerprint `c8b4fc573b49bf66`; seed 1894 →
  different universe. Done-when satisfied on this machine; the
  C-vs-Lua golden vectors carry the cross-machine claim until a second
  machine runs it.

### What broke / what surprised us (post material)

- **The oracle handed us the warm-up lesson unprompted.** xoshiro
  seeded with the naive state `{1,2,3,4}` opens with `0x2d00`, then
  literally `0`, then more near-zero dribble — the generator needs
  well-mixed state before its output looks random. That *is* the
  argument for splitmix64 seeding, demonstrable in five lines. Kept as
  a named spec.
- **The first bug of the simulation era was in a test, not the code.**
  The all-zero-state guard test asserted the first draw ≠ 0. It failed:
  xoshiro's output function reads only state word `s1`, which the guard
  (writing `s0`) leaves at 0 — the first draw is 0 *by design*, and
  only the state escape matters. The test was asserting a promise the
  guard never made. Lesson for the post: a failing test is a claim
  meeting a mechanism, and either can be wrong.
- **Deleting the 112 worktree deleted the toolchain** (`.toolchain/`,
  `lua_modules/`, wrappers — all gitignored, all living only in the
  worktree). The main checkout got the true fresh-machine experience:
  one `./tools/setup.sh`, doctor all green. Card 112's done-when got
  re-proven by accident.

## Session 2 (2026-07-25, same day) — the post

Mike: draft the post; deep algorithm details matter less than the
prose ("I trust the great math works of others when tested and
verified"). Drafted `docs/posts/0001-ticks-and-determinism.md`:
excerpt (real 1893 run + fingerprint) → design (tick loop, the
market-declares-war shared-stream failure story, Mike's math.random
question with the interface answer) → CS (counter+hash vs shift
register+scrambler, warm-up zeros with real output, birthday
fingerprint, wrap-around as the load-bearing pin, modulo bias,
C oracle) → what we got wrong (post 0000's false pairs() prophecy,
corrected plainly; the test that asserted the wrong promise; the
worktree/toolchain face-palm).

Two factual bugs caught while drafting: quoted the seed-1894
fingerprint from a 3-tick run against a 10-tick claim (fingerprints
depend on run length — obvious in hindsight, worth remembering when
citing them); attributed the toolchain to post 0000 instead of card
112.
