module Random.Pcg exposing (Generator, Seed, bool, int, float, oneIn, sample, pair, list, maybe, choice, choices, frequency, map, map2, map3, map4, map5, andMap, filter, constant, andThen, minInt, maxInt, step, generate, initialSeed, independentSeed, fastForward, toJson, fromJson)

{-| Generate psuedo-random numbers and values, by constructing
[generators](#Generator) for them. There are a bunch of basic generators like
[`bool`](#bool) and [`int`](#int) that you can build up into fancier generators
with functions like [`list`](#list) and [`map`](#map).

You run a `Generator` by calling the [`step`](#step) function, which
also takes a random [`Seed`](#Seed), and passes back a new seed. You should
never use the same seed twice because you will get the same result! If you need
random values over time, you should store the most recent seed in your model.
Alternatively, use [`generate`](#generate) to obtain random values from the Elm
runtime.

This is an implementation of [PCG](http://www.pcg-random.org/) by M. E. O'Neil,
and is not cryptographically secure.

# Getting Started
@docs initialSeed, step, generate

# Basic Generators
@docs Generator, bool, int, float, oneIn, sample

# Combining Generators
@docs pair, list, maybe, choice, choices, frequency

# Custom Generators
@docs constant, map, map2, map3, map4, map5, andMap, andThen, filter

# Working With Seeds
@docs Seed, independentSeed, fastForward, toJson, fromJson

# Constants
@docs minInt, maxInt
-}

import Bitwise
import Json.Encode
import Json.Decode
import Task
import Tuple
import Time


{-| A `Generator` is like a recipe for generating certain random values. So a
`Generator Int` describes how to generate integers and a `Generator String`
describes how to generate strings.
-}
type Generator a
    = Generator (Seed -> ( a, Seed ))


{-| Generate a random value as specified by a given `Generator`, using a `Seed`
and returning a new one.

In the following example, we are trying to generate numbers between 0 and 100
with the `int 0 100` generator. Each time we call `generate` we need to provide
a seed. This will produce a random number and a *new* seed to use if we want to
run other generators later.

    (x, seed1) = step (int 0 100) seed0
    (y, seed2) = step (int 0 100) seed1
    (z, seed3) = step (int 0 100) seed2
    [x, y, z] -- [85, 0, 38]

Notice that we use different seeds on each line. This is important! If you reuse
the same seed, you get the same results.

    (x, _) = step (int 0 100) seed0
    (y, _) = step (int 0 100) seed0
    (z, _) = step (int 0 100) seed0
    [x,y,z] -- [85, 85, 85]

As you can see, threading seeds through many calls to `step` is tedious and
error-prone. That's why this library includes many functions to build more
complicated generators, allowing you to call `step` only a small number of
times.

Our example is best written as:

    (xs, newSeed) = step (list 3 <| int 0 100) seed0
    xs -- [85, 0, 38]

-}
step : Generator a -> Seed -> ( a, Seed )
step (Generator generator) seed =
    generator seed


{-| Create a Command that will generate random values according to the supplied
`Generator`.

Think of this function as an alternative to `step`, since they both provide a
way to actually get the random values that you want. This function frees you
from worrying about seeds entirely, but as a tradeoff, you get your random
values asynchronously, in their own Message. Additionally, due to constraints on
third-party packages, it's possible that multiple commands sent at the same
moment will return the same values.

You can also think of this function as an alternative to `independentSeed`,
since they both allow you to use randomness in deeply nested components. In the
case of this function, it's through sending Commands up the chain that you have
to set up anyway.
-}
generate : (a -> msg) -> Generator a -> Cmd msg
generate toMsg generator =
    Time.now
        |> Task.map (round >> initialSeed >> step generator >> Tuple.first)
        |> Task.perform toMsg


{-| A `Seed` is the source of randomness in the whole system. It hides the
current state of the random number generator.

Generators, not seeds, are the primary data structure for generating random
values. Generators are much easier to chain and combine than functions that take
and return seeds. Creating and managing seeds should happen "high up" in your
program.
-}
type Seed
    = Seed Int Int


{-| Initialize the state of the random number generator. The input should be
a randomly chosen 32-bit integer. You can generate and copy random integers to
create a reproducible psuedo-random generator.

    $ node
    > Math.floor(Math.random()*0xFFFFFFFF)
    227852860

    -- Elm
    seed0 : Seed
    seed0 = initialSeed 227852860

Alternatively, you can generate the random integers on page load and pass them
through a port. The program will be different every time.

    -- Elm
    port randomSeed : Int

    seed0 : Seed
    seed0 = initialSeed randomSeed

    -- JS
    Elm.ModuleName.fullscreen(
      { randomSeed: Math.floor(Math.random()*0xFFFFFFFF) })

Either way, you should initialize a random seed only once. After that, whenever
you use a seed, you'll get another one back.
-}
initialSeed : Int -> Seed
initialSeed x =
    let
        (Seed state1 incr) =
            -- The magic constant is from Numerical Recipes and is inlined for perf.
            next (Seed 0 1013904223)

        state2 =
            state1 + x |> Bitwise.shiftRightZfBy 0
    in
        next (Seed state2 incr)


next : Seed -> Seed
next (Seed state0 incr) =
    -- The magic constant is from Numerical Recipes and is inlined for perf.
    Seed ((state0 * 1664525) + incr |> Bitwise.shiftRightZfBy 0) incr



-- obtain a psuedorandom 32-bit integer


peel : Seed -> Int
peel (Seed state _) =
    -- This is the RXS-M-SH version of PCG, see section 6.3.4 of the paper
    -- and line 184 of pcg_variants.h in the 0.94 C implementation
    let
        word =
            ((state |> Bitwise.shiftRightZfBy ((state |> Bitwise.shiftRightZfBy 28) + 4)) |> Bitwise.xor state) * 277803737
    in
        Bitwise.xor (word |> Bitwise.shiftRightZfBy 22) word
            |> Bitwise.shiftRightZfBy 0


{-| Generate 32-bit integers in a given range, inclusive.

    int 0 10   -- an integer between zero and ten
    int -5 5   -- an integer between -5 and 5

    int minInt maxInt  -- an integer in the widest range feasible

This function *can* produce values outside of the range [[`minInt`](#minInt),
[`maxInt`](#maxInt)] but sufficient randomness is not guaranteed.

*Performance note:* This function will be ~1.5x faster if the range (i.e. `max - min + 1`) is a power of two. The
effect will only be noticable if you are generating tens of thousands of random integers.

-}
int : Int -> Int -> Generator Int
int a b =
    Generator <|
        \seed0 ->
            let
                ( lo, hi ) =
                    if a < b then
                        ( a, b )
                    else
                        ( b, a )

                range =
                    hi - lo + 1
            in
                -- fast path for power of 2
                if (range |> Bitwise.and (range - 1)) == 0 then
                    ( (peel seed0 |> Bitwise.and (range - 1) |> Bitwise.shiftRightZfBy 0) + lo, next seed0 )
                else
                    let
                        threshhold =
                            -- essentially: period % max
                            rem (-range |> Bitwise.shiftRightZfBy 0) range |> Bitwise.shiftRightZfBy 0

                        accountForBias : Seed -> ( Int, Seed )
                        accountForBias seed =
                            let
                                x =
                                    peel seed

                                seedN =
                                    next seed
                            in
                                if x < threshhold then
                                    -- in practice this recurses almost never
                                    accountForBias seedN
                                else
                                    ( rem x range + lo, seedN )
                    in
                        accountForBias seed0


bit53 =
    9007199254740992.0


bit27 =
    134217728.0


{-| Generate floats in a given range. The following example is a generator
that produces numbers between 0 and 1.

    probability : Generator Float
    probability =
      float 0 1
-}
float : Float -> Float -> Generator Float
float min max =
    Generator <|
        \seed0 ->
            let
                -- Get 64 bits of randomness
                seed1 =
                    next seed0

                n0 =
                    peel seed0

                n1 =
                    peel seed1

                -- Get a uniformly distributed IEEE-754 double between 0.0 and 1.0
                hi =
                    toFloat (n0 |> Bitwise.and 0x03FFFFFF) * 1.0

                lo =
                    toFloat (n1 |> Bitwise.and 0x07FFFFFF) * 1.0

                val =
                    ((hi * bit27) + lo) / bit53

                -- Scale it into our range
                range =
                    abs (max - min)

                scaled =
                    val * range + min
            in
                ( scaled, next seed1 )


{-| Create a generator that produces boolean values with equal probability. This
example simulates flipping three coins and checking if they're all heads.

    threeHeads : Generator Bool
    threeHeads =
      map3 (\a b c -> a && b && c) bool bool bool
-}
bool : Generator Bool
bool =
    map ((==) 1) (int 0 1)


{-| The maximum value for randomly generated 32-bit ints.
-}
maxInt : Int
maxInt =
    2147483647


{-| The minimum value for randomly generated 32-bit ints.
-}
minInt : Int
minInt =
    -2147483648


{-| Create a pair of random values. A common use of this might be to generate
a point in a certain 2D space. Imagine we have a collage that is 400 pixels
wide and 200 pixels tall.

    randomPoint : Generator (Int,Int)
    randomPoint =
        pair (int -200 200) (int -100 100)

-}
pair : Generator a -> Generator b -> Generator ( a, b )
pair genA genB =
    map2 (,) genA genB


{-| Create a list of random values of a given length.

    floatList : Generator (List Float)
    floatList =
        list 10 (float 0 1)

    intList : Generator (List Int)
    intList =
        list 5 (int 0 100)

    intPairs : Generator (List (Int, Int))
    intPairs =
        list 10 <| pair (int 0 100) (int 0 100)
-}
list : Int -> Generator a -> Generator (List a)
list n (Generator generate) =
    Generator <|
        \seed ->
            listHelp [] n generate seed


listHelp : List a -> Int -> (Seed -> ( a, Seed )) -> Seed -> ( List a, Seed )
listHelp list n generate seed =
    if n < 1 then
        ( list, seed )
    else
        let
            ( value, newSeed ) =
                generate seed
        in
            listHelp (value :: list) (n - 1) generate newSeed


{-| Create a generator that always produces the value provided. This is useful
when creating complicated chained generators and you need to handle a simple
case. It's also useful for the base case of recursive generators.
-}
constant : a -> Generator a
constant value =
    Generator (\seed -> ( value, seed ))


{-| Transform the values produced by a generator using a stateless function as a
callback.

These examples show how to generate letters based on a basic integer generator.

    lowercaseLetter : Generator Char
    lowercaseLetter =
      map (\n -> Char.fromCode (n + 97)) (int 0 25)

    uppercaseLetter : Generator Char
    uppercaseLetter =
      map (\n -> Char.fromCode (n + 65)) (int 0 25)

-}
map : (a -> b) -> Generator a -> Generator b
map func (Generator genA) =
    Generator <|
        \seed0 ->
            let
                ( a, seed1 ) =
                    genA seed0
            in
                ( func a, seed1 )


{-| Combine two generators. This is useful when you have a function with two
arguments that both need to be given random inputs.

    pointInCircle : Float -> Generator (Float, Float)
    pointInCircle radius =
      let
        r = float 0 radius
        theta = map degrees (float 0 360)
      in
        map2 (curry fromPolar) r theta

-}
map2 : (a -> b -> c) -> Generator a -> Generator b -> Generator c
map2 func (Generator genA) (Generator genB) =
    Generator <|
        \seed0 ->
            let
                ( a, seed1 ) =
                    genA seed0

                ( b, seed2 ) =
                    genB seed1
            in
                ( func a b, seed2 )


{-| Combine three generators. This could be used to produce random colors.

    rgb : Generator Color.Color
    rgb =
      map3 Color.rgb (int 0 255) (int 0 255) (int 0 255)

    hsl : Generator Color.Color
    hsl =
      map3 Color.hsl (map degrees (float 0 360)) (float 0 1) (float 0 1)
-}
map3 : (a -> b -> c -> d) -> Generator a -> Generator b -> Generator c -> Generator d
map3 func (Generator genA) (Generator genB) (Generator genC) =
    Generator <|
        \seed0 ->
            let
                ( a, seed1 ) =
                    genA seed0

                ( b, seed2 ) =
                    genB seed1

                ( c, seed3 ) =
                    genC seed2
            in
                ( func a b c, seed3 )


{-| Combine four generators. This could be used to produce random transparent
colors.

    rgba : Generator Color.Color
    rgba =
      map4 Color.rgba (int 0 255) (int 0 255) (int 0 255) (float 0 1)
-}
map4 : (a -> b -> c -> d -> e) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e
map4 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) =
    Generator <|
        \seed0 ->
            let
                ( a, seed1 ) =
                    genA seed0

                ( b, seed2 ) =
                    genB seed1

                ( c, seed3 ) =
                    genC seed2

                ( d, seed4 ) =
                    genD seed3
            in
                ( func a b c d, seed4 )


{-| Combine five generators.
-}
map5 : (a -> b -> c -> d -> e -> f) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e -> Generator f
map5 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) (Generator genE) =
    Generator <|
        \seed0 ->
            let
                ( a, seed1 ) =
                    genA seed0

                ( b, seed2 ) =
                    genB seed1

                ( c, seed3 ) =
                    genC seed2

                ( d, seed4 ) =
                    genD seed3

                ( e, seed5 ) =
                    genE seed4
            in
                ( func a b c d e, seed5 )


{-| Map over any number of generators.

    randomPerson : Generator Person
    randomPerson =
       map person genFirstName
           |> andMap genLastName
           |> andMap genBirthday
           |> andMap genPhoneNumber
           |> andMap genAddress
           |> andMap genEmail
-}
andMap : Generator a -> Generator (a -> b) -> Generator b
andMap =
    map2 (|>)


{-| Chain random operations by providing a callback that accepts a
randomly-generated value. The random value can be used to drive more randomness.

This example shows how we can use `andThen` to generate a list of random values
*and* random length. Then we use `map` to apply a stateless function to that
list. Assume we already have `genName : Generator String` defined.

    authors : Generator String
    authors =
      int 1 5 -- number of authors
      |> andThen (\i -> list i genName)
      |> map (\ns ->
        case ns of
          [n] ->
            "Author: " ++ n
          n::ns ->
            "Authors: " ++ String.join ", " ns ++ " and " ++ n
          [] ->
            "This can't happen"
        )

If you find yourself calling `constant` in every branch of the callback, you can
probably use `map` instead.
-}
andThen : (a -> Generator b) -> Generator a -> Generator b
andThen callback (Generator generateA) =
    Generator <|
        \seed ->
            let
                ( result, newSeed ) =
                    generateA seed

                (Generator generateB) =
                    callback result
            in
                generateB newSeed


{-| Filter a generator so that all generated values satisfy the given predicate.

    evens : Generator Int
    evens =
      filter (\i -> i % 2 == 0) (int minInt maxInt)

**Warning:** If the predicate is unsatisfiable, the generator will not terminate, your
application will hang with an infinite loop, and you will be sad. You should
also avoid predicates that are merely very difficult to satisfy.

    badCrashingGenerator =
      filter (\_ -> False) anotherGenerator

    verySlowGenerator =
      filter (\i -> i % 2000 == 0) (int minInt maxInt)
-}
filter : (a -> Bool) -> Generator a -> Generator a
filter predicate generator =
    Generator (retry generator predicate)


retry : Generator a -> (a -> Bool) -> Seed -> ( a, Seed )
retry generator predicate seed =
    let
        ( candidate, newSeed ) =
            step generator seed
    in
        if predicate candidate then
            ( candidate, newSeed )
        else
            retry generator predicate newSeed


{-| Produce `True` one-in-n times on average.

Do not pass a value less then one to this function.

    flippedHeads = oneIn 2
    rolled6 = oneIn 6
    criticalHit = oneIn 20
-}
oneIn : Int -> Generator Bool
oneIn n =
    map ((==) 1) (int 1 n)


{-| Given a list, choose an element uniformly at random. `Nothing` is only
produced if the list is empty.

    type Direction = North | South | East | West

    direction : Generator Direction
    direction =
      sample [North, South, East, West]
        |> map (Maybe.withDefault North)

-}
sample : List a -> Generator (Maybe a)
sample =
    let
        find k ys =
            case ys of
                [] ->
                    Nothing

                z :: zs ->
                    if k == 0 then
                        Just z
                    else
                        find (k - 1) zs
    in
        \xs -> map (\i -> find i xs) (int 0 (List.length xs - 1))


{-| Choose between two values with equal probability.

    type Flip = Heads | Tails

    coinFlip : Generator Flip
    coinFlip =
      choice Heads Tails
-}
choice : a -> a -> Generator a
choice x y =
    map
        (\b ->
            if b then
                x
            else
                y
        )
        bool


{-| Create a generator that chooses a generator from a list of generators
with equal probability.

**Warning:** Do not pass an empty list or your program will crash! In practice
this is usually not a problem since you pass a list literal.
-}
choices : List (Generator a) -> Generator a
choices gens =
    frequency <| List.map (\g -> ( 1, g )) gens


{-| Create a generator that chooses a generator from a list of generators
based on the provided weight. The likelihood of a given generator being
chosen is its weight divided by the total weight (which doesn't have to equal 1).

**Warning:** Do not pass an empty list or your program will crash! In practice
this is usually not a problem since you pass a list literal.
-}
frequency : List ( Float, Generator a ) -> Generator a
frequency pairs =
    let
        total =
            List.sum <| List.map (Tuple.first >> abs) pairs

        pick choices n =
            case choices of
                ( k, g ) :: rest ->
                    if n <= k then
                        g
                    else
                        pick rest (n - k)

                _ ->
                    Debug.crash "Empty list passed to Random.Pcg.frequency!"
    in
        float 0 total |> andThen (pick pairs)


{-| Produce `Just` a value on `True`, and `Nothing` on `False`.

You can use `bool` or `oneIn n` for the first argument.
-}
maybe : Generator Bool -> Generator a -> Generator (Maybe a)
maybe genBool genA =
    genBool
        |> andThen
            (\b ->
                if b then
                    map Just genA
                else
                    constant Nothing
            )


{-| A generator that produces a seed that is independent of any other seed in
the program. These seeds will generate their own unique sequences of random
values. They are useful when you need an unknown amount of randomness *later*
but can request only a fixed amount of randomness *now*.

Let's say you write a component that uses some randomness to initialize itself
and then never needs randomness again. You can easily write a `Generator
Component` by mapping over the generators it needs. But if component requires
randomness after initialization, it should keep its own independent seed, which
it can get by mapping over *this* generator.

    type alias Component = { seed : Seed }

    genComponent : Generator Component
    genComponent = map Component independentSeed

If you have a lot of components, you can initialize them like so:

    genComponents : List (Seed -> a) -> Generator (List a)
    genComponents constructors =
        list (List.length constructors) independentSeed
            |> map (List.map2 (<|) constructors)

The independent seeds are extremely likely to be distinct for all practical
purposes. However, it is not proven that there are no pathological cases.
-}
independentSeed : Generator Seed
independentSeed =
    Generator <|
        \seed0 ->
            let
                gen =
                    int 0 0xFFFFFFFF

                ( ( state, b, c ), seed1 ) =
                    step (map3 (,,) gen gen gen) seed0

                {--
                Although it probably doesn't hold water theoretically, xor two
                random numbers to make an increment less likely to be
                pathological. Then make sure that it's odd, which is required.
                Finally step it once before use.
                --}
                incr =
                    (Bitwise.xor b c) |> Bitwise.or 1 |> Bitwise.shiftRightZfBy 0
            in
                ( seed1, next <| Seed state incr )


mul32 : Int -> Int -> Int
mul32 a b =
    -- multiply 32-bit integers without overflow
    let
        ah =
            (a |> Bitwise.shiftRightZfBy 16) |> Bitwise.and 0xFFFF

        al =
            Bitwise.and a 0xFFFF

        bh =
            (b |> Bitwise.shiftRightZfBy 16) |> Bitwise.and 0xFFFF

        bl =
            Bitwise.and b 0xFFFF
    in
        -- The Bitwise.or could probably be replaced with shiftRightZfBy but I'm not positive?
        (al * bl) + (((ah * bl + al * bh) |> Bitwise.shiftLeftBy 16) |> Bitwise.shiftRightZfBy 0) |> Bitwise.or 0


{-| Fast forward a seed the given number of steps, which may be negative (the
seed will be "rewound"). This allows a single seed to serve as a random-access
lookup table of random numbers. (To be sure no one else uses the seed, use
`step independentSeed` to split off your own.)

    diceRollTable : Int -> Int
    diceRollTable i =
      fastForward i mySeed |> step (int 1 6) |> Tuple.first
-}
fastForward : Int -> Seed -> Seed
fastForward delta0 (Seed state0 incr) =
    let
        helper : Int -> Int -> Int -> Int -> Int -> Bool -> ( Int, Int )
        helper accMult accPlus curMult curPlus delta repeat =
            let
                ( accMult_, accPlus_ ) =
                    if Bitwise.and delta 1 == 1 then
                        ( mul32 accMult curMult
                        , mul32 accPlus curMult + curPlus |> Bitwise.shiftRightZfBy 0
                        )
                    else
                        ( accMult, accPlus )

                curPlus_ =
                    mul32 (curMult + 1) curPlus

                curMult_ =
                    mul32 curMult curMult

                newDelta =
                    -- divide by 2
                    delta |> Bitwise.shiftRightZfBy 1
            in
                if newDelta == 0 then
                    if delta0 < 0 && repeat then
                        -- if passed a negative number, negate everything once
                        helper accMult_ accPlus_ curMult_ curPlus_ -1 False
                    else
                        ( accMult_, accPlus_ )
                else
                    helper accMult_ accPlus_ curMult_ curPlus_ newDelta repeat

        ( accMultFinal, accPlusFinal ) =
            -- magic constant same as in next
            helper 1 0 1664525 incr delta0 True
    in
        Seed (mul32 accMultFinal state0 + accPlusFinal |> Bitwise.shiftRightZfBy 0) incr


{-| Serialize a seed as a [JSON
value](http://package.elm-lang.org/packages/elm-lang/core/latest/Json-Encode#Value)
to be sent out a port, stored in local storage, and so on. The seed can be
recovered using `fromJson`.

Do not inspect or change the resulting JSON value.
-}
toJson : Seed -> Json.Encode.Value
toJson (Seed state incr) =
    Json.Encode.list [ Json.Encode.int state, Json.Encode.int incr ]


{-| A JSON decoder that can recover seeds encoded using `toJson`. Alternatively,
pass an integer to create a seed using `initialSeed`.

    Json.Decode.decodeValue fromJson (toJson mySeed) == Ok mySeed
-}
fromJson : Json.Decode.Decoder Seed
fromJson =
    Json.Decode.oneOf
        [ Json.Decode.map2 Seed
            (Json.Decode.index 0 Json.Decode.int)
            (Json.Decode.index 1 Json.Decode.int)
        , Json.Decode.map initialSeed Json.Decode.int
        ]
