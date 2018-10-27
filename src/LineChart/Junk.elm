module LineChart.Junk exposing
  ( Config, Layers, default, hoverOne, hoverMany, custom
  , Transfrom, transform, move, offset, placed
  , vertical, horizontal, verticalCustom, horizontalCustom
  , rectangle, circle
  , label, labelAt
  , withinChartArea
  , hover, hoverAt
  )

{-|

Junk is a way to draw whatever you like in the chart. The name comes from
[Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
If you want to add tooltips, sections for emphasis, or kittens on your chart,
this is where it's at.

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/junk.png?raw=true"></src>

@docs Config, default, hoverOne, hoverMany

# Customization
@docs custom, Layers

# Helpers

## On chart area

A good thing to know before reading this section is what I mean by "chart area".
It is basically the rectangle which covers your entire x and y axis-range.
Below is an illustration.

_What is an axis-range? See the `Axis.Range` module._

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/chartarea.png?raw=true"></src>

@docs withinChartArea

## Lines
@docs vertical, horizontal, verticalCustom, horizontalCustom

## Shapes
@docs rectangle, circle

## Label
@docs label, labelAt

## Placing
@docs placed, Transfrom, transform, move, offset

## Hover views
This is just regular html views! Nothing fancy - you can also make your own!
Notice that you can override all the styles.

@docs hover, hoverAt


-}

import Svg
import Svg.Attributes as Attributes
import Html
import LineChart.Coordinate as Coordinate
import Internal.Junk as Junk
import Internal.Svg as Svg
import Color



-- QUICK START


{-| For the junk-free chart.
-}
default : Config data msg
default =
  Junk.none



-- CUSTOMIZE


{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

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

    customJunk : Maybe Data -> Junk.Junk msg
    customJunk hovered =
      Junk.hoverOne model.hovered
        [ ( "Age", toString << .age )
        , ( "Weight", toString << .weight )
        ]

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Junk/Example1.elm)._

<img alt="Tooltip" width="540" src="https://github.com/terezka/line-charts/blob/master/images/tooltip1.png?raw=true"></src>

-}
hoverOne : Maybe data -> List ( String, data -> String ) -> Config data msg
hoverOne =
  Junk.hoverOne


{-| Draws the default tooltip for multiple hovered points.

    customJunk : List Data -> Junk.Junk msg
    customJunk hovered =
      Junk.hoverMany model.hovered formatX formatY

    formatX : Data -> String
    formatX =
      .date >> Date.fromTime >> Date.Format.format "%e. %b, %Y"

    formatY : Data -> String
    formatY data =
      toString data.weight ++ "kg"


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Junk/Example4.elm)._


<img alt="Tooltip" width="540" src="https://github.com/terezka/line-charts/blob/master/images/tooltip2.png?raw=true"></src>

-}
hoverMany : List data -> (data -> String) -> (data -> String) -> Config data msg
hoverMany =
  Junk.hoverMany


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


    junk : Maybe Coordinate.Point -> Coordinate.System -> Junk.Layers msg
    junk hovered system =
      { below =
          case hovered of
            Just hovered -> [ sectionBand hovered system ]
            Nothing      -> []
      , above = []
      , html = []
      }

    sectionBand : Coordinate.Point -> Coordinate.System -> Svg.Svg msg
    sectionBand hovered system =
      Junk.rectangle system
        [ Svg.Attributes.fill "#b6b6b61a" ]
        (hovered.x - 5) (hovered.x + 5)
        system.y.min    system.y.max


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Junk/Example2.elm)._


-}
custom : (Coordinate.System -> Layers msg) -> Config data msg
custom =
  Junk.custom



-- PLACING HELPERS


{-| -}
type alias Transfrom =
  Svg.Transfrom


{-| Produces a SVG transform attributes. Useful to move elements around.

    movedStuff : Coordinate.System -> Svg.Svg msg
    movedStuff system =
      Svg.g
        [ Junk.transform
            [ Junk.move system someDataPoint.age someDataPoint.weight
            , Junk.offset 20 10
            -- Try changing the offset!
            ]
        ]
        [ Junk.label Colors.blue "stuff" ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Junk/Example3.elm)._

-}
transform : List Transfrom -> Svg.Attribute msg
transform =
  Svg.transform


{-| Moves in data-space.
-}
move : Coordinate.System -> Float -> Float -> Transfrom
move =
  Svg.move


{-| Moves in SVG-space.
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


{-| Draws a rectangle. This can be used for grid bands and highlighting a
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


{-| Draws a circle. Pass the system, radius, color and x- and y-coordinates respectively.

-}
circle : Coordinate.System -> Float -> Color.Color -> Float -> Float -> Svg.Svg msg
circle system radius color x y =
  Svg.gridDot radius color <| Coordinate.toSvg system (Coordinate.Point x y)


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
  Svg.label (Color.toCssString color)



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


    customJunk : Junk.Config Data msg
    customJunk =
      Junk.custom <| \system ->
        { below = []
        , above =
            [ Junk.labelAt system 2  1.5 0 -10 "middle" Colors.black "← axis range →"
            , Junk.labelAt system 2 -1.5 0  18 "middle" Colors.black "← data range →"
            -- Try changing the numbers!
            ]
        , html = []
        }

-}
labelAt : Coordinate.System -> Float -> Float -> Float -> Float -> String -> Color.Color -> String -> Svg.Svg msg
labelAt system x y xo yo anchor color text =
  Svg.g
    [ transform [ move system x y, offset xo yo ]
    , Attributes.style <| "text-anchor: " ++ anchor ++ ";"
    ]
    [ label color text ]


{-| An attribute which when added, truncates the rendered element if it
extends outside the chart area.
-}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea =
  Svg.withinChartArea



-- HOVER VIEWS


{-| Make the markup for a hover placed in the middle of the y-axis and at a given x-coordinate.

Pass the hint x-coordinate, your styles and your internal view.

    customJunk : Maybe Data -> Junk.Config Data msg
    customJunk hovered =
      Junk.custom <| \system ->
        { below = []
        , above = []
        , html =
            [ Junk.hover system hovered.x
                [ ( "border-color", "red" ) ]
                [ Html.text (toString hovered.y) ]
            ]
        }

 -}
hover : Coordinate.System  -> Float -> List ( String, String ) -> List (Html.Html msg) -> Html.Html msg
hover =
  Junk.hover


{-| Make the markup for a hover placed at a given x- and y-coordinate.

Pass the hint x- and y-coordinate, your styles and your internal view.

    customJunk : Maybe Data -> Junk.Config Data msg
    customJunk hovered =
      Junk.custom <| \system ->
        { below = []
        , above = []
        , html =
            [ Junk.hoverAt system hovered.x system.y.max
                [ ( "border-color", "red" ) ]
                [ Html.text (toString hovered.y) ]
            ]
        }

-}
hoverAt : Coordinate.System  -> Float -> Float -> List ( String, String ) -> List (Html.Html msg) -> Html.Html msg
hoverAt =
  Junk.hoverAt
