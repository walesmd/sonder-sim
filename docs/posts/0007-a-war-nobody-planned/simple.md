# A War Nobody Planned

*Post 0007 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: our simulated civilizations can only act on what they've
heard, never on the truth itself. Until now, they were placeholders
rolling dice.*

---

On day 86 of universe number 1893, the Khedrun declared war on the
Vessari. Here is the moment, straight from the simulator's feed:

```
tick   86 · khedrun-holds · the day's books: 0 sacks in the granary (+7, −7), 40¢ in the treasury
tick   86 · khedrun-holds · hunger — the granaries came up 3 sacks short
tick   86 · khedrun-holds · the khedrun declare war on the vessari — 4 hungry days were the last insult
tick   87 · vessar-reaches · a khedrun war party rides against the vessari granaries (force 8)
tick   88 · vessar-reaches · the khedrun raiders carry off 8 sacks and 400¢ from the vessari and put 4 to the torch
```

Read it like a news ticker. The Khedrun's granary is empty and their
treasury is down to forty cents. They have gone hungry four days in a
week. So they ride against their neighbors, take grain and silver,
burn some of what they can't carry — and ten days later, with grain
cheap again, they go home.

Here is the part we care about: **nobody wrote that war.** There is no
line of code that schedules a war and no script with day 86 in it. We
ran a thousand days of this universe, and twenty wars broke out on
their own — the first on day 86, the last on day 971. Our one goal for
this milestone was exactly that: a thousand days should produce a
story worth reading, and ideally a war nobody planned.

## Two personalities, written as numbers

The universe now holds two small civilizations, and each one is just a
list of tendencies turned into numbers.

The **Vessari** are farmers and merchants. Their valleys grow ten to
fourteen sacks of grain a day and they only eat eight, so they sell
the extra — but never below their fifty-sack emergency reserve, and
never for less than 80 cents a sack. Below that price, they simply
close the ledger and wait.

The **Khedrun** live on high stony ground. They grow six to eight
sacks a day and need ten. That gap is their whole history. They buy
the difference when they have silver — and take it by force when they
don't. Their patience has real limits written down: grain priced above
150 cents for seven markets in a row is an insult; going hungry four
days in a week is a deeper one. Cross either line and the war parties
ride.

We never tell the story what to do. We write the *personalities* and
the weather, and history is what the personalities do to each other.

## Money has to travel in a circle

Our first version of this economy had a fatal flaw: money only flowed
one way. The Khedrun spent their silver on grain, the Vessari piled it
up, and around day 35 the Khedrun went broke forever. Worse, they then
starved *quietly* — our only war trigger was high prices, and a
civilization too poor to bid doesn't push prices up. A thousand days
of one rich republic and a silent famine next door. Not a story worth
reading.

Two changes brought it to life. First, hunger itself became an insult
— being unable to afford grain at any price now lights the fuse too.
Second, raiders carry silver home as well as sacks. That closes the
loop: trade drains the Khedrun treasury, poverty empties the granary,
hunger starts a war, plunder carries grain and coin back, peace
returns, and trade starts the drain again.

```mermaid
graph LR
    trade["trade drains the treasury"] --> hunger["poverty, then hunger"]
    hunger --> war["war"]
    war --> plunder["plunder brings grain and silver home"]
    plunder --> peace["peace — trade resumes"]
    peace --> trade
```

Run a thousand days and that loop turns roughly every forty-five days
— but no constant anywhere says "45." The rhythm *emerges* from
appetite, harvests, and plunder rates. This way of building — grow the
history instead of scripting it — is called agent-based modeling, and
it has a famous pedigree: researchers have grown trade, migration, and
combat from simple agents since the 1970s. Our twist is that our
universe keeps receipts: every war can cite the exact hunger events
that caused it.

## What we got wrong

The best bug of the project so far: **the plunder was real, but nobody
believed in it.** The battlefield genuinely moved the silver — but the
civilizations' *beliefs* only recorded the grain. So the Khedrun never
believed they'd been paid, and the Vessari never noticed they'd been
robbed. Both sides acted perfectly sensibly on wrong information, and
the result was a world with 184 tiny wars, one every five days. Last
post we built a wall between what is true and what each side believes;
this post shipped the first bug that lived *inside that wall*. The fix
was one line. The lesson was bigger: we added an independent auditor
that recomputes every civilization's books from scratch and checks
them, cent for cent, sack for sack.

One more honest note: the "prices too high for too long" war trigger
has never actually fired — all twenty wars were hunger wars. The
mechanism works in tests, but no universe we've met has used it. We're
saying so rather than quietly tuning it until it triggers.

## What's next

Version 0.1: the complete walking skeleton — ticks, events, a durable
history, a tamper seal, beliefs, and a world where wars break out over
grain prices. The very first post we ever drafted finally gets its
excerpt from a universe that really runs.

Seed 1893, day 86. Four hungry days were the last insult — and you can
ask the file to cite them.
