# Cross-analysis: seven posts, four reading levels

*28 rewrites of the 7 published posts (0000–0006), produced against one
shared rubric. Everything below compares the rewrites to each other and
to the originals. The prompt behind the experiment: the posts can feel
academic — what do we actually gain and lose at other levels?*

## The numbers first

Word counts include headers and code blocks, so ratios are approximate
but consistently measured.

| Post | Original | Elementary | Middle | High school | Graduate |
|------|---------:|-----------:|-------:|------------:|---------:|
| 0000 First Tick | 1,851 | 588 | 949 | 1,399 | 1,259 |
| 0001 Ticks & Determinism | 2,634 | 640 | 983 | 1,527 | 1,746 |
| 0002 The Event Log | 2,742 | 614 | 1,078 | 1,551 | 2,021 |
| 0003 The Lore Shelf | 2,428 | 602 | 1,052 | 1,541 | 1,753 |
| 0004 The History Book | 2,160 | 617 | 998 | 1,469 | 1,533 |
| 0005 The Tamper Seal | 1,937 | 590 | 949 | 1,370 | 1,482 |
| 0006 Truth & Belief | 2,000 | 584 | 977 | 1,483 | 1,300 |
| **rough share of original** | 100% | **~27%** | **~44%** | **~65%** | **~70%** |

Two things jump out of the table before reading a single rewrite:

1. **The elementary and middle bands landed inside their budgets on all
   seven posts; the high-school band blew its 900–1,200 target on all
   seven.** Every rewriter reported the same conflict: the rubric said
   "keep the concrete numbers and details" and the budget said 1,200
   words, and for these posts those are incompatible. That is a finding
   about the originals, not about the rubric: their density is not in
   the prose, it's in the *evidence* — seeds, hashes, counts, named
   files, specific specs. You can compress the writing 35% before you
   have to start deleting claims; after that, every cut is a fact.

2. **The graduate rewrites are only ~30% shorter than the originals,
   and every rewriter described the work the same way: "deleting charm,
   not adding rigor."** Nothing needed to be made *more* technical.
   The mechanisms were already named (event sourcing, capability
   security, watermarks, golden masters); the graduate pass mostly
   swapped narrative connective tissue for standard labels
   ("lower-bound specification," "rejection sampling," "fail-closed
   writes / fail-open reads").

Put those together and you get the central diagnosis of the experiment:

> **The originals are already graduate-level texts wearing a literary
> voice.** The gap between an original and its graduate rewrite is
> small and stylistic. The gap between an original and its high-school
> rewrite is large and *substantive* — claims have to die to get there.
> If the posts feel academic, the cause is claim density and assumed
> background (including assumed prior posts), not vocabulary.

## What survives translation, by layer

Across all seven posts the same layers proved portable or fragile,
independent of topic:

**Survives to every level (including elementary):**
- The narrative devices. The gremlin stealing one number, the war
  office reading its mail, the diary that only appends, the seed as a
  recipe, the wax seal. Every rewriter leaned on the device the
  original had already built; where the original argued *through* a
  story, the lower levels inherited it nearly free (0002, 0005, 0006).
- The "what we got wrong" sections — the single most level-robust
  material in the corpus. Admissions of error translate at every
  register ("we fixed the test, not the program"), and several
  rewriters noted they are what keeps the low-level versions from
  feeling like children's marketing. The honesty is load-bearing at
  every reading level.
- The core thesis of each post. No level had to give up "same seed,
  same universe," "nothing happens except an append," or "act on what
  you heard, not what is true."

**Survives to middle school, dies at elementary:**
- Anything requiring positional/sequential reasoning about randomness
  (why one extra draw shifts every later draw) — the shared-deck
  analogy barely carries it.
- Named CS concepts as *names* ("this is called event sourcing") — the
  middle band can drop a name without depth; elementary can't use it
  at all.

**Survives to high school, dies below:**
- The numbers-as-argument sections (2^64, birthday bound, the 0.5
  expected duplicate universes), the vocabulary of versioning and
  forward compatibility, tamper-evidence vs tamper-proofing — several
  rewriters noted these need words ("cryptographic," "version") that
  simply don't exist lower down.

**Survives only at graduate:**
- The second-order arguments: the log as simultaneously cache and
  authoritative record; the recursive-CTE fixpoint/visited-set
  termination argument; watermark generality; the re-cut-ledger
  bisection reasoning. The 0004 rewriter made the right call explicit:
  below graduate these degrade into hand-waving, so they were *dropped
  rather than distorted* — which means a general reader of the lower
  versions never learns these ideas exist.
- The post-series web. Cross-references (card numbers, "post 0005
  promised...", the re-cut ledger) had to be cut from every low-level
  version. The lower the level, the more standalone the post — and the
  less the series reads as one continuous project.

## Per-post grain

- **0000 (First Tick)** is a manifesto, not a mechanic write-up, and it
  resisted the rubric's shape: its CS lives inside the four bets, not
  in a section. It compressed *hardest* at graduate (1,259 words — the
  shortest graduate file) because much of it is voice, and voice is
  what graduate compression deletes.
- **0001 (Ticks & Determinism)** was the most resistant post overall:
  its argument *is* its numbers. Elementary keeps only the shared-deck
  story and the Minecraft scale; high school ran 20%+ over budget
  because every section is concrete detail the rubric protected.
- **0002 (The Event Log)** translated down the most gracefully — the
  original already argues by ledger, photograph, and telescope, so
  lower levels inherited analogies instead of inventing them. It is
  also the longest graduate rewrite (2,021), i.e. the post with the
  most irreducible claims.
- **0003 (The Lore Shelf)**, the zero-code post, translated *down* more
  easily than expected (the lore excerpt doubles as the code sample at
  every level) but is so densely packed — four mechanisms, four schema
  commitments, three mistakes — that high school still burst its
  budget on connective tissue alone.
- **0004 (The History Book)** is excerpt-driven ("ask the file"), so
  lower levels lose the most: proof-by-query becomes "we asked and got
  the same answer." Its triggers translated beautifully (pen vs
  pencil, tripwires); its recursive query didn't translate at all.
- **0005 (The Tamper Seal)** has the most abstract payload
  (state-is-the-log, canonical bytes, watermarks) but was rescued at
  every level by the gremlin — a concrete villain is the single best
  translation device in the corpus — and by a central metaphor (the
  seal) the project vocabulary had already done the work of coining.
- **0006 (Truth & Belief)** mapped almost one-to-one onto everyday
  machinery (mailbox → courier, dealt cards → capabilities, telephone
  game → degraded news). Law 3 turns out to be the most inherently
  teachable idea in the project.

A quiet defect worth noting: the seven elementary versions, written to
one rubric, converge on a nearly identical opening formula ("We are
building a pretend universe inside a computer..."). Fine for any single
post; monotonous as a series. Voice diversity is another thing the
bottom band pays for.

## What each band would cost us, as a house voice

- **Elementary (~27%)** proves the ideas are sound — every core thesis
  survived — but it can only ever be a companion artifact. It cannot
  cite, cannot cross-reference, cannot show code, and cannot carry the
  educational obligation the working agreement actually imposes (Mike
  must be able to defend the *implementation*, and these versions
  don't contain it).
- **Middle school (~44%)** is the surprise of the experiment: it keeps
  one excerpt, names real CS ideas, keeps the mistakes, and reads as a
  genuinely pleasant standalone explanation. As an *entry track* —
  not a replacement — it's the strongest candidate.
- **High school (~65%)** is the awkward band, structurally: too tight
  to keep the evidence, too loose to shed it. Every rewriter fought
  the budget here, and the resolution was always to cut whole claims.
  If the goal were one simpler canonical voice, this is the band the
  posts would naturally land in — and the experiment suggests they'd
  lose their proof-carrying character to get there.
- **Graduate (~70%)** demonstrates that the originals' length is not
  bloat: ~30% is removable narrative, and what it buys is the wit, the
  jointly-owned tone, and the story-before-theory sequencing the
  project's charter explicitly wants. The graduate versions are
  competent and slightly lifeless — precision kept, warmth mostly
  gone.

## If the goal is "less academic," the levers this data suggests

Not decisions — observations for the review:

1. **The felt "academic-ness" is claim density, not diction.** A
   version that keeps the voice but caps claims-per-section (moving
   the second-order arguments to labeled asides or footnotes) would
   likely read far lighter without deleting anything.
2. **The serial dependence is a real on-ramp cost.** Lower levels got
   more readable partly by *severing* cross-post references. A
   "previously in Sonder" one-liner convention could buy much of that
   without breaking the series web.
3. **The analogies are already the posts' best translation layer** —
   where an original had one load-bearing analogy per concept (0002,
   0005, 0006), simplification was nearly free; where it argued by
   number (0001) or by query (0004), it wasn't. That's a repeatable
   editorial check for future posts.
4. **The mistakes sections should never be the thing cut for length.**
   They survived every band and did disproportionate work at every
   band.
5. **If a second track is wanted, middle school is the one to build**,
   and it costs ~950 words a post — roughly the length of the "What we
   got wrong" plus "Next" sections of an original.

## Method note

Each post was rewritten by an independent pass working from one shared
rubric (level definitions, fidelity invariants, structure-preservation
rules — see `README.md`). Hard invariants held across all 28 files:
no number, seed, hash, or claim altered (verified: the only 16-hex-digit
values present anywhere in the rewrites are the twelve that appear in
the originals); simplification by omission and analogy, never
distortion; at least one "what we got wrong" admission retained at
every level. The originals in `docs/posts/` are untouched.
