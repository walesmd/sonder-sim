# Notebook — 169-books

Card 169: *The believed-books extraction: one fold, three worlds.*
The biggest clarity win on the card-166 findings menu, saved for a
monitored session because it carries a genuine design fork.

## Why this card exists

Every world hand-writes the same bookkeeping fold twice over:

- **Belief-side** (`believed_books`): anchor on my last self-report,
  then absorb every road leg I've learned since — written three
  times (space 155-199, office 134-176, continent 197-238), with
  the four framework legs (cargo/payment shipped/delivered)
  byte-equivalent in all three.
- **Truth-side** (`catch_up`): the incremental annals cursor with
  the same four framework ledger legs — also written three times.

The engine already states this knowledge once more, in the audit's
framework_effects. One piece of knowledge — what the road grammar
does to a set of books — in seven homes. Rule of three, cashed
twice over; two vocabularies predicted the extraction's sibling
(card 171 paid that one).

## Session 1 (2026-08-10) — setup and the fork

Merged first: the overnight chain (cards 168/170/171/172) landed
on main — with a repair: GitHub auto-closes stacked PRs when their
base branch is deleted, so #24/#26 closed unmerged and #25 merged
into a branch; fixed with local --no-ff merges per card, tags
re-pinned at true commits (post/0019–0022 verified by rev-list),
closed PRs annotated. Lesson memorized: stacked PRs merge
bottom-up without --delete-branch, and never pipe a mutation
through tail under set -e.

Branch `169-books` cut from `2fc7733` (engine 0.2.5, 188 specs).

**The fork, confirmed in code.** Office and continent fold with
uniform names: the column, the tally payload field, and the
founding payload field are all "grain"-style identical, so their
folds can walk a column list. Space cannot: its founding says
`grain` but its daily tally says `stock` — same quantity, two
field names, neither matching usage in the other anchor kind. Any
shared fold must bridge that, and there are exactly two bridges:

- **(A) A field-name map, defaulting to identity.** The extracted
  fold takes an optional per-anchor map; office and continent
  declare nothing, space declares `{ grain = "stock" }` on its
  tally anchor. Seals stand — the extraction is provable
  bit-identical, the card-153 pattern. The quirk stays, but as one
  line of declared data in the world that owns it.
- **(B) Rename space's tally field `stock` → `grain`.** Uniformity;
  the simpler fold. But the vocabulary is a versioned public API —
  a field rename is a breaking change (space v3 → v4, migration
  documented per the day-one requirements), byteform bytes move,
  and the golden master re-cuts → the first 0.3.0.

*Recommendation:* **A now — and if uniformity is wanted, bundle
the rename into card 163**, which will re-cut space's seal anyway
(real mechanisms, the Fleet). Never burn a deliberate history fork
on a rename when a scheduled fork can carry it free; the
identity-defaulting map makes the later rename a two-line change.

Scope note: the card covers both halves (belief-side fold and
truth-side catch_up ledger) — they are the same knowledge stated
from two sides — sequenced separately, each proven by unmoved
seals; if the truth-side balloons it splits into a follow-on card.

## Session 2 (2026-08-11) — the question restated in plain words

Mike didn't recognize the question, and the confusion was
diagnostic: he was picturing the *shipping manifest* (when it
left, when it arrives — which exists, as the cargo.*/payment.*
road events and the audit's road ledger) when the card is about
the *balance sheet* — the believed_books fold that reconstructs
"what do I hold this morning" from an anchor self-report plus
every road leg learned since. Two ledger-shaped things; the card
touches only the second. Worth carrying into the post: the fold
is not a record of movement, it is the recovery of a balance that
law 2 forbids us from storing.

Two things came out of the plain-words pass:

- **Mike independently reinvented the continent's design.** Asked
  what he'd expect, he described a generic integer quantity plus a
  what-is-it descriptor — which is exactly `COLUMNS = { grain,
  iron, salt, cents }` plus the cargo `commodity` field. Space and
  office are single-commodity worlds where the field name *is* the
  commodity. This strengthens A-now: space's real future change is
  going multi-commodity like the continent (re-cutting the seal
  for real reasons), not respelling a temporary single-commodity
  field. Burning a 0.3.0 on the spelling would pay twice.
- **The office has its own anchor wrinkle, undersold in session
  1.** `office.hired` carries no `work` field at all — the fold
  starts work at 0 from the hiring anchor (office.lua:142). So
  "office and continent are uniform" was only true for `cents`;
  the extracted fold needs a notion of *column absent on this
  anchor → declared default*, carried by the same per-anchor
  declaration as space's field-name map. One mechanism, two
  quirks: space renames a column, the office omits one.

The fork decision (A vs B) is still open and blocks
implementation.
> Mike: Let's go with option A.

## Session 3 (2026-08-29) — implementation

Decision recorded: **A** — the extracted fold takes a per-anchor
declaration (field-name map defaulting to identity, plus declared
defaults for absent columns); space declares `{ grain = "stock" }`
on its tally anchor, the office declares `work = 0` on its hiring
anchor, the continent declares nothing. Seals must not move; the
rename, if ever wanted, rides card 163's scheduled re-cut.

**The design, before code.** One module, `sonder/books.lua`, two
entry points — the same knowledge from its two sides:

- `Books.believed(beliefs, decl, owner)` — the belief-side fold.
  Engine owns the discipline: an ordered anchor list (first match
  wins; each anchor carries its own window and matches `by =
  "seat"` — location against the owner's seat — or `by = "name"` —
  payload.name against the owner; those are the only two shapes in
  all six anchors), the `learned > absorbed` watermark (card 122's
  lesson, id watermarks drop late news), and the four framework
  road legs keyed by the world's `commodities` map and `money`
  column — the same resolution the audit's framework legs use.
  World declares: columns, default window, commodities, money,
  anchors (with `fields` map and `defaults`), and its own legs as
  an ordered array `{ kind, apply(b, e, owner) }` — the engine
  keeps the watermark, the world keeps the meaning (owner-match
  included: `target == owner.name` is world knowledge).
  Returns `(books, since)`; worlds keep one-line adapters for
  their historical return shapes.
- `Books.ledger(u, decl)` — the truth-side cursor object: `.rows`,
  `:enroll(name, opening)` (zero-fill over declared columns, the
  audit's enroll rule — this is what makes the office's
  `work = 0` fall out for free), `:catch_up()` walking the annals
  with framework-first dispatch (the audit's pattern exactly:
  engine books the road grammar, `decl.effects[kind]` books world
  kinds, unknown kinds skip silently as every elseif chain already
  did). Shipped legs call `decl.roads:schedule(e)` — the mail
  keeps arriving at dawn.

Conscious choices, on the record:
- `commodities`/`money` now appear in the world file AND the
  world's audit legs. Different consumers, different shapes (audit
  columns carry negative-balance phrasings); unifying would couple
  the audit legs file to decision code. Declined until a fourth
  consumer appears.
- The engine's framework legs assert on a commodity the map can't
  book, where old space/office code would have silently subtracted
  grain (they never consulted the commodity). No well-formed
  history reaches either path; the assert is the honest voice.
- Bit-identity argument: the fold draws no RNG and emits nothing;
  all legs are commutative integer sums over disjoint events;
  framework-first dispatch mirrors each world's elseif order. Same
  inputs, same integers out — the seals must not notice.

**Implementation record (same session).** Sequenced as planned,
each half proven before the next began:

1. `src/sonder/books.lua` written: `Books.believed` (the fold) and
   `Books.ledger` (the cursor object: `.rows`, `:enroll`,
   `:catch_up`). The card-122 watermark commentary moved into the
   module header — it is fold discipline, not world lore; the
   card-153 self-knowledge dividend stayed in space.lua, whose
   voice it is written in.
2. Belief side migrated in all three worlds — helpers
   (`my_latest_tally`, `my_founding`/`my_hiring`) and fold bodies
   replaced by `BELIEVED` declarations plus one-line adapters
   keeping each world's historical return shape. Suite: 188/188,
   all three golden seals in place.
3. Truth side migrated — `cursor`/`catch_up` elseif chains replaced
   by `Books.ledger` declarations; world kinds became `effects`
   entries closing over world state (homes, seats, calendars,
   pitches) exactly as before; `local ledger = books.rows` keeps
   every downstream system (exchange, battle, clients) reading the
   same table. Suite: 188/188 again.
4. Beyond the golden seeds: a throwaway harness ran **10 seeds ×
   3 worlds (150–300 ticks each) on HEAD and on the working tree —
   30 runs, byte-identical seals AND byte-identical audit reports**
   (0 violations, 0 mismatches, 0 unexplained everywhere). The
   card-153 proof pattern, widened.

Diff shape: worlds net −68 lines (216+/284−) and now declare;
the engine gains one module. The truth side did not balloon — no
follow-on card needed; card 169 covers both halves as chartered.

Still owed: Mike's interrogation of the code, the post, the docs
sweep (architecture.md's module list and api.md gain books.lua —
the fold is now public surface a world relies on; glossary check
on any new reader-facing term), and the adversarial review's
findings (running as of this entry).

**The adversarial review** (37 agents: three lenses, two skeptics
per finding; 16 confirmed, 1 contested, 0 refuted). The
determinism sweep came back clean and is on the record: no
pairs(), no floats, no clock, no RNG, fold order preserved, every
apply a pure commutative sum. The confirmed findings split two
ways.

*Fixed in the draft same session* (defects in the new code, no
design content): the module header misattributed the road grammar
(roads.lua emits only the arrivals; the grammar is
vocabulary.lua's) and implied the commodities map is shared with
the audit when it is a copy; the office revenue comment called
revenue "the one open door" when the office's money has an
outbound mouth too (every tally's spent column — the world's own
audit file says so); the no-anchor error message hardcoded
"tally/founding" in a module whose header forbids it knowing world
kinds (now it names the declared anchor kinds); each world stated
its columns/commodities/money twice (BELIEVED + ledger decl) — now
one shared local trio per world, so the in-file copies are gone
(the audit's copy remains the chartered exception). Engine bumped
0.2.5 → 0.2.6 (rockspec renamed): engine changed, every seal
stands — the patch-bump convention. 188/188 after all fixes.

*For Mike — the review's design forks, none applied:*

1. **Framework-kind collision is silent and asymmetric** (the top
   finding, 4 confirming votes). A world declaring a truth-side
   effect for one of the four road kinds is silently shadowed
   (framework-first dispatch); a belief-side leg with a road kind
   *double-books* (framework loop AND the leg both run). The
   vocabulary explicitly permits worlds to re-declare road kinds,
   so the trap is chartered-reachable — card 163 is the obvious
   first victim. Proposed: disjointness asserts so the collision
   is loud at declaration. (Nuance a skeptic added: the audit has
   always shadowed framework-first, so the truth side extends an
   old convention; the belief-side double-run is the new hazard.)
2. **Books.believed validates nothing** while Books.ledger checks
   its declaration at construction — against card 171's "one
   contract, checked once." Wrinkle: believed takes a static decl
   on a hot path (every mind, every morning). Cleanest shape
   would be a `Books.check(decl)` worlds call once at file scope,
   mirroring Vocabulary.check — and it could carry finding 1's
   disjointness check for the legs. One decision, two findings.
3. **`rows` coins a synonym** for what the audit calls `books`
   (same structure, same enroll rule) and collides with the
   carrier taxonomy's "row." Naming is a rename-now question
   (nothing shipped yet).
4. **`seat` vs `home`**: the engine's public word for a faction's
   address is `home` (u:add_faction, api.md); books coined
   owner.seat / by="seat" (from the audit's *internal* s.seats).
   Rename to home, or glossary the distinction.
5. **Anchor defaults are fallbacks, not overrides**: office's
   `work = 0` holds only while office.hired's payload never gains
   a `work` field — a vocabulary edit two files away would
   silently change opening books. Options: a warning comment in
   office_vocabulary, or `fields = { col = false }` meaning
   "never read the payload for this column."
6. **On the record, no change recommended**: the unmapped-
   commodity assert now crashes mid-tick where the old space/
   office silently booked the units and the audit soft-flagged
   after the run — fail-fast chosen over finish-and-flag,
   consciously. Likewise enroll's zero-fill forgives partial
   openings exactly as the audit's enroll does (the contested
   finding): physics and audit agree by construction; strictness
   here would be a policy change, not a bug fix.
7. **Docs sweep specifics the review pinned** (owed at PR):
   architecture.md's module map lacks books.lua and its "five
   folds over one log" line becomes six; api.md needs a Books
   section (and its header still says engine 0.2.0); glossary
   candidates: *anchor*, the truth-cursor's name (per fork 3),
   and seat/home (per fork 4).
## Session 4 (2026-10-08) — the forks ruled, the branch committed

The return review (`docs/reviews/2026-09-24-the-return.md`, §5.2
D3) restated session 3's forks in plain words, added a fork 0, and
gave each a default.

> Mike: go with all of your suggestions for the changes and get
> this branch committed and pushed.

All six defaults taken:

0. **Exact, not counted.** The fold no longer reads `recent()`
   count windows. `Belief:since(kind, after)` returns exactly what
   was learned after the anchor's stamp; `Belief:newest_where(kind,
   test)` finds the owner's newest anchor however far back it is.
   `window` is gone from every declaration. Exactness rests on one
   invariant — learned stamps never go backward in arrival order —
   and `Belief:receive` now asserts it, so the courier being the
   only writer is structural, not assumed. (The review's prototype
   patch, `2026-09-24-probes/watermark-scan.patch`, adopted with
   two changes: `newest_where` hands its test copies, the store's
   standing discipline; and the redundant `learned > absorbed`
   re-checks after `since()` are dropped.)
1. **Road kinds refused loudly.** `Books.check` refuses a belief
   leg for any of the four road kinds (it would have double-
   booked); `Books.ledger` refuses a truth-side effect for one (it
   would have been silently shadowed). The framework table in
   books.lua is the one list.
2. **`Books.check(decl, vocabulary)`, once, at world file scope.**
   Each world hoisted its vocabulary `require` to a file-level
   `VOCABULARY` and wraps `BELIEVED` in the check. It validates
   columns, money, the commodities map, every anchor (kind
   declared, match shape, field map and defaults naming real
   columns, every column opening from exactly one source) and
   every leg. `Books.believed` refuses an unchecked declaration —
   a weak-keyed set lookup, cheap enough for the hot path.
3. **`rows` → `books`.** The truth-side table is `led.books`, the
   audit's own word for the same thing. The worlds' ledger object
   is now the local `truth` (`truth.books`, `truth:catch_up()`).
4. **`seat` → `home`.** `owner.home`, `by = "home"`. The engine's
   public word. (The audit's internal `s.seats` and space's
   `seats` reverse map are untouched — internal names, not this
   fork.)
5. **Defaults can't be silently overtaken.** If an anchor's
   vocabulary payload carries a column that the anchor also
   defaults, `Books.check` fails and says to drop one. The office's
   `work = 0` is now guarded at load, not by a comment.

**Proof.** 202/202 specs (188 + 14 new: `tests/books_spec.lua`,
and three belief-store specs for the monotone diary, `since`, and
`newest_where`). All three golden seals stand. 30 full runs — 10
seeds × 3 worlds, 400 ticks (office 1,000), `--audit` — compared
byte-for-byte against a `main` worktree: 0 diffs. Engine stays
0.2.6: the engine changed again, every seal stands.

**Still owed, deliberately:** Mike's interrogation of the code,
post 0023, and the docs sweep (architecture.md module map,
api.md's Books section, glossary). Mike's next move is a step
back — he finds the three-world position hard to reason about
and is considering a return to a plain space sim — so the branch
is committed and pushed as a checkpoint, without a PR, until
that direction is decided.
