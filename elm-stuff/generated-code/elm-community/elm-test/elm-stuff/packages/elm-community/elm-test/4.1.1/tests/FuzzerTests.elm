module FuzzerTests exposing (fuzzerTests)

import Expect
import Fuzz exposing (..)
import Helpers exposing (..)
import Lazy.List
import Random.Pcg as Random
import RoseTree
import Test exposing (..)
import Test.Runner


die : Fuzzer Int
die =
    Fuzz.intRange 1 6


seed : Fuzzer Random.Seed
seed =
    Fuzz.custom
        (Random.int Random.minInt Random.maxInt |> Random.map Random.initialSeed)
        (always Lazy.List.empty)


fuzzerTests : Test
fuzzerTests =
    describe "Fuzzer methods that use Debug.crash don't call it"
        [ describe "FuzzN (uses tupleN) testing string length properties"
            [ fuzz2 string string "fuzz2" <|
                \a b ->
                    testStringLengthIsPreserved [ a, b ]
            , fuzz3 string string string "fuzz3" <|
                \a b c ->
                    testStringLengthIsPreserved [ a, b, c ]
            , fuzz4 string string string string "fuzz4" <|
                \a b c d ->
                    testStringLengthIsPreserved [ a, b, c, d ]
            , fuzz5 string string string string string "fuzz5" <|
                \a b c d e ->
                    testStringLengthIsPreserved [ a, b, c, d, e ]
            ]
        , fuzz
            (intRange 1 6)
            "intRange"
            (Expect.greaterThan 0)
        , fuzz
            (frequency [ ( 1, intRange 1 6 ), ( 1, intRange 1 20 ) ])
            "Fuzz.frequency"
            (Expect.greaterThan 0)
        , fuzz (result string int) "Fuzz.result" <| \r -> Expect.pass
        , fuzz (andThen (\i -> intRange 0 (2 ^ i)) (intRange 1 8))
            "Fuzz.andThen"
            (Expect.atMost 256)
        , fuzz
            (map2 (,) die die
                |> conditional
                    { retries = 10
                    , fallback = \( a, b ) -> ( a, (b + 1) % 6 )
                    , condition = \( a, b ) -> a /= b
                    }
            )
            "conditional: reroll dice until they are not equal"
          <|
            \( roll1, roll2 ) ->
                roll1 |> Expect.notEqual roll2
        , fuzz seed "conditional: shrunken values all pass condition" <|
            \seed ->
                let
                    evenInt : Fuzzer Int
                    evenInt =
                        Fuzz.intRange 0 10
                            |> Fuzz.conditional
                                { retries = 3
                                , fallback = (+) 1
                                , condition = even
                                }

                    even : Int -> Bool
                    even n =
                        (n % 2) == 0

                    shrinkable : Test.Runner.Shrinkable Int
                    shrinkable =
                        Test.Runner.fuzz evenInt
                            |> flip Random.step seed
                            |> Tuple.first
                            |> Tuple.second

                    testShrinkable : Test.Runner.Shrinkable Int -> Expect.Expectation
                    testShrinkable shrinkable =
                        case Test.Runner.shrink False shrinkable of
                            Nothing ->
                                Expect.pass

                            Just ( value, next ) ->
                                if even value then
                                    testShrinkable next
                                else
                                    Expect.fail <| "Shrunken value does not pass conditional: " ++ toString value
                in
                testShrinkable shrinkable
        , describe "Whitebox testing using Fuzz.Internal"
            [ fuzz randomSeedFuzzer "the same value is generated with and without shrinking" <|
                \seed ->
                    let
                        step gen =
                            Random.step gen seed

                        aFuzzer =
                            tuple5
                                ( tuple ( list int, array float )
                                , maybe bool
                                , result unit char
                                , tuple3
                                    ( percentage
                                    , map2 (+) int int
                                    , frequency [ ( 1, constant True ), ( 3, constant False ) ]
                                    )
                                , tuple3 ( intRange 0 100, floatRange -51 pi, map abs int )
                                )

                        valNoShrink =
                            aFuzzer |> Result.map (Random.map RoseTree.root >> step >> Tuple.first)

                        valWithShrink =
                            aFuzzer |> Result.map (step >> Tuple.first >> RoseTree.root)
                    in
                    Expect.equal valNoShrink valWithShrink
            , shrinkingTests
            , manualFuzzerTests
            ]
        ]


shrinkingTests : Test
shrinkingTests =
    testShrinking <|
        describe "tests that fail intentionally to test shrinking"
            [ fuzz2 int int "Every pair of ints has a zero" <|
                \i j ->
                    (i == 0)
                        || (j == 0)
                        |> Expect.true "(1,1)"
            , fuzz3 int int int "Every triple of ints has a zero" <|
                \i j k ->
                    (i == 0)
                        || (j == 0)
                        || (k == 0)
                        |> Expect.true "(1,1,1)"
            , fuzz4 int int int int "Every 4-tuple of ints has a zero" <|
                \i j k l ->
                    (i == 0)
                        || (j == 0)
                        || (k == 0)
                        || (l == 0)
                        |> Expect.true "(1,1,1,1)"
            , fuzz5 int int int int int "Every 5-tuple of ints has a zero" <|
                \i j k l m ->
                    (i == 0)
                        || (j == 0)
                        || (k == 0)
                        || (l == 0)
                        || (m == 0)
                        |> Expect.true "(1,1,1,1,1)"
            , fuzz (list int) "All lists are sorted" <|
                \aList ->
                    let
                        checkPair l =
                            case l of
                                a :: b :: more ->
                                    if a > b then
                                        False
                                    else
                                        checkPair (b :: more)

                                _ ->
                                    True
                    in
                    checkPair aList |> Expect.true "[1,0]|[0,-1]"
            , fuzz (intRange 1 8 |> andThen (\i -> intRange 0 (2 ^ i))) "Fuzz.andThen shrinks a number" <|
                \i ->
                    i <= 2 |> Expect.true "3"
            ]


manualFuzzerTests : Test
manualFuzzerTests =
    describe "Test.Runner.{fuzz, shrink}"
        [ fuzz randomSeedFuzzer "Claim there are no even numbers" <|
            \seed ->
                let
                    -- fuzzer is guaranteed to produce an even number
                    fuzzer =
                        Fuzz.intRange 2 10000
                            |> Fuzz.map
                                (\n ->
                                    if failsTest n then
                                        n
                                    else
                                        n + 1
                                )

                    failsTest n =
                        n % 2 == 0

                    pair =
                        Random.step (Test.Runner.fuzz fuzzer) seed
                            |> Tuple.first
                            |> Just

                    unfold acc maybePair =
                        case maybePair of
                            Just ( valN, shrinkN ) ->
                                if failsTest valN then
                                    unfold (valN :: acc) (Test.Runner.shrink False shrinkN)
                                else
                                    unfold acc (Test.Runner.shrink True shrinkN)

                            Nothing ->
                                acc
                in
                unfold [] pair
                    |> Expect.all
                        [ List.all failsTest >> Expect.true "Not all elements were even"
                        , List.head
                            >> Maybe.map (Expect.all [ Expect.lessThan 5, Expect.atLeast 0 ])
                            >> Maybe.withDefault (Expect.fail "Did not cause failure")
                        , List.reverse >> List.head >> Expect.equal (Maybe.map Tuple.first pair)
                        ]
        , fuzz randomSeedFuzzer "No strings contain the letter e" <|
            \seed ->
                let
                    -- fuzzer is guaranteed to produce a string with the letter e
                    fuzzer =
                        map2 (\pre suf -> pre ++ "e" ++ suf) string string

                    failsTest =
                        String.contains "e"

                    pair =
                        Random.step (Test.Runner.fuzz fuzzer) seed
                            |> Tuple.first
                            |> Just

                    unfold acc maybePair =
                        case maybePair of
                            Just ( valN, shrinkN ) ->
                                if failsTest valN then
                                    unfold (valN :: acc) (Test.Runner.shrink False shrinkN)
                                else
                                    unfold acc (Test.Runner.shrink True shrinkN)

                            Nothing ->
                                acc
                in
                unfold [] pair
                    |> Expect.all
                        [ List.all failsTest >> Expect.true "Not all contained the letter e"
                        , List.head >> Expect.equal (Just "e")
                        , List.reverse >> List.head >> Expect.equal (Maybe.map Tuple.first pair)
                        ]
        ]
