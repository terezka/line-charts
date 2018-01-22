module Internal.Axis.Line exposing (Line, none, default, full, rangeFrame, Config, custom, config)


import Svg exposing (Attribute)
import LineChart.Colors as Colors
import Internal.Coordinate as Coordinate
import Color


{-| -}
type Line msg =
  Line (Coordinate.Range -> Coordinate.Range -> Config msg)


{-| -}
none : Line msg
none =
  Line <| \_ {min, max} ->
    { color = Colors.transparent
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
  Line <| \data range ->
    let largest = Coordinate.largestRange data range in
    { color = Colors.gray
    , width = 1
    , events = []
    , start = largest.min
    , end = largest.max
    }


{-| -}
rangeFrame : Line msg
rangeFrame =
  Line <| \data range ->
    let smallest = (Coordinate.smallestRange data range) in
    { color = Colors.gray
    , width = 1
    , events = []
    , start = smallest.min
    , end = smallest.max
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
