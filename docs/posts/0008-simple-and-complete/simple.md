# Simple & Complete

*Post 0008 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: seven posts explained how our universe simulator works.
This one is about the posts themselves.*

---

Here is the same idea, written four ways:

> **For a ten-year-old:** "Imagine two players drawing cards from one
> shuffled deck. Player one starts taking one extra card each turn.
> Now every card player two gets is different. Nobody touched player
> two's rules. But player two's whole game changed."
>
> **For a middle schooler:** "Every card the war machine draws after
> that is now a *different card* — it's reading one position further
> down the same shared deck."
>
> **For a high schooler:** "One extra draw — and every war draw,
> forever after, is a different number."
>
> **For a computer science graduate:** "Ship one small feature... and
> every subsequent war draw reads one position further down the shared
> sequence."

Same bug, four readers. We recently wrote 28 documents like this:
every post this project had published, rewritten at four different
reading levels. Nobody asked us to. Here's why we did it, what we
learned, and what we changed — including the awkward part, which is
that we then went back and edited every post we had ever published.

## Why we did this now

This project is a school first and a simulator second. Every piece of
the universe ships with an essay explaining how it works, and for most
people those essays *are* the project. So when Mike reread them and
felt they were getting too academic, that wasn't about style. It meant
the main product had a defect: lessons that only work for people who
already know the material are teaching the wrong audience. We stopped
and fixed it now because every future essay would have made the
problem bigger.

## The experiment

The obvious fix for "too academic" is "write simpler." We didn't trust
that, so we tested it. We rewrote all seven posts at four levels —
elementary, middle school, high school, and graduate — with strict
rules: no fact, number, or name may change; you may simplify by
*leaving things out*, never by bending the truth; and every version
keeps at least one "here's what we got wrong" confession, because the
honesty is part of the product.

Then we measured. The graduate versions — written for experts — came
out only 30% shorter than our originals. That was the diagnosis: our
posts were *already* expert-level texts, just wearing a friendly
voice. What made them feel academic wasn't fancy words. It was how
many ideas each paragraph asked you to hold at once.

Other results surprised us. The middle-school versions, about 950
words each, were the best all-around reads — they kept the main idea,
the real computer science, and the confessions. The high-school
versions were the trap: to hit their length, every single one had to
delete the specific numbers and test results that let a reader *check*
our claims. And some ideas resisted plain words at every level — not
because they're hard, but because they're pictures, not sentences.

## What we changed

Two things, now written down as an official project decision.

**Every post now comes in two versions.** The *complete* version is
the full essay we were already writing — it keeps all its depth. The
*simple* version is a plain-language companion, about a thousand
words, same facts, same confessions. You're reading a simple version
right now. We chose two versions, not four: the experiment showed the
middle-school register was the one worth maintaining, and that
watering down the complete version would cost the evidence.

**Every post now asks: does this need a diagram?** When an essay
explains an algorithm or a piece of math, we now draw the picture
instead of forcing a paragraph to do a diagram's job. The seven
rewritten posts gained seventeen diagrams, and the first one drawn was
the card-deck problem at the top of this page — the idea every
version struggled to say in words.

## What we got wrong

**We rewrote published history.** To add the diagrams and the new
structure, we edited all seven published posts. Between 9% and 19% of
what you'd read in each post today wasn't there when it was first
published. Nothing was deleted and no fact changed — but if you'd
bookmarked a post, it's different now, and the file itself doesn't
say so. The original versions are permanently preserved (every post
is pinned to a frozen snapshot in our code history), and this post is
the public notice.

**We did the paperwork after the work.** Our own rules say: open a
task card first, keep a live logbook of decisions as you go. This
work started with no card — the card was created halfway through, and
the logbook was written from memory partway in, after several
decisions were already made. For a project whose whole philosophy is
"write everything down as it happens," doing the bookkeeping
backwards deserves a public sentence. This is it.

**Our test copies all sounded the same.** Five of the seven
elementary rewrites opened with the near-identical sentence "We are
building a pretend universe inside a computer." When you write to a
checklist, you can lose your voice without noticing — a failure mode
we had literally warned ourselves about in an earlier post, and then
demonstrated within a week. The simple versions we actually published
were each forced to open differently because of this.

**Skipping the queue had a price.** While we did this unscheduled
work, the scheduled work went ahead and claimed post number 0007. So
this is post 0008, and the queue-jumper had to wait its turn after
all.

## What's next

Version 0.1 of the simulator is coming, and with it a rewrite of post
0000 — which will now be born with both versions and a diagram check,
like every post from here on. The 28 experiment files stay in the
repo, untouched, so anyone can check whether the evidence really
supports what we decided.

Same facts, two versions. Pick whichever fits — they'll never
disagree.
