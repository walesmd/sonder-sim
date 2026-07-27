# The Event Log

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0002-the-event-log.md` · original untouched*

---

```
$ ./lua src/main.lua --seed 1893 --ticks 5 --why 9
universe 1893 — 5 ticks
tick    0 · the-void · a universe begins (seed 1893)
tick    1 · the-void · the market drifts -1
tick    1 · the-void · the war office musters 4 levies
...
tick    5 · the-void · the war office musters 6 levies
fingerprint 30022225827550c9

why event 9:
tick    4 · the-void · the war office musters 1 levy
  tick    3 · the-void · the war office musters 2 levies
    tick    2 · the-void · the war office musters 2 levies
      tick    1 · the-void · the war office musters 4 levies
        tick    0 · the-void · a universe begins (seed 1893)
```

Post 0001's draws, rendered as prose: tick 1's market drift −1 and war muster 4 match that post's table, and always will for this seed. The market and war office remain placeholder RNG consumers. The change is structural: draws that were previously printed and discarded are now **events** appended to a log (the annals), and the feed is a viewer rendering that log after the fact. Delete the viewer and seed 1893 produces a bit-identical universe, silently. `--why 9` walks the causal chain of tick 4's war muster to the unique uncaused event; every event in every universe answers that query, and this post is about why the answer is cheap.

## Nothing happens except an append

Law 2, verbatim from the design doc: nothing "happens" except an append to the annals; all state views, chronicles, and statistics are projections of it. Before this card the law was aspirational — the market's drift lived in a local variable, and process exit erased history. Now the sole state-mutation primitive is emission:

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

`emit` validates, appends, and returns the new event's id. Every event carries a uniform envelope — tick, kind, location, magnitude, visibility, payload, causes — plus two fields the annals stamps itself, both to remove trust from callers. **tick** comes from the universe clock (a system cannot lie about when), and **id** is the event's log position — the nth append is event n — so a system cannot lie about order. Position-as-identity is free, survives into card 115 as the SQLite rowid, and is deterministic by construction: emission order is systems-in-array-order (post 0001's loop), so a given seed numbers its events identically on every machine. Row 1 of seed 1893:

```lua
{
   id = 1,
   tick = 0,
   kind = "universe.genesis",
   location = "the-void",
   magnitude = 0,
   visibility = "public",
   payload = { seed = 1893 },
   causes = {},   -- the only empty one there will ever be
}
```

**Visibility** is a closed set — `public`, `regional`, `secret` — stamped honestly by every emitter (musters are `regional`; you'd have to be nearby to count levies) and read by nothing yet. It ships now because it cannot be added retroactively: the belief store (three cards out) will decide what each civilization *knows*, which requires who-could-know-this on every event since genesis. History written without visibility is history to be fabricated later.

## Causality as a required field

`causes` is **required**: every event must cite at least one prior event. Markets don't just move; a volcanic catastrophe that looks like divine dice to the civilization on the volcano will, in the log, cite plate mechanics or the mining charter that drilled too deep. The sole exception is `universe.genesis`, whose uniqueness the annals enforces — once, first, empty cause list, nothing else may open a log.

Validation is a single comparison carrying the philosophy: a cause must be an id already in the log, an integer in `[1, len]`. Edges point strictly backwards; an event cannot cite itself (its id doesn't exist until the append completes), the future, or a cycle. The annals is therefore a **DAG by construction**, threaded through an array — acyclicity by induction on append order, no cycle detection, no graph library. Every why-chain terminates at event 1; `--why` is fifteen lines walking `causes`. The placeholders use the field honestly: each drift cites the previous drift, each muster the previous muster, the first of each cites genesis — a random walk, narrated.

## Asymmetric strictness: strict writer, tolerant reader

The design decision that took longest: the two sides of the log get opposite strictness.

**Writes fail closed.** `emit` appends a fully valid event or raises — no warnings, no nil returns, no soft-failure path. Unregistered kind; missing or undeclared envelope field; float magnitude (outcomes are integers, law 1); visibility outside the set; payload field mistyped, missing, or uninvited; a cause that isn't a past id — all errors. Determinism makes this severity cheap: a malformed event either always occurs for a given seed or never does, so the crash fires on the first run, on the developer's machine, not years into a player's universe. A malformed event that reached the log would be corrupted history permanently — append-only means no do-overs.

**Reads fail open.** The chronicle owns a sentence per known kind and renders unknown kinds generically from the envelope every era shares:

```
tick  512 · sector:7 · diplomacy.betrayal, magnitude 8, secret — traitor=house-veyl, victim=house-omast
```

`diplomacy.betrayal` doesn't exist in today's vocabulary; that line is a test feeding the chronicle an event from an imaginary future. Forward compatibility here is scheduled, not hypothetical: universes cross engine versions and carry new-era events in front of old-era tools; the synopsis tool exists to compare universes from *different* versions; a seed report is someone else's universe file. A reader that crashes on unknown kinds obsoletes every old tool against every new log. Writes are forever; readers age. One spec keeps tolerance from covering for laziness: it walks the vocabulary and asserts *this* repo's chronicle has a real sentence for every kind — the fallback is for other eras' events only.

## The vocabulary is a public API

Permissible kinds are declared in one place, `src/sonder/vocabulary.lua`, as plain data — per kind, a doc line and an ordered list of typed payload fields:

```lua
["market.drift"] = {
   doc = "placeholder: the market moves for no modeled reason "
      .. "yet (card 118 replaces this)",
   payload = { { "drift", "integer" } },
},
```

Three payload constraints, all serving the same two audiences: fields are **integers and strings only** (no floats near outcomes, law 1; every value is one bind from a SQLite column, card 115); payloads are **flat** (rows aren't trees); declarations are an **ordered array**, so anything walking a payload — validation now, hashing and persistence later — iterates the declaration, never `pairs()`, whose unspecified order is banned near outcomes.

The module carries `schema_version = 1`, which buys nothing today — it's the hook card 115 writes into every universe's provenance table so two log files can announce whether they speak the same dialect. The kinds themselves are churn-freely placeholders (`market.drift` and `war.muster` won't survive to v0.1). What ships is the discipline: versioned schema, strict from day one, additions cheap, removals owing a documented migration.

## Projection, not subscription

"Event bus" conventionally means callbacks. We built the other thing, for law 4: the core is headless and must run bit-identically under zero or a thousand observers. Callback subscribers execute inside the sim's tick — a throwing viewer halts the universe; a state-writing viewer alters it; both violations are one incautious line away, and the law would hold only by politeness. Instead the annals array is the interface, and a chronicle is a cursor plus a render function:

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

Live-following is calling `lines()` again; full replay is a fresh chronicle over the same annals — same function, no special case. The spec suite pins law 4 as an executable claim: two universes, same seed, one rendered every tick and one never observed, must produce identical annals. Under projection that passes by construction — pinned so a future "optimization" can't unpin it.

The read side is guarded structurally too: `get()` returns a **copy**, never the log's own row, and `append` rebuilds caller tables field by field rather than aliasing them. A shared live row is a pen that rewrites history silently; a retained caller table lets later mutations reach back into the past. The log takes photographs and hands out photographs; nobody touches the negatives. Append-only by structure, not politeness.

## The CS underneath: event sourcing

The pattern is **event sourcing**, older than software: a bank stores every transaction since account opening, and the balance is a fold over them. When teller screen and ledger disagree, the ledger wins — record versus cache. Double-entry bookkeeping has run on this since the 1400s.

Software reinvents it because it keeps being right. Git stores an append-only DAG of commits linking to parents; the working tree is a projection (our events-citing-causes is the same picture with sequential integers for hashes). Kafka made the-log-is-the-system-of-record into infrastructure, and its consumer offsets are exactly the chronicle's cursor — offset *is* identity. Every RDBMS write hits a write-ahead log first; queried tables are formally a materialized view of it. The annals says this out loud instead of hiding it in the basement: the log is the truth, and every view is a **projection** — a pure function from a log prefix to a view. Same input, same view — hence a golden feed test that hardcodes four exact terminal lines for seed 1893 on every machine forever.

One odd consequence of stacking event sourcing on post 0001's determinism: the log is simultaneously the source of truth and, strictly, redundant — recomputable from eight bytes, since `(code version, seed)` regenerates every event bit for bit. Both hold at once. Relative to the generator, the log is a cache; relative to everything downstream — viewers, statistics, belief store, next card's database — it's the authoritative record and the only permitted read interface. It's stored because readers want random access, card 115 wants rows, and once interventions exist, apocrypha branches make the log the *only* complete account of what a meddling god actually did.

## What we got wrong

**A backwards sentence shipped in the design conversation.** Arguing for tolerant readers, Claude wrote "viewers of old logs will meet kinds younger than they are" — inverted, as Mike's confusion correctly flagged: old logs don't contain young kinds; viewers meet *logs* younger than themselves. The corrected sentence convinced in one read. The lesson is the working agreement: an explanation that confuses the decision's owner isn't context, it's a bug — in the explanation or the idea — and you must determine which.

**The first red test was wrong about the assertion library.** Second card running. luassert's `assert.has_error(fn, msg)` takes an *expected error message* as its second argument, while its cousins (`assert.is_true(cond, msg)`) take a failure label; the label habit leaked into the error assertion. The annals raised exactly the right error; the test demanded it match "0 accepted as a cause" and failed. A failing test is a claim meeting a mechanism; know which side the strings are on.

**Genesis has magnitude 0.** The largest event in any universe's history carries the minimum magnitude, because magnitude has no scale until the toy world (card 118) defines one, and 0 is an honest "unscaled." It reads absurd; it's recorded here as a public wart to fix or defend when the scale arrives.

## Next

The annals is an in-RAM array; close the terminal and the "permanent record" evaporates. Card 115 gives it durable form: SQLite, plus the provenance table — engine version, git commit, seed, config, schema version — that makes a universe file self-describing, so a log found on a beach can testify about its own origins.

Same seed, same history, line for line. Ask it why.
