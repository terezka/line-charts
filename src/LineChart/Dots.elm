module LineChart.Dots exposing
  ( Shape, none
  , circle, triangle, square, diamond, plus, cross
  , Config, default, static, hoverable, hoverOne, hoverMany
  , Style, bordered, disconnected, aura, full
  )

{-|

# Quick start
@docs none

# Customizing shape
@docs Shape, circle, triangle, square, diamond, plus, cross

# Customizing style
@docs Config, default, static, hoverable, hoverOne, hoverMany

## Styles
@docs Style, full, bordered, disconnected, aura

-}

import Internal.Dots as Dot



-- QUICK START


{-| If you don't want a dot at all.

    humanChart : Html msg
    humanChart =
      LineChart.view .age .income
        [ LineChart.Line Color.pink Dot.none "Alice" alice ]
-}
none : Shape
none =
  Dot.None



-- SHAPES


{-| The shapes in this section is the selection you have available to use as the
shape of your line's dot.

    humanChart : Html msg
    humanChart =
      LineChart.view .age .income
        [ LineChart.Line Color.orange Dot.plus "Alice" alice
        , LineChart.Line Color.blue Dot.square "Bob" bob
        , LineChart.Line Color.pink Dot.diamond "Chuck" chuck
        ]
-}
type alias Shape =
  Dot.Shape


{-|
-}
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
type alias Config data =
  Dot.Config data


{-| -}
default : Config data
default =
  Dot.default


{-|

    dotsConfig : Dot.Config data
    dotsConfig =
      Dot.static (Dot.full 5)
-}
static : Style -> Config data
static =
  Dot.static


{-|

    dotsConfig : Dot.Config Info
    dotsConfig =
      Dot.hoverable
        { normal = Dot.full 5
        , hovered = Dot.aura 7 4 0.5
        , isHovered = isOverweight
        }

    isOverweight : Info -> Bool
    isOverweight info =
      bmi info > 25

-}
hoverable :
  { normal : Style
  , hovered : Style
  , isHovered : data -> Bool
  }
  -> Config data
hoverable =
  Dot.hoverable


{-| -}
hoverOne : Maybe data -> Config data
hoverOne hovering =
  Dot.hoverable
    { normal = disconnected 10 2
    , hovered = aura 7 6 0.4
    , isHovered = Just >> (==) hovering
    }


{-| -}
hoverMany : List data -> Config data
hoverMany hovering =
  Dot.hoverable
    { normal = disconnected 10 2
    , hovered = aura 7 6 0.4
    , isHovered = \data -> List.any ((==) data) hovering
    }



-- STYLES


{-| -}
type alias Style =
  Dot.Style


{-| Makes dots plain and solid. Pass the radius.
-}
full : Float -> Style
full =
  Dot.full


{-| Makes dots with a white core and a colored border.
Pass the radius of the dot and the width of the border.
-}
bordered : Float -> Int -> Style
bordered =
  Dot.bordered


{-| Makes dots with a colored core and a white border (Inverse of `bordered`).
Pass the radius of the dot and the width of the border.
-}
disconnected : Float -> Int -> Style
disconnected =
  Dot.disconnected


{-| Makes dots with a colored core and a less colored, transparent border.
Pass the radius of the dot, the width of the border, and the opacity of the
border (A number between 0 and 1).
-}
aura : Float -> Int -> Float -> Style
aura =
  Dot.aura
