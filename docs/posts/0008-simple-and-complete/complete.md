# Simple & Complete

*Post 0008 · pinned at tag `post/0008` · lines of code shipped: 0 ·
~9 min read · plain-language version: [simple](./simple.md)*

*Previously: seven posts taught the engine — ticks, the annals, the
seal, beliefs. This one is about the posts themselves.*

---

> **Elementary.** "Imagine two players drawing cards from one shuffled
> deck. Player one starts taking one extra card each turn. Now every
> card player two gets is different. Nobody touched player two's
> rules. But player two's whole game changed."
>
> **Middle school.** "Every card the war machine draws after that is
> now a *different card* — it's reading one position further down the
> same shared deck. A saved universe that used to end in a peace
> treaty now ends in a conquest, just because the market got
> chattier."
>
> **High school.** "One extra draw — and every war draw, forever
> after, is a different number, because it reads one position further
> down the shared sequence."
>
> **Graduate.** "Ship one small feature (the market checks one extra
> price fluctuation per tick, one extra draw) and every subsequent war
> draw reads one position further down the shared sequence."

One idea — the shared-randomness bug from post 0001 — written four
times, for four different readers. There are 28 documents like this in
`docs/experiments/reading-levels/`: all seven posts this project had
published, each rewritten at an elementary, middle-school,
high-school, and graduate-CS reading level, under one shared rubric,
then cross-analyzed. No simulation produced them and no card asked for
them. This post is about why we made them anyway, what they taught us,
and the two decisions they earned — including the uncomfortable one,
which is that we then went back and edited every post we had ever
published.

## Why this jumped the queue

Sonder's constitution says the project is educational first: every
mechanic ships with a lesson, and the learning is the product, tied
for first place with the universe itself. The posts are not release
notes bolted onto a simulator. For most people who ever encounter this
project, the posts *are* the project.

So when Mike read back through them and said they were starting to
feel academic, that wasn't a style nitpick. It was a defect report
against the product's core. A universe simulator whose lessons only
land for readers who already have the background is teaching to the
people who need it least — the exact inversion of the charter. That's
why this work happened *now*, unscheduled, between the belief store
and the toy world: not because prose is more urgent than civilizations,
but because every future post would either compound the problem or
fix it, and there are decades of future posts.

We should be honest that "unscheduled" is doing real work in that
sentence, and we'll return to it in the mistakes section.

## The experiment

The instinct when writing feels too academic is to write simpler. We
didn't trust the instinct, so we tested it: rewrite everything at four
deliberately spaced reading levels and see what each level actually
costs. One rubric governed all 28 rewrites. Elementary (grades 3–5,
~500 words): no jargon, no code, analogies only. Middle school
(6–8, ~950 words): one excerpt, real CS ideas named when defined
in-line. High school (9–12, ~1,100 words): an intro-programming
reader, real terminology, the numbers kept. Graduate: full technical
content, standard names for every mechanism. Three invariants at every
level: no fact, number, seed, or hash may change; simplify by omission
and analogy, never by distortion; and every rewrite keeps at least one
"what we got wrong" admission, because the honesty is not a garnish.

The word counts alone settled half the argument. Elementary landed at
roughly 27% of each original's length, middle school at 44%, high
school at 65% — and graduate at 70%. That last number is the
diagnosis. If rewriting a post *for graduate computer scientists*
only shrinks it by 30%, the original was already a graduate-level
text; it was just wearing a literary voice. Every rewriter described
the graduate pass the same way: deleting charm, not adding rigor.
Nothing needed to be made more technical. The academic feel was never
the vocabulary — it was **claim density**: how many load-bearing
assertions each paragraph asks the reader to hold, and how many prior
posts it assumes.

The other findings, compressed:

- **Middle school was the surprise winner.** At ~950 words it kept
  the thesis, an excerpt, the named CS ideas, and the mistakes, and
  read as a genuinely pleasant standalone explanation.
- **High school was the trap.** Too tight a budget to keep the
  evidence — the seeds, hashes, and specs that make these posts
  *checkable* — and too loose to shed it. All seven rewrites blew the
  word budget, and every overrun was resolved by deleting whole
  claims. Had we followed the "just write simpler" instinct, this
  band is where we'd have landed: the posts would have gotten shorter
  by losing exactly the parts that let a reader verify us.
- **The mistakes sections survived every level.** Nothing else
  traveled so well. "We fixed the test, not the program" works for a
  ten-year-old and a professor.
- **Some concepts refused prose at every level.** The stream-shift
  bug, the cause graph, the log fanning out to its projections, the
  checkpoint trail being binary-searched for a first divergence, the
  capability argument list — every level struggled to *say* these,
  because they aren't sentences. They're pictures.

## What we decided

Two decisions, recorded at the harness level as ADR 0003.

**Every post now ships in two tracks.** Each post is a directory:
`complete.md` — the collegiate register we were already writing, kept
at full density, still the canonical version — and `simple.md` — a
plain-language companion in the middle-school register, ~950 words,
same facts, same mistakes, simplification only by omission. We
deliberately did *not* create four tracks (the experiment corpus
stays as a one-time artifact), and we deliberately did not sand the
canonical posts down toward the middle: the data says the simple
track carries the on-ramp so the complete track can keep its
evidence.

**Visuals are now a standing editorial question.** When a post
explains an algorithm or a mathematical argument, the review asks
out loud: does this need a diagram? The diagrams are Mermaid, inline
in the post source — text, so they diff, review, version, and pin at
tags like everything else. The source is canonical; a rendering is a
projection. The seven rewritten posts gained seventeen diagrams under
this rule, and the flagship is exactly the one the excerpt above was
struggling to say in words: three stacked panels of the shared stream
before the feature, after it, and with named streams.

Two smaller conventions rode along, both bought by experiment
findings: posts that lean on earlier posts now open with a one-line
*Previously* note (the rewrites got readable partly by severing our
cross-references, which told us what those references cost a new
reader), and second-order arguments now sit in labeled asides, so a
first pass can skip them without losing the main line — claim density
managed instead of denied.

And one observation is recorded without being solved: doing this
surfaced that the repo holds two kinds of decision — **harness
decisions** (how we build and run the thing: ADRs, toolchain, this
post) and **simulation decisions** (what the universe is: the laws,
the vocabulary, the lore). They'll likely deserve tagging when the
project is publicized. ADR 0003 writes the observation down so the
future decision starts from a record instead of a rediscovery.

## The CS underneath: evals, again — pointed at ourselves

Post 0003 chartered the lore shelf as an eval suite: handwritten hard
cases the engine must be able to host, a floor rather than a ceiling.
This card is the same methodology turned on our own prose. Each
middle-school rewrite was an eval of its post's *explainability*: if
the core argument couldn't survive translation to ~950 honest words,
the problem wasn't the translator. The rewrites that struggled told
us exactly where the posts leaned on background instead of
explanation — and, just as the shelf predicts, the failures belonged
to the system (a missing diagram, an unmarked aside, an unpriced
cross-reference), not to the test.

The experiment also handed us a live demonstration of the failure
mode post 0003 warned about. Goodhart's law — when a measure becomes
a target, it stops being a good measure — showed up *inside our own
corpus*: five of the seven elementary rewrites opened with the
near-verbatim sentence "We are building a pretend universe inside a
computer," and the middle-school band converged on the same shape.
Seven independent rewrites, one rubric, one voice: the rubric had
been optimized against, and the price was everything a voice is for.
The shipped simple tracks were forced into seven distinct openings
because of this finding. It is one thing to write "benchmark
overfitting" in a charter; it is another to catch your own test suite
doing it within a week.

There's one more idea worth naming, because it's the honest frame for
the section below. This repo's second law says nothing happens except
an append, and git already works that way: commits and tags are an
append-only record; the working tree is a projection of wherever you
point it. When we rewrote the published posts, we did not touch the
annals — every `post/NNNN` tag still points at the exact bytes it
always did. We re-rendered the projection. That framing is true, and
we're keeping it. It is also *convenient*, and the next section is
where we stop leaning on it.

## What we got wrong

**We rewrote our own published history, and you should know the
scope.** All seven living posts now differ from the versions their
tags pinned — moved into new directories, given previously-lines,
asides, and diagrams. Git rates the surviving text at 81–91%
similarity per post, which is a precise way of saying 9–19% of what
you read today at each post's canonical path was not there when that
post was published. Nothing was deleted and no fact changed (the
asides are verbatim relocations; we diffed every removed line to
check), but a reader who cites the living file is citing a document
that changed after publication, and nothing inside the file says so —
only the tags, the commit messages, and this post. The tags stay
frozen; the notebook keeps an open thread about one stale name
(`canon.lua`, renamed in card 117, still stands in post 0005's living
prose) precisely because "we may now edit living posts" makes the old
leave-it-forever answer less obviously right.

**The process ran backwards, and the paperwork was written after the
fact.** The working agreement's rhythm is card → branch → notebook →
work. This work began with no card, on a worktree named for an
experiment; card 147 was created mid-flight and the branch renamed to
match; and the notebook — the document whose whole job is to be a
live log of decisions — was reconstructed partway through, from the
conversation, after several decisions had already been made. The
project that insists nothing happens except an append did its process
bookkeeping retroactively. The notebook says this in its own honesty
ledger, and now the post does too. The record is complete; it was not
kept in order, and on a project whose thesis is that the log *is* the
product, that distinction is worth a public sentence.

**Our test corpus overfit its rubric** — the five identical openings
above. We caught it at cross-analysis rather than during generation,
which is the correct place for a review to catch things and still a
week later than a voice should be lost.

**And the unscheduled work collided with the scheduled kind.** While
this branch was open, card 118 merged and took post number 0007 for
the toy world. This post is 0008 because jumping the queue has a
price, and the queue collected it. Post 0007 will also need migrating
into the two-track structure — the first post to be born flat in the
new era and converted after, which is a small mess this card created
for its neighbor.

## Next

Card 119 cuts v0.1 and re-cuts post 0000 — the draft manifesto — which
now means re-cutting it into two tracks and asking it the standing
question every post answers from here on: *does this need a picture,
and does the simple version agree?* The experiment corpus stays put in
`docs/experiments/reading-levels/`, unmaintained, as the evidence this
decision can be checked against.

Same facts, two registers. Pick the one that fits, and check our work
in either.
