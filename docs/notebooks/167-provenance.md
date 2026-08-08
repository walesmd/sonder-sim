# Notebook — 167-provenance

Card 167: *Provenance: the world row (ADR 0004's unpaid
requirement).* First card off the card-166 findings menu — Mike's
call: queue everything, start doing it. The most urgent finding,
the smallest fix.

## Why this card exists

ADR 0004 (accepted at card 160): "Provenance grows one requirement:
every universe file records which world wrote it, and that world's
version. Three worlds' archives must never be confusable." Eleven
weeks later, never implemented — two worlds' files from one seed
were confusable on disk, and every file written until now is
ambiguous forever (their git commits identify the code, not the
world). Post 0017's lesson made flesh: an accepted ADR is not an
implemented ADR.

## Session 1 (2026-08-07) — built

Design, one decision worth recording: ADR 0004 asked for the world
*and its version*. Worlds declare no version of their own — but
each world has exactly one vocabulary, and vocabularies are
versioned (space 3, continent 2, office 1). Ruling taken: **a
world's version is its vocabulary's schema_version**, which
provenance already writes — so the fix is one row (`world`), and
`schema_version` gets documented as world-scoped rather than
duplicated. One world, one vocabulary, one number. Mike can veto
at review; a per-world version declaration would be a new world-
interface field with no consumer.

Changes:
- `archive.lua` — REQUIRED gains `world`; the rows table writes it.
- `main.lua` — passes `world = opts.world or "space"`.
- `archive_spec.lua` — the birth spec asserts the row; a new spec
  proves a file that cannot say its world is refused.
- `docs/universe-file.md` — the honest caveat published at card 166
  deleted three days later, replaced by the ninth row and the
  schema_version reading note. The living-docs doctrine working
  exactly as designed.
- `docs/glossary.md` — provenance entry to nine rows.
- Engine 0.2.1 (patch: engine changed, all seals stand — no event
  bytes moved; provenance is not hashed by the seal).

183 specs, 0 failures. Verified live: a Harrow run's file answers
`world|continent`.

One wrinkle, kept honestly: the first run failed — validation
accepted `world` (REQUIRED gained it) but the file didn't carry it,
because the provenance *writer* enumerates its rows in a second
list that must agree with REQUIRED by hand. Two lists, one
contract, no guard: noted for the hygiene sweep (card 172), and
into the post's what-we-got-wrong.

Post 0018, *The File That Knows Its Name*: front door is the
sqlite output; CS underneath is self-describing data (FITS
headers, EXIF — files that carry their own provenance) with W3C
PROV as the pointer for data lineage as a field. The
does-this-need-a-visual question was asked and answered **no** — a
nine-row table needs no diagram, and saying so is the rule working.
Both tracks deliberately short: the smallest card yet gets the
smallest post yet, honestly, rather than padded.