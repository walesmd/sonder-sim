# The History Book

*Reading-level experiment · target: elementary school · rewritten from `docs/posts/0004-the-history-book.md` · original untouched*

---

We are building a pretend universe inside a computer. Little pretend
countries live in it. Things happen to them, tick by tick, like turns
in a board game. Every happening gets written down, like lines in a
diary.

Last time we told you a secret. The diary was a problem. It only
lived in the computer's short-term memory. Close the program, and the
whole diary vanished. Imagine writing history on a foggy window.

That's fixed now. Every run of the universe saves its diary to a
file. The file stays on your computer after the program ends. You can
open it later and ask it questions.

Here is our favorite test. In the old version, the running program
could answer "why did this happen?" It would list the chain of
happenings that led up to it, back to the very beginning. Now we ask
the *file* the same question. The program isn't even running anymore.
The file gives the exact same answer, step by step, back to the
start. Same history, told by a new witness.

## The file tells you where it came from

Open a real history book and look at the first pages. They say who
wrote it, and when, and which edition it is. Our universe files do
that too. Each one starts with a little table of facts about itself.
Which version of our program wrote it. Which "seed" it used — the
seed is the starting number that decides how the whole universe
unfolds, like the setup card in a board game. Same seed, same
universe, every time.

Why bother with those pages now? Because you can't add them later. A
file without them is like a letter with no name and no return
address. Once it leaves your computer, nobody can tell where it came
from.

## Nobody gets to erase history

The diary is written in pen, not pencil. We built rules right into
the file itself. Try to change an old line, and the file says no. Try
to erase one, and the file says no. Even a sneaky person with special
tools gets stopped. The rules travel inside the file, wherever it
goes.

One more careful choice. We save the diary after every tick, not
after every single happening, and not only at the very end. If the
program crashes, you lose one tick at most. Never half a sentence.

## What we got wrong

We admit mistakes here. That's part of the project.

First, Claude (the AI helping build this) made saving optional. You
had to ask for a file. Mike (the human in charge) flipped it. Now
every run saves itself. A history book you have to request isn't much
of a history book.

Second, a testing tool tricked us. It created an empty file when we
only wanted a name for one. Our own "never overwrite a file" rule
then blocked us. Annoying — but really, our safety rule worked. It
just caught us first.

Third, we noticed two runs made files that matched perfectly, down to
the last dot. We wanted to brag about it. We didn't. That perfect
match is luck, not a promise. What we promise is simpler: same seed,
same history.

Last, a teamwork mistake. Claude saved work before Mike had checked
it, which hid the marks Mike uses to review. New rule: nothing gets
saved for good until Mike says so.

## Next

The file can say where it came from. But can it prove nobody messed
with it along the way? That's next: a tamper seal for the history
book.
