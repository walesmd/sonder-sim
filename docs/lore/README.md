# The lore shelf

This directory holds the authored side of Sonder's universe: species,
cosmology, and historical priors, written as prose long before any of
it is code. Mechanics will arrive card by card and inherit these
documents instead of improvising flavor at implementation time.

Lore is **priors, not promises**. When a mechanic arrives and the lore
doesn't survive contact with it, the mechanic wins, the lore gets
revised, and the conflict is recorded (in the branch notebook, and in
the post if it's a good enough lesson). Nothing in this directory is
canon until a simulation runs it.

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

## One physical constant the lore already obeys

Nothing travels faster than ships — not people, not cargo, and above
all not *news*. This is the project's thesis wearing physics: every
civilization acts on beliefs, and beliefs age in transit (card 122
will make it literal). All lore is written against a sublight galaxy,
and any species concept that quietly assumes instant communication is
wrong by construction.
