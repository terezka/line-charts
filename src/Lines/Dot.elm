module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , Look, default, static, emphasizable
  , Style, bordered, disconnected, aura, full
  )

{-|

# Quick start
Can't be bothered to figure out about dots right now? I gotcha.
@docs none

## Easy defaults

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

# Customizing dot shape
@docs Shape, circle, triangle, square, diamond, plus, cross

# Customizing dot style
@docs Look, default, static, emphasizable

## Styles
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


{-| These customzation are used in `Lines.Config` when you use `viewCustom`.

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , dot = Dot.default -- Use here!
      , ...
      }
-}
type alias Look data =
  Dot.Look data


{-| The default dot look. -}
default : Look data
default =
  Dot.default


{-| Alter the style of the dot.

    dotLook : Dot.Look data
    dotLook =
      Dot.static (Dot.full 50) -- TODO attributes?
-}
static : Style -> Look data
static =
  Dot.static


{-| Alter the style of the dot and pass an alternative style, to be used when
the predicate in the third argument is fulfilled.


    dotLook : Dot.Look Info
    dotLook =
      Dot.emphasizable
        (Dot.full 50)
        (Dot.aura 50 4 0.5)
        isOverweight

    isOverweight : Info -> Bool
    isOverweight info =
      bmi info > 25

TODO link
-}
emphasizable :
  { normal : Style
  , emphasized : Style
  , isEmphasized : data -> Bool
  }
  -> Look data
emphasizable =
  Dot.emphasizable



-- STYLES


{-| -}
type alias Style =
  Dot.Style


{-| Produces a circle with a white core and a colored border.
Pass the size of the dot and the width of the border.
-}
bordered : Float -> Int -> Style
bordered =
  Dot.bordered


{-| Produces a circle with a colored core and a white border (Opposite of `bordered`).
Pass the size of the dot and the width of the border.
-}
disconnected : Float -> Int -> Style
disconnected =
  Dot.disconnected


{-| Produces a circle with a colored core and a less colored border.
Pass the size of the dot, the width of the border, and the opacity of the
border (A number between 0 and 1).
-}
aura : Float -> Int -> Float -> Style
aura =
  Dot.aura


{-| Produces a solid dot. Pass the size.
-}
full : Float -> Style
full =
  Dot.full
