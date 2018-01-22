module Internal.Junk exposing (..)

{-| -}

import Svg exposing (Svg)
import Html exposing (Html)
import LineChart.Coordinate as Coordinate



{-| -}
type Config msg =
  Config (Coordinate.System -> Layers msg)


{-| -}
none : Config msg
none =
  Config (\_ -> Layers [] [] [])


{-| -}
type alias Layers msg =
  { below : List (Svg msg)
  , above : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
getLayers : Coordinate.System -> Config msg -> Layers msg
getLayers system (Config toLayers) =
  toLayers system


{-| -}
addBelow : List (Svg msg) -> Layers msg -> Layers msg
addBelow below layers =
  { layers | below = below ++ layers.below }
