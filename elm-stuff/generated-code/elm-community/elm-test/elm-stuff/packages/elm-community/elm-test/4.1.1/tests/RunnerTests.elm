module RunnerTests exposing (all)

import Expect
import Fuzz exposing (..)
import Helpers exposing (expectPass)
import Random.Pcg as Random
import Test exposing (..)
import Test.Runner exposing (SeededRunners(..))


all : Test
all =
    Test.concat
        [ fromTest ]


toSeededRunners : Test -> SeededRunners
toSeededRunners =
    Test.Runner.fromTest 5 (Random.initialSeed 42)


fromTest : Test
fromTest =
    describe "TestRunner.fromTest"
        [ describe "test length"
            [ fuzz2 int int "only positive tests runs are valid" <|
                \runs intSeed ->
                    case Test.Runner.fromTest runs (Random.initialSeed intSeed) passing of
                        Invalid str ->
                            if runs > 0 then
                                Expect.fail ("Expected a run count of " ++ toString runs ++ " to be valid, but was invalid with this message: " ++ toString str)
                            else
                                Expect.pass

                        val ->
                            if runs > 0 then
                                Expect.pass
                            else
                                Expect.fail ("Expected a run count of " ++ toString runs ++ " to be invalid, but was valid with this value: " ++ toString val)
            , test "an only inside another only has no effect" <|
                \_ ->
                    let
                        runners =
                            toSeededRunners <|
                                describe "three tests"
                                    [ test "passes" expectPass
                                    , Test.only <|
                                        describe "two tests"
                                            [ test "fails" <|
                                                \_ -> Expect.fail "failed on purpose"
                                            , Test.only <|
                                                test "is an only" <|
                                                    \_ -> Expect.fail "failed on purpose"
                                            ]
                                    ]
                    in
                    case runners of
                        Only runners ->
                            runners
                                |> List.length
                                |> Expect.equal 2

                        val ->
                            Expect.fail ("Expected SeededRunner to be Only, but was " ++ toString val)
            , test "a skip inside an only takes effect" <|
                \_ ->
                    let
                        runners =
                            toSeededRunners <|
                                describe "three tests"
                                    [ test "passes" expectPass
                                    , Test.only <|
                                        describe "two tests"
                                            [ test "fails" <|
                                                \_ -> Expect.fail "failed on purpose"
                                            , Test.skip <|
                                                test "is skipped" <|
                                                    \_ -> Expect.fail "failed on purpose"
                                            ]
                                    ]
                    in
                    case runners of
                        Only runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Only, but was " ++ toString val)
            , test "an only inside a skip has no effect" <|
                \_ ->
                    let
                        runners =
                            toSeededRunners <|
                                describe "three tests"
                                    [ test "passes" expectPass
                                    , Test.skip <|
                                        describe "two tests"
                                            [ test "fails" <|
                                                \_ -> Expect.fail "failed on purpose"
                                            , Test.only <|
                                                test "is skipped" <|
                                                    \_ -> Expect.fail "failed on purpose"
                                            ]
                                    ]
                    in
                    case runners of
                        Skipping runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Skipping, but was " ++ toString val)
            , test "a test that uses only is an Only summary" <|
                \_ ->
                    case toSeededRunners (Test.only <| test "passes" expectPass) of
                        Only runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Only, but was " ++ toString val)
            , test "a skip inside another skip has no effect" <|
                \_ ->
                    let
                        runners =
                            toSeededRunners <|
                                describe "three tests"
                                    [ test "passes" expectPass
                                    , Test.skip <|
                                        describe "two tests"
                                            [ test "fails" <|
                                                \_ -> Expect.fail "failed on purpose"
                                            , Test.skip <|
                                                test "is skipped" <|
                                                    \_ -> Expect.fail "failed on purpose"
                                            ]
                                    ]
                    in
                    case runners of
                        Skipping runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Skipping, but was " ++ toString val)
            , test "a pair of tests where one uses skip is a Skipping summary" <|
                \_ ->
                    let
                        runners =
                            toSeededRunners <|
                                describe "two tests"
                                    [ test "passes" expectPass
                                    , Test.skip <|
                                        test "fails" <|
                                            \_ -> Expect.fail "failed on purpose"
                                    ]
                    in
                    case runners of
                        Skipping runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Skipping, but was " ++ toString val)
            , test "when all tests are skipped, we get an empty Skipping summary" <|
                \_ ->
                    case toSeededRunners (Test.skip <| test "passes" expectPass) of
                        Skipping runners ->
                            runners
                                |> List.length
                                |> Expect.equal 0

                        val ->
                            Expect.fail ("Expected SeededRunner to be Skipping, but was " ++ toString val)
            , test "a test that does not use only or skip is a Plain summary" <|
                \_ ->
                    case toSeededRunners (test "passes" expectPass) of
                        Plain runners ->
                            runners
                                |> List.length
                                |> Expect.equal 1

                        val ->
                            Expect.fail ("Expected SeededRunner to be Plain, but was " ++ toString val)
            ]
        ]


passing : Test
passing =
    test "A passing test" expectPass
