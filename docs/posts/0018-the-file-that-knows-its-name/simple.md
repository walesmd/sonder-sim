# The File That Knows Its Name

*Post 0018 · the plain-language version · the full essay:
[complete](./complete.md)*

Every simulation run saves its complete history into a database
file — we've called it the universe file since post 0004, when we
decided such a file must be able to *testify about itself*: a file
found on a beach (realistically: in a cluttered folder, six months
from now) should answer every question you'd need before trusting
it. Which version of the engine wrote you? Which exact code? Which
seed grew you?

Last card's big review found the hole in that testimony, and rated
it the most urgent finding of thirty: the file could not say
**which world** it was. We run three — the space simulation, the
fantasy continent, the office — and two universe files made from
the same seed by different worlds were indistinguishable without
opening them up and squinting at the events inside. The
embarrassing part: a design document from eleven weeks ago
*required* exactly this row, in bold terms ("three worlds' archives
must never be confusable"), and it simply never got built.
Everyone treated *decided* as *done* — the precise lesson last
card's essay ends on.

So this card is the payment, and it's the smallest card in the
project's history. The file gains one row:

```
world|continent
```

One design question came up. The old requirement asked for the
world's name *and its version* — but worlds don't have version
numbers. What they have is a vocabulary (the declared list of
everything that can happen there), and vocabularies *are*
versioned. So the ruling: a world's version simply is its
vocabulary's version, a number the file already carried. We
documented that meaning instead of inventing a second number.

The quietly satisfying part: three days ago, the review card
published a reference page describing this database, and that page
honestly listed this exact gap as a known caveat. Today the card
deleted the caveat and added the ninth row to the table. That's
the new documentation system working as designed — reference pages
are *living* and change when the system does, while essays like
this one are *pinned* and remember it happened.

There's a nice bit of history behind the whole idea. Astronomy
solved this problem in 1981 with a file format called FITS, which
requires every file to begin with plain-text lines describing
exactly what it contains — which telescope, what coordinates, what
units. Forty-year-old FITS files are still perfectly readable
today *because each file explains itself*. Your phone's photos do
it too (that's how they remember which camera and what day). Our
nine little rows are the same old, good idea: data that carries
its own birth certificate.

What we got wrong, kept as always: the very first test run failed.
We added the new requirement to the checklist that *validates*
what callers provide — but the code that actually *writes* the
rows keeps its own separate list, and nobody told it. The gate
demanded the fact; the file still didn't get it. Two lists that
have to agree by hand, with no guard — which is a miniature of the
exact copy-paste disease the big review just cataloged, caught
red-handed while we were paying off one of that review's findings.
It's on the cleanup card now. And one more small first: every
essay here asks "does this need a diagram?" — this is the first to
answer *no*. Nine rows in a table don't need a picture, and an
honest no proves the question is real.

The engine version ticks to 0.2.1 — a patch, by our convention:
the code changed, but no history changed anywhere, because the
file's nameplate was never part of history. Next up, whenever Mike
picks from the review's menu: bigger refactors, with this small
one as the warm-up.
