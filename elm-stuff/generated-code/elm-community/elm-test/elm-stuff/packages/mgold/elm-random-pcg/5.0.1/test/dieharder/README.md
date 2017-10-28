# Dieharder tests for Random.Pcg

**These tests rely on a library that has not been update for 0.17.**

The purpose of testing the random number generator is twofold: one, show the deficiencies in the core implementation;
two, show the correctness of the Pcg implementation *in Elm*. Because we are testing the Elm implementation, not the Pcg
algorithm, we must feed dieharder a file of already-generated random numbers. I've seen sources recommending 10 million
random numbers; these tests use 24 million, but even so the files are "rewound", as many as 2500 times on later tests.

For the original 19 diehard tests, the core fails 9 tests while Pcg fails none. (One test resulted in "weak" but further
investigation resulted in passing; we expect this on one test in 100). On the entire battery, core passes 29, fails 75,
and is weak in 10. Pcg passes 82, fails 24, and is weak in 8. Some of Pcg's strength may be attributed to its 64 bits of
state, compared to core's 32, but this does not excuse failing the less-comprehensive diehard tests. Conversely, many of
the failures can be attributed to reusing pre-generated random numbers.

The source Elm is `Dieharder.elm`. Because the tests require more random numbers than can be stored in memory, they
output chunks of 2 million at a time. In order to reuse the code, `compile.sh` rewrites the file to change the Random
implementation. It also writes out the `.txt` data files, and then runs dieharder, logging the results.

The result log files have been committed to version control; I would have liked to commit the data files but they're
huge, and only take a few minutes to generate. You are free to alter the random seed in the Elm code, and rerun the
tests with `sh compile` (which takes several hours to complete). That said, I encourage you to run it long enough to see
core fail the birthday test, after only five or six seconds of scrutiny. (The `dieharder` tool is available through most
package managers. Once the data files are generated, try `time dieharder -g 202 -f elm-core-random.txt -d 0`.)

The Pcg paper uses the TestU01 (e.g. BigCrush) suite; I'm using dieharder since it was easier to get to work
reading from a file.
