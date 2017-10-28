module FilterTest exposing (..)

import Html exposing (Html)
import Random.Pcg as Random


{-| This test checks that very difficult-to-satisfy filters do not result in a stack
overflow (just run slowly). The test will take several seconds to run!
-}
main : Html Never
main =
    let
        -- Try 'predicate i = False' to verify that the test hangs instead of
        -- crashing with a stack overflow (indicating that tail recursion has
        -- been properly optimized into a loop, which in this case happens to
        -- be infinite).
        predicate i =
            i % 1000000 == 0

        divisibleNumberGenerator =
            Random.filter predicate (Random.int Random.minInt Random.maxInt)

        listGenerator =
            Random.list 10 divisibleNumberGenerator

        initialSeed =
            Random.initialSeed 1234

        generatedList =
            fst (Random.step listGenerator initialSeed)
    in
        -- You can verify that everything is working by observing that the generated
        -- sum is in fact divisible by the chosen divisor (e.g. for a divisor of
        -- 1000000 the sum should always have six trailing zeros)
        Html.text (toString (List.sum generatedList))
