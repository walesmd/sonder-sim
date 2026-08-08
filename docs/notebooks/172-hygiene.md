# Notebook — 172-hygiene

Card 172: *The hygiene sweep.* Overnight run, card 4 of 4
(2026-08-08). Scope discipline: the **seal-safe subset** only —
anything that would move a seal or change a world's public grammar
waits for Mike.

## Done (ten of the twelve)

- `Universe:beliefs(name)` — the viewer's door; five hand-rolled
  faction scans retired (main --believes, continent_spec ×2,
  office_spec ×2, space_spec).
- `--why` renders with the world's templates at last — the
  explain-flag was the one view still speaking in envelope
  fallback while TEMPLATES sat in scope four lines up.
- The WORLDS registry is the only world list: parse_args consults
  it (`if not WORLDS[value]`), and the comment that pointed at the
  wrong copy now points at the right one. A fourth world is one
  entry.
- Audit: `s.roads` → `s.road_ledger` (it was one letter from
  `s.road`, the map, while meaning the goods-in-transit book); the
  "legs never touch s's internals" comment replaced with an honest
  statement of practice (they do, for their own columns; the
  uniform folds go through lib).
- Archive: REQUIRED and the writer's row table are now guarded
  against each other (card 167's first-run failure, made
  impossible: an assert per REQUIRED key after the rows build).
- Declaration-level audit coverage specs for the continent and the
  office — space's audit_spec discipline copied to both, so a kind
  with no ledger classification fails at declaration, not in
  whichever run happens to emit it (continent.letter-lost needs an
  encounter to appear at all — exactly the kind the run-based
  check can miss).
- Continent's tally leg walks `s.legs.columns` instead of a
  four-string literal — a fifth column now gets claim-checked
  instead of silently under-audited.
- space_audit's `comma()` gains the sign branch its templates twin
  always had (a summary that can't print a deficit honestly is a
  summary waiting to lie); dedupe into a shared helper deferred —
  two copies in one world is below the extraction bar.
- The office rent comment corrected: the rent leaves through
  mara's tally, not amity's — in a repo where comments are
  published prose, that was a small lie with a long shelf life.
- The rng.courier shared-stream warning: already relocated into
  courier.lua's header at card 168; confirmed, closed.

## Deferred to Mike (the two that aren't hygiene)

- **Window discipline** (finding 15): resizing scan windows
  changes minds' inputs → seals move. Wants its own small card
  with a deliberate re-cut (or a ruling that space's two-civ
  literals are fine at two civs).
- **war.peace payload divergence** (finding 16): space says
  `price`, continent says `measure` — a public-API decision
  (shared `unit` field? explicit divergence note?) that belongs in
  a design conversation, likely alongside the war-content
  extraction question (F5, two worlds' near-identical battle
  systems).

Also out of scope, unchanged: constructor-convention drift and the
sorted-pairs idiom (finding 19) — judgment calls about API shape,
queued behind bigger fish.

188 specs (+2 coverage), 0 failures, three seals bit-identical.
Engine 0.2.5. Post 0022, *A System That Is Used*: Lehman's laws as
the CS (a used system must change; unless work is done, its
complexity increases — this card is the "unless work is done"
clause, scheduled); visual question asked, answered no.