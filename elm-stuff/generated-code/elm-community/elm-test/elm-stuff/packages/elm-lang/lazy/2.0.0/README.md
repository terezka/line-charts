# Laziness in Elm

This package provides the basic primitives for working with laziness in Elm.


# Motivating Example

Maybe you have 100 different graphs you want to show at various times, each
requiring a decent amount of computation. Here are a couple ways to handle
this:

 1. Compute everything up front. This will introduce a delay on startup, but
    it should be quite fast after that. Depending on how much memory is needed
    to store each graph, you may be paying a lot there as well.

 2. Compute each graph whenever you need it. This minimizes startup cost and
    uses a minimal amount of memory, but when you are flipping between two
    graphs you may be running the same computations again and again.

 3. Compute each graph whenever you need it and save the result. Again, this
    makes startup as fast as possible fast, but since we save the result,
    flipping between graphs becomes much quicker. As we look at more graphs
    we will need to use more and more memory though.

All of these strategies are useful in general, but the details of your
particular problem will mean that one of these ways provides the best
experience. This library makes it super easy to use strategy #3.


# Pitfalls

**Laziness + Time** &mdash;
Over time, laziness can become a bad strategy. As a very simple example, think
of a timer that counts down from 10 minutes, decrementing every second. Each
step is very cheap to compute. You subtract one from the current time and store
the new time in memory, so each step has a constant cost and memory usage is
constant. Great! If you are lazy, you say &ldquo;here is how you would subtract
one&rdquo; and store that *entire computation* in memory. This means our memory
usage grows linearly as each second passes. When we finally need the result, we
might have 10 minutes of computation to run all at once. In the best case, this
introduces a delay that no one *really* notices. In the worst case, this
computation is actually too big to run all at once and crashes. Just like with
dishes or homework, being lazy over time can be quite destructive.

**Laziness + Concurrency** &mdash;
When you add concurrency into the mix, you need to be even more careful with
laziness. As an example, say we are running expensive computations on three
worker threads, and the results are sent to a fourth thread just for rendering.
If our three worker threads are doing their work lazily, they
&ldquo;finish&rdquo; super quick and pass the entire workload onto the render
thread. All the work we put into designing this concurrent system is wasted,
everything is run sequentially on the render thread! It is just like working on
a team with lazy people. You have to pay the cost of coordinating with them,
but you end up doing all the work anyway. You are better off making things
single threaded!


## Learn More

One of the most delightful uses of laziness is to create infinite streams of
values. Hopefully we can get a set of interesting challenges together so
you can run through them and get comfortable.

For a deeper dive, Chris Okasaki's book *Purely Functional Data Structures*
and [thesis](http://www.cs.cmu.edu/~rwh/theses/okasaki.pdf)
have interesting examples of data structures that get great
benefits from laziness, and hopefully it will provide some inspiration for the
problems you face in practice.

