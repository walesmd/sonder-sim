# Notebook — 166-the-beat

Card 166: *The beat: structural review and the documentation
overhaul.* Requested by Mike at card 151's close (2026-08-07), in
his words: take a little beat — a comprehensive review as a
Principal Engineer and Systems Architect identifying opportunities
to refactor and make the structure clearer; and as a Product
Manager and Architect, a review of how everything is documented —
including the local databases — updating all documentation with
diagrams, API-level documentation, rendered images, whatever
serves best.

## Why this card exists

Seven cards have landed since the v0.1 cut (120, 122, 153, 160,
161, 150, 151): the engine became a framework, gained the carriage
and the witness rule, and took its first deliberate history fork.
Nobody has looked at the whole since. Fast-moving increments leave
two kinds of debt this card hunts: structure that made sense
card-by-card but reads poorly as a whole, and documentation that
teaches each increment beautifully (the posts) while nothing
teaches the *system* — no architecture overview, no API reference,
and a universe-file schema documented only in the DDL that creates
it. The project is educational-first; the gap between "every card
has an essay" and "a newcomer can find the map" is exactly a
product manager's gap to close.

Deliverable split, agreed in the request itself:

- **Engineering half: identify, don't apply.** A findings report —
  refactor opportunities ranked, each with evidence and effort.
  Mike decides what gets applied and when (some findings likely
  become cards).
- **Documentation half: apply.** Architecture documentation with
  Mermaid diagrams (source canonical, per house doctrine), API
  documentation for the engine's public surface, the universe-file
  schema documented properly (tables, columns, triggers, a query
  cookbook), and staleness fixes found along the way.

## Session 1 (2026-08-07) — setup and method

Card 166 created and moved to Up Next; branch `166-the-beat` cut
from `b50925d` (card 151's merge, tag post/0016, engine 0.2.0).

Method: three parallel reviewers, then synthesis —

1. **Engine reviewer** — every module in src/sonder/ plus main.lua:
   structure, duplication, naming, seams the known future cards
   will cut through, comment drift.
2. **Worlds reviewer** — all twelve world files plus the spec
   fixture: rule-of-three extraction candidates, cross-world
   inconsistencies, interface leaks, vocabulary/template/audit
   drift.
3. **Docs auditor** — full inventory, the newcomer path (what a
   strong engineer cannot find), staleness against 0.2.0, and the
   exact universe.db schema from archive.lua's DDL to seed the
   schema reference.

Synthesis lands here as the findings report; the documentation
artifacts follow it in the same branch.

Planned documentation artifacts (to be confirmed against the
auditor's findings):

- `docs/architecture.md` — the system map: module diagram, the
  tick sequence (dawn losses → systems → courier → minds), the
  life of an event (emission → annals → carriage → belief →
  chronicle/audit/seal projections), each as inline Mermaid.
- `docs/reference/engine-api.md` — the public surface: Universe.new
  and its options (the world interface, ADR 0004 as it stands
  amended), add_system/add_faction contracts, the carriage row
  schema, belief store queries, the audit's legs contract.
- `docs/reference/universe-file.md` — the database a run writes:
  tables, columns, indexes, triggers, provenance rows, the
  append-only enforcement, and a query cookbook (expanding
  README's three examples).
- README gains a "start here" pointer into the above.

(As built, the reference pages went flat — `docs/architecture.md`,
`docs/api.md`, `docs/universe-file.md`, `docs/verification.md`,
`docs/README.md` — matching the glossary's placement; the
`reference/` subdirectory idea died in favor of discoverability.)

## The findings report — Principal Engineer half

Three reviewers (engine, worlds, docs), thirty findings, curated
and re-ranked as one body. **Nothing below was applied** — this
card identifies; Mike decides. Tiered by what should happen next.

### Tier 1 — findings that should become cards

1. **Extract the courier from the heartbeat** (`universe.lua`
   201-238). The whole courier — cursor, carriage query, encounter
   dice, three-way delivery branch — lives inline in step(), and
   degradation-blur (151's second half) and interpretation (152)
   must cut straight through it. A `sonder/courier.lua` gives them
   a file instead of the heartbeat. Medium effort; seals stand.
2. **Provenance cannot say which world wrote a file** (ADR 0004
   requires it; never implemented). No `world`/`world_version`
   rows; `config` is hardcoded `"{}"`; per-world vocabulary
   `schema_version`s collide (space 3, continent 2, office 1) so
   the number identifies nothing alone. Two worlds' files with one
   seed are confusable — the exact thing provenance exists to
   prevent. Small effort, day-one-requirement debt.
3. **The believed-books cluster is written three times** — the
   watermark fold (space 155-199, office 134-176, continent
   197-238), the catch_up cursor + framework ledger legs (×3), and
   the four road kinds copy-declared in three vocabularies (two of
   which predict this extraction in their own comments). The
   engine already folds the same grammar once on the truth side
   (audit framework_effects). Rule of three, cashed thrice over.
   Large effort, the biggest single clarity win available; caveat:
   space's tally/founding payload names differ (stock vs grain),
   so extraction takes a field-name map or a space seal re-cut.
4. **One place for road-day arithmetic; retire channel_speed as
   authoritative** — `(d + speed - 1) // speed` exists five times
   (three engine, two worlds); `u.channel_speed` survives as a
   retired concept still consumed by roads, audit, and two worlds,
   so a world declaring a row at speed ≠ channel_speed gets
   freight and news silently priced differently. A
   `Universe:days(from, to, tick)` (or Travel.days) consumed
   everywhere. Small-medium; seals stand.
5. **A vocabulary module** — the vocabulary is a four-way contract
   (annals, seal, archive, byteform) with four partial validations
   and different error voices; plus `Vocabulary.compose` /
   `road_kinds()` to end the copy-declaration (finding 3's
   vocabulary leg). Medium.

### Tier 2 — findings that ride already-scheduled cards

6. **The audit's in-flight explainer is field-shaped**
   (`audit.lua` ship/drift) — confirmed by two reviewers
   independently; already on card 163's docket. Must land before
   space migrates or drift certification lies.
7. **Loudness stamps diverge across worlds** (space one notch
   louder than office/continent for equivalent kinds: tallies
   local vs quiet, market.order loud). Cosmetic today; behavior
   the day space gets earshot. Rides 157/163 — the stamp
   re-judgment those cards already own — but the divergence table
   is now written down.
8. **The unmapped-adjacent leak lives on in space and office**
   (continent fixed it at 151 and documented why). Each fix moves
   that world's seal, so each rides its own migration card
   (163/164) deliberately.
9. **belief.lua's card-152 seam comment points nowhere** — the
   store is deliberately vocabulary-free while interpretation
   needs declared fields; decide at 152 whether the transform
   lives courier-side (before receive) or the store gains a
   vocabulary. Note only.

### Tier 3 — one hygiene sweep card (all small, ~a session)

10. `Universe:beliefs(name)` accessor — the factions-array scan is
    copy-pasted five times across main.lua and three spec files.
11. `--why` renders with the envelope fallback while TEMPLATES is
    in scope four lines up — the explain-flag is the one view
    speaking in `kind, magnitude N` instead of prose.
12. The WORLDS registry is written twice in main.lua and the
    comment points at the wrong copy.
13. Carriage validates ranges against a hardcoded loudness triple
    while every world declares its own loudness set.
14. Audit internals: `s.road` vs `s.roads` (unrelated, one letter
    apart); legs receive `lib` two different ways; every world's
    legs reach into `s.*` directly against the file's own stated
    discipline (fix: three accessors or an honest comment).
15. Window discipline: office/continent size scan windows to the
    crowd (a recorded lesson) but each still carries bare
    literals, and space never got the lesson at all.
16. `war.peace` payload diverges between space (`price`) and
    continent (`measure`) while the other five war kinds match —
    either a `unit` field or an explicit doc note.
17. Declaration-level audit-coverage specs exist only for space;
    office/continent test only what a run happened to emit
    (space's spec is copyable as-is).
18. Continent's column list is stated three times, one a literal
    inside the audit leg that would silently under-check a fifth
    column.
19. Constructor conventions drift (Archive.create vs .new;
    positional vs opts; two modules return plain tables); the
    sorted-pairs walk idiom has hit three occurrences.
20. Two same-world duplications: space's `comma()` exists twice
    (one handles negatives, one doesn't); an office comment
    attributes the rent to amity's tally when it leaves through
    mara's.
21. RNG doc note: the courier stream is the engine's one *shared*
    stream — adding or reordering factions shifts its draw
    sequence (correct, but nothing says so where 163/158 will
    trip on it).

### Two things the reviewers praised, kept for balance

The spec fixture world is clean — a genuinely minimal fourth
instance of the litmus with no drift. And no dead vocabulary
anywhere: every declared kind in all three worlds is emitted,
templated, and audit-classified (checked by hand, 17/12/17).

### Cross-cutting judgment

The engine's modules are small, deliberate, and heavily narrated —
the debt is not mess, it's *success debt*: three worlds exercised
seams faster than extractions could keep up (believed books,
catch_up, road grammar), and two concepts retired in doctrine
(field arithmetic, channel_speed) still have living consumers. The
single most valuable next engineering card is the believed-books
cluster (finding 3); the single most urgent is provenance
(finding 2), because every universe file written until then is
ambiguous on disk.

## The documentation half — applied

Built (living, flat under docs/ beside the glossary):
`architecture.md` (module map, tick sequence, life-of-an-event —
three Mermaid diagrams — plus the per-world status table),
`universe-file.md` (full DDL, the eight provenance rows and their
suppliers, checkpoint semantics, honest caveats, a seven-query
cookbook), `api.md` (Universe options, the decide contract, the
row schema with encounters, Belief/Travel/Roads/Annals/Seal/
Archive/Chronicle/Audit surfaces, RNG), `verification.md` (three
seals in one table, the verify-a-db procedure), `docs/README.md`
(the index + the pinned-vs-living doctrine).

Fixed: glossary (world de-duplicated — it violated its own
one-definition rule; provenance to eight rows with the owed world
row flagged; re-cut ledger generalized to three; channel speed
de-staled; audit entry brought past 153; determinism epoch added),
README (0.2.0 headline block; CLI finally teaches --world,
--believes, --as-of; story-so-far retitled), both eval charters
(+living "current state" sections), CLAUDE.md's docs-sweep
checklist (names the living pages; adds the simple-track diagram
rule).

Post 0017, *Success Debt*: front door is the unimplemented-ADR
finding; CS underneath is Cunningham's debt metaphor and Fowler's
quadrant, with Sonder's debts placed on it (the licensed-shortcut
ledger as deliberate-prudent; the review's catches as inadvertent
success debt). Does-this-need-a-visual: asked, yes — the quadrant
chart. What-we-got-wrong: the index that rotted for four sweeps
(symptom fixed at 150, system fixed now), the simple track's lost
diagrams, accepted-ADR ≠ implemented-ADR, and the glossary
breaking its own law. Both tracks written; the space charter was
deliberately NOT written retroactively — the destination's
founding document deserves Mike as co-author, so it stands as a
finding, not a fix.
