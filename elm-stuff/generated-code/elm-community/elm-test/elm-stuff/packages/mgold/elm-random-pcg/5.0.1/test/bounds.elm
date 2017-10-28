module Bounds exposing (..)

{-| Demonstrate that, after creating ten million floats between 0 and 1, all
indeed fall inside that range. If you try this test with core (4.x) Random, it
will produce at least one value less than zero! This could have catastrophic
effects if you take the log or square root of this value, although more likely
it will just propogate NaN through your program.
-}

import Random.Pcg as Random
import Html
import Html.App


n =
    10000000


seed0 : Random.Seed
seed0 =
    Random.initialSeed 628318530


samples : List Float
samples =
    Random.step (Random.list n (Random.float 0 1)) seed0 |> fst


range : ( Maybe Float, Maybe Float )
range =
    ( List.minimum samples, List.maximum samples )


main : Program Never
main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text <| toString <| range
        }
