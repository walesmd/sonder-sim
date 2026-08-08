# A System That Is Used

*Post 0022 · the plain-language version · the full essay:
[complete](./complete.md)*

The last of four overnight cards is a cleanup — twelve small
things the big review found, none big enough for its own essay,
all worth ending. A tour of the highlights:

The `--why` command, whose entire job is explaining why something
happened, was the only view in the project still printing raw
technical fallback text — while the world's own beautiful
sentences sat unused four lines away. The list of playable worlds
was written in two places in the same file, and a comment
helpfully pointed at the wrong one. The auditor kept two
completely different things in variables one letter apart — "road"
(the map) and "roads" (the ledger of goods in transit). One world
had two copies of the routine that formats money with thousands
separators, and the copy the auditor used printed negative numbers
garbled — a financial summary that can't print a deficit honestly
is a summary waiting to lie. And one comment claimed the office
rent left through the operations person's books when it actually
leaves through the founder's — a small lie with a five-card shelf
life, which matters extra in this project, where code comments are
published prose that essays get distilled from.

Ten of twelve findings are now fixed. Two were deliberately left
alone, and the reason is the overnight run's golden rule: this was
unmonitored work, so anything that could change *history* — the
actual events of the simulated worlds — waited for Mike. Resizing
how far back minds scan their memories would change decisions, and
changed decisions are changed history. Renaming a field two worlds
disagree about is a public-API decision. Cleanups don't get to do
either while nobody's watching.

Two of the fixes deserve a special mention because they're guards,
not polish. When we added the "which world wrote this file" row
two days ago, the first attempt failed because the archive checks
requirements in one list and writes rows from another, and nobody
told the second list. Now an assertion makes those two lists
police each other — that exact failure is structurally impossible.
And all three worlds now verify that every declared kind of event
has bookkeeping instructions *at declaration time*, rather than
hoping a test run happens to emit it. The lost-letter event, which
only appears when a rider actually dies, is precisely the kind of
rare event the old check could miss.

The computer science here is fifty years old and reads like
prophecy. In 1974, Meir Lehman studied how large software systems
actually evolve and wrote down laws that still hold. First law: a
system that is used *must* change — or it becomes steadily less
useful. Second law: as it changes, its complexity increases —
*unless work is done* to reduce it. Our project is eight months
old and obeys both laws precisely: six intense cards exercised
every seam (first law), and complexity accrued in the seams
exactly as promised — duplicated knowledge, drifting comments,
near-miss names (second law). Tonight's card is the second law's
escape clause, turned from a heroic occasional act into a
scheduled, named practice.

The honest reflection this time is about economics rather than a
mistake: every one of tonight's twelve fixes was cheap *because it
traveled in a batch*. None of them, alone, would have justified a
branch, a card, and an essay — which is exactly how all twelve
survived six cards of otherwise disciplined work. Small wrongness
has no natural predator in a one-task-at-a-time workflow. It needs
the occasional full read-through — what Mike called taking a beat
— to flush it into the open where it can be fixed by the dozen.

Engine 0.2.5: the fourth patch of the night, and the fourth proof
that no simulated history moved while its machinery got cleaner.
That's the overnight run complete — four cards, zero histories
disturbed — and the morning report has the menu of what's left,
which is only the decisions big enough to deserve Mike awake.
