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
import Svg.Attributes as Attributes
import Html exposing (Html)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Junk


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
type Transfrom =
  Transfrom Float Float


{-| -}
move : Coordinate.System -> Float -> Float -> Transfrom
move system x y =
  Transfrom (toSVG X system x) (toSVG Y system y)


{-| -}
offset : Float -> Float -> Transfrom
offset x y =
  Transfrom x y


{-| -}
transform : List Transfrom -> Svg.Attribute msg
transform translations =
  let
    (Transfrom x y) =
      toPosition translations
  in
  Attributes.transform <|
    "translate(" ++ toString x ++ ", " ++ toString y ++ ")"



-- INTERNAL


toPosition : List Transfrom -> Transfrom
toPosition =
  List.foldr addPosition (Transfrom 0 0)


addPosition : Transfrom -> Transfrom -> Transfrom
addPosition (Transfrom x y) (Transfrom xf yf) =
  Transfrom (xf + x) (yf + y)
