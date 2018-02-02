module LineChart.Junk exposing
  ( Config, Layers, default, hoverOne, custom
  , Transfrom, transform, move, offset, placed
  , vertical, horizontal, verticalCustom, horizontalCustom
  , rectangle, label, labelPlaced
  , withinChartArea
  )

{-|

Junk is a way to draw whatever you like in the chart. The name comes from
[Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
If you want to add tooltips, sections for emphasis, or kittens on your chart,
this is where it's at.

<img alt="Legends" width="610" src="https://github.com/terezka/lines/blob/master/images/junk.png?raw=true"></src>

_A lot of junk, huh?_

@docs Config, default, hoverOne

# Customization
@docs custom, Layers

# Helpers

## On chart area

A good thing to know before reading this section is what I mean by "chart area".
It is basically the rectangle which covers your entire x and y axis-range.
Below is an illustration.

_What is an axis-range? See the `Axis.Range` module._

<img alt="Legends" width="610" src="https://github.com/terezka/lines/blob/master/images/chartarea.png?raw=true"></src>

@docs withinChartArea


## Lines
@docs vertical, horizontal, verticalCustom, horizontalCustom

## Rectangle
@docs rectangle

## Label
@docs label, labelPlaced

## Placing
@docs placed, Transfrom, transform, move, offset


-}

import Svg
import Svg.Attributes as Attributes
import Html
import LineChart.Coordinate as Coordinate
import Internal.Junk as Junk
import Internal.Svg as Svg
import Internal.Utils as Utils
import Color
import Color.Convert



-- QUICK START


{-| For the junk-free chart.
-}
default : Config data msg
default =
  Junk.none



-- CUSTOMIZE


{-| Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , junk = Junk.default
      , ...
      }

-}
type alias Config data msg =
  Junk.Config data msg


{-| Draws the default tooltip.

    junk : Maybe Data -> Junk.Junk msg
    junk hovered =
      Junk.hoverOne model.hovered
        [ ( "Age", toString << .age )
        , ( "Weight", toString << .weight )
        ]

_See full example [here](https://ellie-app.com/gpctbpbZ8a1/1)._

-}
hoverOne : Maybe data -> List ( String, data -> String ) -> Config data msg
hoverOne =
  Junk.hoverOne


{-| The layers where you can put your junk.

  - **below** junk will be placed below your lines
  - **above** junk will be placed above your lines
  - **html** junk will be placed on top of the SVG chart.

-}
type alias Layers msg =
  { below : List (Svg.Svg msg)
  , above : List (Svg.Svg msg)
  , html : List (Html.Html msg)
  }


{-| Draw whatever junk you'd like. You're given the `Coordinate.System` to help
you place your junk on the intended spot in the chart, because it allows you
to translate from data-space into SVG-space and vice versa.

To learn more about the `Coordinate.System` and how to use it, see the
`Coordinate` module.


    junk : Junk.Junk msg
    junk =
      Junk.custom <| \system ->
        { below = [ emphasisSection system ]
        , above = []
        , html = []
        }

    emphasisSection : Coordinate.System -> List (Svg msg)
    emphasisSection system =
      Junk.rectangle system [] 5 8 system.y.min system.y.max


_See full example [here](https://ellie-app.com/fyqDKvqrRa1/1)._


-}
custom : (Coordinate.System -> Layers msg) -> Config data msg
custom =
  Junk.custom



-- PLACING HELPERS


{-| -}
type alias Transfrom =
  Svg.Transfrom


{-| Produces a SVG transform attributes. Useful to move elements around.

    movedStuff : Coordinate.System -> Data -> Svg msg
    movedStuff system hovered =
      Svg.g
        [ Junk.transform
            [ Junk.move system hovered.age hovered.weight
            , Junk.offset 20 10
            ]
        ]
        [ Junk.label Color.blue "stuff" ]

_See full example [here](https://ellie-app.com/gfbQPqfPna1/1)._

-}
transform : List Transfrom -> Svg.Attribute msg
transform =
  Svg.transform


{-| Moves in data space.
-}
move : Coordinate.System -> Float -> Float -> Transfrom
move =
  Svg.move


{-| Moves in SVG space.
-}
offset : Float -> Float -> Transfrom
offset =
  Svg.offset



-- COMMON


{-| Draws a vertical line, which is the full length of the y-range.

Pass the x-coordinate.

**Note:** The line is truncated off if outside the chart area.
-}
vertical : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
vertical system attributes at =
  Svg.vertical system (withinChartArea system :: attributes) at system.y.min system.y.max


{-| Draws a horizontal line which is the full length of the x-range.

Pass the y-coordinate.

**Note:** The line is truncated off if outside the chart area.
-}
horizontal : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
horizontal system attributes at =
  Svg.horizontal system (withinChartArea system :: attributes) at system.x.min system.x.max


{-| Draws a vertical line.

Pass the x-, y1- and y2-coordinates, respectively.

**Note:** The line is truncated off if outside the chart area.
-}
verticalCustom : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float -> Float -> Svg.Svg msg
verticalCustom system attributes =
  Svg.vertical system (withinChartArea system :: attributes)


{-| Draws a horizontal line.

Pass the  y-, x1- and x2-coordinates, respectively.

**Note:** The line is truncated off if outside the chart area.
-}
horizontalCustom : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float ->  Float -> Svg.Svg msg
horizontalCustom system attributes =
  Svg.horizontal system (withinChartArea system :: attributes)


{-| A rectangle. This can be used for grid bands and highlighting a
range e.g. for selection.

    xSelectionArea : Coordinate.System -> Float -> Float -> Svg msg
    xSelectionArea system startX endX =
        Junk.rectangle system
          [ Attributes.fill "rgba(255,0,0,0.1)" ]
          startX endX system.y.min system.y.max

**Note:** The rectangle is truncated off if outside the chart area.
-}
rectangle : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float -> Float -> Float -> Svg.Svg msg
rectangle system attributes =
  Svg.rectangle system (withinChartArea system :: attributes)


{-| Place a list of elements on a given spot.

Arguments:
  1. The coordinate system.
  2. The x-coordinate in data-space.
  3. The y-coordinate in data-space.
  4. The x-offset in SVG-space.
  5. The y-offset in SVG-space.
  6. The list of elements

-}
placed : Coordinate.System -> Float -> Float -> Float -> Float -> List (Svg.Svg msg) -> Svg.Svg msg
placed system x y xo yo =
  Svg.g [ transform [ move system x y, offset xo yo ] ]



-- HELPERS


{-| Given a color, it draws the text in the second argument.
-}
label : Color.Color -> String -> Svg.Svg msg
label color =
  Svg.label (Color.Convert.colorToHex color)


{-| A label, but you get to place it too.

Arguments:
  1. The coordinate system.
  2. The x-coordinate in data-space.
  3. The y-coordinate in data-space.
  4. The x-offset in SVG-space.
  5. The y-offset in SVG-space.
  6. The `text-anchor` css value.
  7. The color of the text.
  8. The text.


    customJunk : Junk.Config data msg
    customJunk =
      Junk.custom <| \system ->
        { below = []
        , above =
            [ Junk.labelPlaced system 2  1.5 0 -10 "middle" Color.black "← axis range →"
            , Junk.labelPlaced system 2 -1.5 0  18 "middle" Color.black "← data range →"
            -- Try changing the numbers!
            ]
        , html = []
        }

_See full example [here](https://ellie-app.com/gfbQPqfPna1/1 TODO)._

-}
labelPlaced : Coordinate.System -> Float -> Float -> Float -> Float -> String -> Color.Color -> String -> Svg.Svg msg
labelPlaced system x y xo yo anchor color text =
  Svg.g
    [ transform [ move system x y, offset xo yo ]
    , Attributes.style <| "text-anchor: " ++ anchor ++ ";"
    ]
    [ label color text ]


{-| An attribute which when added, truncates the rendered element if it
extends outside the chart area.
-}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea { id } =
  Attributes.clipPath <| "url(#" ++ Utils.toChartAreaId id ++ ")"
