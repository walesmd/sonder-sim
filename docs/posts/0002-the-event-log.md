# The Event Log

*Post 0002 · code pinned at tag `post/0002` · Lua 5.4 · this post's
universe: seed `1893` · ~10 min read*

---

```
$ ./lua src/main.lua --seed 1893 --ticks 5 --why 9
universe 1893 — 5 ticks
tick    0 · the-void · a universe begins (seed 1893)
tick    1 · the-void · the market drifts -1
tick    1 · the-void · the war office musters 4 levies
tick    2 · the-void · the market drifts +3
tick    2 · the-void · the war office musters 2 levies
tick    3 · the-void · the market drifts -1
tick    3 · the-void · the war office musters 2 levies
tick    4 · the-void · the market drifts -1
tick    4 · the-void · the war office musters 1 levy
tick    5 · the-void · the market drifts +1
tick    5 · the-void · the war office musters 6 levies
fingerprint 30022225827550c9

why event 9:
tick    4 · the-void · the war office musters 1 levy
  tick    3 · the-void · the war office musters 2 levies
    tick    2 · the-void · the war office musters 2 levies
      tick    1 · the-void · the war office musters 4 levies
        tick    0 · the-void · a universe begins (seed 1893)
```

These are post 0001's numbers wearing sentences. Check tick 1 against
that post's table: market drift −1, war muster 4 — same seed, same
draws, and they always will be. The market and the war office are
still placeholders drawing random numbers where decisions will someday
go. What changed is underneath: those draws used to be printed and
forgotten in the same breath. Now each one is an **event**, appended
to a log the sim calls the annals, and the feed you're reading is not
the simulation talking — it's a viewer rendering the log after the
fact. Delete the feed code entirely and seed 1893 produces the exact
same universe, silently.

And then there's `why event 9`. Ask the annals about the fourth tick's
war muster and it doesn't just repeat the fact — it walks you down a
chain of causes, link by link, until it reaches the event that needs
no cause. Every event in every Sonder universe, forever, will answer
that question all the way to the bottom. This post is about the
machinery that makes the answer cheap.

## Nothing happens except an append

The second law of this project, verbatim from the design doc: nothing
"happens" except an append to the annals. All state views, chronicles,
and statistics are projections of it.

Before this card, that law was aspirational. The market's drift lived
in a local variable; the terminal read the variable; when the process
exited, history had never happened. Now the sim has exactly one way to
change the world: announce what occurred. Here is the market doing it,
from `src/main.lua`:

```lua
local drift = stream:int(-3, 3)
last_market = universe:emit{
   kind = "market.drift",
   location = "the-void",
   magnitude = math.abs(drift),
   visibility = "public",
   payload = { drift = drift },
   causes = { last_market },
}
```

`emit` validates, appends, and returns the new event's id. Every event
carries the same envelope — tick, kind, location, magnitude,
visibility, payload, causes — plus the two fields the annals stamps
itself. The very first row of seed 1893's log looks like this:

```lua
{
   id = 1,                  -- its position in the log
   tick = 0,
   kind = "universe.genesis",
   location = "the-void",   -- there is nowhere else yet
   magnitude = 0,
   visibility = "public",
   payload = { seed = 1893 },
   causes = {},             -- the only empty one there will ever be
}
```

Two of those fields are stamped by the machinery rather than passed by
the caller, and both for the same reason. The **tick** comes from the
universe's own clock, so a system cannot lie about when something
happened. The **id** is simply the event's position — the nth append
is event n — so a system cannot lie about order either. Position as
identity costs nothing, survives into card 115 as the database rowid,
and is deterministic for free: emission order is systems-in-array-
order (post 0001's loop), so the same seed numbers its events the same
way on every machine.

**Visibility** deserves a sentence, because nothing reads it yet. It's
a small closed set — `public`, `regional`, `secret` — stamped honestly
by every emitter (the war office musters `regional`ly; you'd have to
be nearby to count levies). It exists today because it cannot be added
retroactively: the belief store (three cards from now) will decide
what each civilization gets to *know*, and it can only do that if
every event since genesis carries who-could-know-this on its face.
History written without visibility would be history we'd have to make
up later.

## Why did that happen?

The `causes` field is the card's quiet radicalism: it is **required**.
Every event must cite at least one earlier event that caused it —
markets don't just move, wars don't just start, asteroids don't just
exist. A volcanic catastrophe may look like the gods rolled dice, to
the civilization standing on the volcano; in the log it will cite
plate mechanics, or the mining charter that drilled too deep. The one
exception is `universe.genesis`, the uncaused event, and the annals
enforces its uniqueness: genesis happens once, first, with an empty
cause list, and nothing else may open a log.

The validation rule is a single comparison doing a lot of philosophy:
a cause must be an id **already in the log** — an integer between 1
and the current length. Links can only point backwards in time. An
event can't cite itself (its id doesn't exist until the append
completes), can't cite the future, can't form a loop. Which means the
annals is, by construction, a *directed acyclic graph* threaded
through an array: no cycle detection, no graph library, just the fact
that you cannot reference what hasn't been written yet. Every chain of
whys bottoms out at event 1 — that's the ladder in the excerpt, and
it's not a rendering trick; `--why` is fifteen lines of code walking
`causes` fields.

Our placeholders use it honestly: each drift cites the previous drift,
each muster the previous muster, the first of each cites genesis. A
random walk, narrated: prices moved from where they were.

## Strict at the door, tolerant at the telescope

The two sides of the log get opposite strictness, and the asymmetry is
the design decision we spent the longest on.

**The writer is strict.** `emit` either appends a fully valid event or
raises — no warnings, no nil returns, no soft-failure path into the
log. Unregistered kind: error. Missing envelope field, or a field
nobody declared: error. Float magnitude: error (outcomes are integers;
law 1). Visibility outside the set: error. Payload field mistyped,
missing, or uninvited: error. A cause that isn't a past event's id:
error. This severity is cheap precisely *because* the sim is
deterministic — a malformed event either always happens for a given
seed or never does, so the crash fires on the first run, on the
developer's machine, not years into some player's universe. A
malformed event that got written, though, is corrupted history
forever. Append-only logs don't do do-overs.

**The reader is tolerant.** The chronicle owns a sentence for every
kind it knows, and for kinds it doesn't, it renders a generic line
from the envelope — which every event of every era carries:

```
tick  512 · sector:7 · diplomacy.betrayal, magnitude 8, secret — traitor=house-veyl, victim=house-omast
```

There is no `diplomacy.betrayal` in today's vocabulary. That line is
from a test feeding the chronicle an event from an imaginary future,
and the chronicle's job is to not blink. This matters because a viewer
will meet logs younger than itself — not hypothetically, but as a
scheduled consequence of our own plans: universes that cross engine
versions carry new-era events in front of old-era tools; the synopsis
tool exists to compare universes made by *different* versions; a seed
report is someone else's universe file, made by whatever they were
running. A chronicle that crashes on unknown kinds makes every old
tool useless against every new log. Writes are forever; readers age.

One stitch keeps the tolerance from becoming sloppiness on our own
side of the fence: a spec walks the vocabulary and asserts *this*
repo's chronicle has a real sentence for every kind. You can't add a
kind and forget to teach the viewer — the fallback is for other eras'
events, not for our own laziness.

## The vocabulary is a public API

What may happen in a universe is declared in one place,
`src/sonder/vocabulary.lua`, as plain data: each kind carries a doc
line and an ordered list of typed payload fields.

```lua
["market.drift"] = {
   doc = "placeholder: the market moves for no modeled reason "
      .. "yet (card 118 replaces this)",
   payload = { { "drift", "integer" } },
},
```

Three constraints on payloads, all with the same two audiences in
mind. Fields are **integers and strings only** — no floats near
outcomes (law 1), and every value is one bind away from a SQLite
column (card 115). Payloads are **flat** — no nested tables, because
rows aren't trees. And field declarations are an **ordered array**, so
anything that ever walks a payload — validation today, hashing and
persistence tomorrow — iterates the declaration, never `pairs()`,
whose order is unspecified and banned near outcomes.

The module carries `schema_version = 1`, and honesty requires saying
what that buys today: nothing. It's the hook that card 115 writes into
every universe's provenance table so that two log files can announce
whether they speak the same dialect. The kinds themselves are
placeholders — `market.drift` and `war.muster` will not survive to
v0.1, and pre-0.1 we churn the vocabulary freely. What ships today is
the discipline, not the words: a versioned schema, strict from day
one, additions cheap, removals owing a documented migration.

## The chronicle is a function, not a listener

"Event bus" usually means callbacks: viewers subscribe, the bus calls
them on every event. We built the other thing, and the reason is law 4
— the core is headless; the sim must run bit-identically whether zero
or a thousand things watch.

With callbacks, subscriber code runs *inside* the sim's tick. A viewer
that throws an error halts the universe. A viewer that writes to state
alters it. Both violations are one incautious line away, and the law
holds only as long as every viewer behaves — politeness again, where
we keep insisting on structure. So: **projection, not subscription**.
The annals array is the interface. A chronicle is a cursor and a
render function:

```lua
function Chronicle:lines()
   local out = {}
   while self.cursor < self.annals:len() do
      self.cursor = self.cursor + 1
      out[#out + 1] = line(self.annals:get(self.cursor))
   end
   return out
end
```

Live-following is calling `lines()` again later. Replaying a universe
from the beginning is a fresh chronicle over the same annals — same
function, no special case. And the spec suite contains the law as an
executable claim: two universes, same seed, one rendered every tick
and one never observed, must produce identical annals. With projection
that test passes by construction, which is precisely the point — it's
pinned so that some future "optimization" can't unpin it.

The structure is guarded on the read side too. `get()` returns a
**copy**, never the log's own row, and `append` rebuilds the caller's
tables field by field rather than storing them. Hand out a live row
and any viewer holds a pen that rewrites history — silently, no error,
no trace. Hold a caller's table and the caller's later mutations reach
back into the past. The log takes photographs and hands out
photographs; nobody touches the negatives. Append-only by structure,
not by politeness.

## The CS underneath: event sourcing

The pattern this card implements has a name in industry — **event
sourcing** — and a longer pedigree than software. A bank does not
store your balance and update it; it stores every transaction since
the account opened, and your balance is what you get by folding them
up. When the teller's screen disagrees with the ledger, the ledger
wins, because the ledger is the *record* and the balance is a *cache*.
Double-entry bookkeeping has run on this principle since the 1400s.

Software keeps reinventing it because it keeps being right. Git
doesn't store your project's current state as the truth — it stores an
append-only DAG of commits, each linking to its parents, and your
working tree is a projection of it (our events-citing-causes is the
same picture, with sequential integers where git uses hashes). Kafka
made "the log is the system of record" into infrastructure, and its
consumers keep exactly our chronicle's cursor: an offset into an
append-only sequence, where offset *is* identity. Even your database
is secretly one of these — every write goes to a write-ahead log
first, and the tables you query are, formally, a materialized view of
that log. The annals is Sonder saying this out loud instead of hiding
it in the basement: the log is the truth; everything you can look at
is a **projection** — a pure function from a prefix of the log to a
view. Same input, same view, which is why our golden feed test can
hardcode four exact lines of terminal output for seed 1893 and expect
them on every machine forever.

There's one delightfully odd consequence of building event sourcing
*on top of* post 0001's determinism. The annals is the source of truth
for every reader — and yet, strictly speaking, it's redundant: the
whole log is recomputable from eight bytes, because `(code version,
seed)` regenerates every event bit for bit. Both statements are true
at once. Relative to the generator, the log is a cache; relative to
everything downstream — viewers, statistics, the belief store, next
card's database — it's the authoritative record, and the only
interface anything is allowed to read. We store it because readers
want random access, because card 115 wants rows, and because the day
interventions arrive, apocrypha branches will make the log the *only*
complete account of what a meddling god actually did.

## What we got wrong

**The design conversation shipped a backwards sentence.** Arguing for
tolerant readers, Claude wrote that "viewers of old logs will meet
kinds younger than they are" — which confused Mike, correctly, because
it's inverted: old logs don't contain young kinds. Viewers meet *logs*
younger than themselves. The corrected sentence convinced in one read.
The lesson is the working agreement itself: nothing merges that Mike
can't defend, and an explanation that confuses the person who owns the
decision isn't context — it's a bug, in the explanation or in the
idea, and you have to find out which.

**The card's first failing test was wrong about the assertion library,
not the code.** Second card in a row where the first red came from a
test-side mistake. This time: luassert's `assert.has_error(fn, msg)`
treats its second argument as the *expected error message* — but its
cousins (`assert.is_true(cond, msg)`) treat theirs as a failure label,
and we wrote the label habit into the error assertion. The annals
raised exactly the right error; the test demanded it match the words
"0 accepted as a cause" and failed. Post 0001's lesson, new costume: a
failing test is a claim meeting a mechanism, and you have to know
which side the strings are on.

**Genesis has magnitude 0, and we're not proud of it.** The largest
event in any universe's history — the universe — carries the smallest
possible magnitude, because magnitude has no scale until the toy world
(card 118) gives it one, and 0 is an honest "unscaled." It reads
absurd, we know it reads absurd, and we wrote it down here so that
when card 118 defines the scale, there's a public wart on record to
either fix or defend.

## Next

The annals is an array in RAM. Close the terminal and history
evaporates — a strange property for a thing this post kept calling
*the permanent record*. Card 115 gives it a home: SQLite, and the
provenance table that makes a universe file self-describing — engine
version, git commit, seed, config, schema version — so a log found on
a beach can testify about its own origins.

Same seed, same history, line for line. Ask it why.
