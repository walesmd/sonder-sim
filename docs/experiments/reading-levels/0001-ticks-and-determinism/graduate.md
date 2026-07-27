# Ticks & Determinism

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0001-ticks-and-determinism.md` · original untouched*

---

```
$ ./lua src/main.lua --seed 1893 --ticks 10
universe 1893 — 10 ticks
tick    1   market drift -1   war muster 4
tick    2   market drift +3   war muster 2
...
tick   10   market drift -2   war muster 2
fingerprint c8b4fc573b49bf66
```

Same command, same ten lines, same fingerprint — next year, on your machine, always; a divergence is a filable bug. To be clear about what this is: there is no market and no war, only two placeholder subsystems wired to the new tick loop, drawing where decisions will eventually go. The claim under test is that the draws are identical on every run, and that the fingerprint — a fold over every draw of the run — is `c8b4fc573b49bf66` for seed 1893 on every machine, forever. Seed 1894 yields `2be4bcacedf8cc33`.

## Determinism as the first law

Everything post 0000 promised — saves as `(seed, intervention log)`, exact replays, golden-master regression over simulated millennia, free fast-forward — is one invariant: a `(code version, seed, intervention log)` triple defines exactly one universe, bit for bit, on every machine. Not statistically similar; identical.

The threat model, all innocent-looking:

- **Wall clock.** One `os.time()` in sim code couples the universe to run time.
- **Unordered iteration.** Lua's `pairs()` order is unspecified (hash-internal); iterating outcome-affecting loops over it makes history depend on table layout.
- **Floating point.** Accumulated float error is platform- and library-sensitive; outcome-affecting quantities are therefore Lua 5.4 integers (money in cents, matter in discrete units).
- **Shared PRNG state** — the subtle one, and the reason this card exists.

The tick loop enforces the first two structurally:

```lua
function Universe:step()
   self.tick = self.tick + 1
   for i = 1, #self.systems do
      local system = self.systems[i]
      system.fn(self, self.rng:stream(system.name), self.tick)
   end
end
```

Systems run every tick, in registration order, over an array by index; each receives exactly one entropy source — its named stream. The signature is the social contract: there is no clock to hand a system.

## Shared randomness: how the market declares war

With one global stream — which is precisely what `math.random` is — market and war draws interleave. Ship one small feature (the market checks one extra price fluctuation per tick, one extra draw) and every subsequent war draw reads one position further down the shared sequence. Seed 1893's tense armistice at day 638 becomes a Khedrun conquest because the market got chattier; saved universes break, the regression diff implicates everything, and bug reports reproduce only at matching commits.

Hence the second law: **a new feature must never shift another subsystem's draws** — true by construction, not by review vigilance. The construction: each stream's initial state is a pure function of `(universe seed, stream name)` and nothing else. For this post's universe:

```
(1893, "market")
  → hashed together          0xfd959b6eb92bb149
  → expanded to 256 bits     0xd339e512781132b7 0xafe7febe36e1fc52
                             0x4dcdc958cbe6067d 0xf218642849ebf06a
  → first draw               0xe3e3b7d2dcad36ef
```

Those values are frozen. A subsystem added in 2031 gets its own hash, its own 256 bits, its own eternal sequence; seed 1893's market moves by zero bits.

Mike's review question — if Lua is pinned anyway, why not `math.random`? — has a sharp answer: the algorithm is fine (it is in fact the one we adopted); the **interface** fails every requirement. One global stream only: no instantiation (named streams impossible), no state introspection (checkpoint/resume impossible), no copying (forking an intervention branch mid-flight impossible), and global reach (a test framework or stray debug draw anywhere in the process shifts the sim). We rejected the plumbing, not the math.

## The generators

A PRNG is a **state** advanced by a fixed transition rule plus an **output function** mapping state to the emitted value. We use two, each in its designed seat.

**splitmix64: counter plus hash.** State is one 64-bit word; the transition is addition of a constant; the output function does all the work — three xor-shift-multiply rounds providing avalanche:

```lua
local function splitmix64(s)
   s = s + 0x9e3779b97f4a7c15
   local z = s
   z = (z ~ (z >> 30)) * 0xbf58476d1ce4e5b9
   z = (z ~ (z >> 27)) * 0x94d049bb133111eb
   return s, z ~ (z >> 31)
end
```

That is the entire generator, and it passes the standard statistical batteries.

**xoshiro256\*\*: shift register plus scrambler.** 256 bits of state (four 64-bit words), a transition that genuinely mixes all words (xors, shifts, a rotation). It is the algorithm inside Lua 5.4's `math.random`; we carry our own ~25-line port (`src/sonder/rng.lua`) so the state is ours to hold, serialize, and fork.

Why not splitmix64 everywhere? Two failure modes invisible at hello-world scale, real at decades scale:

- Every splitmix64 seed is an offset on the *same* 2^64 cycle, so stream independence is a probabilistic argument (a good one) rather than structural. xoshiro's 2^256 state space makes independently seeded streams disjoint for practical eternity.
- splitmix64's output function is a bijection of its counter: no output repeats within the cycle. True uniform 64-bit sampling collides at the **birthday bound**, ~2^32 ≈ 4 billion draws — a horizon a long-running civilization sim actually reaches. "Too perfect to be random" is a detectable statistical tell.

Why not xoshiro alone? 256 bits of state must come from a 64-bit seed, and xoshiro opens badly from low-entropy state. Real output from state `{1, 2, 3, 4}`:

```
0x0000000000002d00
0x0000000000000000      ← the second draw is literally zero
0x000000005a007080
0x10e0000000009d80
```

The authors' own recommendation: seed via splitmix64, taking four outputs as initial state. Final pipeline: **FNV-1a** hashes `(seed, name)` to 64 bits → **splitmix64** expands to 256 → **xoshiro256\*\*** generates. Each algorithm sits where its designers intended.

Two Lua notes. Load-bearing: the multiplies, shifts, and adds all exceed 64 bits, and Lua 5.4 integers wrap exactly like the C `uint64_t` these algorithms target. That semantics is why ADR 0001 pinned Lua 5.4, and `tools/doctor.lua` verifies the *property* (versions are proxies) on every machine. Cosmetic: half the draws print negative — Lua's signed view of the same 64 bits. The bits are what we test.

One named trap: `draw % 6` for a die roll. 2^64 doesn't divide by 6, so residues are non-uniform — **modulo bias**. Tiny, but bit-identical-for-decades promises compound "tiny." `Stream:int(lo, hi)` uses mask-and-reject (**rejection sampling**): mask to the smallest covering power-of-two range, reject and redraw on overshoot. Exact uniformity at an expected cost under two draws.

## Eighteen quintillion universes, give or take a coin flip

Seeds are 64-bit: 2^64 = **18,446,744,073,709,551,616** universes per code version — the same catalog size as Minecraft's world seeds. For scale: 200 million players clearing two worlds an hour around the clock manage ~3.5 trillion worlds a year and need roughly **5.3 million years** for the catalog.

The honest asterisk: 2^64 counts *seeds*, an upper bound on *distinct universes*. Stream states come from a hash, not a bijection, so two seeds can collide on a stream. By the birthday bound you expect on the order of 2^63 seed pairs to share *some one* stream — but a duplicate universe requires collision on **every** stream simultaneously, and each name is an independent roll. With today's two streams, the expected number of fully-duplicate pairs over the whole seed space is about 0.5 — a coin flip that even one exists; at three subsystems it is effectively zero, and it falls with every added system. At most 2^64 universes, almost certainly exactly that — "almost certainly" being a probability argument, not a proof, because we chose a hash over a bijection. One universe lost to a coin flip is affordable.

## Trust, but verify against C

The risk in "write your own PRNG" was never the math — Blackman, Vigna, and thirty years of analysis own that. It's the transcription: one transposed shift constant yields a generator that looks random, passes casual inspection, and is quietly wrong everywhere, discovered years late. So the repo carries an independent oracle: `tests/golden/reference.c` — the authors' public-domain C, verbatim, plus our derivation rule. The suite asserts the Lua port matches bit for bit, from raw generators through the full `(1893, "market")` derivation; a transcription error would have to be mirrored across both languages on the same line. Twenty-three specs, ~10 ms, and the golden numbers regenerate with:

```
cc -o /tmp/sonder-ref tests/golden/reference.c && /tmp/sonder-ref
```

This is also the honest form of "same on every machine": we have run on exactly one computer. The cross-machine claim currently rests on the C oracle and the Lua port agreeing about arithmetic both languages define exactly — a strong argument, but an argument is not a second machine. A differing fingerprint for seed 1893 is our first real determinism bug, and we will name a release after you.

## What we got wrong

**Post 0000 prophesied the wrong humbling.** Written pre-code, it claimed `pairs()` had already bitten us ("our very first universe quietly refused to happen the same way twice"). Didn't happen — the loop was array-based before the first run, which repeated exactly on the first try. The prophecy stays in post 0000's draft, corrected here: the record outranks the story. Reality supplied a better humbling anyway:

**The first bug of the simulation era was in a test.** xoshiro has one absorbing state — all four words zero — emitting zeros forever. No derivation reaches it (probability 2^-256), but a law deserves a guard, not a probability, so the constructor swaps all-zero state for a fixed constant. The test asserted the guard by checking the first draw was nonzero. It failed — not because the guard was broken, but because xoshiro's output function reads only *one* state word, still zero in the guarded state; a zero first draw is by design, escaped on the next step. The test asserted a promise the guard never made. The code survived its first failing test unchanged; the test didn't. Lesson: a failing test is a claim meeting a mechanism, and either can be wrong.

**We un-installed our own toolchain.** The previous card's tools lived gitignored in a git worktree; deleting the worktree deleted them. Consolation: a true fresh-machine test — setup rebuilt to green in one command, accidentally re-proving that card's done-when.

## Next

The heartbeat ticks, but nothing persists: a draw moves a price and the fact evaporates. Post 0002 is the event log — the annals — where nothing happens except an append, and history becomes a database you can point a telescope at.

Same seed, same universe. Check our fingerprint.
