# The lore shelf

This directory holds the authored side of Sonder's universe: species,
worlds, and historical priors, written as prose long before any of it
is code. Mechanics will arrive card by card and inherit these
documents instead of improvising flavor at implementation time.

## What this shelf is — an eval suite, not a PRD

Nothing here is definitive of the worlds, species, and civilizations
that inhabit Sonder's universes. The world catalog is not a menu the
generator picks from; the cast is not a roster every galaxy must
contain. This shelf does not tell the engine what to build.

It tells the engine what it must never make impossible. Each story
here is a **test case** for every system we will ever build: the
engine must be able to *host* these stories, and we never build
something that structurally blocks one. If a proposed mechanic cannot
support the Vess's centuries-long grudges, the Fleet's homeworld-
shaped absence, or a shellsea civilization that has never seen a
star, the mechanic has failed an eval — it gets redesigned, not the
story.

**And the shelf is a floor, not a ceiling.** Passing these evals is
the minimum, never the target. We are not building systems to create
these three civilizations; we are building systems that could *at
least* create these three — and could also create things this shelf
never imagined. A design that hosts exactly the current cast and
nothing stranger has over-fit the evals and missed the point: the
generator should eventually surprise the shelf's own authors, and
when it does, the surprise isn't a violation — it's a candidate for
the next eval.

Two exception paths exist, and both go through Mike, on the record:
a story can turn out to be a **bad test** (it quietly assumed
something the four laws forbid — the laws outrank the shelf, though
the laws themselves are revisable through Mike when a story makes a
strong enough case; nothing in this project is beyond amendment,
only beyond *silent* amendment), or a story can be **consciously
retired** because supporting it isn't worth what it costs. Either
way the decision gets written down, in the notebook and in the
story's file. A story never just erodes.

Nothing here is canon until a simulation runs it — but everything
here is binding on design until Mike retires it.

## The flexibility principles

We are modeling an entire universe over decades, iteratively. These
rules exist so no lore decision ever paints the code into a corner:

1. **Species are data, not code.** There is one physics: one market
   code path, one war code path, one belief store. A species is a
   configuration of shared machinery — parameters, vocabulary,
   weights — never a new mechanism. If a species concept seems to
   demand its own code path, that's the signal we've found a missing
   *general* mechanic, and it becomes a card.
2. **Axes are append-mostly.** The set of questions a species answers
   (see `axes.md`) will grow. Every new axis ships with a default
   that keeps every existing species valid — the same discipline the
   event vocabulary uses, applied to character sheets.
3. **Qualitative now, quantitative when a mechanic needs it.** Lore
   says "the Vess reprice slowly and hold grudges for centuries";
   the number of ticks arrives with the mechanic that consumes it,
   chosen deliberately and explained in a post. Numbers written years
   before their mechanic are false precision and real handcuffs.
4. **Everything reduces to three primitives.** The simulation knows
   how to say exactly three kinds of things: entity **attributes**
   (typed values on things), **events** (appends to the annals), and
   **beliefs** (what a civilization thinks is true). Any lore idea we
   can't eventually express in those three is flagged early, while
   it's still cheap to rethink — the lore or the primitives.
5. **Authored archetypes, emergent instances.** These documents
   define species the way a field guide defines birds. Whether a
   given universe contains *the* Marrow Fleet or something
   Fleet-shaped grown from the seed is deliberately undecided — it's
   bound up with the pre-genesis question (does the universe have an
   authored past?), which Mike has explicitly deferred until genesis
   itself has content to look at.
6. **Write the gaps down.** Three archetypes is not coverage; thirty
   might be. Every lore session should end by noting what the current
   cast *fails* to represent, so the next session fills holes instead
   of deepening grooves.

## Shelf contents

- [`axes.md`](axes.md) — the seven questions every civilization must
  be able to answer, and how each would eventually be accounted for
  in infrastructure. Start here.
- [`worlds.md`](worlds.md) — the world library: seven axes a world is
  made of, and a fifteen-type field guide from Gardens to Graves.
  Types are presets, not enums; habitability is a relation, not a
  column.
- [`civilizations/`](civilizations/) — deep profiles, one file per
  species. Current cast: [the Vess](civilizations/the-vess.md),
  [the Continuance](civilizations/the-continuance.md), and
  [the Marrow Fleet](civilizations/the-marrow-fleet.md).

## The speed of truth (a default, not a law)

Nothing in the current cast signals or travels faster than light, and
every profile is written against a galaxy where news rides in hulls
(card 122 will make that literal). But — Mike's call, reversing an
earlier draft of this section — **no-FTL is not a cosmological
constant.** Faster-than-light information is a possible
*technological achievement*, the same category as stations and
satellites: an output of civilizations, not a rule the universe
enforces. The sketch that settled it: a civilization that truly
masters the quantum might move information faster than light — and if
a personality and its lived experience are data, then moving *that*
into a waiting body across the universe is faster-than-light travel
by any name that matters. We write no mechanism lore yet,
deliberately; we simply decline to call the wall load-bearing.

What *is* constant is law 3. However fast the channel, what arrives
is still belief — received, aged, and culturally interpreted. A
civilization that beats lightspeed does not beat epistemology; it
gets fresher beliefs than its neighbors, which is power, and story.
And the default remains ships: a species written with a faster
channel must earn it in-fiction as technology, never assume it as
baseline.
