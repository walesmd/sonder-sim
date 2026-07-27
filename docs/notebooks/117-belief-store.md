# Notebook — 117-belief-store

Card 117: *Pass-through belief store — the seam.* Agents act on
beliefs, never truth. Each faction's decision code reads only its
belief store — structurally, not politely. v0.1 ships a pass-through
(everyone briefly omniscient); the seam exists so news can later
travel at ship speed, degrade in transit, and be culturally
interpreted. Ignorance stays free: no events received → no rows.
Done when: no decision code path can reach world state directly.

(The card says "ships with post 0003" — stale; the board predates
the lore shelf claiming that number. This ships as post 0006.)

## Session 1 (2026-07-26)

### What's already decided (inherited, not ours to relitigate)

- Law 3, verbatim: faction decision code reads only that faction's
  belief store — structurally, not politely: no reaching into world
  state. Ignorance is free: a civ that has received no events about
  something simply has no rows about it.
- The pass-through is deliberate scope: everyone briefly omniscient.
  **122** owns news at ship speed (delay, degradation, cultural
  interpretation); **118** owns real civilizations; visibility stays
  stamped-but-unconsumed for one more card (122 needs geography to
  mean anything by "regional").
- Post 0005's closing promise: the seam ships so that when news
  degrades in transit, *no decision code has to change* — it was
  reading beliefs all along.

### The design space (drafted; decisions marked, all awaiting Mike's
### interrogation)

**1. What makes it structural rather than polite?** The wrong
answers: metatable jails around the universe (bypassable — polite
with extra steps), code review discipline (politeness by
definition). The right answer is **capabilities**: you cannot reach
what you were never handed. Decision code is a function
`decide(beliefs, stream, tick)` — it receives a belief store, a
named RNG stream, and an integer. No universe, no annals, no emit.
It *returns* intents (event specs); the universe emits them. A
decision function that wants to read world state has no expression
in the language that gets there — not "please don't," but "there is
no door."

**2. The store can't reach truth either.** If the store held an
annals reference (a cursor, like the chronicle), decision code could
walk `beliefs.annals` — one field away from omniscience forever. So
the store is **push-based**: `Belief.new(owner)` starts empty;
`receive(event)` is called by the universe's courier with copies;
queries read only what was received. The store doesn't know the
annals exists. In v0.1 the courier is a pass-through — every new
event, delivered at the faction's turn, everyone briefly omniscient.
In 122 the courier grows delay, loss, and distortion — and the
store, the queries, and every decide() signature stay identical.
The seam is the interface between courier and store, and it ships
now precisely because it cannot be retrofitted onto decision code
written against world state.

**3. Universe grows factions.** `u:add_faction(name, decide)` next
to `add_system`. Each tick: systems run in registration order
(ambient physics — the market stays one), then factions in
registration order: courier catch-up (deliver everything new to the
store), then `decide(store, stream, tick)`, then the universe emits
the returned intents in array order. Everything arrays, nothing
`pairs()`. Names are unique across systems *and* factions — two
actors sharing a name would share a named RNG stream, which is a
law-1 footgun (two actors, coupled draws) dressed as a convenience.

**4. Intents, not emissions.** decide returns an array of event
specs (possibly empty; nil is an error — strictness at the seam).
The universe emits them through the same strict annals validation as
everything else, tick stamped centrally. Causes work because belief
rows carry event ids: a faction that believed drift #14 cites 14 —
**cause chains now flow through beliefs**, which is the lore thesis
in one mechanism: what you do is caused by what you know, and what
you know has provenance.

**5. Queries: small, copies, ignorance-shaped.** `latest(kind)` →
the newest believed event of that kind or nil; `recall(kind)` → all
of them, received order, possibly empty; `len()`. Copy-in at
receive, copy-out at query — the same photographs-not-negatives
discipline as the annals, so a scribbling faction can't corrupt its
own memory by accident. Ignorance is free by structure: rows index
by kind lazily; a kind never received has no table, and `latest`
of it is nil. (A faction *can* call `receive` on itself and inject
a false belief — that's self-deception, not reaching truth; law 3
doesn't forbid a faction lying to itself. Noted, allowed, shrugged.)

**6. The demo: the war office becomes the first believer.** The
market stays ambient physics; the war office converts from a blind
placeholder system to a faction that musters *what it believes the
market justifies*: reads its latest believed drift, musters
`2×|drift| + d(0,3)` levies, cites the believed drift event. Two
consequences worth the churn: the `--why` ladder crosses subsystems
for the first time (muster ← drift ← drift ← genesis, machine-made
lore), and ignorance has a visible shape — a war office that has
heard nothing musters nobody, not zero levies: no event at all.

**7. The golden master re-cuts — the policy's first exercise.**
History changes (musters now depend on beliefs), so seed 1893 × 500
ticks seals to a new constant. Post 0005 wrote the rule before we
needed it: re-cut deliberately, in its own commit, with the reason
in the message. Chronicle's golden feed is insulated (its fixture
universe is market-only); archive_spec counts survive (still two
events per tick in the toy).

### What we built

- `src/sonder/belief.lua` — the store. Push-based: `receive(event)`
  is the courier's door; `latest(kind)` / `recall(kind)` / `len()`
  are the queries; copies both directions; kinds index lazily so
  ignorance allocates nothing. No vocabulary on purpose (it must
  hold beliefs about kinds it has never heard of — viewer-grade
  tolerance, and the one sanctioned pairs() copy, with the
  order-independence argument in a comment). No annals, no universe,
  no emit — the store can only be *told* things.
- `src/sonder/universe.lua` — factions beside systems:
  `add_faction(name, decide)`; step() runs systems then factions in
  registration order; per faction, the pass-through courier delivers
  everything new as copies, then `decide(store, stream, tick)`
  returns intents the universe emits through the annals' strict
  door. Nil return is an error; empty is a decision. Names unique
  across systems and factions together (shared name = shared stream
  = coupled draws, a law-1 footgun).
- Toy + main.lua — the war office converted to the first believer:
  musters `2×|believed drift| + d(0,3)`, cites the believed drift.
  The feed now visibly correlates (drift +3 → 8 levies) and the
  `--why` ladder crosses subsystems: muster ← drift ← … ← genesis.
- `tests/belief_spec.lua` (9) — the store contract, including
  no-road-back structural checks and ignorance-has-no-rows.
- `tests/faction_spec.lua` (10) — the capability spec (decide gets
  exactly beliefs/stream/tick, none of them the universe), courier
  delivers genesis, intent ordering and central tick stamping,
  systems-then-factions order, nil-vs-empty, name collisions, bad
  intents dying at the annals door, muster-cites-drift integration,
  the fifty-ticks-of-silence ignorance spec, determinism.
- Golden re-cut: `27e3e0a8080e04f8` → `ae08cb9d02bd99c1`, and the
  spec now carries a **re-cut ledger** documenting both cuts with
  reasons. Suite: 98 green (79 + 19), twice in a row.

### What broke / what surprised us (post material)

- **Post 0005's debt of two bugs got paid in a currency we didn't
  expect.** The prediction: nothing broke last card, so this one
  owes two. The first full run failed exactly two specs — both the
  golden master, both *planned*: the net catching the deliberate
  history change, both universes agreeing on the new constant. The
  re-cut ledger is the receipt.
- **The muster distribution changed shape and nobody had to be
  told.** Old war office: uniform d(0,9). New: 2×|drift| + d(0,3) —
  correlated with the market, mean shifted. Chronicle sentence,
  vocabulary entry, archive schema: all untouched. The seam means
  behavior changes are payload-value changes.
- **Pass-through omniscience includes same-tick news** — the war
  office believes a drift the instant it happens (courier runs at
  the faction's turn, after systems). Card 122 will make "when did
  you learn it" a real question; the spec pinning same-tick
  citations (`cause.tick == e.tick`) is written to be *broken* by
  122, on purpose, as the visible moment news stops being instant.

### Proving "done"

- The capability spec: a spy faction records everything it is
  handed; assert it's exactly three values — a belief store (no
  `annals` field, no `emit`, not the universe object), a stream, an
  integer — and that mutating nothing it holds can reach the annals.
- Store contract: receive → latest/recall/len see it; copies both
  directions (mutate what you passed in, mutate what you got out,
  store unmoved); received order preserved; ignorance = nil / empty
  table for unheard kinds.
- Faction mechanics: factions run after systems in registration
  order; intents emitted in order with stamped ticks; empty intents
  legal; nil return raises; duplicate names (vs system or faction)
  raise.
- Integration: the war office's musters cite the drifts it believed;
  a war office in a marketless universe emits nothing ever
  (ignorance is free, executably).
- Determinism: same seed, factions and all → same seal, twice.
- The re-cut golden master: new constant, pinned, passes twice.
