module IndependentSeedTest exposing (..)

import Html exposing (Html)
import Random.Pcg as Random exposing (Generator)
import Debug


{-| This test ensures that the 'independentSeed' generator actually produces
valid random seeds that can be stepped properly to produce distinct values. If
there is an error in 'independentSeed', at some point a seed such as 'Seed 0
0' will be produced which when stepped will yield itself, resulting in an
infinite loop within 'filter' (since it will internally just keep generating
the same value over and over again).
-}
main : Html Never
main =
    let
        initialSeed =
            Random.initialSeed 1234

        seedListGenerator =
            Random.list 1000 Random.independentSeed

        randomSeeds =
            fst (Random.step seedListGenerator initialSeed)

        isDivisible i =
            let
                _ =
                    Debug.log "i" i
            in
                i /= 0 && i % 10 == 0

        divisibleNumberGenerator =
            Random.filter isDivisible (Random.int Random.minInt Random.maxInt)

        divisibleNumbers =
            List.map (Random.step divisibleNumberGenerator >> fst) randomSeeds
    in
        Html.text (toString (List.sum divisibleNumbers))
