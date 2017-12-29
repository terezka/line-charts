module Lines.Axis.Line exposing (Line, default, fat, Config, custom)

{-|

@docs Line, default, fat, Config, custom

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
custom : (Coordinate.Range -> Config msg) -> Line msg
custom =
  Line.custom
