module Internal.Axis.Line exposing (Config, none, default, full, rangeFrame, Properties, custom, config)


import Svg exposing (Attribute)
import LineChart.Colors as Colors
import Internal.Coordinate as Coordinate
import Color



{-| -}
type Config msg =
  Config (Coordinate.Range -> Coordinate.Range -> Properties msg)


{-| -}
default : Config msg
default =
  rangeFrame


{-| -}
none : Config msg
none =
  custom <| \_ {min, max} ->
    { color = Colors.transparent
    , width = 0
    , events = []
    , start = min
    , end = max
    }


{-| -}
full : Config msg
full =
  custom <| \data range ->
    let largest = Coordinate.largestRange data range in
    { color = Colors.gray
    , width = 1
    , events = []
    , start = largest.min
    , end = largest.max
    }


{-| -}
rangeFrame : Config msg
rangeFrame =
  custom <| \data range ->
    let smallest = (Coordinate.smallestRange data range) in
    { color = Colors.gray
    , width = 1
    , events = []
    , start = smallest.min
    , end = smallest.max
    }



-- CUSTOM


{-| -}
type alias Properties msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> Properties msg) -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
config : Config msg -> Coordinate.Range -> Coordinate.Range -> Properties msg
config (Config config) =
  config
