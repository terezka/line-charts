module Lines.Axis.Line exposing
  ( Line, none, default
  , full, rangeFrame
  , Config, custom
  )

{-|

# Quick start
@docs Line, none, default

# Alternatives
@docs full, rangeFrame

# Customizing
@docs Config, custom

-}

import Svg exposing (Attribute)
import Lines.Color as Color
import Internal.Coordinate as Coordinate
import Internal.Axis.Line as Line


{-| -}
type alias Line msg =
  Line.Line msg


{-| -}
none : Line msg
none =
  Line.none


{-| -}
default : Line msg
default =
  Line.default


{-| -}
full : Line msg
full =
  Line.full


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
