module Lines.Axis.Title exposing (Title, default, at, custom)

{-|

@docs Title, default, at, custom

-}

import Svg exposing (Svg)
import Internal.Axis.Title as Title
import Lines.Coordinate as Coordinate


{-| -}
type alias Title msg =
  Title.Title msg


{-| -}
default : String -> Title msg
default =
  Title.default


{-| -}
at : String -> (Coordinate.Range -> Float) -> (Float, Float) -> Title msg
at =
  Title.at


{-| -}
custom : Svg msg -> (Coordinate.Range -> Float) -> (Float, Float) -> Title msg
custom =
  Title.custom
