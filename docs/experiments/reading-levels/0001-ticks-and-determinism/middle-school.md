# Ticks & Determinism

*Reading-level experiment · target: middle school · rewritten from `docs/posts/0001-ticks-and-determinism.md` · original untouched*

---

We are building a universe simulator: a program that grows pretend civilizations that will someday trade, scheme, and fight. This post is about its very first piece — the heartbeat — and one big rule that everything else depends on.

Here is what the program prints when you run it:

```
$ ./lua src/main.lua --seed 1893 --ticks 10
universe 1893 — 10 ticks
tick    1   market drift -1   war muster 4
tick    2   market drift +3   war muster 2
tick    3   market drift -1   war muster 2
...
tick   10   market drift -2   war muster 2
fingerprint c8b4fc573b49bf66
```

Let's walk through it. The first line is the command: run the simulator, start from the number 1893, simulate 10 ticks. A **tick** is one beat of simulated time — like one turn in a board game. The starting number is a **seed**, because a whole universe grows out of it. Each tick line shows two placeholder parts, a "market" and a "war" machine, each pulling a random number. Honestly: there is no real market and no real war yet, and the numbers mean nothing. The last line is a **fingerprint** — one short code folding together every random number the run produced.

What matters: run that command again and you get the same ten lines and the same fingerprint. Next year: same. On your computer: same. If it isn't, that's a bug, and we mean it — please report it. Change the seed to 1894 and you get a completely different universe that nobody had ever seen before.

This property is called **determinism**: the same starting conditions always produce the same result, with zero surprises. It's our project's first law, because every big promise depends on it. Saving a universe? Just save the seed. Perfect replays of history? Re-run the seed. Testing that a code change didn't secretly break the world? Run the same seed twice and compare fingerprints.

But wait — how can *random* numbers be repeatable? Because computers don't actually roll dice. They use a **pseudo-random number generator**: a recipe that starts from the seed and produces a long stream of numbers that *look* random but are completely determined by where you started. Like a deck of cards shuffled in one exact, repeatable way.

Determinism has sneaky enemies. If the program ever checks the real clock, the result depends on *when* you ran it — so our simulator has no clock at all, only its tick counter. If the program processes things in an order the computer picks unpredictably, two runs can differ — so we always process in a fixed order. But the sneakiest enemy deserves its own story.

Imagine the market and the war machine drawing from **one shared deck** of random numbers, taking turns. Now we add a tiny feature: the market checks one extra price per tick. One extra card drawn. Every card the war machine draws after that is now a *different card* — it's reading one position further down the same shared deck. A saved universe that used to end in a peace treaty now ends in a conquest, just because the market got chattier.

So we made a second rule: a new feature must never shift another part's random numbers. And we made it true by construction, not by hoping everyone is careful. Every part of the simulator gets its **own deck**, shuffled using exactly two things: the universe's seed and that part's name. The market's deck comes from (1893, "market"); the war deck from (1893, "war"). The market's chattiness appears nowhere in the war deck's recipe, so it *cannot* matter. A part added in 2031 gets its own deck, and seed 1893's market won't move by one bit.

Turning a name and a number into a shuffled deck uses a **hash** — a function that crunches any input into a scrambled, fixed-size number, the same way every time. We also wrote our own random number generator instead of using our programming language's built-in one. Not because ours has better math — it's the *same* algorithm — but because the built-in one only gives you a single shared deck you can't duplicate, save, or copy. We rejected the plumbing, not the math. And because we transcribed the algorithm by hand, our tests compare it against the original authors' version, written in a different language, number for number.

How many universes are there? A seed can be any of about 18.4 quintillion numbers — 18,446,744,073,709,551,616. Minecraft names its worlds with the same size of number. Even if all 200 million Minecraft players played around the clock, two worlds an hour, seeing them all would take roughly 5.3 million years. Nobody is running out of seeds.

Now, what we got wrong. Our previous post, written before any code existed, predicted that a certain ordering bug had already bitten us. It hadn't — we designed around it, and the universe repeated perfectly on the first try. We're leaving the wrong prophecy in that post and correcting it here, because the record matters more than the story. The first *real* bug was in a test: it claimed a safety guard in our generator was broken. The guard was fine; the test was checking a promise the guard never made. We fixed the test, not the code. Lesson: when a test fails, either the code or the test can be the wrong one. (We also accidentally deleted our own tools by removing a work folder — and rebuilding everything in one command accidentally proved our setup instructions worked.)

Next up: the heartbeat ticks, but nothing is written down — when a number moves a price, that fact evaporates. The next post builds the event log, where history becomes a permanent record you can study.

Same seed, same universe. Check our fingerprint.
