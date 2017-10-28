module Plot.Container exposing (Config, default)

import Svg exposing (Svg)
import Plot.Coordinate as Coordinate exposing (..)
import Plot.Attributes as Attributes


type alias Config msg =
  { frame : Coordinate.Frame
  , attributes : List (Attributes.Attribute msg)
  , defs : List (Svg msg)
  }


default : Config msg
default =
  { frame = Frame (Margin 40 40 90 90) (Size 500 400)
  , attributes = []
  , defs = []
  }
