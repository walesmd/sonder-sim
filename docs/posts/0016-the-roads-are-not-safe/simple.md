# The Roads Are Not Safe

*Post 0016 · the plain-language version · the full essay:
[complete](./complete.md)*

Last post, our fantasy continent got honest mail: letters ride
real roads to named recipients, and news only exists if someone
witnessed it or carried it. This post, the mail gets dangerous.
Letters can now be lost — and the very first casualty, four days
into the run, was a small tragedy nobody in the world will ever
know happened.

Here's what the permanent record shows. On day 3, the valebright
(the rich valley people) accepted a salt offer from the ashfold
(the small clan holding the mountain gate) and immediately sent
payment — that's how trade works there: you act on your own yes
the morning you make it. Their acceptance letter left the same
day. On day 4, somewhere on the road, the rider carrying it was
lost. The letter died with them. But the payment was already
moving — coins travel in strongboxes on the same roads — and on
day 6 the ashfold received four hundred and fifty cents from
neighbors who, as far as the ashfold know, never answered their
offer at all. They will never ship the salt. The valley has paid
for salt that will never come, and will never learn why. Nobody
saw the rider die. The only witnesses are the history book and
you, reading it.

Building this took four decisions, and Mike made the important
ones in plain language.

**How often do riders die?** Wrong question, it turns out. Mike's
ruling: we can't say how often a rider dies — that depends on
technology, hardiness, things we haven't modeled — and it's not
the road that kills them, it's what they *encounter* on the road.
So the dice roll once per day of travel: a longer road is more
dangerous simply because it's longer. For now, one encounter per
fifty rider-days — a number we openly call a placeholder.

**Why did the rider die?** The record refuses to say — on
purpose, and this became the card's big principle. The tempting
move was a table of reasons: roll one, bandits; roll two, a
swollen river. Mike vetoed the whole category: the goal is not a
configuration file of twenty things that could happen — there
should be an *engine that creates the options*. A config-file
bandit is a costume with nothing underneath: nobody actually
robbed anyone; nothing actually has the letter. So until that
engine exists (it's now on the project board), the record says
*somewhere on the road, a letter is lost* — and stops, because
that is the full extent of what this universe knows. The universe
does not fake knowledge it lacks.

**When did they die?** On the actual day. The computer decides
the letter's fate the moment it departs — but the history book
stamps the death on the day it really happens, two days into the
pass, not the day the dice were rolled. And no one magically
finds out: the death is quiet, in a place beyond everyone's
earshot. Twenty-seven riders die completely unobserved in the
first four hundred days of our test world. These are the first
events in the project's history that no civilization ever learns
about — the universe now keeps secrets for real.

The world already knew how to cope, with zero new code: sellers
who hear nothing for eight days simply write again. From inside
the world, a lost letter is indistinguishable from a rude
neighbor. The steppe assumes the mountains are ignoring them.

Two satisfying results from the computer science shelf. That
half-settled salt trade is a famous impossibility called the Two
Generals' Problem, proved fifty years ago: two parties talking
over a channel that can lose messages can never reach guaranteed
agreement — every "did you get my yes?" needs its own "did you
get my did-you-get-it?", forever. Real networks live with this;
so does Harrow now. And the sellers' eight-day patience window is
exactly what the internet calls a retransmission timeout — the
mechanism at the heart of how the web reliably delivers anything.
We didn't design either resemblance; both fell out of letters,
patience, and honest bookkeeping.

One number moved that never moved before. Our worlds carry a
tamper seal — a fingerprint of all history — and last post we
were proud it *didn't* change. This time it had to: lost letters
change which trades happen, which changes everything downstream.
So the continent's seal was deliberately re-cut, with the reason
written in the ledger, and the engine's version went from 0.1.1
to 0.2.0 — the first use of our new rule that the version number
tracks the universe, bumping its middle digit only when history
itself forks. The space and office worlds, which declared no
dangers, are untouched to the last bit.

What we got wrong, kept on the record: Claude asked four
architecture-flavored questions that only made sense once
restated as one rider's story — third language lesson this
project has paid for. The card's own two-week-old warning (that
lost mail would force us to loosen the accounting audit) turned
out to be wrong — losses change behavior, never arithmetic, so
the audit passes untouched. A dormant map bug — "unknown places
are next to everyone" — would have broadcast each rider's lonely
death to the whole continent, and was caught only because a death
finally needed a somewhere. And an earlier card confidently
predicted a different card would earn 0.2.0 first. The code
disagreed. It usually does.
