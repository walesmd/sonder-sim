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
this project's history and look around. Every post comes in two tracks —
the complete essay, and a plain-language *simple* version that assumes
nothing but curiosity — so bring whichever background you have. The universe's authored side —
species, cosmology, historical priors, written long before they are
code — lives in [`docs/lore/`](docs/lore/). And the words this repo
leans on — *annals*, *chronicle*, *faction*, *seal* — are each defined
once, in [`docs/glossary.md`](docs/glossary.md).

## Status

**Engine 0.2.0.** Three worlds — space (the destination), a
fantasy continent, an office — run on one engine, each guarded by
a golden seal; news rides declared mechanisms, roads can lose
letters, and the version's minor digit moves only when history
itself forks (the determinism-epoch convention, card 150). The
system as it stands is mapped in
[`docs/architecture.md`](docs/architecture.md); the full
documentation index is [`docs/README.md`](docs/README.md).

**The story so far, in order.** v0.1 — the walking skeleton — was
cut at card 119, with
post 0000 ([*First Tick*](docs/posts/0000-first-tick/complete.md),
tag `post/0000`) re-cut from aspiration to fact as its front door.
The pieces, in the order they arrived: A deterministic tick loop
with a named RNG stream per subsystem, so adding a feature to the
market never shifts a single draw in the war machine — post 0001,
[*Ticks & Determinism*](docs/posts/0001-ticks-and-determinism/complete.md)
(tag `post/0001`). And the annals: an append-only event log with a
strict vocabulary, where every event cites the events that caused it
and a terminal chronicle renders the feed — and answers *why* — from
the log alone — post 0002,
[*The Event Log*](docs/posts/0002-the-event-log/complete.md) (tag `post/0002`).
The universe also has its first authored inhabitants: three
civilizations and a fifteen-type world library on the lore shelf,
chartered as an eval suite — stories the engine must be able to host,
never a spec of what it builds — post 0003,
[*The Lore Shelf*](docs/posts/0003-the-lore-shelf/complete.md) (tag
`post/0003`). And history now survives the terminal: every run writes
a SQLite universe file — the annals as rows, causes as a walkable
graph, and a provenance table so the file can testify about its own
origins — post 0004,
[*The History Book*](docs/posts/0004-the-history-book/complete.md) (tag
`post/0004`). The history book carries a tamper seal: a rolling
state hash checkpointed into every universe file, and the golden-
master replay test every later mechanic lands inside — same seed,
500 ticks, same sixteen hex digits on every machine — post 0005,
[*The Tamper Seal*](docs/posts/0005-the-tamper-seal/complete.md) (tag
`post/0005`). And law 3 is now structural: factions decide on belief
stores their code is handed instead of a world it never sees, the
war office became the first believer, and `--why` ladders cross
subsystems — post 0006,
[*Truth & Belief*](docs/posts/0006-truth-and-belief/complete.md) (tag
`post/0006`). And the universe has its first economy: the Vessari
and the Khedrun — temperaments compiled to constants — trading one
commodity across one naive market, with money in integer cents and
wars nobody planned precipitating out of grain prices roughly every
forty-five days — post 0007,
[*A War Nobody Planned*](docs/posts/0007-a-war-nobody-planned/complete.md)
(tag `post/0007`). Every post since ships on two tracks — the
collegiate essay and a plain-language companion, same facts and
hashes in both — post 0008,
[*Simple & Complete*](docs/posts/0008-simple-and-complete/complete.md)
(tag `post/0008`), and every entry on the lore shelf carries an
eval note recording what the engine owes it — post 0009,
[*What Failure Looks Like*](docs/posts/0009-what-failure-looks-like/complete.md)
(tag `post/0009`). The economy answers to an independent
double-entry audit that refolds all of history from the log alone —
post 0010,
[*Double Entry*](docs/posts/0010-double-entry/complete.md) (tag
`post/0010`). And news now travels: the world has a map, every
event reaches every faction days late at channel speed, armies take
the road, the audit certifies that belief drifts from truth by
exactly the news still in flight — and `--believes` renders any
faction's private newspaper, double-dated, at any tick. Three
fingerprints, one seal — post 0011,
[*News at Ship Speed*](docs/posts/0011-news-at-ship-speed/complete.md)
(tag `post/0011`). And nothing teleports anymore: goods and payment
physically ride the roads (a shared travel scheduler, born with a
bit-identical equivalence proof), war parties carry their spoils
home, the audit keeps a goods-in-transit account — and the belief
drift of the previous card died honestly, because everything that
moves a nation's books now happens at its own gates — post 0012,
[*Nothing Teleports*](docs/posts/0012-nothing-teleports/complete.md)
(tag `post/0012`). And the engine is a framework in fact: the toy
world took its real name — space, the destination — and two
deliberately shallow eval universes now stand guard beside it, an
office where distance is the org chart and a continent where trade
travels by letter, all three running on one engine that got smaller
with every world it gained. Anything built here must serve all
three, or it's one world's content — post 0013,
[*Whatever That Universe May Be*](docs/posts/0013-whatever-that-universe-may-be/complete.md)
(tag `post/0013`). And the field model's replacement is designed —
on paper, for all three worlds at once: everything that moves rides
a mechanism (one row: speed, coverage, failure profile, cost,
owner), cargo splits into net-zero and copyable, a rumor is one
*plus* shipments, and an event's news exists only in the minds that
caught it — the witness rule. Zero code, one ADR, and a build map
handing each piece to the card that builds it — post 0014,
[*The Witness Rule*](docs/posts/0014-the-witness-rule/complete.md)
(tag `post/0014`). And the rows are real: news rides declared
mechanisms now (`sonder/carriage.lua`) — the field survives only as
a row two worlds admit to, while Harrow pilots its retirement with
earshot and letters. The pilot's surprise: the golden seal did not
move, because no Harrow mind had ever read what the field
over-delivered — history stood still while every civilization's
knowledge shrank to what was witnessed or carried. The valley no
longer hears the mountains declare war; the raid arrives
unannounced — post 0015,
[*The Seal That Didn't Move*](docs/posts/0015-the-seal-that-didnt-move/complete.md)
(tag `post/0015`). And the roads are not safe: Harrow's letters
carry an encounter profile — one chance per fifty rider-days,
drawn on the courier's own stream — and a lost letter dies on its
true day, on the road, reason-free and witnessed by no one; the
world's first half-settled trade (paid, never shipped) is the Two
Generals' Problem living in a fantasy continent, and the golden
seal re-cut deliberately for the first time, taking the engine to
0.2.0 — post 0016,
[*The Roads Are Not Safe*](docs/posts/0016-the-roads-are-not-safe/complete.md)
(tag `post/0016`). And the project took a beat: a comprehensive
review with two hats — thirty findings identified and ranked for
Mike's verdicts (none applied; identify first, decide second), and
the documentation of the *system* built at last: a living
reference shelf ([architecture](docs/architecture.md), the
[universe file](docs/universe-file.md), the [API](docs/api.md),
[verification](docs/verification.md)) beside the pinned posts —
post 0017,
[*Success Debt*](docs/posts/0017-success-debt/complete.md)
(tag `post/0017`). The first finding is already paid: every
universe file now records which world wrote it — nine provenance
rows, engine 0.2.1 — post 0018,
[*The File That Knows Its Name*](docs/posts/0018-the-file-that-knows-its-name/complete.md)
(tag `post/0018`). Ahead: Mike's remaining picks from the findings, the
courier's remaining successors (cards 152–159), the encounter
engine that will give losses their reasons (card 165), and the
lore shelf's road to thirty species. Watching now means watching
from very nearly the beginning, which is rather the point.

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
./lua src/main.lua --seed 1893 --ticks 10             # a universe, narrated
./lua src/main.lua --seed 1893 --ticks 10 --why 21    # why did event 21 happen?
./lua src/main.lua --seed 1893 --ticks 1000 --audit   # do the books balance?
./lua src/main.lua --world continent --seed 7 --ticks 200   # Harrow instead
./lua src/main.lua --world office --seed 7 --ticks 120      # Bellwether & Co.
./lua src/main.lua --world continent --seed 7 --ticks 60 \
   --believes tethri --as-of 30   # one mind's private newspaper, at a past tick
./lua_modules/bin/busted                              # the spec suite
```

`--world` picks the universe (`space` is the default); `--believes
NAME` renders the feed as one faction received it, double-dated
(learned ← happened), and `--as-of T` rewinds that mind to what it
knew *then*.

Same seed, same feed, on every machine — that is the whole promise so
far. `--why` walks an event's cause links back to genesis, because
every event in a Sonder universe cites what caused it.

Every run is also written down: a fresh SQLite universe file lands in
`out/` (gitignored, uniquely named by time, seed, and engine version),
or wherever `--db PATH` says, or nowhere with `--db none`. The save
file is a database and the database is a history book — browse it:

```sh
sqlite3 out/universe-*.db "SELECT key, value FROM provenance"
sqlite3 out/universe-*.db "SELECT kind, count(*) FROM annals GROUP BY kind"
sqlite3 out/universe-*.db "SELECT * FROM checkpoints"   # the seal trail
```

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
repo if you want the universe, or neither — it runs regardless. The
cards being worked, and the queue behind them, are on the
[public project board](https://app.fizzy.do/6237702/public/boards/A7cGuM6i11p3NH8av6LoWxeE)
— as close to a roadmap as this project will ever have.

Seeds are the local currency: same seed, same universe, so "go look
at seed 40412" is a complete story recommendation.
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
