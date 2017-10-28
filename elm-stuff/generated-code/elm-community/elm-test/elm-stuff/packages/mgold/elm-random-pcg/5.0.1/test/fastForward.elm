module FastForwardTest exposing (..)

{-| Compares the outputs of seeds created using the ordinary sequential stepping method,
and those created using the `fastForward` function. Note that we compare output, not the
seeds themselves, because somestimes the states get confused between signed and unsigned--
this has no effect on the psuedo-random output. (Edit July 2016: not sure if that's true
anymore...)
-}

import Random.Pcg as Random
import Html
import Html.App


n =
    100000


seed0 : Random.Seed
seed0 =
    Random.initialSeed 628318530


stepped : List Random.Seed
stepped =
    List.scanl
        (\_ oldSeed -> Random.step Random.bool oldSeed |> snd)
        seed0
        [1..n]


fastForwarded : List Random.Seed
fastForwarded =
    List.map
        (\i -> Random.fastForward i seed0)
        [0..n]


gen =
    Random.int 1 10000


generate seed =
    Random.step gen seed |> fst


bools =
    List.map2
        (\seed1 seed2 -> generate seed1 == generate seed2)
        stepped
        fastForwarded
        |> List.all identity


main : Program Never
main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text <| toString <| bools
        }
