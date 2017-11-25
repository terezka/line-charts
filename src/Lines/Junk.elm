module Lines.Junk exposing
  ( Junk, Layers, none, custom
  , Transfrom, transform, move, offset
  )


{-|

# Junk

## Quick start
@docs Junk, none

## Custom
@docs custom

## Placing help
@docs Transfrom, transform, move, offset

-}

import Svg exposing (Svg, Attribute, g)
import Html exposing (Html)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Junk
import Internal.Svg as Svg


{-| -}
type alias Junk msg =
  Internal.Junk.Junk msg


{-| -}
type alias Layers msg =
  { above : List (Svg msg)
  , below : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
none : Junk msg
none =
  Internal.Junk.Junk (\_ -> Layers [] [] [])


{-| -}
custom : (Coordinate.System -> Layers msg) -> Junk msg
custom =
  Internal.Junk.Junk



-- PLACING


{-| -}
type alias Transfrom =
  Svg.Transfrom


{-| -}
move : Coordinate.System -> Float -> Float -> Transfrom
move =
  Svg.move


{-| -}
offset : Float -> Float -> Transfrom
offset =
  Svg.offset


{-| -}
transform : List Transfrom -> Svg.Attribute msg
transform =
  Svg.transform
