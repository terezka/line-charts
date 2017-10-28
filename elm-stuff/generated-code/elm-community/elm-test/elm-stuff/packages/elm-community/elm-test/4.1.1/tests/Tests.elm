module Tests exposing (all)

import Dict
import Expect
import Fuzz exposing (..)
import FuzzerTests exposing (fuzzerTests)
import Helpers exposing (..)
import Random.Pcg as Random
import RunnerTests
import Set
import Shrink
import Test exposing (..)
import Test.Expectation exposing (Expectation(..))
import Test.Runner


all : Test
all =
    Test.concat
        [ readmeExample
        , regressions
        , testTests
        , expectationTests
        , fuzzerTests
        , RunnerTests.all
        ]


readmeExample : Test
readmeExample =
    describe "The String module"
        [ describe "String.reverse"
            [ test "has no effect on a palindrome" <|
                \_ ->
                    let
                        palindrome =
                            "hannah"
                    in
                    Expect.equal palindrome (String.reverse palindrome)
            , test "reverses a known string" <|
                \_ ->
                    "ABCDEFG"
                        |> String.reverse
                        |> Expect.equal "GFEDCBA"
            , fuzz string "restores the original string if you run it again" <|
                \randomlyGeneratedString ->
                    randomlyGeneratedString
                        |> String.reverse
                        |> String.reverse
                        |> Expect.equal randomlyGeneratedString
            ]
        ]


expectationTests : Test
expectationTests =
    describe "Expectations"
        [ describe "Expect.err"
            [ test "passes on Err _" <|
                \_ ->
                    Err 12 |> Expect.err
            , expectToFail <|
                test "passes on Ok _" <|
                    \_ ->
                        Ok 12 |> Expect.err
            ]
        , describe "Expect.all"
            [ expectToFail <|
                test "fails with empty list" <|
                    \_ -> "dummy subject" |> Expect.all []
            ]
        ]


regressions : Test
regressions =
    describe "regression tests"
        [ fuzz (intRange 1 32) "for #39" <|
            \positiveInt ->
                positiveInt
                    |> Expect.greaterThan 0
        , fuzz
            (custom (Random.int 1 8) Shrink.noShrink)
            "fuzz tests run 100 times"
            (Expect.notEqual 5)
            |> expectToFail

        {- If fuzz tests actually run 100 times, then asserting that no number
           in 1..8 equals 5 fails with 0.999998 probability. If they only run
           once, or stop after a duplicate due to #127, then it's much more
           likely (but not guaranteed) that the 5 won't turn up. See #128.
        -}
        ]


testTests : Test
testTests =
    describe "functions that create tests"
        [ describe "describe"
            [ expectToFail <| describe "fails with empty list" []
            , expectToFail <| describe "" [ test "describe with empty description fail" expectPass ]
            ]
        , describe "test"
            [ expectToFail <| test "" expectPass
            ]
        , describe "fuzz"
            [ expectToFail <| fuzz Fuzz.bool "" expectPass
            ]
        , describe "fuzzWith"
            [ expectToFail <| fuzzWith { runs = 0 } Fuzz.bool "nonpositive" expectPass
            , expectToFail <| fuzzWith { runs = 1 } Fuzz.bool "" expectPass
            ]
        , describe "Test.todo"
            [ expectToFail <| todo "a TODO test fails"
            , test "Passes are not TODO"
                (\_ -> Expect.pass |> Test.Runner.isTodo |> Expect.false "was true")
            , test "Simple failures are not TODO" <|
                \_ ->
                    Expect.fail "reason" |> Test.Runner.isTodo |> Expect.false "was true"
            , test "Failures with TODO reason are TODO" <|
                \_ ->
                    Test.Expectation.fail { description = "", reason = Test.Expectation.TODO }
                        |> Test.Runner.isTodo
                        |> Expect.true "was false"
            ]
        , identicalNamesAreRejectedTests
        ]


identicalNamesAreRejectedTests : Test
identicalNamesAreRejectedTests =
    describe "Identically-named sibling and parent/child tests fail"
        [ expectToFail <|
            describe "a describe with two identically named children fails"
                [ test "foo" expectPass
                , test "foo" expectPass
                ]
        , expectToFail <|
            describe "a describe with the same name as a child test fails"
                [ test "a describe with the same name as a child test fails" expectPass
                ]
        , expectToFail <|
            describe "a describe with the same name as a child describe fails"
                [ describe "a describe with the same name as a child describe fails"
                    [ test "a test" expectPass ]
                ]
        , expectToFail <|
            Test.concat
                [ describe "a describe with the same name as a sibling describe fails"
                    [ test "a test" expectPass ]
                , describe "a describe with the same name as a sibling describe fails"
                    [ test "another test" expectPass ]
                ]
        , expectToFail <|
            Test.concat
                [ Test.concat
                    [ describe "a describe with the same name as a de facto sibling describe fails"
                        [ test "a test" expectPass ]
                    ]
                , describe "a describe with the same name as a de facto sibling describe fails"
                    [ test "another test" expectPass ]
                ]
        , expectToFail <|
            Test.concat
                [ Test.concat
                    [ describe "a describe with the same name as a de facto sibling describe fails"
                        [ test "a test" expectPass ]
                    ]
                , Test.concat
                    [ describe "a describe with the same name as a de facto sibling describe fails"
                        [ test "another test" expectPass ]
                    ]
                ]
        ]
