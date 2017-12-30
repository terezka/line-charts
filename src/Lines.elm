module Lines exposing
  ( view1, view2, view3
  , view, Line, line, dash
  , viewCustom, Config, Dimension
  , Interpolation, linear, monotone
  )

{-|

# Quick start
@docs view1, view2, view3

# Customize lines
@docs view, Line, line, dash

# Customize everything
@docs viewCustom, Config, Dimension

## Interpolations
@docs Interpolation, linear, monotone



-}

import Html
import Svg
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Junk as Junk
import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Events as Events
import Internal.Interpolation as Interpolation
import Internal.Junk
import Internal.Legends as Legends
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Axis.Range as Range
import Internal.Axis.Title as Title
import Internal.Axis.Intersection as Intersection



-- TODO http://package.elm-lang.org/packages/eskimoblood/elm-color-extra/5.0.0/Color-Convert
-- TOOO prevent dots from going outside range

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

_See the full example [here](https://ellie-app.com/s8kQfLfYZa1/1)._

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


{-| -}
type alias Line data =
  Line.Line data


{-| Customize a solid line.

Try changing the color or explore all the available dot shapes from `Lines.Dot`!

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
SVG [`stroke-dasharray` documentation](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
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



-- VIEW / CUSTOM


{-| The customizations available for your line chart viewed with `viewCustom`.

  - `margin`: Customizes the size and margins of your chart.
    See `Lines.Coordinate` for more information and examples.

  - `x`: Customizes the look of your horizontal axis.
    See `Lines.Axis` for more information and examples.

  - `y`: Customizes the look of your vertical axis.
    See `Lines.Axis` for more information and examples.

  - `interpolation`: Customizes the curve of your lines.
    See the `Interpolation` type for more information and examples.

  - `areaOpacity`: Determines the opacity of the area under your line.
    The area is always the same color as your line, but the transparency
    can be altered with this property. Takes a number between 0 and 1.

  - `legends`: Customizes your chart's legends.
    See `Lines.Legends` for more information and examples.

  - `line`: Customizes your lines' width and color.
    See `Lines.Line` for more information and examples.

  - `dot`: Customizes your dots' size and style.
    See `Lines.Dot` for more information and examples.

  - `attributes`: Customizes the SVG attributes added to the
    `svg` element containing your chart.

  - `events`: Customizes your chart's events, allowing you easily
    make your chart interactive (adding tooltips, hover startes etc.).
    See `Lines.Events` for more information and examples.

  - `junk`: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are allowed set your creativity loose and add whatever SVG or HTML fun
    you can imagine. (This is also where you can add grid lines!)
    See `Lines.Junk` for more information and examples.


The default configuration is the following (besides the `.age` and `.weight`,
you have to provide your own x and y property). A good start would be to
copy it and play around with customizations available for each property.

    chartConfig : Config data msg
    chartConfig =
      { margin = Margin 40 150 90 150
      , x = Axis.default (Axis.defaultTitle "" 0 0) .age
      , y = Axis.default (Axis.defaultTitle "" 0 0) .weight
      , interpolation = Lines.linear
      , areaOpacity = 0
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.default
      , junk = Junk.none
      , attributes = []
      , events = []
      , id = "chart"
      }

-}
type alias Config data msg =
  { margin : Coordinate.Margin
  , x : Dimension data msg
  , y : Dimension data msg
  , intersection : Intersection.Intersection
  , interpolation : Interpolation
  , areaOpacity : Float
  , legends : Legends.Legends msg
  , line : Line.Look data
  , dot : Dot.Look data
  , attributes : List (Svg.Attribute msg)
  , events : List (Events.Event data msg)
  , junk : Junk.Junk msg
  , id : String
  }


{-| -}
type alias Dimension data msg =
  { title : Title.Title msg
  , variable : data -> Float
  , pixels : Float -- TODO
  , padding : Float
  , range : Range.Range
  , axis : Axis.Axis data msg
  }


-- INTERPOLATIONS


{-| -}
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



{-| Customize your chart. See the `Config` type for information about the
available customizations. The example below adds color to the area below the lines.

**Note:** Speaking of areas, remember that area charts are for properties for
which the area under the curve _matters_. Typically, this would be when you
have an quantity changing with respect to time. In that case, the area under
the curve shows how much the quantity changed. However if that amount is not
significant, it's best to leave it out. -- TODO revise

    chart : Html msg
    chart =
      Lines.viewCustom chartConfig
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

    chartConfig : Config data msg
    chartConfig =
      { frame = Frame (Margin 40 150 90 150) (Size 650 400)
      , x = Axis.default (Axis.defaultTitle "" 0 0) .age
      , y = Axis.default (Axis.defaultTitle "" 0 0) .income
      , range = Limitation identity identity
      , domain = Limitation identity identity
      , interpolation = Lines.linear
      , areaOpacity = 0.25 -- Changed from the default!
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.default
      , attributes = []
      , events = []
      , junk = Junk.none
      , id = "chart"
      }

_See the full example [here](https://ellie-app.com/smkVxrpMfa1/2)._

-}
viewCustom : Config data msg -> List (Line data) -> Svg.Svg msg
viewCustom config lines =
  let
    allData =
      List.concatMap (.data << Line.lineConfig) lines

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

    frame =
      Coordinate.Frame config.margin
        (Coordinate.Size config.x.pixels config.y.pixels)

    system =
      { frame = frame
      , x = allPoints
              |> Coordinate.range (.point >> .x)
              |> Range.apply config.x.range
      , y = allPoints
              |> Coordinate.range (.point >> .y)
              |> adjustDomainRange
              |> Range.apply config.y.range
      }

    adjustDomainRange domain =
      if config.areaOpacity > 0 then
        Coordinate.ground domain
      else
        domain

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
      Line.view system config.dot config.interpolation config.line config.areaOpacity config.id

    viewLines =
      List.map2 viewLine lines dataPoints

    viewLegends =
      Legends.view system config.line config.dot config.legends config.areaOpacity lines dataPoints
  in
  container <|
    Svg.svg attributes
      [ Svg.defs [] [ clipPath config system ]
      , Svg.g [ Attributes.class "junk--below" ] junk.below
      , Svg.g [ Attributes.class "lines" ] viewLines
      , Axis.viewHorizontal system config.intersection allData config.x
      , Axis.viewVertical   system config.intersection allData config.y
      , viewLegends
      , Svg.g [ Attributes.class "junk--above" ] junk.above
      ]



-- INTERNAL


clipPath : Config data msg -> Coordinate.System -> Svg.Svg msg
clipPath { id } system =
  Svg.clipPath [ Attributes.id (Utils.toClipPathId id) ]
    [ Svg.rect
      [ Attributes.x <| toString system.frame.margin.right
      , Attributes.y <| toString system.frame.margin.top
      , Attributes.width <| toString (Coordinate.lengthX system)
      , Attributes.height <| toString (Coordinate.lengthY system)
      ]
      []
    ]



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { margin = Coordinate.Margin 40 150 90 150
  , attributes = [ Attributes.style "font-family: monospace;" ] -- TODO: Maybe remove
  , events = []
  , x =
      { title = Title.default ""
      , variable = toX
      , pixels = 650
      , padding = 20
      , range = Range.default
      , axis = Axis.float (Axis.around 10)
      }
  , y =
      { title = Title.default ""
      , variable = toY
      , pixels = 400
      , padding = 20
      , range = Range.default
      , axis = Axis.float (Axis.around 10)
      }
  , intersection = Intersection.default
  , junk = Junk.none
  , interpolation = linear
  , legends = Legends.default
  , line = Line.default
  , dot = Dot.default
  , areaOpacity = 0
  , id = "chart"
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
