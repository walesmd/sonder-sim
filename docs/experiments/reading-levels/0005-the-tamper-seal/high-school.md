# The Tamper Seal

*Reading-level experiment · target: high school · rewritten from `docs/posts/0005-the-tamper-seal.md` · original untouched*

---

Sonder is a universe simulator with one non-negotiable rule: the same seed must produce the same history, bit for bit, on every machine. This post is about verifying that — boiling 500 ticks of history down to sixteen hex digits that stand guard.

```
$ ./lua src/main.lua --seed 1893 --ticks 500 | tail -3
fingerprint 70483ffb282aa288
seal 27e3e0a8080e04f8
annals archived to out/universe-20260726-190723-seed1893-dev-1.db (1001 events)

$ ./lua src/main.lua --seed 1893 --ticks 500 | grep seal
seal 27e3e0a8080e04f8

$ sqlite3 out/universe-20260726-190723-seed1893-dev-1.db "SELECT * FROM checkpoints"
100|201|85a336802f8c22ba
200|401|e7b38ecfb42d1d17
300|601|4b9b9bcc9cd6d926
400|801|043b16ef9ec38f7b
500|1001|27e3e0a8080e04f8
```

Read that top to bottom. First run: seed 1893, 500 ticks, ending with a **seal** — a hash of the entire history — printing `27e3e0a8080e04f8`. Second run, same seed: same seal. The claim isn't the number; it's the *second* number. Run it on your machine and you get `27e3e0a8080e04f8` too, or one of us has a bug. Third command: the universe file (a SQLite database, called the *annals*) now carries a `checkpoints` table — one row per 100 ticks holding the tick, how many events existed through it, and the seal of history so far; the last row seals the whole run.

The quieter deliverable will outlast everything else on this branch: the project's first **golden-master test**. A spec (an automated test) now asserts that seed 1893, run 500 ticks, seals to exactly that constant. Every mechanic we ever add lands inside that net — touch history, even one random draw of it, and the net says so.

## What "state" even means here

To hash "the state," you first have to define it. Sonder's second law already did: nothing happens except an append to the event log, and every view of the world is a projection (a computed summary) of that log. The tick counter, the random number generator's internals — all rebuildable from the log. So the state hash is simply **a hash of the event log**, folded in event by event as history grows.

That definition dodges a much harder design: no world-state to walk, no RNG internals to serialize. The first divergence that *matters* is, by definition, an event divergence. Hash the history; the history *is* the state.

It also means the seal is a pure function: give anyone the events, and they can compute the same eight bytes. The simulator core doesn't even know it can be hashed. The golden test, the archive, and a stranger holding your universe file all compute it — and must all agree, which is the entire point of a seal.

## One event, one sequence of bytes

A hash is only as trustworthy as its input bytes, so every event gets exactly one canonical byte form:

```
{"id":9,"tick":4,"kind":"war.muster","location":"the-void","magnitude":1,"visibility":"regional","payload":{"muster":1},"causes":[7]}
```

Fields in a fixed order, integers printed as integers, escaping fully specified. It happens to be valid JSON as a courtesy to humans; the *contract* is the bytes. The encoder lives in one shared file (`src/sonder/canon.lua`) used by both the archive and the seal, so the two can never disagree about an event's bytes.

The hash function is **FNV-1a, 64-bit** — about eight lines of xor-and-multiply, pure Lua integer arithmetic. It is deliberately *not* cryptographic, and saying so matters: the seal defends against divergence and accident — a port gone subtly wrong, a refactor that shifted one random draw — not against adversaries. Nobody is attacking their own save file. This is **tamper-evidence**, not tamper-proofing; if we ever need the stronger property, that's a one-function swap.

## When is a tick actually over?

Checkpoint 100 means "the hash of everything through tick 100." But the archive writes checkpoints while reading a stream of events — mid-stream, how does it know tick 100 won't produce one more event? It doesn't, until an event stamped tick 101 arrives. Time never flows backwards in the log (the database enforces it), so a later event *proves* tick 100 is over. Rule: **a tick is sealable when an event from a later tick shows up.** Stream-processing systems (Flink, Kafka Streams) ask the identical question — when can a time window close? — and call the answer a **watermark**. Ours is the simple case where the next event *is* the watermark.

Closing the file gets the last word: close means nothing more is coming, so every file ends with a checkpoint sealing its entire history. The two writers can never collide, by a pleasing little proof: a periodic row at tick T needs an event from beyond T, and close means there are none.

## The golden master and the gremlin

The card's done-when: the replay test passes twice in a row, *and fails when a draw is deliberately perturbed*. The saboteur is the spec's **gremlin**:

```lua
u:add_system("gremlin", function(universe, _, tick)
   if tick == 250 then
      universe.rng:stream("market"):int(-3, 3)
   end
end)
```

Same seed, same everything — plus one extra random draw stolen from the market's stream at tick 250, a number nobody even looks at. That's enough. Every market draw after tick 250 shifts by one position, prices walk a different walk, and the seal comes out different. **One stolen random number is a different universe.** A companion test sharpens it: the two universes' seals *agree through tick 250* and differ from 251 on. Divergence has a first moment — and the checkpoint table lets tools **binary-search** for it (differ at 300, match at 200, split the difference), finding the first fork in O(log n) comparisons instead of reading two histories line by line.

## The CS underneath, briefly

**Golden-master testing** pins a system's exact output and fails on any deviation. Its weakness — the golden value is opaque, so a failure says *something* changed, not *what* — is exactly what checkpoints answer: "what changed?" becomes "when did it first change?", and binary search makes that cheap. When we deliberately change history's format later, the constant gets re-cut in its own commit with the reason written down — a golden master you re-cut casually is just a cache of your bugs.

**FNV-1a** earns its keep through the **avalanche property**: flip one input bit and, on average, half the output bits flip, so a tiny difference lands as fully different digits, not a near-miss you might skim past. With 64 bits, an accidental collision needs on the order of 2³² histories before you'd expect a single matching pair (the "birthday bound") — far beyond any test suite, meaningless against an adversary, which is why the honest label is tamper-evidence.

## What we got wrong

**FNV-1a existed in three places**, and it took Mike's code review to say so out loud: the RNG, the feed fingerprint, and this card's third copy of the constants. Two copies is coincidence; three is a pattern. We extracted it to a shared module (`src/sonder/fnv.lua`) and rebuilt all three on it — proven safe by the one copy we deliberately did *not* touch: an independent C implementation the RNG's test vectors are checked against, because an oracle that shares code with its subject vouches for nothing. Zero bits failed.

**Tick 500's checkpoint almost didn't exist.** 500 is a multiple of 100, so the periodic writer should seal it — but it needs an event from tick 501 as its watermark, and in a 500-tick run none ever comes. The final-seal-at-close rule catches it instead. We designed both rules before noticing they meet exactly at the last tick; the edge case fell out handled — luck, not skill.

**Nothing broke, and we're suspicious.** The last two cards each opened with a failing test. This one broke the streak: 79 specs, green on the first full run, twice. The hardest decisions (what bytes to hash, when a tick completes) got settled on paper before any code existed — either a lesson about design-first or a warning that the next card owes two bugs. We're publishing the prediction so it can embarrass us.

## Next

Two civilizations are coming (card 118), and before they arrive the universe owes them the belief store (card 117) — the structural wall between what a faction *knows* and what is *true*.

Same seed, same history, same sixteen digits. Now go flip a bit.
