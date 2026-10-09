# Probes for the 2026-09-24 review

Throwaway scripts the review's verifiers wrote to check claims, kept so
every headline number in [`../2026-09-24-the-return.md`](../2026-09-24-the-return.md)
can be regenerated; the claim-by-claim verdicts are in
[`verification-ledger.md`](verification-ledger.md). They are evidence, not tools: no specs, no polish,
written against the card-169 working tree (engine 0.2.6, uncommitted).
Run everything from the repo root.

| probe | what it shows | run |
|---|---|---|
| `c1_zeroday.lua` | a zero-day shipment lands on an already-drained calendar page and is never delivered; the audit still balances | `./lua docs/reviews/2026-09-24-probes/c1_zeroday.lua` |
| `c2_colocated.lua` | at road distance 0, same-tick visibility depends on registration order | `./lua …/c2_colocated.lua` |
| `c3_latecomer.lua` | a faction enrolled mid-history believes the whole past on its first morning | `./lua …/c3_latecomer.lua space 1893 201 vessar-reaches` |
| `c4_opts.lua` | `Universe.new` silently ignores a misspelled option key; hidden loudness demands | `./lua …/c4_opts.lua` |
| `c5_law3.lua` | what decision code *can* reach (debug library, planting via `receive`) | `./lua …/c5_law3.lua` |
| `mut_helper.lua` | busted helper: drop or delay deliveries of one kind (a courier mutant). All three env vars are required; a misspelled `MUT_KIND` mutates nothing and passes trivially | `MUT_MODE=drop MUT_KIND=market.order MUT_OUT=/tmp/mut ./lua_modules/bin/busted --helper=docs/reviews/2026-09-24-probes/mut_helper.lua` |
| `bdigest.lua` | a belief digest beside the seal: the mutants move it, not the seal | `./lua …/bdigest.lua space 1893 500 drop market.order` |
| `forge_toy.lua` | a misrouted, same-tick delivery audits with zero violations | `./lua …/forge_toy.lua` |
| `locale_probe.lua` | byteform's `%c` escaping changes under a UTF-8 `LC_CTYPE` | `./lua …/locale_probe.lua` |
| `synthetic.lua` | `Books.believed`'s count windows fail silently when overfilled | `./lua …/synthetic.lua` |
| `whycount.lua` | how many lines `--why N` would print (it walks a DAG as a tree) | `./lua …/whycount.lua space 1893 150 10000` |
| `wars.lua` | war census: count, durations, reasons, pairs, why each peace happened | `./lua …/wars.lua space 1893 1000` |
| `rim.lua` | the Selm and Tethri: last decisions, war beliefs held | `./lua …/rim.lua 7 2000` |
| `know.lua` | what share of the annals each mind holds | `./lua …/know.lua continent 7 1000` |
| `closure.sql` | a war declaration's full cause ancestry, grouped by location | `./lua src/main.lua --world continent --seed 7 --ticks 1000 --db /tmp/h7.db`, then `printf '.param set :war %s\n.read docs/reviews/2026-09-24-probes/closure.sql\n' $(sqlite3 /tmp/h7.db "select max(id) from annals where kind='war.declared'") \| sqlite3 /tmp/h7.db` |
| `verify_file.lua` | recompute a universe file's checkpoints from its rows alone | `./lua …/verify_file.lua path/to/universe.db` |
| `watermark-scan.patch` | the engine lane's prototype: `Books.believed` without count windows (exact, seal-identical, ~2.4x faster on the office) | `git apply --check docs/reviews/2026-09-24-probes/watermark-scan.patch` |

The patch applies cleanly to the card-169 working tree as of
2026-09-24. It is a prototype, not a reviewed change: it leaves the
now-dead `window` fields in the three world declarations, and the
no-anchor error message it keeps mentions windows.
