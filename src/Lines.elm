module Lines exposing
  ( view1, view2, view3
  , view, line, dash, area
  , viewCustom, Config
  , Interpolation, linear, monotone
  )

{-|

# Quick start
@docs view1, view2, view3

# Customize lines
@docs view, line, dash, area

# Customize everything
@docs Config, viewCustom

## Interpolations
@docs Interpolation, linear, monotone


-}

import Html
import Svg
import Svg.Attributes as Attributes
import Lines.Axis as Axis
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Lines.Junk as Junk
import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Events as Events
import Internal.Interpolation as Interpolation
import Internal.Junk
import Internal.Legends as Legends
import Internal.Line as Line



-- CONFIG


{-| The customizations available for your line chart viewed with `viewCustom`.

  - `frame` customizes the size and margins of your chart. See `Lines.Coordinate`
    for more information and examples.
  - `attributes` allows you to specify SVG attributes to be added to the `svg`
    element containing your chart.
  - `events` allows you to add events to your chart, allowing you easily making
    your chart interactive (adding tooltips, hover startes etc.). See
    `Lines.Events` for more information and examples.
  - `junk` gets its name from Edward Tufte's concept of "chart junk". Here you
    are allowed set your creativity free and add whatever SVG or HTML fun you
    can imagine. Useful when you are the victim of a designer's urge to explore
    their artistic potential within data visualizing. See `Lines.Junk` for
    more information and examples. -- TODO joke
  - `x` allows you to customize the look of your horizontal axis. See
    `Lines.Axis` for more information and examples.
  - `y` allows you to customize the look of your vertical axis. See
    `Lines.Axis` for more information and examples.
  - `interpolation` allows you to customize the curve of your lines.
    See the `Interpolation` type for more information and examples.
  - `legends` allows you to customize your charts legends. See
    `Lines.Legends` for more information and examples.
  - `line` allows you to customize your lines' width and color. See
    `Lines.Line` for more information and examples.
  - `dot` allows you to customize your dots' size and style. See
    `Lines.Dot` for more information and examples.

  TODO reorder properties, add links, align examples to run progressively


The default configuration is the following. A good start would be to copy it and
play around with customizations available for each property. Again, to be used
with `viewCustom`!

    import Lines
    import Lines.Axis as Axis
    import Lines.Coordinate exposing (Frame, Margin, Size)
    import Lines.Dot as Dot
    import Lines.Events as Events
    import Lines.Junk as Junk
    import Lines.Legends as Legends
    import Lines.Line as Line

    chartConfig : Config data msg
    chartConfig =
      { frame = Frame (Margin 40 150 90 150) (Size 650 400)
      , attributes = []
      , events = []
      , junk = Junk.none
      , x = Axis.default (Axis.defaultTitle "Age" 0 0) .age
      , y = Axis.default (Axis.defaultTitle "Weight" 0 0) .weight
      , interpolation = Lines.linear
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.default
      }

    chart : Html msg
    chart =
      Lines.viewCustom chartConfig
        [ Lines.line "red" Dot.cross "Alice" alice
        , Lines.line "blue" Dot.square "Bob" bob
        , Lines.line "green" Dot.circle "Chuck" chuck
        ]

-}
type alias Config data msg =
  { frame : Coordinate.Frame
  , attributes : List (Svg.Attribute msg)
  , events : List (Events.Event data msg)
  , junk : Junk.Junk msg
  , x : Axis.Axis data msg
  , y : Axis.Axis data msg
  , interpolation : Interpolation
  , legends : Legends.Legends msg
  , line : Line.Look data -- TODO Look type ref doesn't show up in docs
  , dot : Dot.Look data
  }



-- INTERPOLATIONS


{-| Representes an interpolation (curving of lines).
-}
type alias Interpolation =
  Interpolation.Interpolation


{-| A linear interpolation.
-}
linear : Interpolation
linear =
  Interpolation.Linear


{-| A monotone-x interpolation.
-}
monotone : Interpolation
monotone =
  Interpolation.Monotone



-- LINE


{-| -}
type alias Line data =
  Line.Line data


{-| Customize a solid line.

Try changing the color or explore all the available dot shapes from `Lines.Dot`!

    import Lines
    import Lines.Dot as Dot

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/stWdWjqGZa1/0)._

Besides the color and the dot, you also pass the function a string title and
the data for that line. These titles will show up in the legends.

If you are interested in customizing your legends, dot size or line width,
check out `viewCustom`. For now though, I'd recommend you stick to `view` and
get your lines right first, and then stepping up the complexity.

 -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line =
  Line.line


{-| Customize a dashed line.

Works just like `line`, except it takes another argument second to last which
is and array of floats describing your dashing pattern. See the
[SVG `stroke-dasharray` documentation](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
for examples of patterns. Dashed lines are especially good for visualizing
processed data, like averages or predicted values.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.dash "rebeccapurple" Dot.none "Average" [ 2, 4 ] average
        , Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/syMhqfR8qa1/1)._

-}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash =
  Line.dash


{-| -}
area : Color.Color -> Dot.Shape -> String -> Float -> List data -> Line data
area =
  Line.area


-- TODO: Cutable domain/range
-- TODO: Add area negative curve
-- TODO: Fix axis outliers maybe
-- TODO: Curbing the translation in the custom event searcher
-- TODO: Make all lines area if area


-- VIEW / SIMPLE


{-| Show a line chart.

For example, if you want to show a few points, you can display it like this:

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      Lines.view1 .x .y
        [ Point 0 2
        , Point 5 5
        , Point 10 10
        ]

_See the example [here](https://ellie-app.com/s5M4fxFwGa1/0)._

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data points (like a human with an `age`, `weight`,
`height`, and `income`) we can easily pick which two we want to display:

    aliceChart : Html msg
    aliceChart =
      Lines.view1 .age .weight
        [ Info  4 24 0.94 0
        , Info 25 75 1.73 25000
        , Info 43 83 1.75 40000
        ]

    -- Try changing .weight to .height

_See the example [here](https://ellie-app.com/s8kQfLfYZa1/1)._

**Note 1:** Rather than using data like `.weight` directly, you can make a
function like `bmi human = human.weight / human.height ^ 2` and create a
chart of `.age` vs `bmi`. This allows you to keep your data set nice and minimal!

**Note 2:** `view1` is just a function, so it will adjust as your data changes.
If you get more data points or some data points are updated, the chart
updates automatically!

-}
view1 : (data -> Float) -> (data -> Float) -> List data -> Svg.Svg msg
view1 toX toY dataset =
  view toX toY <| defaultLines [ dataset ]


{-| Show a line chart with two data sets.

Say you have two humans and you would like to see how they their weight relates
to their age, we can display it like this:

    humanChart : Html msg
    humanChart =
      Lines.view2 .age .weight alice chuck

_See the full example [here](https://ellie-app.com/scTM9Mw77a1/0)._

-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-| Show a line chart with three data sets. It works just like `view1` and `view2`.

    humanChart : Html msg
    humanChart =
      Lines.view3 .age .weight alice bob chuck

_See the full example [here](https://ellie-app.com/sdNHxCfrJa1/0)._

But what if you have more people? What if you have _four_ people?! In that case,
check out `view`.
-}
view3 : (data -> Float) -> (data -> Float) -> List data -> List data -> List data -> Svg.Svg msg
view3 toX toY dataset1 dataset2 dataset3 =
  view toX toY <| defaultLines [ dataset1, dataset2, dataset3 ]



-- VIEW


{-| Show any amount of lines in your chart. Additional customizations of your
lines are also made available by the use of the function `line`.

    import Lines
    import Lines.Dot as Dot

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "red" Dot.cross "Alice" alice
        , Lines.line "blue" Dot.square "Bob" bob
        , Lines.line "green" Dot.circle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/sgL9mdF7ra1/1)._

-}
view : (data -> Float) -> (data -> Float) -> List (Line data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)



-- VIEW / CUSTOM


{-| Customize your chart. See the `Config` type for information about the
available customizations. The following example changes the font color of
your chart:

    import Svg.Attributes
    import Lines
    import Lines.Axis as Axis
    import Lines.Coordinate exposing (Frame, Margin, Size)
    import Lines.Dot as Dot
    import Lines.Events as Events
    import Lines.Junk as Junk
    import Lines.Legends as Legends
    import Lines.Line as Line

    chartConfig : Config data msg
    chartConfig =
      { frame = Frame (Margin 40 150 90 150) (Size 650 400)
      , attributes =
          -- Changed from the default!
          [ Svg.Attributes.style "fill: darkslategray;" ]
      , events = []
      , junk = Junk.none
      , x = Axis.default (Axis.defaultTitle "" 0 0) .age
      , y = Axis.default (Axis.defaultTitle "" 0 0) .weight
      , interpolation = Lines.linear
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.default
      }

    chart : Html msg
    chart =
      Lines.viewCustom chartConfig
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/smkVxrpMfa1/0)._

-}
viewCustom : Config data msg -> List (Line data) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Data points
    dataPoints =
      List.map (List.map dataPoint << .data << Line.lineConfig) lines

    dataPoint datum =
      Coordinate.DataPoint datum (point datum)

    point datum =
      Coordinate.Point
        (config.x.variable datum)
        (config.y.variable datum)

    -- System
    allPoints =
      List.concat dataPoints

    system =
      { frame = config.frame
      , x = Coordinate.limits (.point >> .x) allPoints
      , y = Coordinate.limits (.point >> .y) allPoints |> Line.setAreaDomain lines
      }

    -- View
    junk =
      Internal.Junk.getLayers config.junk system

    container plot =
      Html.div [] (plot :: junk.html)

    attributes =
      List.concat
        [ config.attributes
        , Events.toAttributes allPoints system config.events
        , [ Attributes.width <| toString system.frame.size.width
          , Attributes.height <| toString system.frame.size.height
          ]
        ]

    viewLine =
      Line.view system config.dot config.interpolation config.line

    viewLines =
      List.map2 viewLine lines dataPoints

    viewLegends =
      Legends.view system config.line config.dot config.legends lines dataPoints
  in
  container <|
    Svg.svg attributes
      [ Svg.g [ Attributes.class "junk--below" ] junk.below
      , Svg.g [ Attributes.class "lines" ] viewLines
      , Axis.viewHorizontal system config.x.look
      , Axis.viewVertical system config.y.look
      , viewLegends
      , Svg.g [ Attributes.class "junk--above" ] junk.above
      ]



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { frame = Coordinate.Frame (Coordinate.Margin 40 150 90 150) (Coordinate.Size 650 400)
  , attributes = [ Attributes.style "font-family: monospace;" ] -- TODO: Maybe remove
  , events = []
  , x = Axis.default (Axis.defaultTitle "" 0 0) toX
  , y = Axis.default (Axis.defaultTitle "" 0 0) toY
  , junk = Junk.none
  , interpolation = linear
  , legends = Legends.default
  , line = Line.default
  , dot = Dot.default
  }


defaultLines : List (List data) -> List (Line data)
defaultLines =
  List.map4 Line.line defaultColors defaultShapes defaultLabel


defaultColors : List Color.Color
defaultColors =
  [ Color.pink
  , Color.blue
  , Color.orange
  ]


defaultShapes : List Dot.Shape
defaultShapes =
  [ Dot.Circle
  , Dot.Triangle
  , Dot.Cross
  ]


defaultLabel : List String
defaultLabel =
  [ "Series 1"
  , "Series 2"
  , "Series 3"
  ]
