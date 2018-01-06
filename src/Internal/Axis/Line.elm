module Internal.Axis.Line exposing (Line, none, default, full, rangeFrame, Config, custom, config)


import Svg exposing (Attribute)
import Lines.Color as Color
import Internal.Coordinate as Coordinate


{-| -}
type Line msg =
  Line (Coordinate.Range -> Coordinate.Range -> Config msg)


{-| -}
none : Line msg
none =
  Line <| \_ {min, max} ->
    { color = "transparent"
    , width = 0
    , events = []
    , start = min
    , end = max
    }


{-| -}
default : Line msg
default =
  rangeFrame


{-| -}
full : Line msg
full =
  Line <| \_ {min, max} ->
    { color = Color.gray
    , width = 1
    , events = []
    , start = min
    , end = max
    }


{-| -}
rangeFrame : Line msg
rangeFrame =
  Line <| \{min, max} _ ->
    { color = Color.gray
    , width = 1
    , events = []
    , start = min
    , end = max
    }



-- CUSTOM


{-| -}
type alias Config msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> Config msg) -> Line msg
custom =
  Line



-- INTERNAL


{-| -}
config : Line msg -> Coordinate.Range -> Coordinate.Range -> Config msg
config (Line config) =
  config
