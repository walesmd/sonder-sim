# Success Debt

*Post 0017 · the plain-language version · the full essay:
[complete](./complete.md)*

Seven big changes landed in five weeks — three worlds on one
engine, mail that travels, roads that lose letters. Every one was
careful: designed, tested, sealed, written up. And then Mike
called a pause: nobody had stepped back and looked at the *whole
thing* since before all of it. This card is the pause. No new
features. Two jobs: review the code like a chief engineer, and
review the documentation like a product manager — with a rule
attached. The engineering review only *identifies* problems (Mike
decides what to fix and when); the documentation review *fixes*
things immediately.

Here's the finding that proves the pause was needed. Eleven weeks
ago we wrote an architecture decision that said: every saved
universe file must record *which world* created it, so that two
worlds' files can never be confused. That decision was approved,
published, and celebrated. It was never actually built. Today, a
fantasy-continent universe and a space universe made from the same
seed produce files you genuinely cannot tell apart without opening
them and squinting at the events. Nobody decided to skip it.
Everybody just kept shipping the next exciting thing, and
"decided" quietly got treated as "done."

That pattern has a name in software: technical debt — Ward
Cunningham's thirty-year-old idea that shipping with a known
shortcut is like borrowing money. You go faster today and pay
interest until you repay the principal. This project actually
handles *deliberate* debt beautifully: our known placeholders are
recorded the day they ship, each with its retirement plan (we call
them licensed shortcuts, and there's a ledger). What the review
caught is the other kind — debt nobody decides to take on. The
same bookkeeping helper is hand-written three separate times, once
per world, because the worlds arrived faster than anyone stopped
to share the code — two of the three files even contain comments
*predicting* someone would eventually need to fix this. We call
that success debt: interest charged not on corners you cut but on
ground you gained. The only cure is what this card is — a periodic
beat where someone reads everything and writes down what speed
outran.

The full review used three parallel readers — one over the
engine's fourteen modules, one over the twelve world files, one
over a hundred-plus documentation files — and produced thirty
findings, ranked. Five deserve their own future cards. Four attach
to cards that already exist. Twelve are small enough to fix in one
tidy afternoon, and two findings were compliments (the test
fixtures are clean, and not one word of the worlds' vocabularies
is dead weight). Nothing was changed in the engine this card:
identify first, decide second is the whole discipline.

The documentation half got fixed on the spot, because its verdict
was stark: our documentation of *each step* is excellent —
seventeen essays, every increment explained twice, mistakes kept —
but documentation of *the system* simply didn't exist. The essays
are deliberately frozen in time, like published journal issues, so
they describe how each piece was earned, not what stands today. A
newcomer could read all seventeen and still have no map. There was
no diagram of how the modules fit together, no reference for the
programming interface, no page describing the database file every
run writes (the one schema shown anywhere in the docs was two
versions out of date), and the README's very first status line
said "v0.1" while the software itself reports 0.2.0.

So the project now has two kinds of documentation, and the
difference is written down as a rule: **essays are pinned, and
never change; reference pages are living, and staleness in them is
a bug.** The new living shelf: an architecture page with three
diagrams (the module map, what happens inside one tick of time,
and the full journey of an event from the moment it happens to the
moment some mind believes it); a database reference with every
table, every column, and a cookbook of ready-to-paste queries; a
reference for the engine's programming surface; a page listing the
three golden fingerprints and how to verify a saved universe
hasn't been tampered with; and an index that tells you which kind
of page to read for which kind of question. Plus a stack of small
honesty fixes: the glossary had defined "world" twice (violating
its own one-definition rule), the README never mentioned the flag
that selects which of our three worlds to run, and both world
charters now carry a living "current state" section.

What we got wrong, kept on the record: the post index went
unmaintained through four straight releases because our checklist
said "fix stale docs" without naming which docs mattered — unnamed
obligations don't survive busy weeks, so they're named now. The
plain-language essays (like this one) stopped getting diagrams
after post 0006 and nobody noticed for ten posts — backwards,
since these are the essays where a picture helps most. And the
biggest one: an approved decision is not an implemented decision.
From now on, a decision gets code or a card the day it's accepted.

Next, Mike picks from the findings menu. The engine didn't change
this card — and that's the point. You can't reorganize what you
haven't read. Now we've read it.
