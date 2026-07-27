# Truth & Belief

*Reading-level experiment · target: graduate CS · rewritten from `docs/posts/0006-truth-and-belief.md` · original untouched*

---

Universe seed 1893, five ticks: the market drifts (-1, +3, -1, -1, +1) and the war office musters (2, 8, 4, 3, 4) levies — the muster magnitudes now track the drift magnitudes. For four posts these were two independent random walks on named RNG streams. This card couples them, and `--why 11` shows where: a muster's cause chain, which previously walked back through prior musters, now steps *across subsystems* to the market drift the war office cited when it acted. Fingerprint `2d5db2774831c4b3`, seal `069373b6ad3d6b59`.

The coupling is epistemic, not direct. The war office never reads the market; it reads its own **belief store**, the only data source its decision code is handed. This is law 3 — agents act on beliefs, never truth — reified as a function signature rather than a review guideline.

## Structurally, not politely

Law 3's phrasing ("structurally, not politely") demands that violations be inexpressible, not merely forbidden — the same move as the annals handing out copies and the database aborting UPDATEs by trigger. A faction registers as:

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

The argument list *is* the security model: a belief store, a named RNG stream, an integer. No universe reference, no annals, no `emit`. The function returns **intents** — event specs — which the universe emits on the faction's behalf through the same strict validation as any event. Code never handed the world has no expression that reaches the world.

Systems retain `fn(universe, stream, tick)`: a system is ambient physics and is entitled to truth. The classification test for future actors: can this thing be *wrong*? Being wrong requires a belief/truth gap, and only a belief store can hold that gap — so it's a faction. The market stays a system; the war office ceased to be one when it started consulting what it knows.

## The store can't cheat either

A restricted parameter list buys nothing if the object leaks ambient authority. Had the belief store followed the annals with a cursor (as the chronicle and archive projections do), `beliefs.annals` would sit one field access from omniscience. So delivery is **push-based**, and that choice is load-bearing: `Belief.new(owner)` starts empty; the universe's **courier** delivers with `store:receive(event)` (copies in); queries (`latest`, `recall`, `len`) read only what has arrived (copies out). The store holds no reference to the annals, the universe, or anything with a pulse — it cannot verify truth because it has no path to it, which is precisely the epistemic situation of every civilization in this universe.

Two properties fall out:

**Ignorance is free.** Beliefs index by kind, lazily; a faction with no received events about a topic has no rows — no placeholder, no table. Executable in the spec: a war office in a marketless universe runs fifty ticks and emits nothing. At galactic scale — ten thousand events per tick — a rim civilization that has heard of forty pays memory for forty.

**The courier is the seam.** Today it is a pass-through: at each faction's turn, deliver everything new immediately; everyone is briefly omniscient, and a muster's cited drift shares its tick. Card 122 replaces that one loop with distance, delay, degradation, and cultural interpretation. Downstream of the store, nothing changes — not the queries, not one decision function's signature; they were reading beliefs all along. This is why the card ships four cards before it's needed: the seam cannot be retrofitted onto decision code written against world state, because such code bakes "I see everything, instantly" into its logic.

## The CS underneath

The security model is **capability-based security** — the object-capability discipline associated with Mark Miller's E language and, earlier, 1970s capability machines. ACL-style access control asks "who are you, and does policy allow this?", enforced by checks at every door and politeness between them. Capability systems ask "what do you hold?": authority is a reference, an unheld reference is a nonexistent resource, and there is no check to forget because there is no door. Lua hosts the discipline well: no ambient globals reaching into the sim, closures over exactly what they're given, argument lists as the visible universe. `decide(beliefs, stream, tick)` is a capability list. The **principle of least authority** is the same idea as design habit — hence a *named* stream rather than the RNG: the war office spends its own luck, nobody else's.

The second mechanism is Feathers' **seam** (*Working Effectively with Legacy Code*): "a place where you can alter behavior in your program without editing in that place." Card 122 edits the courier — one loop in universe.lua — and touches neither the store, the queries, nor any faction ever written. Interfaces age well when cut at the point of future variation, and "how does knowledge reach an agent" is *the* variation point in a simulation whose thesis is that knowledge is partial, late, and bent.

The store is also a **per-agent projection** of the event log, alongside the chronicle (log → sentences) and the archive (log → rows): log → one faction's knowledge. Under the pass-through courier, arrival order equals log order and the projection is trivially faithful. Under delayed couriers, each store's arrival order becomes a private chronology: two civilizations holding the same events in different orders, disagreeing about causality, each internally consistent. The mechanism shipped now; only the delay is missing.

## What we got wrong

**Post 0005's predicted debt was paid in an unexpected currency.** We published a prediction that this card owed two bugs. The first full spec run failed exactly two specs — both golden master, both *deliberate*: the net correctly catching seed 1893's history legitimately changing. Prophecy technically fulfilled, materially dodged; the suspicion rolls to card 118.

**The re-cut policy bent on contact.** Post 0005 mandated re-cutting golden constants "in their own commit." In practice: a standalone re-cut commit means either the implementation commit ships red (poison for bisecting) or the constant moves before the behavior does (a lie). Resolution: the re-cut rides the history-changing commit in a loudly-labeled paragraph, and `seal_spec.lua` now carries a **re-cut ledger** — every constant ever pinned, with the reason it moved. Spirit ("never casually") intact; letter amended.

**Two canons, unnoticed.** Coining *faction* and *courier* forced a glossary (`docs/glossary.md`, one definition per term, now a docs-sweep obligation). Writing it surfaced a collision: *canon* the untouched timeline versus `canon.lua`, the canonical-byte-form module (card 116). The module lost: it is `byteform.lua` now. Post 0005's prose keeps the old name forever at its tag — posts are era artifacts; the glossary carries the "formerly" bridge.

**One spec is written to be broken.** The integration spec pins that a cited drift shares the muster's tick — pass-through news is instant, stated executably. Card 122 breaks it by design: the red spec will be the visible moment the universe stops being omniscient. A test you intend to break is a strange artifact, but it is the honest way to mark an assumption known to be temporary.

## Next

Card 118: the toy world — two civilizations with opposed proclivities (mercantile vs martial), one commodity, one market with naive price adjustment, placeholder vocabulary churned away (the golden ledger grows an entry; that's what it's for). Two factions, two belief stores, and the first universe whose annals record somebody *trading*.

Same seed, same beliefs, same history. The war office read the news, and now you can ask it which article.
