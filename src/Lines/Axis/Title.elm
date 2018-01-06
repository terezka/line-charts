module Lines.Axis.Title exposing (Title, default, at, custom)

{-|

# Quick start
@docs default

# Definition
@docs Title, at, custom

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
at : (Coordinate.Range -> Float) -> Float -> Float -> String -> Title msg
at =
  Title.at


{-| -}
custom : (Coordinate.Range -> Float) -> Float -> Float -> Svg msg -> Title msg
custom =
  Title.custom
