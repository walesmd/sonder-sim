# Sonder

> **sonder** *(n.)* — the realization that each random passerby is living a
> life as vivid and complex as your own.
> — John Koenig, *The Dictionary of Obscure Sorrows*

Sonder is a universe simulator you read. Many simulated civilizations —
each with its own temperament, grudges, and economic instincts — trade,
scheme, ally, and go to war across a procedurally grown galaxy. Nobody
plays it in the usual sense. The simulation runs whether or not you watch,
history accumulates whether or not you read it, and the role on offer is
something between a god and a subscriber.

Two ideas make it worth building. First, no civilization in Sonder acts on
the truth: each acts on what it *knows*, which is partial, late, and bent
by culture — so the same war exists as two contradictory stories in two
sets of records, and somewhere on the rim a small civilization that has
never heard of either empire records a good harvest and some troubling
lights in the sky. Second, everything is deterministic: a seed is a
universe, the same seed is the same universe forever, and divine
interventions are just recorded inputs. Histories here are shareable,
checkable, and forkable.

It is also, deliberately, a learning project. Every mechanic ships with an
essay on the design and the computer science underneath it — priority
queues arrive because fleets need arrival times, distributed-systems
theory arrives because light is slow and news travels on merchant ships.
Posts live in [`docs/posts/`](docs/posts/), each one pinned to a git tag
pointing at the exact code it describes, so you can stand at any moment of
this project's history and look around. The universe's authored side —
species, cosmology, historical priors, written long before they are
code — lives in [`docs/lore/`](docs/lore/).

## Status

**Pre-0.1 — the heartbeat runs, and history is written down.** The
walking skeleton has its first two pieces. A deterministic tick loop
with a named RNG stream per subsystem, so adding a feature to the
market never shifts a single draw in the war machine — post 0001,
[*Ticks & Determinism*](docs/posts/0001-ticks-and-determinism.md)
(tag `post/0001`). And the annals: an append-only event log with a
strict vocabulary, where every event cites the events that caused it
and a terminal chronicle renders the feed — and answers *why* — from
the log alone — post 0002,
[*The Event Log*](docs/posts/0002-the-event-log.md) (tag `post/0002`).
The universe also has its first authored inhabitants: three
civilizations and a fifteen-type world library on the lore shelf,
chartered as an eval suite — stories the engine must be able to host,
never a spec of what it builds — post 0003,
[*The Lore Shelf*](docs/posts/0003-the-lore-shelf.md) (tag
`post/0003`). Still ahead for the skeleton: the SQLite annals with
provenance, the belief-store seam, and two toy civilizations trading
one commodity. Watching now means watching from very nearly the
beginning, which is rather the point.

## Building

The toolchain is real and pinned. On macOS:

```sh
brew install lua@5.4 sqlite   # Lua 5.4 exactly — see docs/adr/0001
./tools/setup.sh
```

Everything lands inside the repo — a pinned LuaRocks in `.toolchain/`,
dependencies at the exact versions in `rocks.lock` in `lua_modules/`, and
`./lua` / `./luarocks` wrappers in the root — nothing global is touched.
The script ends by running `tools/doctor.lua`, which checks the
properties determinism leans on (the Lua 5.4 integer subtype, 64-bit
width, wrapping overflow, lsqlite3, busted) and fails loudly otherwise.
How and why the pin is enforced this way is `docs/adr/0002`.

## Running

```sh
./lua src/main.lua --seed 1893 --ticks 10           # a universe, narrated
./lua src/main.lua --seed 1893 --ticks 10 --why 21  # why did event 21 happen?
./lua_modules/bin/busted                            # the spec suite
```

Same seed, same feed, on every machine — that is the whole promise so
far. `--why` walks an event's cause links back to genesis, because
every event in a Sonder universe cites what caused it.

## The bets

Lua 5.4, because an economy simulation is mostly bookkeeping and Lua
tables are unreasonably good at bookkeeping (also: joy, which on a
decades-long project is a load-bearing engineering criterion).
Determinism as the one non-negotiable law. Event sourcing, because in a
game you mostly read, the record *is* the product — the log lives in
SQLite, where SQL becomes a telescope. Beliefs over truth in every agent
decision. A headless core that never knows whether anyone is watching.
And authored lore as an eval suite: stories the systems must at least
be able to host — a floor, never a ceiling.

The arguments for each live in [`CLAUDE.md`](CLAUDE.md) and get unpacked
post by post.

## Following along

There is no release cadence and no roadmap to 1.0. This is a labor of
love with no end in sight, built slowly in public for the sake of
learning and sharing. Read the posts if you want the lessons, star the
repo if you want the universe, or neither — it runs regardless.

Once v0.1 exists, seeds become the local currency: same seed, same
universe, so "go look at seed 40412" is a complete story recommendation.
Field reports from universes behaving badly will be the most welcome kind
of issue.

## Who

Mike Wales (human — decides, edits, owns the consequences) and Claude
(Anthropic's AI — drafts much of the code and prose), collaborating in
long conversations. Whether a human and an AI can keep a codebase, a
writing voice, and a shared universe coherent over decades is one of the
experiments.

## License

Code: [MIT](LICENSE). Posts and documentation: CC BY 4.0.
