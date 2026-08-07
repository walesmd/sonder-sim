# Notebook — 151-degradation

Card 151: *Degradation: news wears according to what carries it.*
Deferred from card 122 (Q3), designed on paper at card 161, and
now buildable: card 150 gave wear a mechanism to be a property of.

## Why this card exists

Card 122 shipped delay only, with degradation split out on Mike's
verdict: wear is a property of the means by which information
travels — a mechanism property, never a global dial. ADR 0005
typed the column (each row declares a failure profile with a
threat surface) and split wear in two: **freight wear** — the
mechanism's physics acting on what it carries (radio garbles, a
sunk ship loses everything) — and **re-composition wear** — the
one-plus-shipments compounding of retellings, each stop re-telling
from beliefs and agenda (that half is card 152's and the relay
minds', when they exist). This card builds the freight half.

Inherited requirements, from the card and the record:

- Needs the named `rng.courier` stream (law 1) — the courier's
  first randomness ever; a new stream, so no other subsystem's
  draws shift.
- Notebook 122, Q1, pre-answered one design question: "breakdowns
  become events on a named rng.courier stream once there's a
  vehicle to break down." Losses are appends, not silences.
- The card's recorded warning: degradation forces a second
  relaxation of the double-entry audit — with delay only, belief
  drift is exactly explained by in-flight events; once news can
  arrive wrong, that reconciliation needs a new definition.
- The version convention (card 150): this card will move Harrow's
  seal — lost letters change trades, changed trades change history
  — so it carries a re-cut ledger entry and the first minor bump,
  0.2.0. (Card 163's description predicted space's migration would
  earn 0.2.0 first; this card gets there sooner. Corrected there
  when it lands.)

## Session 1 (2026-08-07) — setup and a finding

Branch `151-degradation` cut from main at `b54d975` (card 150's
merge, tag `post/0015`, engine 0.1.1). Card 151 already in Up Next
(moved by Mike). This notebook opened.

**Finding, before any design:** the audit's drift machinery is
still field-shaped. `lib.ship`/`lib.drift` in `sonder/audit.lua`
compute news-in-flight with `distance ÷ channel_speed` — the exact
arithmetic card 150 retired from the courier. It is correct today
only by circumstance: space (the only world whose legs exercise
drift) still declares the field row, and Harrow's mismatches are
zero by design, so its drift machinery never fires. Any card that
makes news arrive wrong — this one — or migrates space off the
field must teach the audit the carriage. On the questionnaire.

Candidate questionnaire:

1. Scope: which wear ships first — loss, blur, detail-drop — and
   on which rows?
2. Is a lost letter an event? (Pre-answered by notebook 122: yes.)
   Then: what kind, what location, what loudness, and who could
   ever witness it?
3. The failure-profile schema on the row, and the numbers: per
   delivery or per day of exposure?
4. The audit: does loss-only actually force the second relaxation,
   or does it wait for wear that corrupts believed books? Either
   way, the field-shaped drift explainer needs the carriage.
5. Post plan.

**Q1 — Which wear ships first, on which rows?** The card names
three degradation modes: whole events vanish (loss), magnitudes
blur, details drop. *Recommendation:* **loss only, on Harrow's
letters row, nothing else.** The reasoning:

- Loss is the mechanism-est mode — "a sunk ship loses everything"
  is the failure the card's own description leads with, and on
  Harrow it is a rider lost in the pass: a letter that simply
  never arrives.
- Blur and detail-drop have no consumer yet. No mind today reads a
  magnitude off a believed copy in a way a blur would change
  (Harrow's minds read payload fields for settlement — blurring
  *those* corrupts trade in ways worth designing deliberately, not
  as a side effect). Unconsumed wear is a zoo exhibit; the modes
  stay typed in the taxonomy and land with their first consumer.
- Earshot stays lossless — self-knowledge at distance 0 must stay
  exact (the mismatches-zero property card 153 earned), and a
  shout that fails to cross two days of air has no story yet.
- Field rows declare no failure profile, so space and the office
  take zero new draws: their seals stand untouched, and the
  witness-rule pattern repeats — the pilot world absorbs the
  change alone.
- Harrow already knows how to *live* with loss, no new mind code:
  sellers re-offer after 8 quiet days (the recent-offer window),
  so a lost letter reads as a slow counterparty and commerce limps
  onward — which is exactly the story. And the loss draw rides the
  new rng.courier stream, so every other stream's history is
  undisturbed.

Honest consequence, stated up front: unlike card 150, **this one
moves Harrow's seal** — a lost letter changes which trades happen
— so the golden continent constant re-cuts (ledger entry) and the
engine takes the first minor bump, 0.2.0, under the card-150
convention.
> Mike (2026-08-07): What is preventing us from introducing loss
> on the space sim — for example, a ship may never make it to
> their destination; maybe they get pirated, or change their
> plans? For the office, maybe someone just forgets to hit send on
> an email? I'm not understanding why we can't introduce loss to
> those universes as well. Or maybe your suggestion is we just
> don't right now? I want to be cognizant of the fact that the
> space sim is our goal and Harrow is just an eval for the
> simulated universe. We don't want to optimize for Harrow; it's a
> test case.

*Q1 discussion.* The challenge answered head-on, and the answer
protects space rather than deprioritizing it:

- Nothing prevents it mechanically. The failure column, the
  rng.courier stream, and loss events are engine machinery,
  available to every row in every world from this card forward.
  Nothing in the design is Harrow-shaped (ADR 0005 typed the
  column against hulls, caravans, and email together).
- What space and the office lack is a mechanism for the loss to be
  *of*: both still ride the declared field row, and notebook 122
  pre-answered this — "the field model owes no breakdown answers."
  A loss draw on the field is failure without a vehicle: no
  pirate, no storm, no location for the loss event — a dice roll
  wearing a mechanism costume, the fake the witness rule killed.
- Mike's space examples are carrier losses: a pirated hull, a ship
  that changes plans, is a carrier-who-is-somebody — cards 163
  (space's rung 2) + 158 (in-flight actors). Bolting a loss
  probability onto space's field today would hand the destination
  a cheap imitation of that story — random non-delivery with
  nobody to blame — optimizing *against* space to look
  even-handed. Space deserves loss with a perpetrator.
- The office example splits: forgetting to hit send is an
  *emission* failure — temperament, mind content — not carriage;
  email eaten by a spam filter is a real mechanism loss and lands
  with card 164.
- The pilot pattern is the eval suite working as chartered: Harrow
  absorbs re-cuts and mistakes so the destination adopts machinery
  already debugged. The engine work is identical either way; only
  the first risk-taker differs, and it should never be the world
  we care most about.
- Sequencing lever, Mike's to pull: if space should feel this
  sooner, the move is pulling card 163 up the queue right after
  151 — loss, hulls, and piracy designed together at space's own
  migration — not loss-on-field now.

Q1 pending Mike's verdict, restated: loss ships as engine
machinery available to every row; it bites today on Harrow's
letters (the only real row in production); space and the office
get it at their own migrations, where the loss can be of something
real.
> Mike (2026-08-07): Let's continue pushing forward with your
> original plan, where Harrow has the mechanism to appreciate this
> loss, and we will recognize that loss in the other universes
> later.

**Q1 closed.** Loss only, on Harrow's letters row; the machinery
world-blind (failure column + rng.courier + loss events available
to every row); blur and detail-drop stay typed in the taxonomy
awaiting their first consumer; space and the office recognize loss
at their own migrations (cards 163, 164).

**Q2 — A lost letter is an event (pre-answered); what kind, where,
how loud, when — and who could ever witness it?** Four sub-parts,
recommendations inline:

- **(a) The kind is world-owned, named in the row.** The engine
  draws the loss but must not own vocabulary (ADR 0004: the engine
  demands only universe.genesis). So a failure profile names the
  event kind that records it — Harrow's letters row declares
  something like `continent.letter-lost` — and the world declares
  that kind in its vocabulary, gives it a chronicle sentence, and
  books it as a no-column audit leg (the unclassified check
  demands every kind be classifiable). Worlds that declare no
  failure profile owe nothing.
- **(b) Location: the road itself — which exposes a witness-rule
  leak to fix first.** Harrow's distance() treats any unmapped
  location as adjacent to everywhere (the-void convention, from
  genesis). Under earshot that means an event at an unmapped
  location is *witnessed by everyone* — a quiet loss at
  "the-roads" would broadcast to all five civilizations. Fix:
  unmapped locations become far-by-default, with the-void kept
  explicitly adjacent (genesis delivery unchanged). Then the loss
  event lives at `the-roads`, payload carrying from/to, cause
  citing the letter that died.
- **(c) Loudness quiet; witnesses: nobody.** A rider dying alone
  in the pass is the first *truly unwitnessed* event in any
  world's content — which closes post 0015's honest caveat
  (per-faction ignorance existed; oblivion didn't occur). The
  observer sees it in the chronicle (law 4: viewers read truth);
  no faction ever does. The seller re-offers after eight quiet
  days out of *silence*, not knowledge — they never learn whether
  the letter died or the buyer sat on it, and neither does the
  buyer know anything at all. The whodunnit from notebook 161's Q5
  discussion, now in production.
- **(d) When: the loss lands mid-journey, not at departure.** The
  draw happens at departure (deterministic: the addressee's
  courier scan, event-id order — fate sealed at departure, like
  delay always was), but the *event* should be stamped the tick
  the rider actually dies — a second draw picks the day in
  [1, road-days], and the engine keeps a small calendar of pending
  losses drained at dawn (before systems, the roads' own
  convention). The alternative — emit at departure-day — is
  simpler but stamps the loss before it happened, and the annals
  does not lie about when. Cost: the courier claims the "courier"
  actor name for its stream (reserved so no world actor can
  collide with it), and step() gains a dawn phase.
> Mike (2026-08-07): I don't think I understand question A, so
> you'll have to explain that more simply. For B, I don't
> understand how an event would happen at an unmapped location —
> an event always happens somewhere. Your narrative on C sounds
> right: if a rider just dies in the mountains and no one
> witnesses it, everyone else just has to react without that
> information. And I don't think I understand D either: a loss
> should happen at a particular point in time, and the universe
> should react to that when they become aware of it — but they
> don't magically become aware of it.

*Q2 discussion — the questions restated as one rider's story*
(vocabulary lesson #3: pose design questions as concrete stories,
not architecture; Mike's common-sense restatements of C and D were
already the design). Day 40: the valebright hand a rider a grain
offer for the korrag, four days of road. The courier's own dice
say the letter never arrives; a second roll says the pass takes
the rider on day 42.

- (a) restated: who invents the *sentence* the history book writes
  on day 42? Worlds declare every sentence-kind they speak; the
  engine may not put words in a world's mouth. So Harrow's letters
  row also names the loss sentence. The world provides the words;
  the engine provides the dice.
- (b) restated: Mike's "an event always happens somewhere" is the
  point — the rider dies on the *road*, and the road isn't one of
  the five named places. The road gets a name; and the map bug
  (unknown places answer "distance zero — next to everyone,"
  which would broadcast the lonely death to all five civs) is
  fixed so unknown places are far, the-void kept adjacent.
- (c) closed in Mike's words: nobody learns; everyone reacts to
  the silence.
- (d) closed in Mike's words: the loss happens at a particular
  point in time — the book stamps day 42, the true day, not the
  departure day when the dice happened to roll; and awareness
  never arrives, because nothing carries it.

Q2 pending one consolidated verdict: Harrow's letters can be lost;
Harrow names the sentence; the loss happens on the road (a place
the map knows is far from everyone); the book stamps the true day;
nobody alive ever learns.
> Mike (2026-08-07, answering toward Q3 and beyond): I don't think
> we can say how often a rider would die. That would depend on the
> civilization's technology, their hardiness, a lot of numbers
> that we don't know. And it's not necessarily the road — it's
> what they encounter on the road. So a longer road means more
> danger because there's more opportunity — but that opportunity
> is not always bad; it could be positive and influential. Road
> length increases scale for interaction; it does not necessarily
> mean that interaction is bad. And circling back: the goal of
> this exercise is not to have a configuration file with 20 or 30
> unique things that could happen. It's to simulate the universe —
> some sort of noun-verb comparison or matching. The goal is not
> that a random roll of four gives you line item number four in a
> config file. A rider may have lost it from being killed, from
> misplacing it, from someone stealing it. We need to start
> considering the engine. It's not a definition of options.
> There's an engine that creates the options.

**Q3 closed, reframed by Mike.** Two rulings extracted:

- **Exposure, not fate: the dice roll per day of travel.** The
  road doesn't kill riders; encounters do, and a longer road is
  more opportunity — mechanically free once the draw is per-day.
  The per-day rate ships as an honestly labeled placeholder (no
  claim to physics we haven't modeled — technology and hardiness
  arrive later as its real inputs; principle 3). The failure
  profile column is revealed as the narrow first slice of an
  **encounter profile**, and encounters are not all bad — the
  positive ones (a rider meets a caravan, arrives knowing more)
  wait for the engine below.
- **The refusal: loss events carry no reason.** The tempting
  config list (roll 1: bandits; roll 2: misplaced...) is cosmetic
  variety — the dice picking a costume with nothing underneath;
  the universe wouldn't *know* there were bandits. Card 151's
  chronicle sentence says "somewhere on the road, a letter is
  lost" and stops, because that is the full extent of what this
  universe knows. Causes arrive when an engine can generate them
  as real facts (the thief *has the letter*). Captured as **card
  165 — The encounter engine: options are generated, not
  configured** — prose-first research, Mike's doctrine verbatim in
  the description; ties to 158/152/163; the vocabulary-as-grammar
  guard recorded (law 2 stays: declare a grammar for composed
  payloads, never an enumeration of happenings). The chronicle
  composition question (naming/narrative engine) is that card's
  second half.

Numbers for the build, honestly labeled: letters row, encounter
chance 1-in-50 per traveler-day, sole outcome today "lost." A
four-day road ≈ 7.8% per letter — felt across a 400-day run
(steady commerce loses a letter roughly monthly per busy lane),
rare enough that commerce limps rather than collapses. The number
is a placeholder awaiting card 165's inputs, and says so in a
comment.

One scenario banked for a spec (found tracing the settlement
grammar): a lost *acceptance* is nastier than a lost offer — the
buyer pays on their own acceptance (learned at their own gates),
but the seller never learns the yes, so payment arrives at a
seller who never ships. Half-settled, chartered settlement risk
(the office charter blessed default risk; recourse is card 159's
business), audit-clean throughout — and the chronicle shows a
strongbox arriving for no reason the seller knows. Drama, not a
bug; spec should pin it.

## Session 2, continued — built

Implementation landed, uncommitted pending Mike's word:

- `sonder/carriage.lua` — addressed rows may declare an encounter
  profile: `encounters = { per_day = N, lost = <kind>, where =
  <location> }`, validated strictly (per_day ≥ 2; radiated rows
  refuse encounters — per-listener wear is blur, waiting for its
  consumer). `arrival()` now returns the carrying row too.
- `sonder/universe.lua` — the courier draws on its own stream
  (`rng.courier`; the name "courier" is reserved so no world actor
  can couple with it): one chance-in-per_day per day of exposure,
  drawn at departure, fate sealed like delay always was. Losses
  ride a small engine calendar and land at dawn on their true day
  — quiet, at the row's named place, payload {from, to},
  reason-free, cause citing the letter that died.
- `worlds/continent.lua` — the map bug fixed: unmapped places are
  FAR (30 days), the-void kept adjacent so genesis still reaches
  everyone; the letters row takes `per_day = 50, lost =
  "continent.letter-lost", where = "the-roads"` with the honest-
  placeholder comment pointing at card 165.
- Vocabulary v2 (append-mostly: one kind), a chronicle sentence
  ("somewhere on the road from X to Y, a letter is lost"), a
  no-op audit leg.
- Specs: 182, 0 failures. New: encounter-profile validation; the
  lossy little universe (coin-flip roads: losses on true days,
  sent = delivered + lost, the reader never learns the roads eat
  mail; same seed same fates); continent — losses occur and cite
  their letters, stamped strictly after departure and within the
  road's days; no store ever holds a loss (the first oblivion in
  production); at least one half-settled acceptance.
- The golden continent re-cut: `9be58120c48a121b` →
  `c6dc5ef5b428aa85`, ledger entry written; **engine 0.2.0** — the
  first minor bump, exactly per the convention (rockspec renamed,
  setup.sh updated, the convention comment's example refreshed).

Evidence from seed 7's 400 days: 291 offers, 76 accepts, 27
letters lost, 8 half-settled acceptances (the first loss of the
run carried an acceptance — the mysterious strongbox fired
immediately), zero witness leaks across five stores.

**Q5 (the post), planned and drafted.** Post 0016, *The Roads Are
Not Safe*: front door is the real four-line tragedy from seed 7's
first week (the acceptance that died on day 4, the strongbox that
arrived anyway on day 6); why-now leads; the design tells Mike's
two rulings (exposure not fate; the reason-free refusal with his
engine-creates-options doctrine verbatim); the CS underneath is
the Two Generals' Problem (Akkoyunlu/Ekanadham/Huber 1975, Gray
1978) for the half-settled trade, ARQ retransmission timeouts for
the eight-day re-offer window, and at-most-once semantics for
single-fire settlement. The does-this-need-a-visual question was
asked and answered yes: a Mermaid sequence diagram of the
half-settled trade. What-we-got-wrong keeps four: the
architecture-shaped questions that needed one rider's story, the
recorded warning that didn't fire, the unmapped-adjacent map leak,
and card 163's corrected prophecy. Docs sweep: glossary gains
encounter profile and the courier entry learns dice; README,
CLAUDE.md, and the posts index advance (the index checked this
time — the lesson from card 150's final review).

**Q4 closed by investigation, not by question.** The second audit
relaxation did *not* bite: the 400-day audit spec passes unchanged
— violations 0, mismatches 0, unexplained 0. Loss-only wear
changes *behavior* (which trades happen), never *book accuracy*:
Harrow's books fold own-gate truth, and a letter that never
arrives moves no column. The relaxation the card warned about
waits for wear that corrupts believed books — blur on book-feeding
kinds — i.e. for degradation's second half, not its first. And the
standing deferral is now on the record twice: audit.lua's
ship/drift machinery (the in-flight explainer) still computes with
field arithmetic — unused by Harrow (zero mismatches), correct for
space (field row) — and must learn the carriage when space
migrates; noted on card 163.
