# Truth & Belief

*Reading-level experiment · target: middle school · rewritten from `docs/posts/0006-truth-and-belief.md` · original untouched*

---

Sonder is a universe simulator you read instead of play. The computer runs a tiny pretend world one step at a time (each step is called a **tick**), and it prints out what happened, like a newspaper writing itself. Because it starts from a single chosen number (the **seed** — this post's universe uses seed 1893), running it again always produces the exact same history.

So far the world has two actors: a market whose price drifts up and down, and a war office that raises groups of soldiers called levies. For four posts they shared a universe without ever noticing each other — two random wanderers in neighboring columns of the newspaper.

This card changed that. Now, when the market lurches up by 3, the war office panics and raises eight levies. When the market barely moves, the musters relax. The simulator can even answer "why did event 11 happen?" like a detective: the muster happened because of a market drift, which happened because of the drift before it, all the way back to tick 0, "a universe begins."

## The rule: act on beliefs, never truth

Here's the part we actually built. The war office never reads the real market. It reads its own **belief store** — think of it as a private mailbox of news it has been told. A **courier** (the mail carrier of the simulation) delivers copies of events into that mailbox. When the war office decides what to do, the mailbox is the *only* thing it's allowed to look at.

Why? Because that's how real civilizations work. Nobody acts on the truth. Everybody acts on what they've heard, and what you've heard can be late, incomplete, or bent — like a game of telephone. Right now the courier is instant: news arrives the same tick it happens. Later, news will take years to cross space. We're building the mailbox now so nothing has to be rewritten then.

## Making cheating impossible, not just forbidden

We could have written a rule: "war office code, please don't peek at the world." But polite rules get broken. Instead we made peeking *impossible*. Here's the actual code that registers the war office (this is Lua, the language the project is written in):

```lua
u:add_faction("war", function(beliefs, stream, tick)
   local drift = beliefs:latest("market.drift")
   if not drift then
      return {} -- ignorance is free: nothing heard, nothing mustered
   end
   local muster = drift.magnitude * 2 + stream:int(0, 3)
   return { { kind = "war.muster", ..., causes = { drift.id } } }
end)
```

Walk through it in plain words:

- The first line says: add a decision-maker (a **faction**) named "war," and here is its decision function. Notice what the function receives: `beliefs` (its mailbox), `stream` (its own personal dice), and `tick` (what day it is). That's *everything* it gets.
- `beliefs:latest("market.drift")` asks the mailbox: what's the newest news I have about the market drifting?
- `if not drift then return {} end` says: if no such letter ever arrived, do nothing at all. No letter, no soldiers.
- The `muster` line decides how many levies to raise: twice the size of the drift it heard about, plus a small roll of its own dice.
- The `return` at the end doesn't *do* anything to the world. It hands back a wish list — "I intend to muster" — and the universe carries it out, checking it like everything else. The `causes = { drift.id }` part cites its source, like a bibliography entry: "I did this because of that piece of news."

The trick is in the argument list. The function was never handed the world, so it has no way to touch the world. It's like a card game: you can only play cards in your hand, and you can't cheat with a card you were never dealt. This idea has a real name in computer science: **capability-based security** — instead of guarding doors with rules, you simply never hand out the keys.

The mailbox itself can't cheat either. It starts empty, holds only what the courier delivered, and keeps no secret pointer back to the real world. It literally does not know where the truth lives.

One nice bonus: ignorance is free. A faction that has heard nothing about something stores *nothing* about it — not even a "?" placeholder. Our test proves it: a war office in a universe with no market runs fifty ticks and emits zero events. Someday the galaxy will produce ten thousand events per tick, and a small civilization on the rim that has heard of forty of them will pay memory for exactly forty.

## What we got wrong

We admit mistakes in every post. Three from this card:

1. Last post we predicted the next card would owe us two bugs. Two tests did fail — but on purpose: they were the alarm correctly noticing that history under seed 1893 had legitimately changed. Prophecy technically fulfilled, materially dodged.
2. We discovered one word, *canon*, was naming two unrelated things — like a class with two kids named Sam. We renamed one (`canon.lua` became `byteform.lua`) and started a glossary so every project word means exactly one thing.
3. We wrote one test that we *plan* to break. It checks that news arrives the same tick it happens. When couriers learn to be slow, that test will fail — on purpose — and the failure will be the visible moment this universe stops knowing everything instantly.

## What's next

Card 118 builds the toy world: two civilizations with opposite personalities — one loves trade, one loves war — one commodity, and one market with simple price adjustment. Two factions, two mailboxes, and the first universe whose history records somebody actually *trading*.
