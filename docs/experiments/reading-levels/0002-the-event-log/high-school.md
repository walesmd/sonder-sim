# The Event Log

*Reading-level experiment · target: high school · rewritten from `docs/posts/0002-the-event-log.md` · original untouched*

---

Sonder is a deterministic universe simulator built in Lua: a seed (one starting number) plus the code fully decides everything that will ever happen, on every machine. Time advances in ticks. The only inhabitants so far are two placeholders drawing random numbers: a market whose price drifts, and a war office that musters levies (drafted soldiers). Here is seed 1893 for 5 ticks, with one new question at the end:

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

These are the previous post's numbers wearing sentences — tick 1 matches post 0001's table: market drift −1, war muster 4. Same seed, same draws, always. What changed is underneath: draws that used to be printed and forgotten are now **events**, appended to a log called the annals, and the feed above is a viewer rendering that log after the fact. Delete the feed code and seed 1893 produces the exact same universe, silently. And `why event 9`? The annals walks a chain of causes down to the one event that needs no cause — a question every event in every Sonder universe will answer.

## Nothing happens except an append

The project's second law: nothing "happens" except an append to the annals; every view is computed *from* the log. Before this change, the market's drift lived in a local variable — when the process exited, history had never happened. Now the sim has exactly one way to change the world: announce what occurred. The market, from `src/main.lua`:

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

`stream:int(-3, 3)` draws a random integer between −3 and 3. `emit` validates the event, appends it, and returns its id, remembered so the *next* drift can cite this one as its cause.

Two fields the caller doesn't get to pass. The **tick** is stamped from the universe's own clock, so a system cannot lie about when. The **id** is the event's position in the log — the nth append is event n — so a system cannot lie about order either; since systems always run in the same order, the same seed numbers its events identically on every machine.

**Visibility** is a small closed set — `public`, `regional`, `secret` — that nothing reads yet. It exists now because it can't be added retroactively: a later feature will decide what each civilization gets to *know*, which requires who-could-know-this on every event since the beginning.

## Why did that happen?

The quiet radicalism: `causes` is **required**. Every event must cite at least one earlier event — markets don't just move, wars don't just start. The one exception is `universe.genesis`, the uncaused event; the annals enforces that it happens once, first, with an empty cause list. Our placeholders comply honestly: each drift cites the previous drift, each muster the previous muster, the first of each cites genesis.

The validation rule is a single comparison doing a lot of philosophy: a cause must be an id already in the log — an integer between 1 and the current length. Links can only point backwards in time: an event can't cite itself (its id doesn't exist yet), the future, or a loop. That makes the log, by construction, a *directed acyclic graph* — arrows, no cycles — with no cycle-detection code at all. Every chain of whys bottoms out at event 1; `--why` is fifteen lines of code walking `causes` fields.

## Strict at the door, tolerant at the telescope

The two sides of the log get opposite strictness — the design decision the team debated longest.

**The writer is strict.** `emit` either appends a fully valid event or raises an error — no warnings, no soft failures. Unregistered kind, missing field, non-integer magnitude, unknown visibility, mistyped payload, a cause that isn't a past event's id: all errors. The severity is cheap *because* the sim is deterministic — a malformed event either always happens for a given seed or never does, so the crash fires on the first run, on the developer's machine. A malformed event that got written would be corrupted history forever.

**The reader is tolerant.** The chronicle owns a sentence for every kind it knows; for kinds it doesn't, it renders a generic line from the envelope every event carries:

```
tick  512 · sector:7 · diplomacy.betrayal, magnitude 8, secret — traitor=house-veyl, victim=house-omast
```

There is no `diplomacy.betrayal` in today's vocabulary — that line is a test feeding the chronicle an event from an imaginary future, and the chronicle's job is to not blink. Viewers *will* meet logs younger than themselves: universes crossing engine versions, tools comparing universes made by different versions, someone else's universe file. Writes are forever; readers age. One test keeps tolerance from becoming laziness: this repo's chronicle must have a real sentence for every kind it defines.

The allowed kinds live in one file, `src/sonder/vocabulary.lua`, as plain data: per kind, a doc line and an ordered list of typed payload fields. Payloads are integers and strings only, flat, and walked in declared order — never Lua's `pairs()`, whose unspecified ordering is banned near outcomes. The module carries `schema_version = 1`, which buys nothing today; it's the hook that will let two universe files announce whether they speak the same dialect.

One more structural guard: the chronicle is a function over the log, not a callback the sim invokes — a callback viewer that crashes halts the universe, and one that writes to state alters it. Instead, a chronicle holds a cursor into the array and renders the lines it hasn't seen; replay is a fresh cursor over the same log. And reads return **copies**, never the log's own rows: the log takes photographs and hands out photographs; nobody touches the negatives.

## The CS underneath: event sourcing

This pattern has a name — **event sourcing** — and predates software. A bank doesn't store your balance and update it; it stores every transaction since the account opened, and your balance is what you get by adding them up. The ledger is the record; the balance is a cache — double-entry bookkeeping has run on this since the 1400s. Git works the same way: an append-only graph of commits, each linking to its parents, just like our events citing causes. In Sonder, the log is the truth and everything you can look at is a **projection** — a pure function from the log to a view. Same input, same view: that's why a test can hardcode four exact lines of output for seed 1893 and expect them on every machine forever.

## What we got wrong

**A backwards sentence.** Arguing for tolerant readers, Claude wrote "viewers of old logs will meet kinds younger than they are" — inverted, as Mike's confusion correctly flagged: viewers meet *logs* younger than themselves. An explanation that confuses the person who owns the decision is a bug, in the explanation or the idea, and you have to find out which.

**A test-side bug, again.** The first failing test was wrong about the assertion library, not the code — second card in a row. luassert's `assert.has_error(fn, msg)` takes an *expected error message* as its second argument, but its cousins take a failure label, and the label habit leaked in: the code raised exactly the right error, and the test failed demanding the words "0 accepted as a cause."

**Genesis has magnitude 0.** The largest event in any universe's history carries the smallest possible magnitude, because magnitude has no scale until the toy world (card 118) gives it one, and 0 is an honest "unscaled." It reads absurd; it's on the record to be fixed or defended.

## Next

The annals is an array in RAM — close the terminal and history evaporates, a strange property for *the permanent record*. Card 115 gives it a home: SQLite, plus a provenance table (engine version, git commit, seed, config, schema version) so a log found on a beach can testify about its own origins.

Same seed, same history, line for line. Ask it why.
