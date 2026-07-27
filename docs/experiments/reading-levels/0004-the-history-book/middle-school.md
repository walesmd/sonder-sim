# The History Book

*Reading-level experiment · target: middle school · rewritten from `docs/posts/0004-the-history-book.md` · original untouched*

---

Sonder is a universe simulator: pretend civilizations trading and
scheming inside a computer. Time moves in **ticks** — turns in a
board game — and everything that happens gets written down as an
**event** in a log we call the annals. Every other view of the
universe is built by reading that log.

Except, until now, "permanent record" was a lie. The log lived only
in the computer's memory. Close the terminal and history evaporated.
Post 0002 admitted this openly. This post fixes it.

Now every run leaves behind a file. We ran the universe with seed
1893 (the seed is the starting number — same seed, same universe,
every time) for 200 ticks, and it saved 401 events into a database
file. A **database** is a file with a built-in librarian: instead of
reading top to bottom, you ask it questions.

Here's the proof it's the same history. The old running program could
answer "why did event 9 happen?" by tracing the chain of causes back
to the beginning. We asked the *file* the same question — program not
even running — and got the exact same chain: muster 1, muster 2,
muster 2, muster 4, genesis. Same events, same numbers, sworn to by a
different witness.

## The file carries its own birth certificate

Every universe file opens with a small table of facts about itself:
which version of our engine wrote it, from which seed, in which
version of the event format. This is called **provenance** — a record
of where something came from. Why rush it in now? Because you can't
add a birth certificate to a file that's already out in the world; a
file without one can never be reproduced once it leaves the machine
that made it.

One detail we're proud of: the file contains **no timestamp at all**.
Two runs with the same seed should produce files with identical
contents, and a "created at" time would be the one thing that
differed. The date lives only in the *filename*, as a note-to-self
for humans. The name is ours; the bytes belong to the universe.

## The archive is just another spectator

Where should the saving code live? The tempting answer: teach the log
itself to write to disk. But one of our four laws says the simulation
must never know whether anyone is watching. So the archive stands
outside, watching events through the same window every other viewer
uses, and copies down what it sees. The simulation runs identically
with or without it — not because the archive is polite, but because
it has no way to reach in.

When does it copy? Not after every event — that's 401 separate saves
for this run, wastefully slow. Not once at the very end — a crash at
tick 199 would lose everything. We save once per tick. A crash costs
at most the current tick, never half an event.

## Written in pen, and the pen travels

Our well-behaved code protects nothing once the file is on someone
else's laptop. So the file carries rules *inside itself*. Here is
one:

```sql
CREATE TRIGGER annals_no_update BEFORE UPDATE ON annals
BEGIN SELECT RAISE(ABORT, 'annals is append-only'); END;
```

Line by line, in plain words:

- `CREATE TRIGGER annals_no_update` — make a tripwire with this name.
- `BEFORE UPDATE ON annals` — it fires whenever anyone tries to
  *change* a row in the history table, before the change lands.
- `RAISE(ABORT, 'annals is append-only')` — when it fires, cancel the
  change and print this complaint. "Append-only" means new lines may
  be added at the end, but old lines may never be touched.

There are four of these tripwires: no changing and no deleting, on
both history tables. Open the file with raw database tools, try to
quietly improve history, and the file itself says no.

## The computer-science idea underneath

Databases make a famous promise called a **transaction**: a group of
changes either *all* happen or *none* do, even if the power dies
mid-write. That's how a crash can't tear an event in half — each
tick's events go in as one transaction.

And there's a joke hiding in the design. How does the database keep
that promise? Internally, it writes its own append-only log first,
then treats its tables as a summary of that log. So we're storing our
append-only log inside a machine that runs on an append-only log.
Logs all the way down — except the database hides its log as
plumbing, while ours *is* the product.

The payoff is the questions the file can answer. The live feed can
tell you the war office mustered 9 levies; it can't tell you the
market drifted up by 24 over 200 ticks unless you read 200 lines.
One database question answers that instantly.

## What we got wrong

Claude built saving as opt-in — you had to ask for a file. Mike
flipped it: every run now archives itself, because the whole point of
a history book is that you can pick it up.

A testing helper secretly created an empty file when we only asked it
to invent a name, and our own never-overwrite rule blocked it. The
safety rule worked as designed — against us first.

Two runs of seed 1893 produced files that matched byte for byte. We
almost bragged, then didn't: that perfect match is luck that could
break with a software update. The promise we keep is *same history*,
not *same bytes*.

And a teamwork bug, jointly owned: Claude committed the work before
Mike had reviewed a line, erasing the highlighting marks Mike reviews
with. New standing rule: nothing gets committed until Mike says so.

## Next

The file can say where it came from, but nothing yet *proves* two
files claiming the same origins lived the same history. That's next:
a tamper seal for the history book.
