# The Same Integer Ceiling

*Post 0020 · pinned at tag `post/0020` · engine 0.2.3 · ~4 min
read · plain-language version: [simple](./simple.md)*

*Previously: the review counted five copies of one formula; post
0019 gave the courier a file. This card gives the formula a home —
and retires a concept that had outlived its own retirement.*

---

The codebase had been confessing this one for a while. In
`audit.lua`: *"the same integer ceiling the courier uses."* In
`space.lua`: *"travels at news speed: the same integer ceiling the
courier uses."* Comments insisting a piece of knowledge was one
thing — while the expression itself, `(d + speed - 1) // speed`,
was written out five times: in the carriage, the roads, the audit,
and two worlds. Five places a future change to how journeys are
priced (moving maps are card 125; per-hull speeds are card 163)
would have to be found by grep and edited in agreement.

Now there is one statement of it — `Travel.days(distance, speed)`
— and one question built on it that everything freight-shaped
asks: `Universe:days(from, to, tick)`, the road between two named
places at this world's road speed. The carriage computes row
arrivals through the former; the roads, both worlds' war parties,
and the audit price journeys through the latter. Grep for the
formula today and you find it once, with its assertions attached —
which the roads' copy, it turns out, never had.

## Why now

Two reasons, one per half. The duplication was the review's
finding 7 and it compounds: every copy is a place the next speed
model must be discovered. And `channel_speed` needed its demotion
made real — card 150 retired it as *the* speed (rows carry their
own), but it survived as a public field that roads, the audit, and
two worlds still read as authoritative. A world declaring a fast
carriage row would have had its news and its freight silently
priced by different constants. The field now has one honest
meaning — **the road speed** — one documented consumer chain, and
a note that renaming it (`road_speed`?) is Mike's call, not an
overnight one.

## The one contract change

The audit used to take `{ distance, channel_speed }` and rebuild
the courier's arithmetic privately — the exact drift the review
flagged, since the real courier has moved on to carriage rows. It
now takes `{ days = fn }`: callers hand it the same pricing the
freight actually rides (a closure over `Universe:days`), and the
audit computes nothing it doesn't own. The honest limit is written
at the contract: this explains belief drift by *freight* pace, not
by carriage rows — a world whose news and freight genuinely
diverge owes the audit a richer road at its migration card, and
card 163's docket already says so.

## The CS underneath: what DRY actually says

"Don't Repeat Yourself" is usually misquoted as *never write
similar lines twice*. What Hunt and Thomas wrote in *The Pragmatic
Programmer* (1999) is narrower and better: **every piece of
knowledge must have a single, unambiguous, authoritative
representation within a system.** The unit is knowledge, not text.
Five spellings of one pricing rule was a DRY violation; three
worlds each declaring their own vocabulary is not, because those
are three different pieces of knowledge that happen to rhyme. The
review's findings sort cleanly along exactly that line, and this
card fixed the one that was pure knowledge-duplication — which is
also why it could not move a seal: five copies of one truth,
reduced to one copy of one truth, is the identity function on
behavior. 183 specs and three seals agree.

## What we got wrong

The review sized this "small," and the *formula* was — but the
audit's road contract turned out to be the widest edit of the
card: five call sites across main and four spec files. Interface
duplication costs more than expression duplication — every caller
holds a copy of the shape — which is the DRY principle restating
itself at a larger scale, and a fair warning for the
believed-books card, whose duplicated knowledge is an entire
*fold*.

Next in the overnight queue: the vocabulary — one contract,
currently validated four partial ways.
