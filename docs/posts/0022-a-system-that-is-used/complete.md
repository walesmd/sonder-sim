# A System That Is Used

*Post 0022 · pinned at tag `post/0022` · engine 0.2.5 · ~4 min
read · plain-language version: [simple](./simple.md)*

*Previously: three overnight refactors, each with one lesson. This
is the fourth and last — twelve small findings, none deserving an
essay, all deserving to stop being true.*

---

No single fix tonight is worth a headline, which is the point of
the card. A sampler: the `--why` flag — the one built to *explain*
history — was the only view still rendering in the engine's
generic fallback while the world's own sentences sat in scope four
lines up. The list of known worlds was written twice in the same
file, with a comment pointing at the wrong copy. The audit kept
`s.road` (the map) and `s.roads` (the goods-in-transit book) one
letter apart. A money formatter existed twice in one world, and
the copy used by the audit's summary formatted negative numbers
wrong — a summary that can't print a deficit honestly is a summary
waiting to lie. And a comment in the office world attributed the
rent to the wrong person's books for five cards, which matters
more here than in most repos, because our comments are published
prose.

Ten of the twelve findings are fixed. Two were deliberately left
for Mike, because they aren't hygiene: resizing belief-scan
windows changes what minds read, which moves seals; and the
`war.peace` payload divergence between two worlds is a public-API
decision, not a cleanup. An unmonitored run fixes what cannot
change history and defers what can — that line held all night.

## Why now

Because small wrongness compounds into distrust of the codebase's
own voice. This project leans unusually hard on prose-in-code: the
comments carry the arguments, the posts are distilled from them,
and a reader who catches one comment lying (the rent, the
whitelist pointer) rightly starts doubting the rest. The sweep's
real product isn't tidiness — it's that the code's testimony is
reliable again, plus two guards that make specific past failures
structurally impossible (the archive's two-lists assert, from card
167's stumble; declaration-level audit coverage for all three
worlds, so a kind with no ledger classification fails at
declaration rather than in whichever run happens to emit it).

## The CS underneath: Lehman's laws

In 1974, Meir Lehman began publishing what became the **laws of
software evolution**, drawn from studying how real systems change
across years. The first law: a system that is used *must* change,
or it becomes progressively less useful. The second: as it
changes, its complexity increases — *unless work is done to
maintain or reduce it*. Half a century later both laws read like
prophecy for any living codebase. Sonder is eight months from its
first commit and already obeys them: six worlds' worth of cards
exercised every seam (first law, in action), and the review found
the complexity quietly accruing exactly as the second law predicts
— duplicated knowledge, drifted comments, near-miss names. This
card is the second law's escape clause, made a scheduled practice
rather than a heroic one: the *unless work is done* is now a card
type, and the beat that generates its worklist is now a habit with
a name.

## What we got wrong

The sweep itself went cleanly, so the honest entry is a
meta-observation: **every one of tonight's twelve findings was
cheap because it was found in a batch.** Individually, none would
have justified a card, a branch, and a post — which is exactly how
they survived six cards of disciplined development in the first
place. Small wrongness has no natural predator in a
one-card-one-branch workflow; it needs the periodic full read (the
beat) to get flushed into the open. The working agreement now
knows this, and the next beat won't need Mike to invent it.

That closes the overnight run: four cards, four patch versions,
zero seals moved, and a findings menu with only the big decisions
left on it. Morning report to follow.
