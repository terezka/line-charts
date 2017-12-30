module Lines.Axis.Line exposing (Line, default, fat, rangeFrame, Config, custom)

{-|

@docs Line, default, fat, Config, custom, rangeFrame

-}

import Svg exposing (Attribute)
import Lines.Color as Color
import Internal.Coordinate as Coordinate
import Internal.Axis.Line as Line


{-| -}
type alias Line msg =
  Line.Line msg


{-| -}
default : Line msg
default =
  Line.default


{-| -}
fat : Line msg
fat =
  Line.fat


{-| -}
rangeFrame : Line msg
rangeFrame =
  Line.rangeFrame


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
  Line.custom
