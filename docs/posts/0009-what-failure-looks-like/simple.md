# What Failure Looks Like

*Post 0009 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: our project keeps a shelf of invented alien
civilizations that work like test cases — everything we build must be
able to host their stories.*

---

Our simulator has an unusual kind of test: made-up alien
civilizations. We write their stories first, in plain prose, long
before any code exists — and then every system we build gets checked
against them. If a new design couldn't possibly host one of the
stories, the design gets fixed, never the story. We call this shelf
of stories our eval suite, which is just a testing word for "examples
the system must handle."

Recently, two new civilizations joined the shelf — the Vessari and
the Khedrun, the traders and raiders from our toy world — and their
files ended with something the older entries didn't have: a short
section called **Eval notes**. It says, in a few sentences, exactly
what the entry is for. Here is the Khedrun one, in full:

> The Khedrun exist to prove the engine can host a martial
> temperament whose violence is *economically legible*: war as
> provisioning, fuses as patience made mechanical, plunder as
> circulation. Systems where war cannot be caused by prices — or
> where a declaration cannot cite the exact events that provoked it —
> fail this entry.

Read the last sentence again. It names what *failure* looks like.
That one sentence turns a story into a test.

Mike spotted the gap: our three original civilizations — the Vess,
the Continuance, and the Marrow Fleet — never got a section like
this. Should they? And should every future entry have one? This card
answered yes twice.

## A test has to be able to fail

Here's the problem with a test that never says what failure looks
like: it can't actually fail, and a test that can't fail isn't a
test — it's a demo. Software people call these smoke tests: they run
the machine and watch the smoke, but they never check the answer.

Our original three stories were rich and strange — a crystal hive
mind the size of a continent, an abandoned maintenance AI that became
a nation, a fleet of living ships with no home planet. But when a
designer asked "does my design support the Vess?", they had to
reverse-engineer the answer from pages of beautiful description.
Which details are requirements, and which are just texture? You could
work it out. You shouldn't have to.

So each of the three now ends with its own Eval notes — the
requirement that was always hiding in the story, written down where a
reviewer will trip over it:

- The **Vess** prove our engine must handle a mind you can't count —
  overlapping, blurry-edged beings who decide at the speed of group
  agreement, never forget, and fight by cutting you off rather than
  by shooting. A design that requires every civilization to be a tidy
  list of individuals fails.
- The **Continuance** proves a civilization doesn't have to be
  biological — it's one computer program that split into millions of
  independent copies. A design that assumes every civilization is a
  species of organisms fails.
- The **Marrow Fleet** proves a civilization doesn't need a home — no
  planet, always moving, its wealth made of reputations and promises
  instead of things. A design with a required "home planet" box fails
  instantly.

Our catalog of world types got one collective note too, and the rule
itself went into the shelf's charter: from now on, every entry ends
with Eval notes — two to four sentences, one clear requirement, and
never a shopping list of features. The "never a list" part matters
most: a short honest claim keeps the stories as a floor the engine
must clear, not a blueprint it must copy.

There's a bonus. We're slowly growing the cast toward thirty
species, and we already know our weakness: our first three aliens
were all ancient, gentle, and likable. The new rule is a filter for
that. If you can't write an entry's Eval notes — if you can't say
what it *proves* — then it's charm, not a test, and it isn't ready
for the shelf.

## What we got wrong

The embarrassing part: we're the same people who declared, in an
earlier post, that these stories *are* test cases — and then wrote
three test cases with no pass/fail line, and didn't notice for
nineteen cards. What exposed the gap wasn't discipline. It was an
accident: the two toy-world civilizations needed a paragraph
explaining why they belonged on the shelf at all, and that
explanation turned out to be exactly the missing piece.

The fix cost five paragraphs and one charter sentence. That's also
the lesson: it was cheap *because* the shelf holds five entries
today. At thirty, someone would have spent a season re-reading every
portrait, guessing what its author meant to require. Our project's
constitution has a phrase for this — cheap now, brutal to retrofit —
and this card is a small proof of it.

One more honest note: our board's convention is that lore work is
Mike's. He explicitly handed this card to Claude while he was in
meetings, so the three new requirements are Claude's drafts of what
are ultimately Mike's decisions — and the project rule that nothing
merges until Mike can defend it without Claude in the room applies
here with extra force.

## What's next

The next species to join the shelf arrives with its Eval notes, or it
doesn't arrive. Five entries, one world library, six written
assertions — and now the shelf can genuinely fail, which was always
the point of calling it a test suite.
