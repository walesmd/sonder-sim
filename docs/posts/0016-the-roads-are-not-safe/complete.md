# The Roads Are Not Safe

*Post 0016 · pinned at tag `post/0016` · Lua 5.4 + SQLite · this
post's universe: Harrow, seed `7` · engine 0.2.0 · ~9 min read ·
plain-language version: [simple](./simple.md)*

*Previously: post 0014 designed the carrier taxonomy and the
witness rule; post 0015 built the mechanism rows and retired the
field on Harrow without moving a seal. This card makes the rows
dangerous — and moves one, on purpose, for the first time.*

---

Four chronicle lines from the first week of universe 7, exactly as
the observer sees them:

```
tick    3 · vale-bright · the valebright say yes to the ashfold: 5 salt for 450¢
tick    4 · the-roads   · somewhere on the road from vale-bright to ash-gate, a letter is lost
tick    4 · vale-bright · a strongbox leaves the valebright for the ashfold: 450¢
tick    6 · ash-gate    · a strongbox from the valebright reaches the ashfold: 450¢
```

Read it slowly, because five civilizations never will. The
valebright accepted the ashfold's salt offer and, acting on their
own yes the morning they made it, sent payment. The acceptance
letter died on the road a day out — the rider is gone, the yes with
them. So on day 6 the ashfold receive four hundred and fifty cents
from a neighbor who, as far as the ashfold know, never answered
their offer at all. The salt will never ship. The valebright have
paid for it. Nobody on the continent knows any of this happened —
not even the valebright, who will simply never see salt arrive and
never learn why. The only witnesses are the annals, and you.

This is card 151: news now wears according to what carries it, and
the first wear we built is the oldest one — the letter that never
arrives.

## Why now

Card 122 shipped delay only, and said so: degradation was split out
on Mike's verdict that wear is a property of the *means* by which
information travels, never a global dial. That deferral has been
waiting for a mechanism to be a property *of* — and post 0015
finally built mechanisms as declared rows. Degradation is the next
rung of the build map for a structural reason too: everything
behind it (reception, interpretation, exchanges, grown-up money)
gets harder to retrofit onto a perfectly reliable postal system,
because minds built against certainty never learn to hedge. The
roads had to become unsafe before anyone builds on their safety.

## Exposure, not fate

The design questionnaire's first real fight was over the numbers.
The obvious schema — "this road loses one letter in ten" — died on
contact with Mike's objection: we *cannot say* how often a rider
dies. That depends on the civilization's technology, their
hardiness, on numbers we haven't modeled. And the road itself was
the wrong subject:

> It's not necessarily the road. It's what they encounter on the
> road. A longer road means more danger because there's more
> opportunity — but that opportunity is not always bad. Road length
> increases scale for interaction; it does not necessarily mean
> that interaction is bad.

So the column ADR 0005 called a failure profile is really the
narrow first slice of an **encounter profile**: the dice roll per
day of exposure, not per journey. Harrow's letters row declares one
encounter per fifty rider-days, which makes a four-day road lose
about one letter in thirteen — and the number is an honestly
labeled placeholder whose real inputs arrive later. Longer roads
are more dangerous purely because they are longer. And the same
seam that today rolls only losses is shaped for encounters that
help — the rider who meets a caravan and arrives knowing more than
they left with — because Mike's ruling was about interaction, not
misfortune.

## The refusal: losses have no reason

The second fight was better, and it produced doctrine. The
tempting way to make losses feel rich is a table of flavors: roll
one, bandits; roll two, a swollen river; roll three, the rider
misplaced it. Mike refused the entire category:

> The goal of this exercise is not to have some sort of
> configuration file with 20 or 30 unique things that could happen.
> It's to simulate the universe. ... It's not a definition of
> options. There's an engine that creates the options.

A config-file bandit is cosmetic: the dice pick a costume, and the
universe underneath knows nothing of bandits — nobody robbed
anyone, nothing has the letter, the "reason" is flavor text wearing
a fact's clothes. So this card ships the refusal: **the loss event
carries no reason at all.** The chronicle says *somewhere on the
road, a letter is lost* — and stops, because that is the full
extent of what this universe currently knows. When the encounter
engine exists (captured as card 165, a research card in the
carrier-taxonomy tradition), "lost" can become "stolen by someone
who now has it" — a generated fact with cause links and
consequences, never line four of a config file. Until then, the
universe does not fake knowledge it lacks.

One good bug fell out of taking "an event always happens
somewhere" seriously. The loss happens on the road — and the road
is not one of Harrow's five named places. Harrow's map answered
questions about unknown places with "distance zero: adjacent to
everyone," a leftover convenience from genesis at the-void. Under
the witness rule that convenience was a leak: a rider's lonely
death at an unmapped location would have been *heard by all five
civilizations at once*. Unknown places are now far from everyone
(the-void stays adjacent — creation was loud), and the rider dies
at `the-roads`, beyond every ear.

## The true day, and the first oblivion

Two more rulings, both Mike's, both arriving as common sense
rather than architecture. A loss happens at a particular point in
time: the fate is *drawn* at departure (like delay always was),
but the event is *stamped* the day the rider actually dies —
day 42, two days into the pass, not day 40 when the dice happened
to roll. The engine holds each sealed fate on a small calendar and
emits it at dawn. And nobody magically becomes aware: the loss is
quiet, at a place mapped beyond every earshot, so its witness set
is empty. These are the first truly unwitnessed events in any
world's content — post 0015 had to admit that oblivion existed
only in synthetic specs; twenty-seven riders per four hundred days
now die entirely unobserved in production, and the only reader who
ever knows is the one holding the chronicle.

The seller's response needed no new code at all. Harrow's minds
already re-offer after eight quiet days — a patience window built
at card 160 — so a lost offer reads, from inside the world, as a
slow counterparty, and commerce limps onward. Nobody knows the
roads eat mail. The steppe assumes the mountains are rude.

```mermaid
sequenceDiagram
    participant V as the valebright
    participant R as the roads
    participant A as the ashfold
    A->>V: offer: 5 salt at 90¢ (arrives day 3)
    V->>V: say yes — and pay, acting on their own acceptance
    V-xR: the acceptance dies with its rider (day 4)
    Note over R: quiet, unwitnessed —<br/>only the annals knows
    V->>A: the strongbox arrives anyway (day 6): 450¢
    Note over A: paid for a yes<br/>they never received
    Note over V: salt never arrives;<br/>no one learns why
```

## What the audit said

Card 151 carried a warning recorded two cards in advance:
degradation forces a second relaxation of the double-entry audit,
because once news can arrive wrong, "drift explained by news still
in flight" needs a new definition. We braced for it, and it did
not come. The four-hundred-day audit passes untouched — zero
violations, zero mismatches, zero unexplained — because loss
changes *behavior*, never *book accuracy*. A letter that never
arrives moves no column: the trade simply doesn't happen, or
half-happens with every recorded step arithmetically clean.
Harrow's books fold events at their own gates, and the gates never
lie. The warned-of relaxation belongs to degradation's second half
— wear that corrupts what a believed copy *says* (blur), which
waits for its first consumer. The warning stays on the record as
the rare prediction that was wrong in our favor, with one caveat
found while checking it: the audit's in-flight explainer still
computes with the old field arithmetic — harmless today, on the
migration card's docket (card 163) before space gets real
mechanisms.

## The first deliberate fork

Unlike post 0015's surprise, this card *meant* to move history.
Lost letters change which trades happen; changed trades change
everything downstream — twenty-seven losses, eight half-settled
trades, and a slightly different war in seed 7's first four
hundred days. Harrow's golden seal re-cut, once, loudly, with its
ledger entry: `9be58120c48a121b` → `c6dc5ef5b428aa85`. And three
days after adopting the version convention — minor bumps when a
seal moves, never silently — the engine took its first minor bump:
**0.2.0**. Space and the office stand bit-identical: no failure
profiles declared, zero new draws, two seals untouched. The
courier's dice ride their own named stream (`rng.courier`, the
name now reserved), so no other subsystem's history shifted by
even one draw.

## The CS underneath: two generals and a patient timeout

The half-settled trade at the top of this post has a famous name.
The **Two Generals' Problem** (Akkoyunlu, Ekanadham & Huber 1975;
Gray 1978 gave it the generals) proves that two parties
communicating over a channel that can lose messages can *never*
reach guaranteed agreement — every acknowledgment needs its own
acknowledgment, forever. It is the canonical impossibility result
of distributed systems, and Harrow now lives it: the valebright's
yes needed to arrive for the trade to be mutual; it didn't; and no
protocol either side could follow would have made them certain.
The charter called this settlement risk and blessed it — Sonder's
answer to two generals is the medieval one: accept the risk, price
it, and let card 159's debt machinery eventually offer recourse.

The mitigation Harrow's minds already had is equally canonical.
Re-offering after eight quiet days is a **retransmission timeout**
— the heart of ARQ (automatic repeat request), the mechanism under
TCP: send, wait for an acknowledgment, resend on silence. And the
single-fire settlement discipline from card 160 (act on a letter
the morning you learn it, never again) is **at-most-once
delivery** semantics — the guarantee distributed systems reach for
precisely because exactly-once is two generals in disguise. None
of this was designed to imitate networking; it fell out of
letters, patience, and honest books. The lesson we keep relearning
is that distributed systems theory is just the study of
civilizations that happen to be computers.

## What we got wrong

**Four architecture questions that needed one rider.** The Q2
design questions — event ownership, unmapped locations, emission
timing — landed on Mike as noise until they were restated as a
single story: a rider leaves on day 40, dies on day 42, and the
book must say who writes the sentence, where it happened, and
when. His plain-language answers to two of them ("an event always
happens somewhere"; "a loss should happen at a particular point in
time... they don't magically become aware") *were* the design.
Third vocabulary lesson this project has paid for; the standing
rule is now: pose design questions as stories, and recognize
common-sense restatements as verdicts.

**The warning that didn't fire.** The card's own description
promised an audit relaxation this card would force. It didn't —
loss-only wear leaves books exact. Recorded warnings are good;
re-examining them instead of obeying them is better.

**The map leak.** "Unmapped means adjacent" survived two cards of
witness-rule work because nothing ever happened at an unmapped
place. The first event that needed a nowhere found it. Latent
conveniences are latent until the day they're load-bearing.

**And a prophecy corrected.** Card 163's description confidently
assigned space's migration the first 0.2.0. This card got there
first. Predictions about version numbers, like predictions about
seals, lose to the code.

Next: the roads can lose a letter, so the successor cards inherit
a lossy world honestly — reception (157) will gate what arrives,
interpretation (152) will bend it, and somewhere past card 165,
the letter that today is merely *lost* will instead be in
somebody's saddlebag, riding toward a purpose.
