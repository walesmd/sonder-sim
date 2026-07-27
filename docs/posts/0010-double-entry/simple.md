# Double Entry

*Post 0010 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: our simulated universe has an economy now — two nations,
one grain market, and wars that break out over prices. This post is
about proving nobody ever cheats it.*

---

Run a thousand days of universe 1893 and ask for the audit, and the
last two lines of output read:

```
audit: 24,000¢ founded, 24,000¢ held; 240 sacks founded, +18,938 harvested, −17,651 eaten, −746 burned, 781 held
audit: the books balance
```

Here's what that means. At the very beginning, the two nations were
founded with 24,000 cents between them. A thousand days later — after
hundreds of trades, twenty wars, and endless raiding — the universe
still holds exactly 24,000 cents. Not one cent appeared from nowhere;
not one vanished. And every sack of grain is accounted for: what was
founded, plus what the fields grew, minus what got eaten, minus what
burned in wars, equals exactly what the granaries hold.

The program that checks this is called the **audit**, and this post
is about why a made-up universe needs an accountant.

## Two kinds of stuff, two kinds of rules

Money in our universe has a simple rule: it can *move*, but it can
never be created or destroyed. When the Khedrun buy grain, cents move
to the Vessari. When Khedrun raiders plunder, cents move back. So the
audit's check is almost childish: add up every treasury and compare
it to day one. If the totals ever differ, somebody conjured or
vanished money, and that's a bug.

Grain is different — it has exactly **two doors**. It comes into the
world through harvests, and it leaves through stomachs and torches.
The crucial rule: both doors are *recorded*. Every harvest is an
event in the universe's diary; every meal and every burned sack is
too. So the audit can count everything that came in and everything
that went out, and demand the granaries hold exactly the difference.
Anything else moving grain around — trades, war plunder — just shifts
sacks between granaries and can't change the world's total.

## The forger test

Our universe's diary is strict about *grammar*: an event with missing
or misspelled fields is rejected on the spot. But grammar isn't
arithmetic. An event that says "5 sacks sold for 80¢ each, total
paid: 0¢" is perfectly well-formed — and a complete lie. The diary
would accept it, and somebody would have gotten five sacks for free.

So our tests include a **forger**: a fake troublemaker we add on
purpose, who slips exactly that kind of lie into a test universe. The
audit has to catch it by name — "trade total 0¢ is not 5 units ×
80¢" — or the test fails. A second forgery buys one sack for ten
million cents, driving a treasury below zero; the audit catches that
too. One system checks the grammar, another checks the math, and we
keep a professional liar on staff to make sure.

There's one more safety net. Every kind of event that can ever happen
must be registered with the audit, along with what it does to the
books — even if the answer is "nothing." Why so strict? Because if
someone someday adds a brand-new event — say, mining an asteroid —
and forgets to tell the accountant, the audit would silently ignore
new matter entering the world, and "conservation" would quietly stop
meaning anything. A test walks the whole list and refuses to pass
until every event kind is accounted for.

## Why now — and the interesting part

This bookkeeping trick is over five hundred years old. Venetian
merchants recorded every movement of money twice — out of one
account, into another — so any error would show up as an imbalance
somewhere. Accountants call it double-entry bookkeeping; programmers
would call it an integrity check. Same idea: add redundancy to a
record specifically so corruption becomes *visible*.

But here's the forward-looking part, and the real reason we built
this now. The audit tracks two different kinds of problem and keeps
them separate. **Violations** are math that can't be right in any
universe — conjured money, negative treasuries. Those must be zero
forever. **Mismatches** are different: each nation keeps its own
books based on what it has *heard*, and the audit compares their
self-reports against the true ledger. Today the two always agree,
because news in our universe still travels instantly. But the very
next project makes news slow — ships carrying information across
space, arriving late. When that lands, a nation's books being out of
date stops being a bug and becomes *the whole point*: that's what it
feels like to live far from the action. We built the accountant now
so it already knows the difference between "the books are wrong" and
"they just haven't heard yet."

## What we got wrong

Our own rules said to build this audit "the moment the market lands."
The market landed three projects ago; two pieces of unscheduled work
jumped the queue first. Nothing broke in the meantime, but we're
noting it: our constitution's schedule lost to the queue-jumpers,
twice.

Two mistakes were caught before the code ever ran: a test that
accidentally audited an *empty* universe instead of a full one, and a
report line that printed "money conserved" before actually checking —
a narrator announcing a verdict it hadn't reached. Both fixed at the
desk. And for the second card in a row, every test passed on the
first full run — which our own track record says should make us
suspicious, so we're saying so in public again.

## What's next

News learns to travel. Distance, delays, and two nations that might
not even know each other exist until the first ship arrives — with
the accountant already trained to tell honest ignorance from cooked
books.

Same seed, same books, balanced to the cent. Try to counterfeit it.
