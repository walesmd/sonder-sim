# The Tamper Seal

*Post 0005 · code pinned at tag `post/0005` · Lua 5.4 + SQLite ·
this post's universe: seed `1893` · ~10 min read*

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

Five hundred ticks of seed 1893, boiled down to sixteen hex digits —
twice, because the claim isn't the number, it's the *second* number.
Run it on your machine and you get `27e3e0a8080e04f8` too, or one of
us has a bug. And the universe file now carries a `checkpoints`
table: every hundred ticks, the running hash of all history so far,
ending with a seal of the whole thing. Post 0004 closed by promising
the history book a tamper seal. This is it.

The other thing this card left behind is quieter and will outlast
everything else on the branch: the project's first **golden-master
test**. A spec now asserts that seed 1893, run 500 ticks, seals to
exactly that constant. Every mechanic we ever add lands inside that
net — touch history, even one draw of it, and the net says so.

## What "state" means when everything is an event

To hash the state you must first say what the state *is*, and law 2
already answered: nothing happens except an append to the annals;
every state view is a projection of it. The sim's whole being — tick
counter, RNG internals, the log — reduces to the log, because the
rest is derivable. So **the state hash is a hash of the event log**,
folded event by event as history grows.

That answer quietly disposes of a harder design: no walking of world
state (there is none to walk), no serializing RNG guts, no worrying
about which subsystem's tables count. If a wobble somewhere never
changes an event, the two universes are observationally identical —
and the first divergence that *matters* is, by definition, an event
divergence. Hash the history; the history is the state.

It also means the seal is a **projection** — the same shape as the
chronicle (post 0002) and the archive (post 0004): a pure function
from a prefix of the log to eight bytes, computable by anyone holding
the events. The core ships this card unchanged; `universe.lua` has no
idea it can be hashed. The golden test computes the seal, the archive
computes it, a stranger holding your universe file computes it, and
they must all get the same answer, which is the entire point of a
seal.

## One event, one sequence of bytes

A hash is only as canonical as its input bytes. Post 0004 built a
deterministic encoder so payload columns would be byte-stable — and
promised that when hashing arrived, "two universes that differ only
in key order must not hash apart." The way to keep that promise is to
make sure the archive and the seal can never disagree about what an
event's bytes *are*: the encoder moved to a shared home,
`src/sonder/canon.lua`, and grew to cover the whole event —

```
{"id":9,"tick":4,"kind":"war.muster","location":"the-void","magnitude":1,"visibility":"regional","payload":{"muster":1},"causes":[7]}
```

— envelope fields in fixed order, payload fields in declaration
order, total escaping, integers printed as integers. It happens to be
valid JSON as a courtesy to humans and `json_extract`; the contract
is the bytes. One canonical form, two consumers, zero chances to
drift apart.

The hash itself is **FNV-1a, 64-bit**: eight lines of xor-and-
multiply, pure Lua 5.4 integer arithmetic, the same wrapping overflow
`doctor.lua` certifies on every machine. It is deliberately *not*
cryptographic, and saying so out loud matters: the seal defends
against divergence and accident — a port gone subtly wrong, a
refactor that shifted one draw — not adversaries. Nobody is mining
collisions against their own save file. Tamper-*evidence*, not
tamper-proofing; if shared apocrypha ever need the stronger property,
that's a future card swapping one function.

## Checkpoints, and when a tick is actually over

The day-one requirement says the hash is "checkpointed every N
ticks," and the archive was the obvious scribe — it already walks
every event at sync time, so it folds the seal as it copies and drops
a row at every hundredth tick (`checkpoint_every`, default 100, an
opts knob). Each row: the tick, how many events existed through it,
sixteen hex digits.

The subtle question is *when it's safe to write one*. Checkpoint 100
means "the hash of everything through tick 100" — but the archive is
a follower reading a stream of events, and mid-stream, how does it
know tick 100 won't produce one more event? It doesn't — until an
event stamped tick 101 arrives, at which point tick 100 is over,
*proven* over, because time doesn't flow backwards (the annals
enforces it). So the rule: *a tick is sealable when an event from a
later tick shows up.* Checkpoints therefore derive purely from the
log — no cooperation from the caller, which means any future tool
replaying an old file computes byte-identical rows. A spec pins that:
an archive that syncs every tick and one that syncs once at close
produce identical files.

`close()` gets the last word: closing completes the final tick by
definition — nothing more is coming — so every file ends with a
checkpoint sealing its entire history. Integrity check: recompute the
seal from the annals table, compare one row. And the two writers can
never collide, by a pleasing little proof: a periodic row at tick T
needs an event from beyond T, and close means there are none.

## The golden master and the gremlin

The card's done-when: the replay test passes twice in a row, and
fails when a draw is deliberately perturbed. The first half is two
universes, same seed, both asserted against the hardcoded constant.
The second half deserved a character, so the spec has a **gremlin**:

```lua
u:add_system("gremlin", function(universe, _, tick)
   if tick == 250 then
      universe.rng:stream("market"):int(-3, 3)
   end
end)
```

Same seed, same market, same war office — plus one extra draw stolen
from the market's own stream at tick 250, a number nobody even looks
at. That's enough. Every market draw after tick 250 shifts by one
position, prices walk a different walk, and the seal comes out
different. One stolen random number is a different universe. This is
post 0001's named-streams argument — *a new feature never shifts
another subsystem's draws* — now running in reverse as an executable
claim: reaching into someone else's stream visibly forks history.

A companion spec sharpens it into the property card 123 will build
on: run the clean and gremlin universes side by side, and their seals
**agree through tick 250** and differ from 251 on. Divergence has a
first moment. Checkpoint tables exist so tools can binary-search for
it — compare checkpoints at tick 300 (differ) and 200 (match), split
the difference, and find the first fork in O(log n) comparisons
instead of reading two histories line by line. That's the synopsis
tool's forensic mode, and its substrate shipped today.

## The CS underneath: nets made of hashes

**Golden-master testing** (the name comes from recording studios —
the master disc everything is pressed from) is the art of pinning a
system's exact observable output and letting any deviation fail the
build. It shines precisely where Sonder lives: output too large to
assert piece by piece, behavior that must never drift by accident,
and a cheap way to compare "before" and "after" wholesale. Its known
weakness — the golden value is opaque, so a failure says *something
changed* but not *what* — is exactly what the checkpoint table
answers: not one seal but a trail of them, so the question "what
changed?" becomes "when did it first change?", and binary search
makes that cheap. When the vocabulary churns (card 118 will churn
it), the constant gets re-cut deliberately, in its own commit, with
the reason in the message — a golden master you re-cut casually is
just a cache of your bugs.

**FNV-1a** earns its keep by the avalanche property: flip one input
bit and, on average, half the output bits flip, so "one payload
differs by 1 in tick 251" lands as fully different digits, not a
near-miss a human might skim past. With 64 bits, accidental collision
needs on the order of 2³² histories before you'd expect a single
pair (the birthday bound) — astronomically beyond a spec suite,
meaningless against an adversary, which is why the honest label is
tamper-evidence.

**And the tick-completion rule has a name in industry: a watermark.**
Stream processors — Flink, Beam, Kafka Streams — face the identical
question: when can a time window close, given events arrive as a
stream? Their answer is a watermark: a signal that no events earlier
than T will arrive again. Ours is the special case where the stream
is totally ordered (the annals rejects backwards time), so the next
event *is* the watermark. We found the rule by asking when a
checkpoint is safe to write; the stream-processing literature found
it by asking when a billing window can bill. Same shape, and it's the
shape to remember when news starts traveling at ship speed (card 122)
and "has everything arrived yet?" stops having easy answers.

## What we got wrong

**FNV-1a existed in three places, and it took Mike's review to say so
out loud.** The RNG derives streams with it (card 113), the feed
fingerprint folds with it (card 114), and this card wrote the
constants down a third time. Rule of three: two copies was
coincidence, three is a pattern. Extracted to `src/sonder/fnv.lua`;
all three consumers rebuilt on it. The refactor was proven safe by
the one copy we deliberately did *not* touch: `tests/golden/
reference.c`, the independent C implementation the RNG's golden
vectors are checked against — an oracle that shares code with its
subject vouches for nothing. Rebuild `stream_hash` on the shared
module, re-run the vectors against the untouched oracle, one wrong
bit fails loudly. Zero bits failed.

**Tick 500's checkpoint almost didn't exist.** 500 is a multiple of
100, so you'd expect the periodic writer to seal it — but the
periodic writer needs an event from tick 501 as its watermark, and
in a 500-tick run none ever comes. The final-seal-at-close rule
catches it instead. We'd designed both rules before noticing they
meet exactly at the last tick; the edge case fell out handled, which
we are counting as luck, not skill.

**Nothing broke, and we're suspicious.** Cards 113 and 114 each
opened with a red spec caused by the test, not the code — a streak
this card broke: 79 specs, green on the first full run, twice. The
honest accounting is that the hardest bug-shaped decisions this card
(what bytes to hash, when a tick completes) got settled in the
notebook before any code existed, which is either a lesson about
design-first or a warning that the next card owes two bugs.
Publishing the prediction so it can embarrass us.

## Next

Two civilizations are coming (card 118), and before they arrive the
universe owes them the seam that makes them interesting: the belief
store (card 117) — the structural wall between what a faction *knows*
and what is *true*. It ships as a pass-through, deliberately boring,
so that when news someday travels at ship speed and degrades in
transit, no decision code has to change — it was reading beliefs all
along.

Same seed, same history, same sixteen digits. Now go flip a bit.
