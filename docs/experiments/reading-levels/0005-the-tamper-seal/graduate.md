# The Tamper Seal

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0005-the-tamper-seal.md` · original untouched*

---

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

The claim is the *second* run: seed 1893 for 500 ticks reduces to sixteen hex digits, reproducibly, on any machine — `27e3e0a8080e04f8` or someone has a bug. The universe file gains a `checkpoints` table (tick, cumulative event count, rolling hash every 100 ticks, terminal row sealing the whole log), and the branch's more durable deliverable is the project's first **golden-master test**: a spec pinning seed 1893 × 500 ticks to that exact constant. Every future mechanic lands inside that net; perturb history by a single draw and it fails.

## State is the log

Hashing "state" requires defining it, and law 2 already had: nothing happens except an append to the annals; all state views are projections. Tick counter, RNG internals — all derivable from the log, so **the state hash is a fold over the event log**. This disposes of the harder design: no world-state traversal (there is none), no RNG serialization, no policy about which subsystem tables count. Internal wobble that never surfaces as an event leaves the universes observationally identical; the first divergence that *matters* is, by definition, an event divergence. Hash the history; the history is the state.

Consequently the seal is a projection in the same sense as the chronicle (post 0002) and the archive (post 0004): a pure function from a log prefix to eight bytes, computable by anyone holding the events. The core ships unchanged — `universe.lua` has no idea it can be hashed — and the golden test, the archive, and a stranger with your universe file must all compute the same value, which is the entire point.

## Canonical bytes

A hash is only as canonical as its input. Post 0004's deterministic payload encoder — which promised "two universes that differ only in key order must not hash apart" — moved to a shared module, `src/sonder/canon.lua`, and grew to cover the full event:

```
{"id":9,"tick":4,"kind":"war.muster","location":"the-void","magnitude":1,"visibility":"regional","payload":{"muster":1},"causes":[7]}
```

Envelope fields in fixed order, payload fields in declaration order, total escaping, integers printed as integers. It is incidentally valid JSON (for humans and `json_extract`); the contract is the byte sequence. One canonical form, two consumers (archive and seal), zero drift surface.

The hash is **FNV-1a, 64-bit**: eight lines of xor-and-multiply in pure Lua 5.4 integer arithmetic, relying on the wrapping-overflow semantics `doctor.lua` certifies per machine. Deliberately non-cryptographic, and stated as such: the threat model is divergence and accident — a subtly wrong port, a refactor that shifts one draw — not adversaries mining collisions against their own save file. **Tamper-evidence, not tamper-proofing**; if shared apocrypha ever need the stronger property, a future card swaps one function.

## Checkpoints and tick completion (a watermark)

The day-one requirement checkpoints the hash every N ticks. The archive is the natural scribe — it already walks every event at sync time — so it folds the seal as it copies and emits a row at every hundredth tick (`checkpoint_every`, default 100, an opts knob).

The subtle question is write-safety. Checkpoint 100 means "hash of everything through tick 100," but the archive is a follower on an event stream: mid-stream, tick 100 might still produce another event. The proof of completion is an event stamped tick 101 — the annals rejects backwards time, so the stream is totally ordered and the next event proves the prior tick closed. Rule: *a tick is sealable when an event from a later tick arrives.* Checkpoints therefore derive purely from the log, with no caller cooperation, so any future tool replaying an old file computes byte-identical rows; a spec pins that an archive syncing every tick and one syncing once at close produce identical files.

This is the **watermark** from stream processing. Flink, Beam, and Kafka Streams answer the same question — when may a time window close, given events arrive as a stream? — with a signal that no events earlier than T will arrive again. Ours is the degenerate total-order case where the next event *is* the watermark. The shape matters later: when news travels at ship speed (card 122), "has everything arrived yet?" stops having easy answers.

`close()` completes the final tick by definition, so every file ends with a checkpoint sealing its full history (integrity check: recompute from the annals table, compare one row). The two writers provably never collide: a periodic row at tick T requires an event beyond T, and close means there are none.

## Golden master, gremlin, first divergence

Done-when: the replay test passes twice, and fails under a deliberately perturbed draw. The perturbation is a character — the spec's **gremlin**:

```lua
u:add_system("gremlin", function(universe, _, tick)
   if tick == 250 then
      universe.rng:stream("market"):int(-3, 3)
   end
end)
```

Identical seed and systems, plus one draw stolen from the market's own stream at tick 250, its value discarded. Every subsequent market draw shifts one position, prices take a different path, and the seal differs. One stolen draw is a different universe — post 0001's named-streams argument (*a new feature never shifts another subsystem's draws*) run in reverse as an executable claim: cross-stream reaches visibly fork history.

A companion spec sharpens this into the property card 123 builds on: clean and gremlin universes' seals **agree through tick 250** and differ from 251 on. Divergence has a first moment, and the checkpoint table is the substrate for **binary search for first divergence**: differ at 300, match at 200, bisect — O(log n) checkpoint comparisons instead of a linear diff of two histories. That is the synopsis tool's forensic mode; its substrate shipped today.

## The CS underneath

**Golden-master testing** (the term is from recording studios — the master disc everything is pressed from) pins exact observable output and fails the build on any deviation. It fits Sonder's regime precisely: output too large for piecewise assertions, behavior that must never drift accidentally, cheap wholesale before/after comparison. Its known weakness — the golden value is opaque, so failure says *something* changed, not *what* — is what the checkpoint trail answers: "what changed?" becomes "when did it first change?", made cheap by bisection. When the event vocabulary churns (card 118 will churn it), the constant is re-cut deliberately, in its own commit, reason in the message — a golden master re-cut casually is a cache of your bugs.

**FNV-1a** earns its keep via the **avalanche property**: one flipped input bit flips ~half the output bits on average, so "payload differs by 1 at tick 251" reads as fully different digits, not a skimmable near-miss. At 64 bits, the **birthday bound** puts an expected accidental collision near 2³² histories — unreachable by a spec suite, meaningless against an adversary; hence the honest label of tamper-evidence.

## What we got wrong

**FNV-1a existed in three places**, and it took Mike's review to say so: RNG stream derivation (card 113), the feed fingerprint (card 114), and this card's third copy of the constants. Rule of three — extracted to `src/sonder/fnv.lua`, all three consumers rebuilt on it. The refactor was validated by the one copy deliberately left untouched: `tests/golden/reference.c`, the independent C implementation backing the RNG's golden vectors. An oracle sharing code with its subject vouches for nothing; rebuild `stream_hash` on the shared module, re-run the vectors against the untouched oracle, and any wrong bit fails loudly. Zero bits failed.

**Tick 500's checkpoint almost didn't exist.** 500 is a multiple of 100, but the periodic writer needs a tick-501 event as its watermark, and in a 500-tick run none comes. The final-seal-at-close rule catches it. Both rules were designed before anyone noticed they meet exactly at the last tick — the edge case fell out handled, which we count as luck, not skill.

**Nothing broke, and we're suspicious.** Cards 113 and 114 each opened with a red spec caused by the test, not the code; this card broke the streak — 79 specs, green on the first full run, twice. The honest accounting: the bug-shaped decisions (what bytes to hash, when a tick completes) were settled in the notebook before code existed. Either a lesson about design-first or a warning that the next card owes two bugs. The prediction is published so it can embarrass us.

## Next

Two civilizations arrive with card 118; before them, the belief store (card 117) — the structural wall between what a faction *knows* and what is *true*, shipped as a deliberately boring pass-through so that when news later travels at ship speed and degrades in transit, no decision code changes: it was reading beliefs all along.

Same seed, same history, same sixteen digits. Now go flip a bit.
