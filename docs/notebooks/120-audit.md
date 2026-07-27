# Notebook — card 120: the double-entry audit

Branch: `120-audit`. Card text: "every credit leaving one treasury
must arrive in another; total matter is conserved unless explicitly
mined or burned. Promote this the moment the toy market lands."
Promoted two cards late; Mike sequenced it ahead of card 122
deliberately — the audit must learn the belief-vs-truth distinction
*before* slow news makes drift the product rather than the bug.

## What shipped

- `src/sonder/audit.lua` — post 0007's spec-local fold, promoted to a
  proper projection: pure function over a prefix of the annals,
  computable by specs, by `--audit`, by a stranger with your universe
  file, all producing the same report.
- `tests/audit_spec.lua` — coverage (every vocabulary kind must be
  classified), conservation across seeds, the counterfeiter, and a
  same-fold determinism check.
- `toyworld_spec.lua` consumes the module; its local `audit()` is
  gone. Claims unchanged.
- `main.lua --audit` — refold history after a run, print the books,
  exit 1 on violations or mismatches.
- 117 specs green (110 + 7). Seal for seed 1893 × 1000 ticks
  unchanged (`948cc6022ed8a8c9`) — the audit is a viewer; history
  didn't move. No golden re-cuts; the re-cut ledger gains nothing.

## Design decisions

- **Violations vs mismatches, kept structurally apart.** Violations
  are arithmetic no universe may exhibit: conjured value, negative
  treasuries, trade totals ≠ units × price, broken conservation.
  Mismatches are a civ's tally disagreeing with the independent fold
  — a bug *today* (pass-through courier: a civ can be neither lying
  nor misinformed) and the *product* after card 122. Specs pin
  mismatches to zero in their own `it` block so 122 relaxes exactly
  one assertion, and `--audit`'s mismatch line says so out loud.
- **The audit never raises; it reports.** A crashing auditor can't
  audit a foreign log (readers age) and can't power a CLI verdict.
  Violations are data; specs assert the list is empty.
- **Classification is total or it's nothing.** Every vocabulary kind
  appears in the effects table — `false` for classified-and-neutral,
  a function for ledger legs; `nil` means unclassified and lands in
  `report.unclassified` (foreign logs) or fails the coverage spec
  (this repo). The chronicle's every-kind-has-a-sentence pattern,
  reused: you cannot add a kind and forget to teach the auditor.
- **Tallies are half record, half claim.** `harvested`/`eaten` are
  the day's only physical record, so the fold trusts them; `stock`/
  `cents` are the civ's claim about its own books, so the fold checks
  them. This asymmetry was implicit in post 0007's fold; audit.lua
  documents it.
- **Determinism of the report itself**: the negative-balance sweep
  iterates founding order (`names` array), never `pairs()` — same
  log, same report, byte for byte, on every machine.
- **comma() is now in two places** (chronicle.lua, main.lua's audit
  print). Rule of three says two copies is coincidence; noted here so
  the third copy triggers the extraction.

## The counterfeiter

The annals checks *shape*, not *arithmetic* — a `market.trade` with
`total = 0` is grammatically valid and economically a lie. The
counterfeiter specs forge exactly such events through a spec-added
system (the gremlin pattern, aimed at money): a free-grain trade
(total ≠ units × price) and an impossible purchase (treasury driven
negative). The audit names both. This is the card's clearest
demonstration: grammar at the door (emit), accounting at the
telescope (audit).

## What we got wrong (candidates for the post)

- The determinism spec's first draft audited an *unrun* universe via
  a careless `x:run(n) or y` chain — caught at desk-check, before
  first red. The test-side-bug tradition (cards 113, 114) continues;
  this one just didn't reach the terminal.
- The first `--audit` print said "money conserved" unconditionally —
  a viewer asserting its conclusion in prose before checking it.
  Caught in self-review; the verdict line now prints only when the
  books actually balance.
- 117 green on the first full run, again. Post 0005's suspicion
  stands re-published.

## Owed / open

- Post 0010 (*Double Entry*), both tracks — drafted on this branch.
- Docs sweep: glossary **audit** entry (pointed at toyworld_spec;
  now audit.lua + post 0010), README run block gains `--audit`,
  CLAUDE.md status, posts index.
- Card 122 inherits: relax `toyworld_spec`'s mismatch assertion (and
  only it), decide what bounded/explained drift looks like, and keep
  violations at zero forever.
