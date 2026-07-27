# Ticks & Determinism

*Reading-level experiment · target: elementary school · rewritten from `docs/posts/0001-ticks-and-determinism.md` · original untouched*

---

We are building a pretend universe inside a computer. Someday it will have space traders and space armies. Right now it has neither. It only has a heartbeat.

Here is the trick. You give the program one starting number. We call it the seed. Our seed today is 1893. The program uses it to play out ten steps of pretend history. At the end, it prints a short code. Think of it as a fingerprint for that whole run.

Now run it again with seed 1893. You get the exact same ten steps. The exact same fingerprint. Run it next year. Same. Run it on your computer instead of ours. Same. If it ever comes out different, our program has a mistake, and we truly want you to tell us.

We should be honest about one thing. There is no market yet, and no war. Two pretend parts stand in for them. They pull random numbers where real decisions will go someday. The numbers mean nothing yet. What matters is that they are the same numbers every single time.

Why do we care so much? Because of promises we made. Saving your universe should be easy: just keep the seed. Replaying history should be perfect, like rewinding a movie. And running the same history twice tests our work. If the runs ever differ, something broke.

A few sneaky things can ruin this. One is the clock. If the program peeks at today's date, the result depends on when you ran it. So our program never looks at a clock. It only counts its own steps.

The sneakiest problem is sharing one bag of random numbers. Imagine two players drawing cards from one shuffled deck. Player one starts taking one extra card each turn. Now every card player two gets is different. Nobody touched player two's rules. But player two's whole game changed.

Our pretend market and army could have that problem. If the market draws one extra number, every number the army gets shifts. A peaceful pretend world could turn into a war, just because the market got chattier. That would ruin saved universes forever.

The fix: give every part its own deck. Each deck is shuffled using the seed plus that part's name. The market has a market deck. The army has an army deck. Now the market can draw all it wants. The army's deck never moves by a single card.

How many universes can we make? The seed can be any of about 18 quintillion numbers. That is 18 followed by 18 zeros. Minecraft names its worlds with numbers of the same size. Even if all 200 million Minecraft players played day and night, finishing two worlds every hour, seeing every world would take about 5.3 million years. Nobody is running out of universes.

Now for what we got wrong. In our last post, written before any code, we predicted a certain bug would bite us. It never did. We are leaving the wrong guess in that post and admitting it here. The true record matters more than a good story.

Our first real mistake was in a test. The test said part of the program was broken. It wasn't. The test itself was wrong about what to expect. We fixed the test, not the program. Lesson: when a test fails, sometimes the test is the mistake.

We also accidentally deleted our own tools. Rebuilding them from scratch worked in one step, which proved our setup instructions were good. A lucky accident.

What's next? Right now, nothing gets written down. When a number moves a price, that fact just vanishes. Next time we build the universe's diary, where every event gets recorded forever.

Same seed, same universe. Every time.
