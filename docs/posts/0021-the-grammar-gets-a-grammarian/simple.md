# The Grammar Gets a Grammarian

*Post 0021 · the plain-language version · the full essay:
[complete](./complete.md)*

Every world in our simulator declares its own vocabulary: the
complete list of everything that can happen there, with the exact
shape each event must have. The space world declares market prices
and war parties; the fantasy continent declares grain offers and
lost letters; the office declares payslips and closed deals. The
vocabulary is a world's grammar, and the engine holds every event
to it — nothing malformed ever enters the permanent record.

This card fixed two problems with how those grammars were handled,
both found by the big review, and one of them was predicted by the
code itself.

The prediction first. Four kinds of event are the same in every
world, because the engine itself operates them: goods departing,
goods arriving, money departing, money arriving — the freight
grammar. All three worlds spelled out those four declarations by
hand, and the office world's file contained a comment, written the
day it was born: a helper that lets worlds *import* these shared
declarations "earns its keep at the third world, per the rule of
three." The third world arrived five days later; the helper
didn't. Tonight it did: worlds now pull the freight grammar in
with one line, and a world that wants its own version of any
declaration keeps it — the grammar belongs to the world; the
shared version just refuses to be missing. The two comments that
predicted this now record that it happened.

The structural problem second. A world's vocabulary is consumed by
four different parts of the engine — the validator, the
serializer, the tamper seal, the archive — and each part checked
only the corner it personally touched. Hand the engine a
half-built vocabulary and you'd get an error eventually, from
whichever part happened to trip first, phrased in that part's
private dialect. Worse: the *complete* set of rules did exist —
but in a test file, checked only when the test suite ran, and only
against one of the three worlds. The other two obeyed the rules
out of discipline, not because anything enforced them.

Now there's one checker, with every rule, speaking one language,
and it runs the instant a universe is constructed — the earliest
possible moment, at the boundary where the world hands its grammar
over. The old test still exists, but it now tests the checker
itself. Software people call this idea design by contract: state
what you require, and check it where the handover happens, not
scattered through the internals. The general lesson is worth
keeping: when a rule matters, its home is the boundary it
protects. The test suite visits; it shouldn't be the landlord.

How do we know none of this changed any world's actual history?
The usual instrument, with one subtle twist worth enjoying. The
tamper seals hash each event's bytes, and those bytes serialize
payload fields *in the order the vocabulary declares them*. So
when we deleted three hand-written copies of the freight grammar
and replaced them with one shared copy, the shared copy had to
match the deleted ones field-for-field, in order — or all three
worlds' seals would have shouted simultaneously. All 186 tests
pass; all three seals are identical to the bit. The extraction
preserved the public grammar down to the byte order, and we know
because the instrument was built to notice.

What we got wrong, honestly: for four releases we described the
vocabulary as "strict from day one," and it was strict only at
test time, for one world of three. The difference between "everyone
follows the rules" and "the rules are enforced" is exactly one bad
Friday. The edge of the system was softer than we advertised. Now
it's as hard as we said it was.

Engine 0.2.4 — the fourth patch of the overnight run, each one
proving no history moved. One stop left: the hygiene sweep, twelve
small fixes, none of which deserves an essay and all of which
deserve to stop being true.
