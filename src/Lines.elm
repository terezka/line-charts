module Lines exposing
  ( view1, view2, view3
  , view, line, dash
  , viewCustom, Config
  , Interpolation, linear, monotone
  )

{-|

# Quick start
@docs view1, view2, view3

# Customize lines
@docs view, line, dash

# Customize everything else
@docs Config, viewCustom

## Interpolations
@docs Interpolation, linear, monotone

More interpolations will come in later versions.

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
      , x = Axis.default (Axis.defaultTitle "Age" 0 0) .age       -- FIXME
      , y = Axis.default (Axis.defaultTitle "Weight" 0 0) .weight -- FIXME
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
type alias Line data = -- TODO Move to Line.elm?
  Line.Line data


{-| Customize a solid line.

For example, if you want to show a pink line with squares for the dots
indicating your data points, and one which is brown and has triangles for dots,
you can do that like this:

    diabetesChart : Html msg
    diabetesChart =
      Lines.view .year .riskOfDiabetes
        [ Lines.line "pink" Dot.square "U.S." healthData.usa
        , Lines.line "brown" Dot.triangle "E.U." healthData.eu
        ]

Besides the color and the dot, you also pass the function a string title and
the data for that line. The title will show up in the legend in top right
side of your chart. You can learn more about the customizations available
for legends by studying the `Config` type.

 -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line =
  Line.line


{-| Customize a dashed line.

Works just like `line`, except it takes another argument second to last which
is and array of floats indicating the pattern of your dashing. TODO insert link
to svg dash-stroke. Dashed lines are especially good for visualizing processed
data, like averages or predicted values. For example:

    diabetesChart : Html msg
    diabetesChart =
      Lines.view .year .avgRiskOfDiabetes
        [ Lines.line "pink" Dot.square "U.S." healthData.usa
        , Lines.line "brown" Dot.triangle "E.U." healthData.eu
        , Lines.dash "darkviolet" Dot.none "Avg." [ 2, 2 ] healthData.avg
        ]

Besides the color and the dot, you also pass the function a string title and
the data for that line. The title will show up in the legend in top right
side of your chart.

If you are interested in customizing your legends, dot size or line width,
check out `viewCustom`. For now though, I'd recommend you stick to `view` and
get your lines right first, and they stepping up the complexity.

-}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash =
  Line.dash


-- TODO: Add area
-- TODO: Fix zero limit
-- TODO: Make sure max data lenght wins
-- TODO: Fix axis outliers maybe
-- TODO: Curbing the translation in the custom event searcher


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

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data points (like a human with an `age`, `weight`,
`height`, and `income`) we can easily pick which two we want to display:

    type alias Alice =
      { age : Float
      , weight : Float
      , height : Float
      , income : Float
      }

    aliceChart : Html msg
    aliceChart =
      Lines.view1 .age .weight
        [ Alice  4 24 0.94 0
        , Alice 25 75 1.73 25000
        , Alice 43 83 1.75 40000
        ]

    -- Try changing .weight to .income


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

    type alias Info =
      { age : Float
      , weight : Float
      , height : Float
      , income : Float
      }

    alice : List Info
    alice =
      [ Info  4 24 0.94 0
      , Info 25 75 1.73 25000
      , Info 43 83 1.75 40000
      ]

    chuck : List Info
    chuck =
      [ Info  4 21 0.98 0
      , Info 25 89 1.83 85000
      , Info 43 95 1.84 120000
      ]


-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-| Show a line chart with three data sets. It works just like `view1` and `view2`.

    humanChart : Html msg
    humanChart =
      Lines.view3 .age .weight alice bob chuck

    type alias Info =
      { age : Float
      , weight : Float
      , height : Float
      , income : Float
      }

    alice : List Info
    alice =
      [ Info 4 24 0.94 0
      , Info 25 75 1.73 25000
      , Info 43 83 1.75 40000
      ]

    bob : List Info
    bob =
      [ Info 4 22 1.01 0
      , Info 25 75 1.87 28000
      , Info 43 77 1.87 52000
      ]

    chuck : List Info
    chuck =
      [ Info 4 21 0.98 0
      , Info 25 89 1.83 85000
      , Info 43 95 1.84 120000
      ]

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

    -- Missing the data `alice`, `bob`, and `chuck`?
    -- You can copy/paste it from the example by `view3`!


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

    chartConfig : (data -> Float) -> (data -> Float) -> Config data msg
    chartConfig toXValue toYValue =
      { frame = Frame (Margin 40 150 90 150) (Size 650 400)
      , attributes =
          -- Changed from the default!
          [ Svg.Attributes.style "fill: darkslategray;" ]
      , events = []
      , junk = Junk.none
      , x = Axis.default (Axis.defaultTitle "" 0 0) toXValue
      , y = Axis.default (Axis.defaultTitle "" 0 0) toYValue
      , interpolation = Lines.linear
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.default
      }

    chart : Html msg
    chart =
      Lines.viewCustom (chartConfig .year .riskOfDiabetes)
        [ Lines.line "pink" Dot.square "U.S." healthData.usa
        , Lines.line "brown" Dot.triangle "E.U." healthData.eu
        , Lines.dash "darkviolet" Dot.none "Avg." [ 2, 3 ] healthData.avg
        ]

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
      , y = Coordinate.limits (.point >> .y) allPoints
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
  List.map4 Line.defaultLine defaultShapes defaultColors defaultLabel


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
