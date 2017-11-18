module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , bordered, disconnected, aura, full
  , default, custom, Style, Look
  , isMaybe, emphasized
  )

{-| # Dots

## Quick start
@docs Dot, none, default1, default2, default3

## Customizing dot shape
@docs circle, triangle, square, diamond, plus, cross

## Customizing dot style
@docs full, disconnected, bordered, aura


-}

import Internal.Dot as Dot exposing (Look, Style, Shape)



-- CONFIG


{-| -}
emphasized : Style -> Style -> (data -> Bool) -> Look data
emphasized normal emphasized isEmphasized =
  Dot.Look
    { normal = normal
    , emphasized = emphasized
    , isEmphasized = isEmphasized
    }


{-| -}
type alias Look data =
  Dot.Look data


{-| -}
type alias Style =
  Dot.Style


default : Look data
default =
  Dot.Look
    { normal = disconnected 4 2
    , emphasized = aura 4 4 0.5
    , isEmphasized = always False
    }


custom : Style -> Look data
custom style =
  Dot.Look
    { normal = style
    , emphasized = aura 20 4 0.5
    , isEmphasized = always False
    }


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



-- DEFAULTS


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



-- STYLE


{-| -}
bordered : Int -> Int -> Style
bordered size border =
  Dot.Style { size = size, variety = Dot.Bordered border }


{-| -}
disconnected : Int -> Int -> Style
disconnected size border =
  Dot.Style { size = size, variety = Dot.Disconnected border }


{-| -}
aura : Int -> Int -> Float -> Style
aura size aura opacity =
  Dot.Style { size = size, variety = Dot.Aura aura opacity }


{-| -}
full : Int -> Style
full size =
  Dot.Style { size = size, variety = Dot.Full }



-- Hover helpers


isMaybe : Maybe data -> data -> Bool
isMaybe hovering datum =
  Just datum == hovering
