# What Failure Looks Like

*Post 0009 · pinned at tag `post/0009` · lines of code shipped: 0 ·
~7 min read · plain-language version: [simple](./simple.md)*

*Previously: post 0003 chartered the lore shelf as an eval suite —
stories the engine must be able to host, a floor rather than a
ceiling. Post 0007 added the shelf's first engine-first residents,
the Vessari and the Khedrun.*

---

> **Eval notes.** The Khedrun exist to prove the engine can host a
> martial temperament whose violence is *economically legible*: war
> as provisioning, fuses as patience made mechanical, plunder as
> circulation. Systems where war cannot be caused by prices — or
> where a declaration cannot cite the exact events that provoked it —
> fail this entry.

That paragraph closes the Khedrun's lore file, and it was written
almost as an afterthought — card 118 needed to say what its two
crash-test civilizations were *for*, so each entry got a section
stating it. Then Mike asked the question this card answers: the
Vess, the Continuance, and the Marrow Fleet don't have one of these.
Should they? And as the shelf grows more kinds — civilizations are
one, worlds are another — is this just a practice now?

Yes, and yes. This card backfills eval notes onto the three
story-first civilizations, gives the world library its collective
one, and writes the practice into the shelf charter as flexibility
principle 7. Zero lines of code; one sentence of constitution; five
paragraphs of acceptance criteria that were always true and never
written down.

## A test suite that forgot its asserts

Post 0003's charter is unambiguous: every entry on the lore shelf is
a test case. A proposed mechanic is held against the stories, and a
mechanic that structurally can't host one gets redesigned — not the
story. That charter is the shelf's whole reason to exist.

But look at what the two generations of entries actually say. The
card-118 residents each end by stating a falsifiable claim: here is
what this entry proves, here is what fails it. The card-129 cast —
richer, stranger, three corners of a parameter space — state their
criteria *nowhere*. When card 118's schema review asked "can this
hold the Vess?", the reviewer had to derive the answer from nineteen
paragraphs of portrait: which parts are load-bearing capabilities,
and which are texture? A crystalline mind the size of a subcontinent
is memorable; *what schema constraint does it forbid?* You can work
it out. You shouldn't have to.

That's the difference between a pile of examples and a test suite:
each test states its assertion. We had built an eval suite with
beautifully engineered arrange and act steps and no asserts — every
case exercised the system and none said what a red run looks like. A
test that can't fail isn't a test; it's a demo. The fix is the
smallest possible one: every entry now ends with **Eval notes** —
what this entry exists to prove, and what would fail it.

The three backfilled assertions, compressed: the **Vess** prove the
engine can host a mind without a census — plural, fuzzy-edged agents
deciding at consensus speed, whose memory doesn't expire and whose
violence is severed connection rather than combat. The
**Continuance** proves a civilization can be an artifact — one mind
become millions of semi-independent forks, personhood as policy, and
ledgers that are never permitted to forget. The **Marrow Fleet**
proves a civilization can stand nowhere — no homeworld, location as
a set of trajectories, wealth as rights and reputation rather than
mass. Each note also names its failures: a schema requiring countable
individuals fails the Vess; one equating civilization with biological
species fails the Continuance; a mandatory homeworld column fails the
Fleet at a stroke. None of this is new lore. It's the acceptance
criteria the portraits always implied, surfaced where a schema review
can trip over them.

The world library got one note, not fifteen. Its assertions were
always collective — habitability is a relation, not a column; types
are presets, not enums — so a per-type note would have been padding
dressed as rigor. One judgment call, recorded, reversible the day
some world type grows an assertion of its own.

## The shape rule, and the trap it guards

The charter amendment (lore README, principle 7) fixes the form: last
section in the file, two to four sentences, **one falsifiable minimum
capability**, never a feature list. Story-first entries state an
*expressibility* claim — the engine must be able to host this.
Engine-first entries state an *emergence* claim — the engine
demonstrably grew this. The two directions already had names (post
0007 coined them when the Vessari and Khedrun joined the shelf); now
every entry declares which kind of test it is.

The never-a-feature-list clause is the load-bearing one. An eval note
that swells into an enumeration — "the engine shall support lattice
minds, meridian networks, dopant scarcity, …" — is the PRD sneaking
back in through the annex, and post 0003 spent three drafts keeping
that document out of the charter. The floor-not-a-ceiling clause
applies to the notes themselves: they state the *least* an engine may
be, and stop.

There's a corollary that may matter more than the backfill. The road
to thirty species (card 130) starts from the gap list, because our
first three civilizations were all ancient, gentle, religious, and
likable — charm converging, proof absent. "Is the eval note
writable?" is now the entry gate: a species pitch that can't say what
it proves the engine must do isn't shelf-ready yet, however charming.
If it proves nothing, it's charm, not test.

## The CS underneath: assertions, and tests as specifications

Every testing tradition converges on the same three-beat structure —
arrange, act, assert — and the assert is the beat that makes the
other two mean anything. A test that arranges and acts but checks
nothing has a name in industry, **smoke test**, and a known failure
mode: it passes while the system quietly does the wrong thing.
Post 0003 said the shelf is TDD at architecture scale, tests written
before the system exists, executable only as design review. This
card is the observation that review-time tests need their assert
written down just as much as runtime tests do — *more*, because
there's no runtime to catch what the reviewer's attention misses.
The eval note is the assert clause of a test whose runner is a
human reading a schema.

The demand that the note be *falsifiable* — name what fails, not
just what's hoped — is Popper's line between a claim and a
compliment, and this repo already lives by it everywhere code runs.
The golden master doesn't say "history should be stable"; it says
seed 1893 seals to one constant and anything else is red. The
gremlin spec doesn't say "streams should be independent"; it steals
exactly one draw and demands the seal notice. Specs in this project
state what failure looks like — the lore shelf's entries now meet
the same bar as its specs. And the shape rule's minimalism has the
same defense as any good assertion's: assert the property, not the
implementation. A test that pins every incidental detail breaks on
every harmless change; an eval note that lists features forbids
futures the story never needed to forbid.

(The eval *loop* — mechanic held against stories, failure redesigns
the mechanic, surprises become next evals — is unchanged from post
0003, which carries its diagram; this card adds nothing to the loop
but the assert.)

## What we got wrong

**We built the eval suite and forgot the asserts — and we are the
same people who wrote the charter.** Post 0003 called the stories
test cases in its second paragraph, then shipped three test cases
with no stated pass/fail criteria, and nobody noticed for nineteen
cards. What finally surfaced the gap wasn't review discipline; it
was accident. The engine-first entries needed a section explaining
why crash-test civilizations belong on a shelf of authored fiction
at all — the justification *was* the assertion, so it got written
down. The receipts taught the tests how to state themselves,
backwards from how anyone would have planned it.

**The practice arrived nineteen cards late, and cheap is the reason
it's embarrassing.** Five paragraphs and a charter principle — this
was available the day post 0003 merged, at the cost of an hour. The
lesson generalizes and the constitution already knew it: cheap now,
brutal to retrofit. This one was still cheap because the shelf holds
five entries and one library. At thirty species it would have been a
season of archaeology, every portrait re-read by someone
reconstructing what its author must have meant to assert.

**And a process note, on the record: a lore card was worked by
Claude.** Board convention says lore cards are Mike's, worked
remotely. Mike explicitly delegated this one ("while I focus on
meetings"), and the assertions shipped here are Claude's drafts of
what are ultimately *Mike's* acceptance criteria. The working
agreement's bar — nothing merges that Mike can't defend without
Claude in the room — does extra work on this card, and the three
backfilled notes are exactly where his interrogation should land
hardest: is each fail-condition one he'd actually enforce in a
schema review?

## Next

Card 130's standing lore sessions now have their entry gate, and
card 119 still owes the universe its v0.1 cut. The next species to
join the shelf arrives with its eval note or it doesn't arrive.

Five entries, one library, six assertions. The shelf can finally
fail — which was always the point of calling it a test suite.
