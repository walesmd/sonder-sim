# Whatever That Universe May Be

*Post 0013 · the simple version — plain language, same facts · the
complete essay: [complete.md](./complete.md)*

*Previously: twelve posts built one simulated universe — two
space-faring nations, a grain market, wars nobody planned, news and
goods that take days to travel. Then Mike asked an uncomfortable
question: was any of that actually about space?*

---

Here's the experiment this post is about. We took the machine that
runs our space universe — the event log, the beliefs, the slow news,
the traveling goods, the incorruptible auditor — and, without
changing it, built two more universes on top of it.

One is an office. Bellwether & Co. has ten employees — a founder,
managers, sellers, makers — and every one of them is a full citizen
of the simulation, with their own beliefs and their own private
newspaper, exactly like an empire. Distance between people isn't
measured in meters: it's measured in the org chart. Two people on
the same team hear each other's news in a day; a rumor takes four
days to climb from sales to the workshop. When a client quietly
walked away from a deal, the seller went silent the next morning,
her neighbor caught the mood two days later, and the makers — four
hops away on the chart — kept cheerfully producing at full speed
until the bad news finally reached them. The company changed its
behavior before the company knew why. Nobody programmed that
episode; it fell out of social distance, and we now test for it.

The other is a continent called Harrow: five kingdoms who cannot
move away from one another. Every road runs through someone's
territory, and there is no marketplace anywhere — trade happens by
letter. An offer rides to a neighbor, a yes rides back, and only
then do the caravan and the strongbox set out — four journeys for
one deal, most of two weeks between the valley and the mountains.
Every lean season, the mountain kingdom runs out of patience four
hungry days at a time and sends war parties through the southern
pass. In four hundred simulated days: fourteen wars, 291 trade
letters, seventy settled deals — and the auditor balanced every
sack, ingot, measure, and cent to zero discrepancies, through all
of it.

The point was never the office or the continent. The point is the
sentence Mike said when we asked whether we'd accidentally built a
general simulation engine: *we are not building a game; we are
building a system of systems — games are just the outcomes.* The
destination is still the universal space simulator. But if the
machine can only host space stories, it isn't a universe simulator
— it's a space game with good posture. So the two little worlds are
now permanent tests. The rule, which we've written into the
project's constitution: anything we build must serve all three
universes, or it gets filed as content for one of them. The engine,
pleasingly, got *smaller* with every world it gained — the space
sim's vocabulary, its bookkeeping rules, even its sentences turned
out to be luggage, not chassis.

We broke things, as always. For the third card running we sized a
"memory window" wrong — the office payroll pays nine people in one
burst, and a window built for two civilizations quietly dropped the
first paycheck from the founder's mental books every single week
(113 tiny errors, each exactly one salary). Our first theory about
that bug was confidently wrong, and the wrong version is kept in
the notebook next to the right one. Then Harrow's traders shipped
one order twice, because the memory of having shipped it expired
before the order did. The final fix was the best kind: stop keeping
memories at all. Every piece of news arrives in a mind exactly
once, on exactly one morning — so traders now simply act on the
morning they learn, and double-shipping became impossible instead
of unlikely. If that one morning finds the seller short or the
buyer broke, the deal quietly fails half-done — which is real
settlement risk, in a world that doesn't have debt collectors yet.

Three universes now run under permanent seals — space
`3475639d8f49678b`, office `10fc9a5781a44136`, continent
`9be58120c48a121b` — one hundred sixty-two automated checks, one
engine among them. The next thing we build is a theory of carriers:
what carries things, and how fast. It will have to answer for
starships, caravans, and inter-office mail in the same breath.
That's the whole trick of this card — the space simulator we're
really here to build now has two small, strange universes standing
behind it, asking of every new idea: *would this work for an
office? for a continent?* If yes, it's the engine. If no, it's just
space — and space, it turns out, was never the hard part.
