module Lines.Container exposing (Config, default)

import Svg exposing (Svg)
import Svg.Attributes exposing (style)
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Attributes as Attributes


type alias Config msg =
  { frame : Coordinate.Frame
  , attributes : List (Attributes.Attribute msg)
  , defs : List (Svg msg)
  }


default : Config msg
default =
  { frame = Frame (Margin 40 40 90 90) (Size 500 400)
  , attributes = [ Attributes.custom <| style "font-family: monospace;" ] -- TODO: Maybe remove
  , defs = []
  }
