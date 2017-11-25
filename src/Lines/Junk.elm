module Lines.Junk exposing
  ( Junk, Layers, none, custom
  , Transfrom, transform, move, offset
  )

{-|

# Junk

## Quick start
@docs none

## Custom
@docs Junk, Layers, custom

## Placing helpers
@docs Transfrom, transform, move, offset

-}

import Html
import Svg
import Lines.Coordinate as Coordinate
import Internal.Junk
import Internal.Svg as Svg



-- QUICK START


{-| -}
none : Junk msg
none =
  Internal.Junk.Junk (\_ -> Layers [] [] [])



-- CUSTOMIZE


{-| -}
type alias Junk msg =
  Internal.Junk.Junk msg


{-| -}
type alias Layers msg =
  { above : List (Svg.Svg msg)
  , below : List (Svg.Svg msg)
  , html : List (Html.Html msg)
  }


{-| -}
custom : (Coordinate.System -> Layers msg) -> Junk msg
custom =
  Internal.Junk.Junk



-- PLACING HELPERS


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
