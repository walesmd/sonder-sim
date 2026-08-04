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
> Mike:

**Q2 — What is distance in the office?** Physical (floors, desks) or
social/organizational (the org chart and channels as the map)?
*Recommendation:* social — distance(from, to, tick) is already
content, so the org chart IS the map, and "hops" between two people
run through teams and shared channels. The boldest available test of
map-as-content — and someday a reorg is the tick parameter finally
moving a name.
> Mike:

**Q3 — What are the office's economy and its doors?** The space toy
is closed (money has no doors). An office earns revenue from outside
and pays salaries out — an *open* system whose conservation identity
has world-declared doors. What's conserved and what flows?
*Recommendation:* money with two doors (revenue in, salaries and
costs out — both recorded events, audit-visible), plus one
work-product commodity riding the cargo grammar between people and
out to clients. Deals with other companies are the office's
"foreign relations."
> Mike:

**Q4 — The continent's cast and geography?** *Recommendation:* four
to six civilizations (drawn fresh, eval-note practice from day one —
not ported from the space shelf), geography as an adjacency graph of
bordering regions (contiguity is the stress: shared borders,
chokepoints, no exchange in the sky), and two or three commodities
so the cargo grammar's commodity field finally earns its keep.
> Mike:

**Q5 — What is each world's "war nobody planned"?** Every world
needs one emergent story class as its KPI — the space toy's is the
unplanned war. *Recommendation:* the office's is the unplanned
*rumor cascade or turf conflict* (a reorg or deal collapse nobody
scheduled, precipitating from beliefs); the continent's is the
unplanned *border war or famine trade crisis* (contiguity makes
neighbors, neighbors make friction). Each charter names its own and
the acceptance run must produce it unprompted.
> Mike:

**Q6 — Scope guard: what do the worlds NOT get in v1?**
*Recommendation:* no new engine features designed FOR them — v1
worlds use only what exists (events, beliefs, loudness, courier,
travel, audit) plus the leak-fixes their construction forces. Any
mechanic a world wants that doesn't exist becomes a card, not scope
creep. The worlds are evals of the engine we have, not wishlists for
the engine we don't.
> Mike:
