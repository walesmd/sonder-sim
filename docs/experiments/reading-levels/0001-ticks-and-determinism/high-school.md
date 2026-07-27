# Ticks & Determinism

*Reading-level experiment · target: high school · rewritten from `docs/posts/0001-ticks-and-determinism.md` · original untouched*

---

Run the simulator and it prints this:

```
$ ./lua src/main.lua --seed 1893 --ticks 10
universe 1893 — 10 ticks
tick    1   market drift -1   war muster 4
tick    2   market drift +3   war muster 2
tick    3   market drift -1   war muster 2
...
tick   10   market drift -2   war muster 2
fingerprint c8b4fc573b49bf66
```

Run it again: same lines, same fingerprint. Next year, on your machine: same. If not, that's a bug — please report it.

Honesty first: there is no market and no war yet, just two placeholders drawing random numbers where real decisions will someday go. What matters is that they're the *same numbers every time*, and that the fingerprint — one value folding in every draw of the run — is `c8b4fc573b49bf66` on every machine that ever runs seed 1893. Seed 1894 gives `2be4bcacedf8cc33`: a brand-new universe.

## Why determinism is the first law

Every promise this project has made reduces to one guarantee: a `(code version, seed, intervention log)` triple defines exactly one universe, bit for bit, on every machine. Not "statistically similar" — identical. That's what makes saves tiny, replays perfect, and regression tests possible.

The guarantee has innocent-looking enemies: the wall clock (one `os.time()` call and the universe depends on when you ran it); unordered iteration (Lua's `pairs()` walks tables in an unspecified order — same seed, different history); floating point (accumulated rounding drifts across hardware, so every outcome-affecting quantity is a Lua 5.4 integer — money in cents, matter in discrete units); and shared randomness, the subtlest, covered below.

The tick loop that enforces the first defenses fits in a dozen lines:

```lua
function Universe:step()
   self.tick = self.tick + 1
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
end
```

Each tick, every system runs in a fixed order — an array walked by index, never `pairs()` — handed exactly one source of chance: its own stream. That signature is the whole social contract. Nothing hands a system the wall clock, because there isn't one.

## How the market declares war

A **pseudo-random number generator (PRNG)** produces numbers that look random but are fully determined by a starting value, the **seed**. Lua's built-in `math.random` is one *global* PRNG: a single shared sequence. Imagine market and war drawing from it, interleaved, and then ship a tiny feature: the market checks one extra price per tick. One extra draw — and every war draw, forever after, is a different number, because it reads one position further down the shared sequence. Seed 1893, which used to produce a tense armistice at day 638, now produces a conquest, because *the market got chattier*.

So the second law: **a new feature must never shift another subsystem's draws** — true by construction, not by code-review vigilance. Every stream's starting state is computed from `(universe seed, stream name)` and *nothing else*; the market's behavior appears nowhere in the war stream's computation, so it cannot matter. A subsystem added in 2031 gets its own stream, and seed 1893's market won't move by one bit.

Why not just use `math.random`, since we pin the Lua version anyway? Its math is fine — it's the same algorithm we adopted. Its **interface** isn't: one global stream you can't duplicate, inspect, or copy — so no named streams, no save/resume, no forked timelines, and any stray debug draw anywhere shifts the sim. We rejected the plumbing, not the math.

## The CS underneath

A PRNG is two parts: **state** that marches forward by a fixed rule, and an **output function** that scrambles state into the number you see. We use two generators.

**splitmix64** is a counter plus a hash: one 64-bit integer of state, a march rule of "add a constant," and an output function of three xor-shift-multiply rounds that smear every input bit across every output bit. That's the whole generator, and it passes the industry's statistical test suites.

**xoshiro256\*\*** is the serious one: four 64-bit words — 256 bits — of state that genuinely stir each other every step. It's the algorithm inside Lua 5.4's own `math.random`; we carry our own ~25-line copy (`src/sonder/rng.lua`) so the state is ours to hold, save, and fork.

Why not the simple one everywhere? Every splitmix64 seed is just an offset on one shared cycle of 2^64 values, so stream independence would be a probability argument, not a structural one; xoshiro's 2^256 states make separately-seeded streams disjoint for practical eternity. And splitmix64 *never repeats an output* within its cycle — but true randomness repeats: by the **birthday paradox**, random 64-bit values should collide after about 2^32 ≈ 4 billion draws, a horizon a years-long sim actually reaches. "Too perfect to be random" is a real statistical tell.

Why not xoshiro alone? Its 256 bits of state must come from a 64-bit seed, and it opens badly from lazy state: started from state `{1, 2, 3, 4}`, its *second draw is literally zero*. The fix, from xoshiro's own authors: expand the seed through splitmix64, taking four outputs as the starting state. Final pipeline: **FNV-1a** (a classic string hash) crunches `(seed, "market")` into 64 bits; splitmix64 expands them to 256; xoshiro256\*\* draws from there. Each algorithm sits where its designers intended, and the derived numbers for `(1893, "market")` are frozen for eternity.

One Lua note is load-bearing: this arithmetic overflows 64 bits, and Lua 5.4 integers *wrap around* exactly like the C `uint64_t` these algorithms were written for — the reason the project pinned Lua 5.4, with a doctor script checking the property (not the version) on every machine.

One classic trap: making a die roll with `draw % 6`. The 2^64 possible draws don't divide evenly into 6 buckets, so some faces come up slightly more often — **modulo bias**. Tiny, but "tiny" compounds over decades. The fix: mask the draw to the smallest covering power-of-two range; on overshoot, discard and redraw. Exactly uniform, under two draws on average.

## Eighteen quintillion universes

A seed is a 64-bit integer: 2^64 = **18,446,744,073,709,551,616** universes per code version. Minecraft's world seeds are 64-bit too. If all 200 million of its players played around the clock at two worlds an hour — about 3.5 trillion worlds a year — they'd need roughly **5.3 million years** to see them all.

One asterisk: hashing `(seed, name)` isn't collision-proof, so two seeds could share a stream — but a duplicate *universe* must collide on every stream at once. With today's two streams, the expected number of fully-duplicate seed pairs is about 0.5 — a coin flip that even one exists — and every added subsystem drives it toward zero.

## Trust, but verify

The scary part of writing your own PRNG isn't the math — the authors and thirty years of analysis did that. It's the *transcription*: one transposed constant makes a generator that looks random and is quietly wrong everywhere. So the repo carries the authors' public-domain C code, verbatim, in `tests/golden/reference.c`, and the tests assert the Lua port matches it bit for bit, through the full derivation of `(1893, "market")` — twenty-three checks in about a hundredth of a second, regenerable by anyone with a C compiler.

It's also the honest version of "same on every machine": so far we've run on exactly one computer, and an agreeing C reference is a strong argument, but an argument is not a second machine. If your fingerprint for seed 1893 differs, you've found our first real determinism bug, and we'll name a release after you.

## What we got wrong

**The previous post prophesied the wrong humbling.** Written before any code, it claimed the `pairs()` bug had already bitten us. It hadn't — we designed around arrays first, and the universe repeated perfectly on the first try. The wrong prophecy stays in that draft, corrected here: the record matters more than the story.

**The first real bug was in a test.** xoshiro has one poisoned state — all four words zero — that emits zeros forever. No real derivation reaches it (probability 2^-256), but a law deserves a guard, so the constructor swaps all-zero state for a fixed constant. Our test asserted the guard's first draw wasn't zero. It failed — not because the guard was broken, but because xoshiro's output function reads only *one* of the four state words, still zero: a zero first draw is *by design*, escaping on the next step. The test asserted a promise the guard never made; the code survived unchanged, and the test didn't. Lesson: a failing test is a claim meeting a mechanism, and either one can be wrong.

**We also un-installed our own toolchain** by deleting the work folder holding it. Consolation: rebuilding went green in one command, re-proving the previous card's setup work.

## Next

The heartbeat ticks, but nothing is written down: when a draw moves a price, that fact evaporates. Next comes the event log — the **annals** — where nothing happens except an append, and history becomes a database you can point a telescope at.

Same seed, same universe. Check our fingerprint.
