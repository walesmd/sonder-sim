# The Witness Rule

*Post 0014 · the plain-language version · the full essay:
[complete](./complete.md)*

This card shipped zero lines of code on purpose. It was a design
conversation — a long one, seven questions — about something the
simulation has been faking politely for months: how does anything
*get* anywhere?

Here's the fake. Since post 0011, news in our worlds travels at one
fixed speed, in every direction, automatically. A battle happens,
and knowledge of it just radiates outward like a ripple in a pond,
reaching everyone eventually. Nobody carries it. Nothing can lose
it. We called this the field model, and we said out loud, the day
we built it, that it was a placeholder — because in a real
universe, information rides *things*. People on ships. Riders
through mountain passes. Email between desks. Mike's rule, written
down back then: nothing arrives that nothing carried.

This card designs the replacement. Not the code — the plan. Ten
future cards will build pieces of it, and if we let each one invent
its own answers, we'd end up with a junk drawer of special cases.
So we sat down first and asked: what is *any* way of moving *any*
thing, described so simply that a cargo ship between stars, a
caravan between towns, and an email between coworkers are all the
same kind of answer?

Because that's the standing test of this whole project now: we run
three practice universes — a space sim, a fantasy continent, an
office — on one engine, and anything we build must work in all
three or it doesn't belong in the engine.

The answer we landed on: movement is a **system**, and the system
owns the properties. Every way of moving things gets one row in one
table, with five facts: how fast it goes, who it can reach and
when, what can go wrong on the way, who pays for it, and who *is*
it — because a mechanism can be somebody. A merchant fleet. A
caravan house. The IT department.

The cargo only splits one way: some cargo is **net-zero** — grain
that leaves your granary is gone from your granary, and the books
must balance — and some cargo is **copyable**, like information,
because telling someone a secret doesn't remove it from your head.
Mike's test for the whole design: money sent as physical coins on a
seven-day ship voyage, and money wired electronically in seconds,
must be the same two events with different gaps between them. One
table has to hold both.

Two of Mike's rulings shaped everything. The first: a rumor is not
a delivery. It's a *chain* of deliveries — A tells B tells C tells
D — and every stop retells the story a little differently,
depending on what that person believes and what they want. His
phrase, which we kept: a rumor is not one shipment; it's one
*plus* shipments. Like the telephone game, except some players
change the message on purpose. So the engine will never have
special rumor machinery — a rumor is just minds choosing to re-send
things, over and over.

The second ruling is the one the post is named after. We asked:
when nobody deliberately sends the news — a battle just *happens* —
how does anyone find out? His answer:

> I say we take the tactic of "if a tree falls in the forest but no
> one is there to hear it, does anyone hear the sound?" If there is
> not someone — an individual, a faction, a persona — to carry the
> information, then is it real?

That's the witness rule. Sound, light, word of mouth — those reach
whoever happens to be nearby *at that moment*. Those people are
witnesses. Everything after that is somebody carrying the story
somewhere. And if nobody witnessed it? Then the news simply never
exists. Not delayed — never. The event still happened, and the
simulation's permanent record still knows it. But no civilization
ever will. The universe gets to keep secrets, which — for a project
named after the realization that every passerby has a full inner
life you'll never know — feels exactly right.

The rule pays off immediately. Mike proposed a test story:
civilization A hires carrier C to haul goods to civilization B, and
C steals the shipment on an empty road. Nobody saw it. So A only
ever learns that B says nothing arrived. Was it the carrier?
Bandits? A shipwreck? A may accuse the wrong neighbor entirely —
and the whole mystery emerges from these rules without anyone
scripting it.

Best part: none of this is theoretical. NASA had exactly this
problem — you can't keep a live connection across a solar system —
and built a real technology called delay-tolerant networking, where
messages are physically held by each node and handed forward when
contact is possible. Their specs even use our word: *custody*. When
Earth's engineers had to network space, they built ships that carry
news. We cite their work in the full essay.

What we got wrong, kept on the record: Claude asked the first
question using the word "ontology," which landed like a brick, and
later said "big-bang migration" to a man whose universes literally
have big bangs — plain words first, always. Claude's first draft
also quietly kept a bit of the old magic ripple, letting nature
"deliver" news instead of witnesses catching it; Mike's tree rule
fixed that. And this post has a "why are we doing this now" section
because Mike pointed out twelve posts never answered that question.
This one does. The next card starts building it.
