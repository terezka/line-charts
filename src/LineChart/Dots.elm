module LineChart.Dots exposing
  ( Shape, none
  , circle, triangle, square, diamond, plus, cross
  , Config, default, custom, customAny, hoverOne, hoverMany
  , Style, bordered, disconnected, aura, full
  )

{-|

# Quick start

## Shapes
@docs Shape, none

## Config
@docs Config, default

# Options

## Shapes
@docs circle, triangle, square, diamond, plus, cross

## Config
@docs custom, hoverOne, hoverMany, customAny

### Styles
@docs Style, full, bordered, disconnected, aura

-}

import Internal.Dots as Dot



-- QUICK START


{-| Gets you a clean line without dots.

    humanChart : Html msg
    humanChart =
      LineChart.view .age .income
        [ LineChart.Line Color.pink Dot.none "Alice" alice ]

-}
none : Shape
none =
  Dot.None



-- SHAPES


{-| The shape type referes to the shape of your dot, denoting where your
data points are on your line.

    humanChart : Html msg
    humanChart =
      LineChart.view .age .income
        [ LineChart.Line Color.orange Dot.plus "Alice" alice
        , LineChart.Line Color.blue Dot.square "Bob" bob
        , LineChart.Line Color.pink Dot.diamond "Chuck" chuck
        ]

_See full example [here](https://ellie-app.com/9mFnMYLnba1/1)._

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


{-| Changes the style of _all_ your dots. See your style options under _Styles_.

Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data Msg
    chartConfig =
      { ...
      , dots = Dots.default
      , ...
      }

-}
type alias Config data =
  Dot.Config data


{-| Draws a white outline around all your dots.
-}
default : Config data
default =
  Dot.default


{-| Change the style of your dots.

    dotsConfig : Dot.Config data
    dotsConfig =
      Dots.custom (Dot.full 5)
-}
custom : Style -> Config data
custom =
  Dot.custom


{-| Change the style of your dots and add another dot state. Particularily useful
for hover states, but it can also be used for

    dotsConfig : Dot.Config Info
    dotsConfig =
      Dot.customAny
        { normal = Dot.full 5
        , hovered = Dot.aura 7 4 0.5
        , isHovered = isOverweight
        }

    isOverweight : Info -> Bool
    isOverweight info =
      bmi info > 25


_See full example [here](https://ellie-app.com/9n8tBnxV5a1/1)._


-}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Dot.customAny


{-| Adds a hover effect on the given dot!

    chartConfig : Maybe Data -> LineChart.Config Data Msg
    chartConfig hovered =
      { ...
      , dots = Dots.hoverOne hovered
      , ...
      }

_See full example [here](https://ellie-app.com/9psJRRS2ja1/1)._

-}
hoverOne : Maybe data -> Config data
hoverOne hovering =
  Dot.customAny
    { legend = \_ -> disconnected 10 2
    , individual = \data ->
        if Just data == hovering then
          aura 7 6 0.4
        else
          disconnected 10 2
    }


{-| -}
hoverMany : List data -> Config data
hoverMany hovering =
  Dot.customAny
    { legend = \_ -> disconnected 10 2
    , individual = \data ->
        if List.any ((==) data) hovering then
          aura 7 6 0.4
        else
          disconnected 10 2
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
