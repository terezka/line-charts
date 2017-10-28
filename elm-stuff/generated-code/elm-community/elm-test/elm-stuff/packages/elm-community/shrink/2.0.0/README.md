# Shrinking strategies with elm-community/shrink

`shrink` is a library for using and creating shrinking strategies. A
shrinking strategy, or shrinker, is a way of taking a value and producing a
list of values which are, some sense, more minimal than the original value.

Shrinking is heavily used in property-based testing as a way to shrink
failing test cases into a more minimal test case. This is key for being
able to debug code swiftly and easily. Therefore, the main intended use
of this library is to support testing frameworks. You might also use it to
define shrinkers for types you define, in order to test them better.

Note that `shrink` uses lazy lists instead of lists. This means that `shrink` has a direct dependency on
[elm-community/elm-lazy-list](https://github.com/elm-community/elm-lazy-list).

```elm
type alias Shrinker a = a -> LazyList a
```
That is, a shrinker takes a value to shrink, and produces, *lazily*, a list
of shrunken values.

### Basic Examples

The following examples show how to use the basic shrinkers and the kinds of
results they produce. Note that we're glossing over the lazy part of this;
pretend there's a `Lazy.List.toList` on the left of each example.

**Shrink an Int**

```elm
int 10 == [0,5,7,8,9]
```


**Shrink a String**

```elm
string "Hello World" ==
  [""," World","Hellod","llo World","Heo World","HellWorld","Hello rld","Hello Wod","ello World","Hllo World","Helo World","Helo World","Hell World","HelloWorld","Hello orld","Hello Wrld","Hello Wold","Hello Word","Hello Worl","\0ello World","$ello World","6ello World","?ello World","Cello World","Eello World","Fello World","Gello World","H\0llo World","H2llo World","HKllo World","HXllo World","H^llo World","Hallo World","Hcllo World","Hdllo World","He\0lo World","He6lo World","HeQlo World","He^lo World","Heelo World","Hehlo World","Hejlo World","Heklo World","Hel\0o World","Hel6o World","HelQo World","Hel^o World","Heleo World","Helho World","Heljo World","Helko World","Hell\0 World","Hell7 World","HellS World","Hella World","Hellh World","Hellk World","Hellm World","Helln World","Hello\0World","HelloWorld","HelloWorld","HelloWorld","HelloWorld","HelloWorld","Hello \0orld","Hello +orld","Hello Aorld","Hello Lorld","Hello Qorld","Hello Torld","Hello Uorld","Hello Vorld","Hello W\0rld","Hello W7rld","Hello WSrld","Hello Warld","Hello Whrld","Hello Wkrld","Hello Wmrld","Hello Wnrld","Hello Wo\0ld","Hello Wo9ld","Hello WoUld","Hello Wocld","Hello Wojld","Hello Wonld","Hello Wopld","Hello Woqld","Hello Wor\0d","Hello Wor6d","Hello WorQd","Hello Wor^d","Hello Wored","Hello Worhd","Hello Worjd","Hello Workd","Hello Worl\0","Hello Worl2","Hello WorlK","Hello WorlW","Hello Worl]","Hello Worl`","Hello Worlb","Hello Worlc"]
```

**Shrink a Maybe Float**

```elm
maybe float (Just 3.14) ==
  [Nothing,Just 0,Just 1.57,Just 2.355,Just 2.7475,Just 2.94375,Just 3.041875,Just 3.0909375,Just 3.11546875,Just 3.127734375,Just 3.1338671875,Just 3.1369335937500002,Just 3.138466796875,Just 3.1392333984375,Just 3.1396166992187498,Just 3.1398083496093747]
```

**Shrink a List of Bools**

```elm
list bool [True, False, False, True, False] ==
  [[],[False,True,False],[True,False,False],[False,False,True,False],[True,False,True,False],[True,False,True,False],[True,False,False,False],[True,False,False,True],[False,False,False,True,False],[True,False,False,False,False]]
```


## Make your own shrinkers

With `shrink`, it is very easy to make your own shrinkers for your own data
types.

First of all, let's look at one of the basic shrinkers available in `shrink`
and how it is implemented.

**Shrinker Bool**

To shrink a `Bool`, you have to consider the possible values of `Bool`: `True`
and `False`. Intuitively, we understand that `False` is more "minimal"
than `True`. As, such, we would shrink `True` to `False`. As for `False`,
there is no value that is more "minimal" than `False`. As such, we simply
shrink it to the empty list.

```elm
bool : Shrinker Bool
bool b = case b of
  True  -> False ::: empty
  False -> empty
```

*Note that there is no "exact" rule to deciding on whether something is more
"minimal" than another.* The idea is that you want to have one case return
the empty list if possible while other cases move towards the more "minimal"
cases. In this example, we decided that `False` was the more "minimal" case and,
in a sense, moved `True` towards `False` since `False` then returns the empty
list. Obviously, this choice could have been reversed and you would be
justified in doing so. Just remember that *a value should never shrink to itself,
or shrink to something that (through any number of steps) shrinks back to itself.*
This is a recipe for an infinite loop.

Now that we understand how to make a simple shrinker, let's see how we can use
these simple shrinkers together to make something that can shrink a more
complex data structure.

**Shrinker Vector**

Consider the following `Vector` type:

```elm
type alias Vector =
  { x : Float
  , y : Float
  , z : Float
  }
```

Our goal is to produce a vector shrinker:

```elm
vector : Shrinker Vector
```

`shrink` provides a basic `Float` shrinker and we can use it in combination
with `map` and `andMap` to make the `Vector` shrinker.

```elm
vector : Shrinker Vector
vector {x, y, z} =
  Vector
    `map`    float x
    `andMap` float y
    `andMap` float z
```

And voila! Super simple. Let's try this on an even larger structure.


**Shrinker Mario**

Consider the following types:

```elm
type alias Mario =
  { position  : Vector
  , velocity  : Vector
  , direction : Direction
  }

type alias Vector =
  { x : Float
  , y : Float
  }

type Direction
  = Left
  | Right
```

And our goal is to produce a shrinker of Marios.

```elm
mario : Shrinker Mario
```

To do this, we will split the steps. We can notice that we have two distinct
data types we need to shrink: `Vector` and `Direction`.

For `Vector`, we can use the approach from the previous example:

```elm
vector : Shrinker Vector
vector {x, y} =
  Vector
    `map`    float x
    `andMap` float y
```

And for `Direction`, we can apply a similar approach to our `Bool` example:

```elm
direction : Shrinker Direction
direction dir = case dir of
  Left  -> empty
  Right -> Left ::: empty
```

Where `Left` here is considered the "minimal" case.


Now, let's put these together:

```elm
mario : Shrinker Mario
mario m =
  Mario
    `map`    vector m.position
    `andMap` vector m.velocity
    `andMap` direction m.direction
```

And, yay! We now can shrink `Mario`! No mushrooms needed!

### One more technique

Sometimes, you want to shrink a data structure but you know intuitively that
it should shrink in a similar fashion to some other data structure. It would
be nice if you could just convert back and from that other data structure and
use its already existing shrinker.

For example `List` and `Array`.

In `shrink`, there exists a `List` shrinker:

```elm
list : Shrinker a -> Shrinker (List a)
```

This shrinker is quite involved and does a number of things to shuffle elements,
shrink some elements, preserve others, etc...

It would be nice if that can be re-used for arrays, because in a high-level
sense, arrays and lists are equivalent.

This is exactly what `shrink` does and it uses a function called `convert`.

```elm
convert : (a -> b) -> (b -> a) -> Shrinker a -> Shrinker b
```

`convert` converts a shrinker of a's into a shrinker of b's by taking a
two functions to convert to and from b's.

**IMPORTANT NOTE: Both functions must be perfectly invertible or else this
process may create garbage!**

By invertible, I mean that `f` and `g` are invertible **if and only if**

```elm
f (g x) == g (f x) == x
```

**for all `x`.**

Now we can very simply implement a shrinker of arrays as follows:

```elm
array : Shrinker a -> Shrinker (Array a)
array shrinker =
  convert (Array.fromList) (Array.toList) (list shrinker)
```

And, ta-da... 0 brain cells were used to get a shrinker on arrays.
