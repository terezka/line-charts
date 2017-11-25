module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , Look, default, static, emphasizable, isMaybe
  , Style, bordered, disconnected, aura, full
  )

{-|

# Dots

## Quick start
@docs none, default1, default2, default3

## Customizing dot shape
@docs Shape, circle, triangle, square, diamond, plus, cross

## Customizing dot style
@docs Look, default, static, emphasizable, isMaybe

### Styles
@docs Style, full, disconnected, bordered, aura

-}

import Internal.Dot as Dot



-- QUICK START


{-| -}
none : Shape
none =
  Dot.None


{-| -}
default1 : Shape
default1 =
  circle


{-| -}
default2 : Shape
default2 =
  triangle


{-| -}
default3 : Shape
default3 =
  cross



-- SHAPES


{-| -}
type alias Shape =
  Dot.Shape


{-| -}
circle : Shape
circle =
  Dot.Circle


{-| -}
triangle : Shape
triangle =
  Dot.Triangle


{-| -}
square : Shape
square =
  Dot.Square


{-| -}
diamond : Shape
diamond =
  Dot.Diamond


{-| -}
plus : Shape
plus =
  Dot.Plus


{-| -}
cross : Shape
cross =
  Dot.Cross



-- LOOK


{-| -}
type alias Look data =
  Dot.Look data


{-| -}
default : Look data
default =
  Dot.default


{-| -}
static : Style -> Look data
static =
  Dot.static


{-| -}
emphasizable : Style -> Style -> (data -> Bool) -> Look data
emphasizable =
  Dot.emphasizable


{-| Helper for `emphasizable`. -}
isMaybe : Maybe data -> data -> Bool
isMaybe hovering datum =
  Just datum == hovering



-- STYLES


{-| -}
type alias Style =
  Dot.Style


{-| -}
bordered : Int -> Int -> Style
bordered =
  Dot.bordered


{-| -}
disconnected : Int -> Int -> Style
disconnected =
  Dot.disconnected


{-| -}
aura : Int -> Int -> Float -> Style
aura =
  Dot.aura


{-| -}
full : Int -> Style
full =
  Dot.full
