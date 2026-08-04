# Notebook — card 160: two new worlds (the continent and the office)

Branch: `160-two-worlds`. Card text: two new universes alongside the
toy space world — (1) a fantasy universe, all civilizations on one
continent, existing amongst one another; (2) an office universe,
everyone working for the same employer, with different social
connections to other companies, all trying to build a business up
together — proving (or disproving) that src/sonder is a framework.

## Why we are doing this — the record, so it is not forgotten

This card exists because of a devil's-advocate question Mike asked
after card 153 shipped: are we at the Quake point, where the engine
and the game separate? The first answer was the id lesson — engines
crystallize out of repeated games; don't extract from one consumer —
and it was correct right up until Mike's reframe made it obsolete:

> **"We are not building a game. We are building a system of
> systems here. Games and observability are just the outcomes of
> the systems upon which we're building."**

If the system is the product, the eval suite must match the thesis —
and every mechanic since card 118 has been evaluated against one
world's stories. Hence this card, and hence its position: BEFORE the
carriers research (reversed from the earlier plan), because a
mechanism taxonomy designed against three worlds — hulls in space,
caravans on a continent, email in an office — finds its general
shape at birth, while one designed against a single world is hulls
with the serial numbers filed off. Mike's own example proved it
before the card existed: payment wired electronically in seconds
versus credits on a hull for seven days is an office-versus-space
mechanism pair, told by the same two events.

**The litmus (standing doctrine, in memory and soon in the
constitution):** what we build must serve all three universes. If it
cannot, it is game-specific content; if it can — like the random
number generator — it is a framework-level addition.

**The method (direction two with direction one's discipline):**
never extract abstractly. Build the two worlds; every place they
cannot be built without touching src/sonder is a leak, found
empirically, fixed when hit. The space sim's golden seal is the
regression anchor for the entire extraction: it must not move while
the vocabulary, audit legs, and chronicle templates relocate. The
first game protects the engine while the new games generalize it.

**The eval practice, extended (Mike's instruction, kept verbatim):**
processes do not change. "When we invent a civilization in the space
sim, that is not a dictation that that civilization should exist. It
is an example of a civilization that our system must be able to
support. Extend that sort of eval process to the other universes."
Every invented kingdom and every invented employee is an eval entry
with an eval note — a story the system must be able to host, never a
spec of what it builds.

**For post 0013 (Mike's framing, kept):** what we are building is a
universe simulator. It does not matter whether the universe is a
spacefaring civilization or an office building — we are trying to
simulate a universe, whatever that universe may be. The two new
worlds are evals we measure all our systems against, to determine
whether they deliver on that standard.

**The focus clarification (mid-session, kept):** "For the majority
of this project, we're going to be focused on the Universal Space
Sim — these two other worlds as an eval will enable us further in
the future. The end goal is this Universal Space Sim." The space sim
is the destination; the continent and the office are enabling
evals, deliberately shallow, never co-equal products. Effort
re-balances toward the space sim the moment this card lands.

## The build order (proposed)

1. **The charters** — one page per world, prose before code: cast,
   the stories each world must host, what distance and money and
   conflict *mean* there. Shaped by the session-1 questionnaire
   below.
2. **The world-interface ADR** — what a world module supplies:
   vocabulary, audit legs and conservation identities, chronicle
   templates, cast, systems, distance. The framework boundary, on
   paper first.
3. **The shelf goes plural** — docs restructuring so each universe
   has a home for its lore-as-evals (the current docs/lore assumes
   one universe).
4. **The office world, minimal** — the sternest test first (social
   distance, open economy, individual minds).
5. **The continent world, minimal** — contiguous geography,
   multi-commodity.
6. **Leaks fixed as hit** — vocabulary out of the engine, audit legs
   world-supplied, templates world-supplied, main.lua learns
   --world; every relocation proven by the space seal not moving.
7. **Three-world eval runs** — each world's acceptance run and its
   own golden seal; the litmus applied to everything the engine
   still contains.
8. **Post 0013 and the docs sweep** — including the constitutional
   promotion: CLAUDE.md's identity paragraph gains the
   system-of-systems sentence.

## Session 1 — the charter questionnaire

Questions to shape the two charters, each with Claude's
recommendation; Mike's answers recorded inline.

**Q1 — Who are the office world's actors?** Individuals (the 20–30
people Mike named) or teams-as-factions? *Recommendation:*
individuals — a faction was always "a decision-maker with a belief
store," and a person qualifies exactly as well as an empire. This is
the notable-figures zoom tier arriving early, with no new engine
machinery. Authoring guard: the charter says 20–30 employees; the
first cut authors a handful of *role templates* (minds as
temperament constants, the VESSARI/KHEDRUN pattern) instantiated
with per-person constants, so thirty people don't mean thirty
hand-written minds.
> Mike: Agreed, individuals — but they should be free to make a
> coalition that creates a team. And this is also true as we scale
> up to universal scale, where civilizations could make alliances
> or enemies.

*Q1 resolution — coalitions are behavior, not structure.* Mike's
addendum passes his own litmus on the spot: a team in the office
and an alliance among civilizations are the same concept at two
scales, which is evidence the concept is framework-shaped — and the
framework already supports it with no new machinery, because the
card-122 visibility lesson applies verbatim. A coalition is not a
state some registry holds; it is events (team.founded,
alliance.sworn — world vocabulary, not engine) living in members'
belief stores, plus minds that read those beliefs and act in
concert. Membership is the behavior of the members. Which buys the
drama for free: the alliance one side believes is still alive —
betrayal as belief divergence about the coalition itself — is the
office world's "same war twice," and at universal scale it is the
alliance that learns of its own dissolution eight days late.
Charter requirement, both worlds: the system must be able to host
coalition stories (formation, defection, the lie that holds a team
together); v1 minds may be simple, but nothing may structurally
preclude the coalition that exists only in one member's head.

**Q2 — What is distance in the office?** Physical (floors, desks) or
social/organizational (the org chart and channels as the map)?
*Recommendation:* social — distance(from, to, tick) is already
content, so the org chart IS the map, and "hops" between two people
run through teams and shared channels. The boldest available test of
map-as-content — and someday a reorg is the tick parameter finally
moving a name.
> Mike: Agreed, social distance — the org chart is the map.

*Q2 resolution.* The charter owes a concrete hop metric (a distance
function, not a vibe): same team adjacent, shared manager two hops,
cross-department through the chart's spine, shared channels as
shortcuts. Noted for later beats: a reorg is the moving map arriving
in the office before it arrives in space, and card 157's reception
capability becomes "who is in the channel." Every mechanic we own —
courier, loudness, travel calendars, the road ledger for a document
making the rounds — must run on this map unchanged; that is the
test.

**Q3 — What are the office's economy and its doors?** The space toy
is closed (money has no doors). An office earns revenue from outside
and pays salaries out — an *open* system whose conservation identity
has world-declared doors. What's conserved and what flows?
*Recommendation:* money with two doors (revenue in, salaries and
costs out — both recorded events, audit-visible), plus one
work-product commodity riding the cargo grammar between people and
out to clients. Deals with other companies are the office's
"foreign relations."
> Mike: Agreed on both — two doors and the work-product commodity.

*Q3 resolution.* The doors follow the torch's precedent: revenue is
lawful because the deal event records money entering; payroll is
lawful because the salary event records it leaving. The identity
becomes world-declared — founded + revenue − paid = held + on-road —
confirming via the litmus that conservation identities were always
world content and only the fold machinery is engine. Work product
rides the existing cargo grammar on the social map (a report making
the rounds is cargo.shipped, and that is not a metaphor); deals
with external companies are the office's foreign relations,
conducted by whoever sits closest to them on the social map.
Chartered simplification: external companies are environment in
v1 — weather with a checkbook — and making them believable actors
is a named, declined future card.

**Q4 — The continent's cast and geography?** *Recommendation:* four
to six civilizations (drawn fresh, eval-note practice from day one —
not ported from the space shelf), geography as an adjacency graph of
bordering regions (contiguity is the stress: shared borders,
chokepoints, no exchange in the sky), and two or three commodities
so the cargo grammar's commodity field finally earns its keep.
> Mike: Agreed on all three — fresh cast, adjacency graph, and no
> exchange.

*Q4 resolution.* Four to six civilizations, authored fresh under
the eval-note practice from day one (never ported from the space
shelf — each kingdom an example the system must host, not a
dictation). Geography as an adjacency graph of named regions:
distance is hops through territory, the map gains interior
(landlocked civs, passes that make near capitals far), and
distance(a, b) violates naive expectations for the first time —
which the seam was built for and has never had to carry. Two or
three commodities with differential needs (the mountain civ has
iron and no grain) so trade has structure. And the chartered
omission: NO exchange — the continent trades bilaterally, neighbor
to neighbor, exercising card 154's future and proving the market
machinery was content all along. Anything bilateral trade needs
that we don't have is a leak found honestly: a card, not scope
creep.

**Q5 — What is each world's "war nobody planned"?** Every world
needs one emergent story class as its KPI — the space toy's is the
unplanned war. *Recommendation:* the office's is the unplanned
*rumor cascade or turf conflict* (a reorg or deal collapse nobody
scheduled, precipitating from beliefs); the continent's is the
unplanned *border war or famine trade crisis* (contiguity makes
neighbors, neighbors make friction). Each charter names its own and
the acceptance run must produce it unprompted.
> Mike: Agreed on both.

*Q5 resolution.* The office's KPI story: the unplanned rumor
cascade — something true happens quietly, its news propagates the
social map unevenly, and the org's collective behavior visibly
changes before the org collectively knows why. The continent's: the
unplanned border war or famine crisis — a bad harvest propagating
through bilateral trade into a war no charter scheduled, the whole
chain legible in cause links across three or more civs' territories.
Both executable as annals-replay specs in the established style.
For post 0013: "a war nobody planned" was never about war — it is
the standard that a universe's drama must be emergent from beliefs
and physics, and each universe names its own genre of it.

**Q6 — Scope guard: what do the worlds NOT get in v1?**
*Recommendation:* no new engine features designed FOR them — v1
worlds use only what exists (events, beliefs, loudness, courier,
travel, audit) plus the leak-fixes their construction forces. Any
mechanic a world wants that doesn't exist becomes a card, not scope
creep. The worlds are evals of the engine we have, not wishlists for
the engine we don't.
> Mike: I agree that worlds are built with the engine we have. If
> the engine cannot build one of those worlds and sustain it, then
> that is a card that we need to bring back into the system. Again,
> we're not building a game; we're building a system of systems.
> These are all of the systems that this project needs to support.

*Q6 resolution.* "Build AND SUSTAIN" is the sharpened bar: a world
that can be constructed but collapses without hand-holding is also
a gap, and gaps become cards brought back into the system. The
hiring tension resolves under this rule: v1 offices have a fixed
cast (the company as founded, like civilizations at genesis), and
actors-who-join-and-leave-mid-history is named as a card the office
world sends back — the first discovered requirement, found before a
line of the world was written. Questionnaire complete: six for six.

## Session 1 — the first leak fixed: the vocabulary leaves the engine

Charters approved; the extraction ran exactly as the ADR's method
demands. `src/sonder/vocabulary.lua` became
`src/worlds/toy_vocabulary.lua` — moved verbatim, v1/v2/v3 history
comments and all — and the engine's default retired: Annals, Seal,
and Universe now *require* a vocabulary and validate one universal
contract, that it declares `universe.genesis`, because the engine
emits genesis itself. The toy passes its own vocabulary at
construction like the content it always was.

The engine specs got the honest upgrade instead of a shim:
`tests/support/vocabulary.lua` is the spec world's own two-kind
vocabulary — genesis plus one event to emit — which makes the test
suite quietly the fourth world, and the litmus enforced at every
`Universe.new` in the repo. The archive provenance spec now records
schema_version "1" for spec-world universes, proving provenance
follows the vocabulary it's handed. Coverage walks (audit
classification, chronicle templates) repointed at the toy's
vocabulary, where those obligations actually live.

**The proof: 148 green, and the golden seal did not move**
(3475639d8f49678b) — the toy's history is bit-identical whether its
vocabulary arrives as an engine default or as world content. Third
edition of the equivalence discipline, and the first entry in ADR
0004's leak ledger closed. Remaining leaks: audit legs, chronicle
templates, main.lua's hardwired world — each waits for the world
build that hits it.

## Session 1 — Bellwether & Co. opens for business

The office world exists and the headline is the card's thesis
proven: **152 specs green, and the engine was not touched.** Ten
minds run on the exact machinery that runs two space civilizations;
the only engine-side edit was main.lua learning `--world office`,
and main was always the host's window, never the engine.

What got built: `office_vocabulary.lua` — the first vocabulary
written against ADR 0004 rather than grandfathered (doors declared:
made and spent ride the tally like harvest and eaten always did;
revenue in and delivered out are the open system's mouths; the
framework's cargo/payment kinds are copy-declared, a composition
helper noted for the rule of three). `office.lua` — the cast from
the charter (mara, sef, tobin, amity, ivo, prue, and the four
makers), the org chart as a distance function (LCA hops; off-chart
places adjacent, so genesis is heard at once), believed books at
desk scale (self-knowledge exact, card 153's dividend — which is
what lets minds dispatch their own shipments with no clamping
middleman), morale as a reading of the belief store (news dims a
mind when it *arrives*, not when it happened), and two systems:
roads (the second hand-rolled copy, counted) and clients — the
world outside with a checkbook and no inner life.

**The chartered KPI fired on the first seed tried.** Seed 7, tick
14: a client tells ivo no, quietly. Ivo goes silent the next
morning; prue, two hops away, learns it and sits on full inventory;
the make-team, four hops out, keeps producing at full rate for days
before the news dims them — pitching stopped org-wide while half
the company hadn't heard why. The office_spec replays it from
truth: seller active before, silent after, the make-team's lag ≥ 3
hops, and dane's private chronology carrying the loss at exactly
tick + distance. The believes viewer works on a person with zero
changes — an employee's newspaper reads like a life.

**Leaks observed, on the ledger:** (1) chronicle templates — office
shipments render through the TOY's cargo templates ("the dane
dispatch 6 work to the tobin"): functional, wearing the wrong
world's prose; extraction when we want office sentences. (2) audit
legs — office kinds land in report.unclassified; the audit means
nothing at Bellwether until legs and the open-system identities
become world-supplied. That extraction is the next chunk. (3) the
roads system copy count stands at two; the continent's copy
triggers the extraction, per the rule of three.

Suite: 152 green, toy seal untouched. Uncommitted, awaiting Mike's
gutter pass under the new rule: code commits only after review.

## Session 1 — the audit's legs leave the engine

The last engine surgery of the card. audit.lua is machinery now:
the fold, the road ledger, the framework cargo/payment legs, the
belief-drift certification, the negative sweep (founding order,
declared column order), and the three findings — while a world's
legs module supplies what the litmus proved was always content: the
ordered book columns with their negative phrasings, the
commodity→column map, which column is money, an effects entry per
world kind, the conservation identities, and a summary line for the
host (the world knows what its own books are called — post 0010's
beloved founded/harvested line lives in toy_audit.summary now,
verbatim). Legs reach the fold only through a helper library —
enroll, embark/disembark, ship/drift, flag/mismatch — so the
discipline stays in one place.

worlds/toy_audit.lua: the toy's legs moved with their exact message
strings (specs held them to it). worlds/office_audit.lua: the first
OPEN system declared — money's identity is founded + revenue −
spent = held + riding; work's is made − delivered = held + riding —
and the audit machinery neither knew nor cared that this economy
breathes. main.lua --audit goes world-generic: legs looked up per
world, summary printed from them.

**The bug the office found, and the wrong theory first:** 113
mismatches, all mara, all cents, all exactly 150¢ high. First
theory (the tally flood — ten tallies arriving per morning evicting
your own from a 12-window) was plausible, got a confident comment,
and was WRONG: the count didn't move. The real cause: payday emits
NINE payment.shipped in one burst and the believed-fold window was
8 — sef's salary, first out the door, was evicted from mara's fold
every single week. Windows resized to the crowd (3 × cast), the
false comment replaced with the true story. Lesson kept for the
post: belief windows are content tuned to a world's event *density*,
and the office's crowd is denser than the toy's duet — the second
world's first genuine teaching.

Suite: 153 green. Both worlds audit clean under their own laws; the
office's zero mismatches are certified, not assumed. ADR 0004's
leak ledger: vocabulary closed, audit legs closed, main closed.
Chronicle templates remain (office prose rides toy templates —
functional, wrong-world wording; extraction when we want office
sentences, likely with the continent). Uncommitted for the gutter.
