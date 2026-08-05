# ADR 0004 — The world interface

Status: accepted (card 160). Supersedes nothing; makes explicit a
boundary that has existed as discipline since card 118.

## Context

The Quake question (2026-08-03): is src/sonder an engine with the
game as a mod? The answer that reframed the project: we are not
building a game — we are building a system of systems, and games
and observability are outcomes. The end goal remains the universal
space sim, but the engine that gets it there must be a framework in
fact, not in posture — so two deliberately shallow worlds (the
continent, the office) join the space toy as standing evals, and
one litmus becomes law: **what we build must serve all three
universes. If it cannot, it is world content. If it can — like the
random number generator — it is a framework-level addition.**

## Decision

A world is a module that builds a universe from a seed. The
interface, stated as what a world supplies and the engine never
contains:

- **a vocabulary** — the world's event kinds, payloads, and
  loudness set (the schema *machinery* — envelope, validation,
  byteform — is engine; the kind *list* is world; Annals.new has
  taken a vocabulary parameter since card 115 and the engine's
  hardcoded default retires when the first non-space world lands);
- **a cast** — factions with homes, minds as decide() functions
  (a faction is a decision-maker with a belief store: an empire, a
  kingdom, or an employee);
- **systems** — the world's physics, entitled to truth, run in
  registration order;
- **a map** — distance(from, to, tick) → days, whatever distance
  means there (void between stars, hops through bordering
  territory, hops through an org chart);
- **its mechanisms** — the carriage rows saying what carries news
  here and how fast (amended at card 150, per ADR 0005: row schema
  is engine, row instances are world content; a world that declares
  nothing gets the field row at channel speed);
- **chronicle templates** — the world's own sentences (the
  follower machinery is engine; the prose is world);
- **audit legs and conservation identities** — what each kind does
  to the books, which doors are lawful, and what identity must
  hold (closed systems and open ones alike declare themselves);
- **its own golden seal and acceptance run** — including the
  world's named KPI story, which must precipitate unprompted.

The engine supplies, for every world identically: the four laws,
ticks and named RNG streams, the annals and its envelope, belief
stores with learned stamps and chronologies, the courier, the
travel calendar, the seal and archive machinery, the audit fold
(violations / mismatches / unexplained / road ledger), and the
chronicle and believes-view machinery.

Provenance grows one requirement: every universe file records which
world wrote it, and that world's version. Three worlds' archives
must never be confusable.

## Method

Extraction is empirical, never speculative: build the worlds, and
every place one cannot be built *and sustained* without touching
src/sonder is a leak — fixed when hit, each relocation proven by
the space world's golden seal not moving. The first game protects
the engine while the new games generalize it. Known leaks at
adoption: the vocabulary default, audit legs, chronicle templates,
and main.lua's hardwired world.

## Consequences

Worlds multiply as evals, not products; the space sim stays the
destination. Every future mechanic is designed against three
universes from birth (a carrier is a hull, a caravan, and an email
before its card is even cut). The eval practice extends to every
universe: an invented civilization, kingdom, or employee is an
example the system must support, never a dictation that it exist.
And the day a fourth world wants to live — orcs, or otherwise — it
should cost a charter and a cast, not an engine change.
