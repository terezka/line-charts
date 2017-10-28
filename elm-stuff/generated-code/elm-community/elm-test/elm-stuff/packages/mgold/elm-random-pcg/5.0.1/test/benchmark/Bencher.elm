module Main exposing (main)

import Html
import Html.App
import Bench.Native as Benchmark
import Bench.Native exposing (Benchmark, BenchmarkSuite, bench, suite)
import Random.Pcg as Ran


main : Program Never
main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text "Done!"
        }
        |> Benchmark.run [ mySuite ]


seed : Ran.Seed
seed =
    Ran.initialSeed 141053960


n =
    1000


mySuite : BenchmarkSuite
mySuite =
    suite
        "Random number suite"
        [ bench "flip a coin" (\_ -> Ran.step Ran.bool seed)
        , bench ("flip " ++ toString n ++ " coins") (\_ -> Ran.step (Ran.list n Ran.bool) seed)
        , bench "generate an integer 0-4094" (\_ -> Ran.step (Ran.int 0 4094) seed)
        , bench "generate an integer 0-4095" (\_ -> Ran.step (Ran.int 0 4095) seed)
        , bench "generate an integer 0-4096" (\_ -> Ran.step (Ran.int 0 4096) seed)
        , bench "generate a massive integer" (\_ -> Ran.step (Ran.int 0 4294967295) seed)
        , bench "generate a percentage" (\_ -> Ran.step (Ran.float 0 1) seed)
        , bench ("generate " ++ toString n ++ " percentages") (\_ -> Ran.step (Ran.list n (Ran.float 0 1)) seed)
        , bench "generate a float 0-4094" (\_ -> Ran.step (Ran.float 0 4094) seed)
        , bench "generate a float 0-4095" (\_ -> Ran.step (Ran.float 0 4095) seed)
        , bench "generate a float 0-4096" (\_ -> Ran.step (Ran.float 0 4096) seed)
        , bench "generate a massive float" (\_ -> Ran.step (Ran.float 0 4294967295) seed)
        ]
