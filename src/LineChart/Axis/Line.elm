module LineChart.Axis.Line exposing
  ( Config, default, full, rangeFrame, none
  , Properties, custom
  )

{-|

If your in doubt about the terminology of data range and axis range, please
see the `Axis.Range` module.

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
-}
type alias Config msg =
  Line.Config msg


{-| Draws the full length of your axis range.
-}
default : Config msg
default =
  Line.default


{-| Same as the default, except you get to pick the color.
-}
full : Color.Color -> Config msg
full =
  Line.full


{-| Draws the full length of your data range in your given color.
-}
rangeFrame : Color.Color -> Config msg
rangeFrame =
  Line.rangeFrame


{-| Removes the axis line entirely.
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


{-| Given your data range and axis range respectivily, define your own
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
-}
custom : (Coordinate.Range -> Coordinate.Range -> Properties msg) -> Config msg
custom =
  Line.custom
