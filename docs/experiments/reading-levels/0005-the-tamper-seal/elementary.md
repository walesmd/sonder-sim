# The Tamper Seal

*Reading-level experiment · target: elementary school · rewritten from `docs/posts/0005-the-tamper-seal.md` · original untouched*

---

We are building a pretend universe inside a computer. It works like a wind-up toy. Wind it up the same way, and it plays the exact same story. Every single time.

The universe writes its story in a big diary. Every little thing that happens gets one line. Nothing counts as "happening" unless it goes in the diary.

Here is the problem. The diary gets long fast. One short run of our universe wrote 1,001 lines. Now, how do you check that two runs told the exact same story? You could read both diaries line by line. That would be slow and boring, and you might miss something.

So we gave the diary a seal.

Long ago, people sealed letters with a blob of wax. If the wax was cracked, you knew someone had opened the letter. Our seal is like that, but it is a short code squeezed out of the whole diary. Change even one letter in the diary, and the code comes out totally different. Not a little different. Totally different.

We started our universe with the number 1893 and let it run for 500 turns. Out came a code, sixteen characters long. We ran it again. Same code. If you ran it on your computer, you would get the same code too. If you didn't, one of us has a mistake to hunt down.

We also drop a bookmark every 100 turns. Each bookmark holds the seal for the story *so far*. Why bother? Say two runs end with different codes. The bookmarks tell you *when* they split apart. If the bookmarks match at turn 200 but not at turn 300, the trouble started in between. Then you check the middle, like the guess-my-number game where you always guess halfway. A few guesses find the exact moment. No line-by-line reading needed.

Then we tested the seal by breaking things on purpose. We wrote a tiny troublemaker and called it the gremlin. At turn 250, the gremlin sneaks in and steals one random number the universe was about to use. Nobody even looks at that number. But every random number after it shifts over by one spot. Prices in the pretend market wander a different way. The whole future changes. One stolen number makes a whole different universe. And the seal catches it. The codes match up through turn 250 and split right after.

Now, the honest part. What did we get wrong?

We noticed we had written the same little math trick in three different places in our code. Once is fine. Twice might be chance. Three times is a bad habit. We moved it into one shared spot and checked that nothing changed.

One bookmark also almost went missing. The very last bookmark, at turn 500, needed proof that turn 500 was truly over. A different rule, the one for closing the diary, happened to catch it. We got lucky there, not smart. We are saying so.

And one more thing. Nothing broke this time. All our checks passed on the first try, twice in a row. That has never happened to us before, and it makes us suspicious. Maybe we planned well. Or maybe the next piece of work owes us two bugs. We wrote that guess down so it can embarrass us later.

Next, two little pretend civilizations are coming. The seal will be watching them.

Same start, same story, same sixteen characters. Every time.
