# Truth & Belief

*Post 0006 · code pinned at tag `post/0006` · Lua 5.4 · this post's
universe: seed `1893` · ~10 min read*

---

```
$ ./lua src/main.lua --seed 1893 --ticks 5 --db none --why 11
universe 1893 — 5 ticks
tick    0 · the-void · a universe begins (seed 1893)
tick    1 · the-void · the market drifts -1
tick    1 · the-void · the war office musters 2 levies
tick    2 · the-void · the market drifts +3
tick    2 · the-void · the war office musters 8 levies
tick    3 · the-void · the market drifts -1
tick    3 · the-void · the war office musters 4 levies
tick    4 · the-void · the market drifts -1
tick    4 · the-void · the war office musters 3 levies
tick    5 · the-void · the market drifts +1
tick    5 · the-void · the war office musters 4 levies
fingerprint 2d5db2774831c4b3
seal 069373b6ad3d6b59

why event 11:
tick    5 · the-void · the war office musters 4 levies
  tick    5 · the-void · the market drifts +1
    tick    4 · the-void · the market drifts -1
      tick    3 · the-void · the market drifts -1
        tick    2 · the-void · the market drifts +3
          tick    1 · the-void · the market drifts -1
            tick    0 · the-void · a universe begins (seed 1893)
```

Read the feed the way you'd read a rumor mill: when the market
lurches +3, the war office panics and raises eight levies; when it
settles to ±1, the musters relax. For four posts those two have
shared a universe without exchanging a word — the market drifted at
random, the war office mustered at random, two random walks in
adjacent columns. Now one of them is *listening*. And the `--why`
ladder shows the moment the wiring changed: a muster's cause chain
used to walk back through other musters; now it steps from the
muster to a **market drift** — across subsystems — because the war
office cited the drift it acted on. What you do is caused by what
you know, and what you know has provenance.

The load-bearing word is *believes*. The war office did not read the
market. It read its own **belief store**, which is the only thing
its decision code can read, because it's the only thing its decision
code is handed. That is law 3 — agents act on beliefs, never truth —
and this card is the seam where the law stops being a sentence in
CLAUDE.md and becomes the shape of a function signature.

## Structurally, not politely

The law's own phrasing sets the bar: decision code reads only its
faction's belief store — *structurally, not politely*. We've leaned
on that distinction twice before (the annals hands out copies; the
database aborts UPDATEs), and each time the trick is the same: make
the violation inexpressible instead of forbidden.

The polite version of law 3 is a code-review rule: "faction code
shouldn't touch `universe.annals`." The structural version is a
question: touch it *with what*? A faction in Sonder is registered as

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

Look at the argument list, because the argument list is the entire
security model: a belief store, a named RNG stream, an integer.
No universe. No annals. No `emit`. The decision function *returns*
its intents — event specs — and the universe emits them on the
faction's behalf, through the same strict validation as everything
else. Code that is never handed the world has no expression that
reaches the world. Systems, by contrast, still run as
`fn(universe, stream, tick)` — a system is ambient physics, the part
of reality that just happens, and physics is entitled to the truth.
The market stays a system; the war office stopped being one the
moment it started asking what it *knows* before acting. That's the
test for every actor to come: could this thing ever be *wrong* about
something? Then it's a faction, because being wrong requires a gap
between belief and truth, and only the belief store can hold that
gap.

## The store can't cheat either

Handing decision code a restricted object buys nothing if the object
leaks. If the belief store followed the annals with a cursor — the
way the chronicle and the archive do — then `beliefs.annals` would
be sitting right there, one field access from omniscience, and law 3
would be politeness wearing a mask.

So the store is **push-based**, and the difference is load-bearing.
`Belief.new(owner)` starts empty. Events arrive only when the
universe's **courier** delivers them — `store:receive(event)`,
copies in — and queries (`latest`, `recall`, `len`) read only what
has arrived, copies out. The store holds no reference to the annals,
the universe, or anything else with a pulse. It cannot check the
truth because it has no idea where the truth lives. It knows exactly
what it has been told, which is the epistemic situation of every
civilization that will ever live in this universe.

Two properties fall out for free:

**Ignorance costs nothing.** Beliefs index by kind, lazily. A
faction that has received no events about something has no rows
about it — not a placeholder, not an "unknown", literally no table.
The spec makes it executable: a war office in a universe with no
market runs fifty ticks and emits *nothing* — not zero-levy musters,
no events at all. When the galaxy has ten thousand events a tick and
a rim civilization has heard of forty of them, that rim civilization
pays memory for forty.

**The courier is the seam.** Today it's a pass-through — at each
faction's turn, deliver everything new, immediately; everyone is
briefly omniscient, and the war office believes a drift the same
tick it happens. Card 122 replaces that loop with distance, delay,
degradation, and cultural interpretation. What changes downstream of
the store when news starts taking years to cross the void? Nothing.
Not the store, not the queries, not one decision function's
signature — they were reading beliefs all along. That is why this
card exists now, four cards before anyone needs it: the seam cannot
be retrofitted onto decision code written against world state,
because every such function would have baked "I can see everything,
instantly" into its logic.

## The CS underneath: capabilities, and seams

The security model this card leans on has a name: **capability-based
security**, the object-capability discipline associated with Mark
Miller's E language and, further back, with 1970s capability
machines. The idea inverts the usual question. Access-control
systems ask "who are you, and does policy allow this?" — then
enforce it with checks at every door (and politeness between the
checks). Capability systems ask "what do you *hold*?" Authority is
a reference; if you were never handed the reference, the resource
does not exist in your world. There is no check to forget, because
there is no door to guard. Lua is a good host for this discipline:
no globals-by-default reaching into the sim, closures that close
over exactly what they're given, and a function's arguments as its
entire visible universe. `decide(beliefs, stream, tick)` is a
capability list. The **principle of least authority** — give code
the minimum it needs — is the same idea worn as a design habit, and
it's why the faction gets a *named* stream rather than the RNG: the
war office can spend its own luck, and nobody else's.

The other name worth knowing is Michael Feathers':

> A **seam** is a place where you can alter behavior in your program
> without editing in that place.

That's from *Working Effectively with Legacy Code*, describing how
to get untestable code under test — but it's exactly what the
courier is. When card 122 wants news to travel at ship speed, it
edits the courier: one loop, in universe.lua. It does not edit the
belief store, the queries, or any faction ever written. The place
where behavior changes and the place where code changes have been
deliberately pulled apart. Interfaces age well when they're cut at
the point of future variation, and "how does knowledge reach an
agent" is *the* point of variation in a simulation whose thesis is
that knowledge is partial, late, and bent.

One more thing the store quietly is: a **per-agent projection**. The
chronicle projects the log into sentences; the archive projects it
into rows; a belief store projects it into *one faction's
knowledge*. With a pass-through courier, its arrival order matches
log order and the projection is boringly faithful. The day couriers
slow down, each store's arrival order becomes that faction's private
chronology — two civilizations will hold the same events in
different orders, disagree about what caused what, and both be
internally consistent. The mechanism shipped today; only the delay
is missing.

## What we got wrong

**Post 0005's debt was paid in a currency we didn't expect.** Last
card nothing broke, and we published a prediction: the next card
owes two bugs. The first full spec run of this card failed exactly
two specs — both the golden master, both *deliberate*: the net
catching the war office's history legitimately changing out from
under seed 1893. Nothing was wrong; everything was different. We're
counting the prophecy as technically fulfilled and materially
dodged, and the suspicion stands for card 118.

**The re-cut policy met reality and bent.** Post 0005 said a golden
constant gets re-cut "in its own commit." Then we tried to do it and
found the trap: a standalone re-cut commit means either the
implementation commit ships with a red suite (poison for bisecting)
or the constant changes before the behavior does (a lie). Resolved:
the re-cut rides the history-changing commit, in its own
loudly-labeled paragraph, and `seal_spec.lua` now carries a **re-cut
ledger** — every constant this project has ever pinned, with the
reason it moved. The policy's spirit was "never casually"; the
letter needed one edit.

**We had two canons and hadn't noticed.** This card coined *faction*
and *courier* and had nowhere durable to define them — which
prompted a glossary (`docs/glossary.md`, every term this repo leans
on, one definition each, now a docs-sweep obligation). Writing it
surfaced a collision our own vocabulary rule should have caught:
*canon* the untouched timeline (four-laws vocabulary, the good kind
of sacred) and `canon.lua` the canonical-byte-form module (card 116)
were unrelated meanings sharing a name. The module lost the coin
flip: it's `byteform.lua` now, so *canon* means exactly one thing.
Post 0005's prose keeps the old name forever at its tag — posts are
era artifacts, and the glossary carries the "formerly" note that
bridges them.

**One spec is written to be broken, on purpose.** The integration
spec pins that a muster's cited drift has the *same tick* as the
muster — pass-through news is instant, and the spec says so out
loud. Card 122 will break it the moment news learns to travel, and
that's the plan: the red spec will be the visible, executable moment
this universe stops being omniscient. A test you intend to break is
a strange artifact, but it's the honest way to mark an assumption
you know is temporary.

## Next

The seam is ready and the placeholders are living on borrowed time.
Card 118 is the toy world: two civilizations with opposed
proclivities — one mercantile, one martial — one commodity, one
market with naive price adjustment, and the placeholder vocabulary
churned away (the golden ledger will grow an entry; that's what it's
for). Two factions, two belief stores, and the first universe where
the annals records somebody *trading*.

Same seed, same beliefs, same history. The war office read the news,
and now you can ask it which article.
