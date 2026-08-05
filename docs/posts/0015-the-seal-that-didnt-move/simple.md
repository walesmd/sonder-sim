# The Seal That Didn't Move

*Post 0015 · the plain-language version · the full essay:
[complete](./complete.md)*

Last post, we designed a rule on paper: news only exists if someone
witnessed it or someone carried it. No more magic ripple that
delivers every event to every civilization automatically. This
post, we built it — and the result surprised us, which is the best
thing a result can do.

First, a reminder of what we were replacing. Since the simulation
learned that news takes time to travel, it has used a placeholder
we call the field: every event radiates outward in all directions,
at one speed, reaching everyone eventually. It behaves like a
pond ripple that never weakens. We said out loud, months ago, that
this was fake and would have to go — in a real universe,
information rides *things*: ships, riders, wires, word of mouth.

The replacement is a table the world fills in. Every way news can
travel gets one row: how fast it goes, and who it can reach. Reach
comes in exactly two shapes. Either the news *radiates* to everyone
within a certain distance — how far depends on how loud the event
was — or it's *addressed* to one named recipient, like a letter.
That's it. The old magic ripple turns out to be just one row of
this table — "radiates everywhere, at standard speed" — so two of
our three practice worlds now declare that row openly while they
wait their turn to migrate. Honest placeholder, on the record.

The third world went first. Harrow is our fantasy continent: five
civilizations, no ocean between them, all trade carried by letters
and caravans over mountain passes. We gave it two rows. **Earshot**:
a loud act — a declaration of war, a city's founding — carries two
days' travel in every direction; ordinary and quiet acts stay home.
**Letters**: a trade offer rides to the named buyer, an acceptance
rides back to the named seller, and nobody else ever sees them.
Then we deleted the ripple.

Here's where it gets good. Our simulations carry a tamper seal — a
fingerprint of everything that ever happened, sixteen characters
long. If history changes by even one event, the seal changes. We
were so sure this surgery would change Harrow's history that we
pre-wrote the paperwork for it. The plan literally said: the seal
will move, once, loudly, and we'll record why.

The seal didn't move.

We had read the minds of all five civilizations, and it turned out
none of them had ever *used* the extra knowledge the ripple gave
them. Every decision on the whole continent runs on two things:
what happened at your own gates, and letters addressed to you by
name. The ripple had been delivering the whole world's history to
everyone, every day, and nobody ever read it. Deleting it changed
no decisions, so it changed no events, so the fingerprint of
history came out identical — while what every civilization *knows*
shrank dramatically. The steppe horsemen no longer know the rich
valley exists. The river middlemen no longer read everyone's mail.
History stayed the same; knowledge got honest.

One new fact of life on Harrow is worth a shiver. When the mountain
clans declare war, the declaration is loud — it carries two days,
one mountain pass. The valley they're about to raid is four days
away. So the valley never hears the declaration. The first they
learn of the war is the raid arriving at their own gates. The
pass-keepers in between heard everything and told no one. Whether
someone in earshot *chooses* to carry a warning onward — a spy, an
ally, a paid informant — is now a real question the simulation can
someday ask. That's not a bug in the design; it's the whole point
of it.

Mike asked one more question after the build: what about knowledge
that nobody sends — say, a star dies and a civilization simply
*sees* it? That's the radiating shape in its purest form. In the
space world, light itself becomes a row in the table: radiates
enormously far, travels enormously fast, owned by no one. A
civilization ten light-years away witnesses the death ten years
late. Astronomy, in this design, is just witnessing very old news
on a very fast medium — no new machinery needed, one more row.

The computer science under all this comes in two parts. Our two
shapes are the two oldest delivery modes in networking — a letter
is *unicast* (one named destination), earshot is *broadcast with a
distance limit*, the same idea as the number in every internet
packet that says how far it may spread before it dies. And the old
ripple has a network name too: *flooding* — send everything to
everyone — which real networks only do when they don't know any
better. The seal, meanwhile, is what testers call a
*characterization test*: it records what a system actually does,
so you can rebuild the system's insides and know instantly whether
its behavior changed. Ours surprised us, and a characterization
test that surprises you is teaching you what your system really
was.

What we got wrong, kept on the record: we confidently predicted the
seal would move, and it didn't — we reasoned from what we were
changing instead of from what the minds actually read. We also
almost claimed the pilot creates events *nobody* ever learns of;
on Harrow, someone is always in earshot, so the truth is events
*most* civilizations never learn of. And a stray line of
tool-configuration noise shipped in the first draft and got caught
in review. Next up: news that wears out as it travels — because now
there's finally something for it to wear out *on*.
