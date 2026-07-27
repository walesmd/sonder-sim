# Notebook — card 147: two-track posts

Branch: `147-two-track-posts` (started life as worktree
`reading-level-test` before the card existed).

## How this card happened

It started as an experiment, not a card. Mike: the posts "can feel
pretty academic" — rewrite all seven at four reading levels
(elementary, middle school, high school, graduate CS) and cross-analyze,
in a worktree, away from the other active session. That produced
`docs/experiments/reading-levels/`: 28 rewrites under one shared rubric
plus `ANALYSIS.md`.

### What the experiment found (full detail in ANALYSIS.md)

- The originals are effectively graduate-level texts with a literary
  voice: graduate rewrites came out only ~30% shorter, and every
  rewriter described the work as "deleting charm, not adding rigor."
  The academic feel is **claim density**, not diction.
- Middle school (~950 words, ~44% of original) was the surprise
  winner — real CS ideas named, one excerpt, mistakes kept, pleasant
  standalone reading.
- High school was the structurally awkward band: too tight to keep
  the evidence (seeds, hashes, specs), too loose to shed it. All seven
  blew the word budget; the resolution was always deleting whole
  claims. If we'd aimed for one "simpler" canonical voice, this is
  where we'd have landed, and it demonstrably costs proof.
- The material that survived every level: narrative devices (the
  gremlin, the mailbox, the seal), the "what we got wrong" sections,
  each post's core thesis. The material that only exists at graduate:
  the second-order arguments (log-as-cache-and-truth, CTE fixpoints,
  watermark generality).
- Lower levels got readable partly by severing cross-post references —
  the series web is an on-ramp cost.
- The concepts that resisted prose at every level are the
  diagram-shaped ones: stream-shift, cause DAG, projections fan-out,
  checkpoint divergence + binary search, the capability argument list.
- Fidelity rubric held across all 28 files: the only 16-hex-digit
  values anywhere in the rewrites are the twelve from the originals.

## Mike's decisions (the guidance that became this card)

1. Land on **two tracks**: the collegiate-level explanations we've been
   writing, plus the middle-school-level track — both public.
2. Introduce a **visuals capability**: when explaining a CS algorithm or
   mathematical problem, ask whether a visual is needed, and develop
   those visuals in the posts (Mermaid).
3. Fine to **rewrite the existing posts now** and build a new directory
   structure hosting "the simple and the complete explanations" — the
   product is early enough.
4. **Document the decision at the harness level.** Mike named a
   distinction while doing it: *harness decisions* (those of us running
   the sim) vs *simulation decisions* (the sim itself). Not two
   products, not solved now — but recorded, with tagging as the likely
   eventual separation once public. Quote kept for the record: "we are
   very clearly making different decisions between the harness that
   runs the Sim and the Sim itself."

Also from the discussion, adopted as conventions rather than laws:
"Previously" one-liners where a post leans on prior posts; second-order
arguments set off as labeled asides so a first read can skip them.

## What shipped on this branch

- `docs/experiments/reading-levels/` — the experiment: 28 rewrites +
  README + ANALYSIS.md. Kept as the record that earned the ADR; the
  elementary and high-school bands are not maintained going forward.
- `docs/adr/0003-two-track-posts.md` — the harness-level decision
  record.
- `docs/posts/NNNN-slug/{complete,simple}.md` — the new structure;
  all seven posts rewritten into it. `complete.md` keeps the canonical
  register and gains visuals/asides/previously-lines where they earn
  their place; `simple.md` is the middle-school companion, distilled
  from the experiment's versions (openings de-formulized — five of the
  experiment's seven elementary files had opened with the near-verbatim
  "We are building a pretend universe inside a computer," and the
  middle-school band converged on the same shape).
- `docs/posts/README.md` — the track explainer and index.
- CLAUDE.md, README.md, glossary — swept for the new structure and
  obligations.

## Decisions made along the way / alternatives rejected

- **Rejected: maintaining four public tracks.** 4× writing on a
  Mike-must-defend project, and it muddies which version `post/NNNN`
  vouches for. The four-level corpus stays as a one-time experiment
  artifact.
- **Rejected: sanding the canonical posts down to high-school.** The
  experiment showed that band deletes evidence; the complete track
  keeps its density and the simple track carries the on-ramp instead.
- **Rejected: separate `docs/posts/simple/` mirror tree.** Per-post
  directories keep the pair together, so the docs sweep can check
  "does the sibling exist and agree" by listing one directory.
- **Old `post/NNNN` tags are left pointing at the single-file layout.**
  Tags are era artifacts; no history rewriting.
- **Mermaid over image files**: diagram source is text — diffable,
  reviewable, pinned at tags; the source is canonical and a rendering
  is a projection (pleasingly on-theme). Known cost: renderer drift
  across years; the source stays readable.

## Honesty ledger (for the post)

This branch inverted the project's own process, and the post should
say so plainly:

- The work was **unscheduled**: no card existed when it started. The
  branch began life as worktree `reading-level-test` for a voice
  experiment; card 147 was created mid-flight and the branch renamed
  to match. The rhythm ran backwards — work first, card after.
- This notebook is a **reconstruction, not a live log**. It was
  written partway through, from the conversation, after several
  decisions had already been made. The project that insists nothing
  happens except an append did its process bookkeeping retroactively
  this time.
- We **edited all seven published posts**. The living files now carry
  previously-lines, asides, and diagrams their `post/NNNN` tags do
  not. The tags remain the untouched era record — the annals; the
  working tree is a projection we re-rendered. That framing is honest
  but it is also convenient, and the post should admit both halves.

## Mike's follow-on guidance (post-review)

- Commit the unscheduled work (standing commit rule satisfied —
  explicitly told).
- Draft the card's post now: focus on educational-product-first, the
  posts feeling too academic, and open honesty about rewriting
  post/notebook history. Post number: **0008** (card 118 took 0007
  mid-branch).

## Owed / open

- **Card 118 merged mid-branch and took post 0007** (*A War Nobody
  Planned*). Consequences at merge time: card 147's own post gets the
  next free number, not 0007; post 0007's file needs migrating into
  the two-track structure (`0007-slug/complete.md` + a new
  `simple.md`); and CLAUDE.md's Status section will conflict —
  both branches edited it. All expected, none hard.

- **`canon.lua` vs `byteform.lua` in post 0005.** The living
  `complete.md` (and its new fold diagram) still says `canon.lua`,
  matching the post's own prose — but card 117 renamed the module, and
  this branch already revises living posts, which weakens the
  "era artifact" argument for keeping the stale name. Mike's call at
  review: update the living 0005 to `byteform.lua` (tag `post/0005`
  stays honest regardless) or keep the old name with the glossary's
  "formerly" note carrying the bridge.

- **The post for card 147 itself** (the working agreement's obligation
  stands — this notebook is its raw material; write it together with
  Mike, not solo).
- Glossary/docs-sweep verification before PR.
- The harness-vs-simulation tagging question, deliberately deferred to
  publicity (recorded in ADR 0003).
- Post 0000 remains a draft (card 119 re-cuts it at v0.1); its two
  tracks keep the draft banner.
