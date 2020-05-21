module LineChart.Axis.Line exposing
  ( Config, default, full, rangeFrame, none
  , Properties, custom
  )

{-|

_If you're confused as to what "axis range" and "data range" means,
check out `Axis.Range` for an explanation!_

@docs Config, default, full, rangeFrame, none, custom, Properties

-}

import Svg exposing (Attribute)
import LineChart.Coordinate as Coordinate
import Internal.Axis.Line as Line
import Color



{-| This configuration is part of the
configuration in `Axis.custom`.

    axisConfig : Axis.Config Data msg
    axisConfig =
      Axis.custom
        { ..
        , range = AxisLine.default
        , ...
        }

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._

-}
type alias Config msg =
  Line.Config msg


{-| Draws the full length of your axis range.

    axisLineConfig : AxisLine.Config msg
    axisLineConfig =
      AxisLine.default

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._

-}
default : Config msg
default =
  Line.default


{-| Same as the default, except you get to pick the color.

    axisLineConfig : AxisLine.Config msg
    axisLineConfig =
      AxisLine.full Color.red

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._

-}
full : Color.Color -> Config msg
full =
  Line.full


{-| Draws the full length of your data range in your given color.

    axisLineConfig : AxisLine.Config msg
    axisLineConfig =
      AxisLine.rangeFrame Color.red

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._

-}
rangeFrame : Color.Color -> Config msg
rangeFrame =
  Line.rangeFrame


{-| Removes the axis line entirely.

    axisLineConfig : AxisLine.Config msg
    axisLineConfig =
      AxisLine.none

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._

-}
none : Config msg
none =
  Line.none



-- CUSTOM


{-| -}
type alias Properties msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| Given your data range and axis range respectively, define your own
axis line configuration.

    axisLineConfig : AxisLine.Config msg
    axisLineConfig =
      AxisLine.custom <| \dataRange axisRange ->
        { color = Colors.gray
        , width = 2
        , events = []
        , start = dataRange.min
        , end = 5
        }

_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/AxisLine/Example1.elm)._


-}
custom : (Coordinate.Range -> Coordinate.Range -> Properties msg) -> Config msg
custom =
  Line.custom
