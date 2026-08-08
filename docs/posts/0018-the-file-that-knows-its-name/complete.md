# The File That Knows Its Name

*Post 0018 · pinned at tag `post/0018` · engine 0.2.1 · ~4 min
read · plain-language version: [simple](./simple.md)*

*Previously: post 0017's review found thirty things, and ranked
one most urgent — an accepted architecture decision, eleven weeks
old, requiring every universe file to record which world wrote it.
Never implemented. This card is the payment.*

---

```
$ sqlite3 out/universe-*.db "SELECT key, value FROM provenance WHERE key = 'world'"
world|continent
```

That row did not exist yesterday. Without it, a Harrow universe
and a space universe run from the same seed produced files whose
provenance tables matched in everything that identifies them — the
exact confusion the provenance table was built to prevent, back in
post 0004, when we decided a log found on a beach must be able to
testify about where it came from. The beach testimony had a hole:
the file could name its engine, its commit, its seed, and its
toolchain, and could not name its *world*.

## Why now

Because the review made it the most urgent finding on the board:
every file written before this card is ambiguous forever, and the
fix was an afternoon. Also because post 0017 had just coined the
lesson — *an accepted ADR is not an implemented ADR* — and leaving
the example unfixed for even one more card would have been a
strange way to mean it.

## The design, all of it

Provenance gains one required row, `world`, supplied by the host
(only the host knows which world it built). One decision was worth
a ruling: ADR 0004 asked for the world *and its version*, and
worlds declare no version of their own. But each world has exactly
one vocabulary, and vocabularies are versioned — so a world's
version **is** its vocabulary's `schema_version`, which provenance
already carried. The fix documents that reading instead of
inventing a second number: space's v3 and the continent's v2 are
different vocabularies, not one vocabulary at two ages, and the
`schema_version` row is meaningful only beside the `world` row.
One world, one vocabulary, one number.

The satisfying part was watching three days of doctrine work.
[`universe-file.md`](../../universe-file.md) shipped at card 166
with an honest caveat — *no world row yet; two worlds' files are
confusable* — and this card deleted that paragraph and wrote the
ninth row into the table. Living documents are supposed to change
when the system does; this one changed seventy-two hours after it
was born, and the pinned post you are reading records that it did.
Both halves behaving exactly as designed.

Engine 0.2.1 — a patch, per the convention: the engine changed and
every seal stands, because provenance is a label on the file, not
history in it. The seal hashes events; it has never hashed the
nameplate.

## The CS underneath: files that testify

The idea that a file should carry its own origins is old and
deeply astronomical. FITS — the Flexible Image Transport System,
astronomy's archival format since 1981 — mandates that every file
open with human-readable header cards describing the data that
follows: the instrument, the coordinates, the units. Forty-year-old
FITS files are still readable *because the file itself says what
it is*; the format's unofficial motto is "once FITS, always FITS."
EXIF does the same for photographs (which camera, what exposure,
when); and the general discipline has a name — data provenance —
and a W3C standard (PROV) for recording what produced what, from
what, by whom. Sonder's provenance table is the small, honest end
of that tradition: nine rows so that a stray `.db` on a beach —
or in `out/` six months from now, which is the realistic beach —
can answer the only questions that matter before replaying it:
what engine, what commit, what seed, *what world*.

## What we got wrong

**The first run failed, instructively.** REQUIRED — the list of
provenance keys the archive demands — gained `world`, and the spec
still found no row in the file: the provenance *writer* enumerates
its rows in a second list that must agree with REQUIRED by hand.
Validation passed; the write didn't happen. Two lists, one
contract, no guard — a miniature of the exact duplication disease
the review just cataloged, discovered while paying down a review
finding. Noted for the hygiene sweep (card 172).

**And the visual question got its first honest no.** Every post
asks *does this need a diagram?* A nine-row table does not, and
recording the no is the rule working — the question exists to be
answered, not to always answer yes.

Next off the findings menu, whenever it's picked: the courier
extraction (before card 152 needs to cut through the heartbeat),
or the believed-books cluster (the big one).
