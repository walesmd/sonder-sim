# A File for the Question

*Post 0019 · the plain-language version · the full essay:
[complete](./complete.md)*

Every simulated day, the universe does the same dance: dawn breaks
(any letters that died on the road yesterday become part of the
record), the world's physics runs, and then each civilization
takes its turn — the mail arrives, the mind decides, its actions
happen. That dance is the heartbeat of the whole simulation, and
its exact order is sacred: change the order and the same seed
grows a different universe.

The problem the last review flagged: the *mail delivery* part had
grown up inside the heartbeat itself. In the beginning it was four
lines — news reaches everyone a few days late, done. Then news
learned to ride mechanisms. Then letters learned to die on the
road, with dice and a calendar of scheduled tragedies. Forty lines
of the most actively-evolving code in the project, living inside
the one function that must never change. And the next several
planned features — news that arrives *garbled*, news that gets
*reinterpreted* by the culture receiving it — all need to modify
exactly that mail-delivery code. Every one of them would have been
open-heart surgery.

So this card moved the mail out. There's now a courier module —
one file that owns the bookmarks, the dice, the calendar of
in-flight letters, and the calendar of doomed ones — and the
heartbeat shrank back to something you can read in one breath:
dawn, physics, then for each mind: deliver, decide, obey. Future
mail features get a file of their own instead of the heartbeat.

How do you *prove* a reorganization changed nothing? This project
has an instrument for exactly that claim: every world carries a
tamper seal — a fingerprint of its entire history, sensitive to a
single displaced die roll. If the move changed anything — one
delivery a day late, one dice roll out of order — the seals would
shout. All 183 tests passed on the first try, all three seals
identical to the bit. Same universes, tidier machine.

The idea underneath comes, delightfully, from architecture — the
buildings kind. Architects talk about *shearing layers*: a
building is layers that change at different speeds. The land never
changes; the structure changes in decades; the wiring in years;
the furniture every week. Buildings survive when fast layers can
move without tearing slow ones — nobody should have to touch the
foundation to move a couch. Code works the same way. The heartbeat
is our foundation: unchanged in months, should be unchanged in
years. Mail delivery is our furniture: changed in four of the last
six cards. This card unbolted the couch from the bedrock, which is
all software people have ever really meant by the phrase
"separation of concerns."

One honest reflection instead of a mistake, since nothing broke.
We *could* have done this extraction two cards ago, when the mail
code first started growing — and we deliberately didn't, because
back then it had no dice, no calendars, no tragedies, and the
module we'd have designed around that simpler code would have been
the wrong shape for what came. This project extracts on the third
real need, never on speculation. The cost of waiting was one item
on a review list; the cost of guessing early would have been a
wrong abstraction holding future cards hostage. We'd pay the first
price again.

The engine ticks to 0.2.2 — a patch, by our convention, because
code moved and history didn't. Next up in the overnight queue: the
travel-time formula that's currently copy-pasted in five places
gets one home.
