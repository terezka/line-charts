module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , Look, default, static, emphasizable, isMaybe
  , Style, bordered, disconnected, aura, full
  )

{-|

# Dots

## Quick start
Can't be bothered to figure out about dots right now? I gotcha.
@docs none

### Easy defaults

The following defaults are equivalent to `Dot.circle`, `Dot.triangle`, and
`Dot.cross`, respectivily.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "red" Dot.default1 "Alice" alice
        , Lines.line "blue" Dot.default2 "Bob" bob
        , Lines.line "green" Dot.default3 "Chuck" chuck
        ]

@docs default1, default2, default3

## Customizing dot shape
@docs Shape, circle, triangle, square, diamond, plus, cross

## Customizing dot style
@docs Look, default, static, emphasizable, isMaybe

### Styles
@docs Style, full, disconnected, bordered, aura

-}

import Internal.Dot as Dot



-- QUICK START


{-| If you don't want a dot at all.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "red" Dot.none "Alice" alice ]
-}
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


{-| Representes a dot shape.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "red" Dot.diamond "Alice" alice
        , Lines.line "blue" Dot.plus "Bob" bob
        , Lines.line "green" Dot.cross "Chuck" chuck
        ]

**Note:** Interested in changing the size and style of the dots? Check out
the `Look` type!
-}
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
