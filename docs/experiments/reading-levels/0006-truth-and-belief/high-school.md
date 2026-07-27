# Truth & Belief

*Reading-level experiment · target: high school · rewritten from `docs/posts/0006-truth-and-belief.md` · original untouched*

---

Sonder is a deterministic universe simulator written in Lua: give it a seed (a starting number for its random number generators) and it produces the exact same history every time, tick by tick. Everything that happens is an event appended to a log called the **annals**, and the **chronicle** turns that log into readable sentences. Here's this post's universe, seed 1893, run for 5 ticks:

```
$ ./lua src/main.lua --seed 1893 --ticks 5 --db none --why 11
universe 1893 — 5 ticks
tick    1 · the-void · the market drifts -1
tick    1 · the-void · the war office musters 2 levies
tick    2 · the-void · the market drifts +3
tick    2 · the-void · the war office musters 8 levies
...
why event 11:
tick    5 · the-void · the war office musters 4 levies
  tick    5 · the-void · the market drifts +1
    tick    4 · the-void · the market drifts -1
      ...
```

Read it like a rumor mill: when the market lurches +3, the war office panics and musters eight levies; when it settles to ±1, the musters relax. For four posts these two shared a universe without exchanging a word — two independent random walks. Now one of them is *listening*. And the `--why` cause chain shows the wiring change: a muster's causes used to walk back through other musters; now the chain steps from the muster to a **market drift**, across subsystems, because the war office cited the news it acted on.

The load-bearing word is *believes*. The war office did not read the market. It read its own **belief store** — its private record of what it has been told. That's the project's law 3: *agents act on beliefs, never truth*. This card is where that law stops being a sentence in a design doc and becomes the shape of a function signature.

## Structurally, not politely

The polite version of law 3 is a code-review rule: "faction code shouldn't touch the world state." The structural version is a question: touch it *with what*? A **faction** (a decision-making actor, as opposed to background physics) is registered like this:

```lua
u:add_faction("war", function(beliefs, stream, tick)
   local drift = beliefs:latest("market.drift")
   if not drift then
      return {} -- ignorance is free: nothing heard, nothing mustered
   end
   local muster = drift.magnitude * 2 + stream:int(0, 3)
   return { {
      kind = "war.muster",
      location = "the-void",
      magnitude = muster,
      visibility = "regional",
      payload = { muster = muster },
      causes = { drift.id },
   } }
end)
```

The argument list is the entire security model: a belief store, a named random-number stream, and an integer tick. No universe object. No annals. No way to emit events directly. The function *returns* its intents — descriptions of events it wants to happen — and the universe emits them on the faction's behalf, through the same strict validation as everything else. Code that is never handed the world has no expression that reaches the world.

Systems, by contrast, still run as `fn(universe, stream, tick)`. A system is ambient physics — the part of reality that just happens — and physics is entitled to the truth. The market stays a system; the war office stopped being one the moment it started asking what it *knows* before acting. That's the test for every future actor: could this thing ever be *wrong* about something? Then it's a faction, because being wrong requires a gap between belief and truth, and only the belief store can hold that gap.

## The store can't cheat either

A restricted object buys nothing if it leaks. If the belief store read the annals through a cursor (the way the chronicle does), then omniscience would be one field access away. So the store is **push-based**: `Belief.new(owner)` starts empty; events arrive only when the universe's **courier** delivers them via `store:receive(event)` (copies in); and queries (`latest`, `recall`, `len`) read only what has arrived (copies out). The store holds no reference to the annals or the universe. It cannot check the truth because it has no idea where the truth lives.

Two properties fall out for free:

**Ignorance costs nothing.** Beliefs are indexed by kind, lazily. A faction that has received no events about something has *no rows* about it — not a placeholder, literally no table. One test makes this executable: a war office in a universe with no market runs fifty ticks and emits nothing at all. When the galaxy produces ten thousand events a tick and a rim civilization has heard of forty of them, it pays memory for forty.

**The courier is the seam.** Today the courier is a pass-through: at each faction's turn, deliver everything new immediately, so everyone is briefly omniscient. Card 122 will replace that loop with distance, delay, degradation, and cultural interpretation. What changes downstream of the store when news starts taking years? Nothing — not the store, not the queries, not one decision function's signature. That's why this card ships now, four cards early: you can't retrofit this seam onto decision code written against world state, because every such function would have baked "I can see everything, instantly" into its logic.

## The CS underneath

The security model has a name: **capability-based security** (an idea associated with Mark Miller's E language and, further back, 1970s capability machines). Traditional access control asks "who are you, and does policy allow this?" and enforces it with checks at every door. Capability systems ask "what do you *hold*?" Authority *is* the reference: if you were never handed it, the resource doesn't exist in your world. There's no check to forget because there's no door to guard. `decide(beliefs, stream, tick)` is a capability list. The related **principle of least authority** — give code the minimum it needs — is why the faction gets a *named* RNG stream rather than the whole RNG: the war office can spend its own luck, and nobody else's.

The second idea is Michael Feathers' **seam**, from *Working Effectively with Legacy Code*: "a place where you can alter behavior in your program without editing in that place." That's exactly the courier. When card 122 makes news travel at ship speed, it edits one loop in `universe.lua` — never the store, the queries, or any faction. "How does knowledge reach an agent" is *the* point of future variation here, so that's where the interface was cut.

One more: the store is a **per-agent projection** of the event log. The chronicle projects the log into sentences; the archive projects it into database rows; a belief store projects it into one faction's knowledge. Once couriers slow down, each store's arrival order becomes that faction's private chronology — two civilizations will hold the same events in different orders, disagree about what caused what, and both be internally consistent.

## What we got wrong

**Post 0005's predicted debt got paid in a strange currency.** We had predicted this card would owe two bugs. The first full test run failed exactly two specs — both the golden master (the same-seed, same-hash replay test), both *deliberate*: the net correctly catching seed 1893's history legitimately changing. Nothing was wrong; everything was different. Prophecy technically fulfilled, materially dodged; the suspicion rolls forward to card 118.

**The re-cut policy bent on contact with reality.** Post 0005 said a golden constant gets re-cut "in its own commit." In practice that means either the implementation commit ships with failing tests (poison for `git bisect`) or the constant changes before the behavior does (a lie). Resolved: the re-cut rides the history-changing commit, loudly labeled, and `seal_spec.lua` now carries a **re-cut ledger** — every constant ever pinned, with the reason it moved.

**We had two canons and hadn't noticed.** Coining *faction* and *courier* forced a glossary (`docs/glossary.md`), and writing it exposed a name collision: *canon* the untouched timeline versus `canon.lua`, the canonical-byte-form module. The module lost the coin flip and is now `byteform.lua`; post 0005's prose keeps the old name forever at its tag, and the glossary carries the "formerly" note.

**One spec is written to be broken, on purpose.** An integration test pins that a muster's cited drift has the *same tick* as the muster — pass-through news is instant, and the test says so. Card 122 will break it the moment news learns to travel, and that's the plan: the red test will be the visible, executable moment this universe stops being omniscient.

## Next

Card 118 is the toy world: two civilizations with opposed proclivities — one mercantile, one martial — one commodity, one market with naive price adjustment, and the placeholder vocabulary churned away. Two factions, two belief stores, and the first universe where the annals records somebody *trading*.

Same seed, same beliefs, same history. The war office read the news, and now you can ask it which article.
