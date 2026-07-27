# ADR 0003 — Posts ship in two tracks, and visuals become a standing editorial question

- **Date:** 2026-07-26
- **Status:** accepted
- **Card:** 147

## Context

The posts are not internal notes; they are the project's public face and
half its product — "for the entire world to look at what we're doing and
learn from it" (Mike, card 147). They had started to feel academic.

To find out why, we ran an experiment (card 147's branch;
`docs/experiments/reading-levels/`): all seven published posts rewritten
at four reading levels — elementary, middle school, high school,
graduate CS — under one rubric, then cross-analyzed. The findings that
drove this decision:

1. **The originals are already graduate-level texts wearing a literary
   voice.** Graduate rewrites came out only ~30% shorter, and the work
   was "deleting charm, not adding rigor." The academic feel is claim
   density and assumed background, not vocabulary.
2. **Middle school (~44% of original length) was the surprise winner**:
   one excerpt, real CS ideas named, the mistakes kept, genuinely
   readable standalone. High school was structurally awkward — too
   tight to keep the evidence, too loose to shed it; every rewrite
   there had to delete whole claims.
3. **The concepts that resisted prose at every level are exactly the
   diagram-shaped ones**: the shared-RNG-stream shift, the cause DAG,
   the log-fans-out-to-projections picture, checkpoint divergence and
   its binary search, the capability argument list.
4. The lower levels got readable partly by severing cross-post
   references — the series web is a real on-ramp cost.

## Decision

**Every post ships in two public tracks**, in a per-post directory:

```
docs/posts/NNNN-slug/
   complete.md    — the collegiate register we already write; canonical
   simple.md      — a plain-language companion, middle-school register,
                    ~900–1,000 words, at most one excerpt, the
                    "what we got wrong" material always kept
```

`complete.md` is the post of record — the one the working agreement's
"Mike can defend it unaided" bar applies to in full, and the one other
documents cite. `simple.md` is a faithful companion, never a fork:
it simplifies by omission and analogy, never by distortion, and no
fact, number, seed, or hash may differ between the tracks. Each file
links to its sibling in its metadata line. The `post/NNNN` tag pins
both.

**Visuals are a standing editorial question.** When a post explains a
CS algorithm or a mathematical argument, the review explicitly asks:
*does this need a visual?* Diagrams are Mermaid, inline in the post
source — text, so they are diffable, reviewable, versioned, and pinned
at tags like everything else. The diagram source is canonical; any
rendering of it is a projection. (Mermaid's renderer will drift over
the years; the source stays readable, which is the part we can
promise.)

**The existing posts (0000–0006) are rewritten into this structure
now**, pre-publicity, rather than grandfathered. The already-pushed
`post/NNNN` tags keep the old single-file layout forever — tags are era
artifacts and that is fine.

Two smaller conventions adopted from the experiment's findings:

- **"Previously" lines.** A post that leans on earlier posts opens with
  a one-or-two-sentence *Previously* note instead of assuming the
  series has been read in order.
- **Asides for second-order arguments.** The deeper claims a first
  read can skip (the log as simultaneously cache and record, fixpoint
  termination, watermark generality) are set off as labeled asides
  rather than woven through the main line, capping claim density
  without deleting claims.

## Two documentation worlds, recorded but not solved

Writing this down surfaced a distinction we now expect to matter: the
project makes **harness decisions** (how we build and run the thing:
ADRs, the toolchain, the working agreement, this document) and
**simulation decisions** (what the universe is: the four laws, the
event vocabulary, the lore shelf). They are very clearly different
kinds of decision made by the same two people in the same repo.

We are deliberately not splitting them into two products now. When the
project is publicized, some form of tagging or labeling will likely
separate the two worlds for readers. This paragraph exists so that
future decision starts from a recorded observation instead of a
rediscovery.

## Consequences

- Each increment's writing obligation roughly doubles, but boundedly:
  the simple track is ~950 words to the complete track's ~2,000–2,700,
  and the experiment showed it is largely a distillation exercise once
  the complete post exists.
- The docs sweep gains two checks: the simple companion exists and
  agrees with the complete post, and the does-this-need-a-visual
  question has been asked.
- Readers get an on-ramp; the complete track keeps its density — we
  deliberately did not sand the canonical posts down to the
  high-school middle, because that band demonstrably costs evidence.
- The reading-level experiment's other two bands (elementary, high
  school) stay in `docs/experiments/reading-levels/` as the record
  that earned this ADR, and are not maintained going forward.
