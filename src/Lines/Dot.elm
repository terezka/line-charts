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

import Internal.Dot as Dot exposing (Look, Style, Shape)



-- LOOK


{-| -}
type alias Look data =
  Dot.Look data


{-| -}
default : Look data
default =
  Dot.Look
    { normal = disconnected 30 2
    , emphasized = aura 20 4 0.5
    , isEmphasized = always False
    }


{-| -}
static : Style -> Look data
static style =
  Dot.Look
    { normal = style
    , emphasized = aura 20 4 0.5
    , isEmphasized = always False
    }


{-| -}
emphasizable : Style -> Style -> (data -> Bool) -> Look data
emphasizable normal emphasized isEmphasized =
  Dot.Look
    { normal = normal
    , emphasized = emphasized
    , isEmphasized = isEmphasized
    }


{-| Helper for `emphasizable`. -}
isMaybe : Maybe data -> data -> Bool
isMaybe hovering datum =
  Just datum == hovering



-- SHAPES


{-| -}
type alias Shape
  = Dot.Shape


{-| -}
none : Shape
none =
  Dot.None


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



-- SHAPES / DEFAULTS


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



-- STYLES


{-| -}
type alias Style =
  Dot.Style


{-| -}
bordered : Int -> Int -> Style
bordered size border =
  Dot.style size (Dot.Bordered border)


{-| -}
disconnected : Int -> Int -> Style
disconnected size border =
  Dot.style size (Dot.Disconnected border)


{-| -}
aura : Int -> Int -> Float -> Style
aura size aura opacity =
  Dot.style size (Dot.Aura aura opacity)


{-| -}
full : Int -> Style
full size =
  Dot.style size Dot.Full
