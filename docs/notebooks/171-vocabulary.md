# Notebook — 171-vocabulary

Card 171: *A vocabulary module: one contract, validated once.*
Overnight run, card 3 of 4 (2026-08-08).

## Why this card exists

The vocabulary is a four-way contract — annals validates events
against it, byteform walks its declaration order, the seal hashes
what byteform makes, the archive writes its version — and each
consumer checked only its own piece, in its own error voice. A
half-shaped vocabulary failed at whichever module it reached
first. Separately: the four framework road kinds were copy-declared
in three vocabularies, two of which predicted the extraction in
their own comments ("it earns its keep at the third world"); and
the carriage validated radiated ranges against a hardcoded loudness
triple while every world declares its own set (finding 13).

## Session 1 — built

- `sonder/vocabulary.lua` — `check(decl)`: every shape rule, one
  voice, run once per universe at construction (the earliest
  moment). The rules previously lived only as manual assertions in
  vocabulary_spec; now the spec exercises the checker.
- `Vocabulary.road_kinds()` / `with_road_kinds(kinds)` — the
  framework grammar declared once; three worlds' copy-declarations
  deleted. The world wins on collision (the vocabulary is the
  world's; the framework only refuses to be absent). Payload
  arrays byte-identical to the old copies, which is why the seals
  cannot move — docs are the only difference, and byteform never
  hashes docs. The per-world doc flavor for these four kinds is
  gone (templates own the prose voice; noted as an accepted cost).
- Carriage.new gains a third argument: the world's declared
  loudness set (nil keeps the classic triple for bare spec
  construction). Radiated rows must now answer for every loudness
  their world can actually speak.
- The two prophetic comments updated to record their own
  fulfillment.
- Specs: +3 (checker accepts all four vocabularies including the
  fixture; rejects five half-shapes; merge semantics with
  world-wins). 186 total, 0 failures, three seals bit-identical.

Engine 0.2.4. Living docs: architecture map gains vocabulary.lua;
api.md's vocabulary row rewritten.

Post 0021, *The Grammar Gets a Grammarian*: front door is the
office vocabulary's own 2026-08-03 comment predicting this card;
CS underneath is design-by-contract in the small (preconditions
validated at the boundary, one authoritative checker — Meyer's
idea without the framework) plus the schema-vs-instance rule this
project keeps re-learning; visual question asked, answered no.
What-we-got-wrong: the rules lived in a spec file for four cards —
executable, but only at test time; a world assembled wrong at
runtime got the four-voices behavior the whole time. Rules that
protect construction belong at construction.