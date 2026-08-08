# The documentation — a map

Seven kinds of writing live here. When to read which:

| you want | read |
|---|---|
| the system as it stands — modules, the tick, the life of an event | [`architecture.md`](architecture.md) |
| to build against the engine, or build a world | [`api.md`](api.md), then ADR [0004](adr/0004-the-world-interface.md) |
| the database a run writes | [`universe-file.md`](universe-file.md) |
| to check a universe hasn't been tampered with | [`verification.md`](verification.md) |
| what a word means when this repo says it | [`glossary.md`](glossary.md) — canonical, one definition per term |
| how each piece was earned, in order, with the mistakes kept | [`posts/`](posts/README.md) — the educational spine; every increment, two tracks, pinned at `post/NNNN` tags |
| why a decision went the way it went | [`adr/`](adr/) — short records; [`notebooks/`](notebooks/) — the raw per-branch working logs the posts distill (numbering has gaps where cards died or haven't run) |
| the authored universe: species, worlds, priors | [`lore/`](lore/README.md) — an eval suite, not a PRD |
| a world's founding intent | [`worlds/`](worlds/) — one charter per eval universe |

Two reading rules. Posts and notebooks are **era artifacts**: they
describe the project as it was at their tag, mistakes and all, and
are never retroactively corrected — that's their value. The
reference pages above (`architecture`, `api`, `universe-file`,
`verification`) and the glossary are **living**: they describe now,
and staleness in them is a bug worth a PR.
