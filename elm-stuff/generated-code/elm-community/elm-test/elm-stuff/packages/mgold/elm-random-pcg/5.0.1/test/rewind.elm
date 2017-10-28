module RewindTest exposing (..)

{-| Demonstrates that `fastForward` may also be used to rewind. We create a seed, fastForward it, then rewind it to get
back the original seed.
-}

import Random.Pcg as Random
import Html
import Html.App


n =
    31


seed0 =
    Random.initialSeed 628318


seed1 =
    Random.fastForward n seed0


seed2 =
    Random.fastForward -n seed1


main : Program Never
main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text <| toString [ seed0, seed1, seed2 ]
        }
