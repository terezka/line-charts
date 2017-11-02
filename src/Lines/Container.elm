module Lines.Container exposing (Config, default)

import Svg exposing (Svg)
import Svg.Attributes exposing (style)
import Lines.Coordinate as Coordinate exposing (..)


type alias Config msg =
  { frame : Coordinate.Frame
  , attributes : List (Svg.Attribute msg)
  , defs : List (Svg msg)
  }


default : Config msg
default =
  { frame = Frame (Margin 40 150 90 150) (Size 650 400)
  , attributes = [ style "font-family: monospace;" ] -- TODO: Maybe remove
  , defs = []
  }
