module LineChart.Axis.Line exposing
  ( Config, none, default
  , full, rangeFrame
  , Properties, custom
  )

{-|

# Quick start
@docs Config, default, none, full, rangeFrame

# Customiztion
@docs Properties, custom

-}

import Svg exposing (Attribute)
import LineChart.Coordinate as Coordinate
import Internal.Axis.Line as Line
import Color



{-| -}
type alias Config msg =
  Line.Config msg


{-| Draws the axis line to fit the range of your data.
-}
default : Config msg
default =
  Line.default


{-| Removes the axis line entirely.
-}
none : Config msg
none =
  Line.none


{-| Draws the axis line as the full length of your dimension.
-}
full : Config msg
full =
  Line.full


{-| Draws the axis line to fit the range of your data.
-}
rangeFrame : Config msg
rangeFrame =
  Line.rangeFrame



-- CUSTOM


{-| -}
type alias Properties msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| Given the range of your data and your dimension range, define your own
axis line configuration.
-}
custom : (Coordinate.Range -> Coordinate.Range -> Properties msg) -> Config msg
custom =
  Line.custom
