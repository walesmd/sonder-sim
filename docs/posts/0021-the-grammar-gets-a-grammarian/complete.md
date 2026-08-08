# The Grammar Gets a Grammarian

*Post 0021 · pinned at tag `post/0021` · engine 0.2.4 · ~4 min
read · plain-language version: [simple](./simple.md)*

*Previously: the courier got a file, the road formula got a home.
Third stop on the overnight run: the vocabulary — one contract,
which four modules were each checking a quarter of.*

---

The office world's vocabulary file, in a comment written the day
that world was born:

> A composition helper that lets worlds import the framework kinds
> instead of restating them is a noted refinement; it earns its
> keep at the third world, per the rule of three.

The third world arrived five days later. The helper did not — it
sat as a prophecy in a comment while the review counted three
copy-declared spellings of the framework's four road kinds. This
card is the fulfillment: `Vocabulary.with_road_kinds` merges the
cargo and payment grammar into a world's declaration, the world
wins on collision (the vocabulary is the world's; the framework
only refuses to be absent), and the two prophetic comments now
record that their prediction came true.

## Why now

The road kinds were the visible half. The structural half: a
vocabulary is a contract with four consumers — the annals
validates events against it, byteform walks its declaration order,
the seal hashes what byteform produces, the archive writes its
version into provenance — and each consumer checked only the piece
it touched, in its own error voice. Hand the engine a half-shaped
vocabulary and it failed at whichever module it reached first,
with a message about that module's corner of the problem. The
review called it one contract validated four partial ways; the fix
is `Vocabulary.check` — every shape rule, one voice, run once per
universe at the earliest possible moment.

One companion fix rode along, because it is the same disease: the
carriage validated radiated rows' ranges against a *hardcoded*
loudness triple, while every world declares its own loudness set —
the one module that consumes loudness for an outcome was the one
that never asked the world what its loudnesses were. The carriage
now takes the declared set, and a radiated row must answer for
every loudness its world can actually speak.

## The proof, and a subtlety

186 specs (three new), three seals bit-identical — and for this
card the seal argument has a nice edge worth teaching: deleting
three copies of the road kinds *couldn't* move the seals, but not
for the usual "pure refactor" reason. The composed declarations
must be **payload-identical** to the deleted copies, because
byteform serializes payload fields in declaration order and the
seal hashes those bytes. The only thing allowed to differ was the
`doc` strings — developer-facing prose byteform never touches. Had
one field been reordered in the shared declaration, three seals
would have shouted at once. They didn't, which is the instrument
confirming the extraction preserved the public API to the byte.

## The CS underneath: contracts checked at the boundary

Bertrand Meyer's design-by-contract says a module should state
what it requires and check it at the boundary — preconditions
belong where the caller hands things over, not scattered through
the callee's internals. Our vocabulary rules had an odd prior
life: they existed, completely, but as a *spec file* — manual
assertions holding the space vocabulary to its own rules at test
time. Executable documentation, genuinely useful, and structurally
in the wrong place: a world assembled wrong at runtime never met
those rules; it met the four partial checks instead. The move this
card makes is small and general — promote the rules from test-time
description to construction-time contract, then point the spec at
the checker so the rules are stated once and exercised twice. When
a rule matters, its home is the boundary it protects; the test
suite visits, but shouldn't be the landlord.

## What we got wrong

The rules lived in that spec file for four cards, and we called
the vocabulary "strict from day one" the whole time. It was strict
*at test time, for the one world the spec imported*. The office
and continent vocabularies were never held to the rules at all
until tonight — they passed, but by discipline rather than by
contract, and the difference between those is exactly one bad
Friday. Schemas harden from the edges inward, the working
agreement says; the edge was softer than advertised, and now it
isn't.

Last stop on the overnight run: the hygiene sweep — twelve small
things, none of which deserves its own essay, all of which deserve
to stop being true.
