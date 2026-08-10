# The Same Integer Ceiling

*Post 0020 · the plain-language version · the full essay:
[complete](./complete.md)*

There's one small formula at the heart of every journey in our
simulated worlds: divide the distance by the speed and round up,
because a trip that takes two and a half days occupies three days
of a traveler's life. Grain caravans use it, war parties use it,
letters used to use it, and the auditor uses it to reason about
money that's still in transit.

Last card's big review found that this one formula was written out
by hand in five different places — and, better, that the code
*knew*: two of the copies sat next to comments insisting "this is
the same integer ceiling the courier uses." The knowledge was one
thing; the spelling of it was five things. That matters because
several planned features will change how journeys are priced (maps
that change over time; ships with their own speeds), and each of
those five copies is a place a future change has to be hunted down
and edited identically. Miss one, and grain and news quietly start
traveling by different rules.

So this card gave the formula a home. There is now exactly one
statement of the arithmetic, with its safety checks attached — and
it turned out one of the five copies had never had any safety
checks at all, which is the quiet bonus of consolidation. On top
of it sits one question everything else asks: *how many days is
the road between these two places, in this world?* The caravans
ask it, the war parties ask it, the auditor is handed it. Ask it
anywhere, get the same answer, forever.

The card also finished a retirement that was overdue. There used
to be a single "channel speed" — THE speed of everything — from
the era when all news traveled uniformly. Two cards ago, news
learned to ride mechanisms that each carry their own speed, which
retired the old concept... in doctrine. In code it lived on, still
consulted by caravans and auditors as if it were still in charge.
Left alone, a world with fast mail and slow roads would have had
its letters and its grain priced by different constants without
anyone deciding that. The old dial now has one honest, narrower
meaning — it is the *road* speed, nothing more — and whether it
deserves a new name is a question waiting for Mike, because names
are his call.

The computer-science idea here is one of the most misquoted rules
in the trade: DRY — "Don't Repeat Yourself." People take it to
mean *never write similar-looking lines twice*, and that version
leads to terrible code, where things that merely rhyme get welded
together. What the rule actually says, as written in The Pragmatic
Programmer back in 1999, is that every piece of *knowledge* should
have exactly one authoritative home in a system. The unit is
knowledge, not text. Our five spellings of one pricing rule
violated it; our three worlds each declaring their own vocabulary
doesn't, because those are genuinely three different facts that
happen to look alike. Knowing which is which is most of the skill.

And because five copies of one truth reduced to one copy is — if
you did it right — no change at all, the proof was the usual one:
all 183 tests pass and all three worlds' tamper seals are
identical to the bit. History didn't budge; only the filing system
did. Engine 0.2.3, a patch.

What we got wrong: the review had labeled this card "small," and
the formula part was. But the auditor's doorway — the shape of
what you hand it — turned out to be copied in five calling places,
and updating a doorway costs more than updating a formula, because
every caller holds a copy of the shape. Duplicated interfaces are
pricier than duplicated arithmetic. We'll remember that on the
next extraction, which is a much bigger one.
