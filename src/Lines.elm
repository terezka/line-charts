module Lines exposing
  ( view1, view2, view3
  , view, Line, line, dash
  , viewCustom, Config
  , Interpolation, linear, monotone
  )

{-|

# Quick start
@docs view1, view2, view3

# Customizing lines
@docs view, Line, line, dash

# Customizing everything
@docs viewCustom, Config

## Interpolations
@docs Interpolation, linear, monotone



-}

import Html
import Svg
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Junk as Junk
import Lines.Dimension as Dimension
import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Grid as Grid
import Internal.Events as Events
import Internal.Interpolation as Interpolation
import Internal.Junk
import Internal.Legends as Legends
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Axis.Range as Range
import Internal.Axis.Intersection as Intersection



-- TODO http://package.elm-lang.org/packages/eskimoblood/elm-color-extra/5.0.0/Color-Convert
-- TODO prevent dots from going outside range
-- TODO broken data
-- TODO consider tick space tolerance as determinating factor of tick amount
-- TODO Add range adjust for nice ticks?



-- VIEW / SIMPLE


{-|

** Show a line chart **

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      Lines.view1 .x .y
        [ Point 0 2, Point 5 5, Point 10 10 ]

_See the full example [here](https://ellie-app.com/s5M4fxFwGa1/0)._


** Choosing your variables **

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data structures, like a human with an `age`, `weight`,
`height`, and `income`, we can easily pick which two properties we want to plot:

    aliceChart : Html msg
    aliceChart =
      Lines.view1 .age .weight
        [ Human  4 24 0.94 0
        , Human 25 75 1.73 25000
        , Human 43 83 1.75 40000
        ]

    -- Try changing .weight to .height


_See the full example [here](https://ellie-app.com/s8kQfLfYZa1/1)._


** Use any function as the variable **

Rather than using data like `.weight` directly, you can make a
function like `bmi human = human.weight / human.height ^ 2` and create a
chart of `.age` vs `bmi`. This allows you to keep your data set nice and minimal!


** The whole chart is just a function **

`view1` is just a function, so it will update as your data changes.
If you get more data points or some data points are changed, the chart
refreshes automatically!

-}
view1 : (data -> Float) -> (data -> Float) -> List data -> Svg.Svg msg
view1 toX toY dataset =
  view toX toY <| defaultLines [ dataset ]


{-|

** Show a line chart with two lines **

Say you have two humans and you would like to see how their weight relates
to their age. Here's how you could plot it.

    humanChart : Html msg
    humanChart =
      Lines.view2 .age .weight alice chuck

_See the full example [here](https://ellie-app.com/scTM9Mw77a1/0)._

-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-|

** Show a line chart with three lines **

It works just like `view1` and `view2`.

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


{-|

** Show any amount of lines **

Try changing the color, the dot, or the title of a line, or see
the `line` function for more information.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "red" Dot.cross "Alice" alice
        , Lines.line "blue" Dot.square "Bob" bob
        , Lines.line "green" Dot.circle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/sgL9mdF7ra1/1)._

See `viewCustom` for all other customizations.

-}
view : (data -> Float) -> (data -> Float) -> List (Line data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)


{-| -}
type alias Line data =
  Line.Line data


{-|

** Customize a solid line **

Try changing the color or explore all the available dot shapes from `Lines.Dot`!

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/stWdWjqGZa1/0)._


** Regarding the title **

The string title will show up in the legends. If you are interested in
customizing your legends, dot size or line width, check out `viewCustom`.
For now though, I'd recommend you stick to `view` and get your lines and
data right first, and then stepping up the complexity.

 -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line =
  Line.line


{-|

** Customize a dashed line **

Works just like `line`, except it takes another argument which is an array of
floats describing your dashing pattern. I'd recommend just typing in
random numbers and see what happends, but alternativelly you can see the SVG `stroke-dasharray`
[documentation](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
for examples of patterns.

    humanChart : Html msg
    humanChart =
      Lines.view .age .weight
        [ Lines.dash "rebeccapurple" Dot.none "Average" [ 2, 4 ] average
        , Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

    -- Try passing different numbers!

_See the full example [here](https://ellie-app.com/syMhqfR8qa1/1)._

** When should I use a dashed line? **

Dashed lines are especially good for visualizing processed data like
averages or predicted values.

-}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash =
  Line.dash



-- VIEW / CUSTOM


{-|

** Available customizations **

Use with `viewCustom`.

  - **id**: Sets the id. It's uniqueness is important for reasons you
    don't really need to know, so please just make sure it is!

  - **margin**: Customizes the size and margins of your chart.
    Arguments are organized like CSS margins: top right bottom left.
    See `Lines.Coordinate` for more information and examples.

  - **x**: Customizes your horizontal axis.
    See `Lines.Dimension` for more information and examples.

  - **y**: Customizes your vertical axis.
    See `Lines.Dimension` for more information and examples.

  - **grid**: Customizes the style of your grid.
    See `Lines.Grid` for more information and examples.

  - **areaOpacity**: Determines the opacity of the area under your line.
    The area is always the same color as your line, but the transparency
    can be altered with this property. Takes a number between 0 and 1.

  - **intersection**: Determines where your axes meet.
    See `Lines.Axis.Intersection` for more information and examples.

  - **interpolation**: Customizes the curve of your lines.
    See the `Interpolation` type for more information and examples.

  - **line**: Customizes your lines' width and color.
    See `Lines.Line` for more information and examples.

  - **dot**: Customizes your dots' size and style.
    See `Lines.Dot` for more information and examples.

  - **legends**: Customizes your chart's legends.
    See `Lines.Legends` for more information and examples.

  - **attributes**: Customizes the SVG attributes added to the `svg` element
    containing your chart.

  - **events**: Customizes your chart's events, allowing you easily.
    make your chart interactive (adding tooltips, hover states etc.).
    See `Lines.Events` for more information and examples.

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.
    See `Lines.Junk` for more information and examples.


** Example configuration **

A good start would be to copy it and play around with customizations
available for each property.

    chartConfig : Config Info msg
    chartConfig =
      { id = "chart"
      , margin = Coordinate.Margin 30 120 90 120
      , x = Dimension.default 650 "Age (years)" .age
      , y = Dimension.default 400 "Weight (kg)" .weight
      , grid = Grid.default
      , areaOpacity = 0
      , intersection = Intersection.default
      , interpolation = Lines.linear
      , line = Line.default
      , dot = Dot.default
      , legends = Legends.default
      , attributes = []
      , events = []
      , junk = Junk.none
      }

_See the full example [here](https://ellie-app.com/smkVxrpMfa1/2)._

-}
type alias Config data msg =
  { id : String
  , margin : Coordinate.Margin
  , x : Dimension.Dimension data msg
  , y : Dimension.Dimension data msg
  , grid : Grid.Grid
  , intersection : Intersection.Intersection
  , interpolation : Interpolation
  , areaOpacity : Float
  , line : Line.Look data
  , dot : Dot.Look data
  , legends : Legends.Legends msg
  , attributes : List (Svg.Attribute msg)
  , events : Events.Events data msg
  , junk : Junk.Junk msg
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


{-|

** Customize everything **

See the `Config` type for information about the available customizations
... or copy the example below if you're lazy. No one will tell.

** Example customiztion **

The example below adds color to the area below the lines.

    chart : Html msg
    chart =
      Lines.viewCustom chartConfig
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice
        , Lines.line "darkturquoise" Dot.diamond "Bob" bob
        , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

    chartConfig : Config Info msg
    chartConfig =
      { id = "chart"
      , margin = Coordinate.Margin 30 120 90 120
      , x = Dimension.default 650 "Age (years)" .age
      , y = Dimension.default 400 "Weight (kg)" .weight
      , grid = Grid.default
      , areaOpacity = 0.25 -- Changed from the default!
      , intersection = Intersection.default
      , interpolation = Lines.linear
      , line = Line.default
      , dot = Dot.default
      , legends = Legends.default
      , attributes = []
      , events = []
      , junk = Junk.none
      }


_See the full example [here](https://ellie-app.com/smkVxrpMfa1/2)._


** Speaking of area charts **

Remember that area charts are for data chart
where the area under the curve _matters_. Typically, this would be when you
have an quantity changing with respect to time. In that case, the area under
the curve shows how much the quantity changed. However if that amount is not
significant, it's best to leave it out.

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

    allDataPoints =
      List.concat dataPoints

    -- System
    system =
      toSystem config allDataPoints

    -- View
    junk =
      Internal.Junk.getLayers config.junk system
        |> Internal.Junk.addGrid (Grid.view system config.x config.y config.grid)

    container plot =
      Html.div [] (plot :: junk.html)

    attributes =
      List.concat
        [ config.attributes
        , Events.toAttributes allDataPoints system config.events
        , [ Attributes.width <| toString system.frame.size.width
          , Attributes.height <| toString system.frame.size.height
          ]
        ]

    viewLines =
      List.map2 viewLine lines dataPoints

    viewLine =
      Line.view system
        config.dot
        config.interpolation
        config.line
        config.areaOpacity
        config.id

    viewLegends =
      Legends.view system
        config.line
        config.dot
        config.legends
        config.areaOpacity
        lines
        dataPoints
  in
  container <|
    Svg.svg attributes
      [ Svg.defs [] [ clipPath config system ]
      , Svg.g [ Attributes.class "chart__junk--below" ] junk.below
      , Svg.g [ Attributes.class "chart__lines" ] viewLines
      , Axis.viewHorizontal system config.intersection config.x.title config.x.axis
      , Axis.viewVertical   system config.intersection config.y.title config.y.axis
      , viewLegends
      , Svg.g [ Attributes.class "chart__junk--above" ] junk.above
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


toSystem : Config data msg -> List (Coordinate.DataPoint data) -> Coordinate.System
toSystem config data =
  let
    isArea = config.areaOpacity > 0
    size   = Coordinate.Size (toFloat config.x.pixels) (toFloat config.y.pixels)
    frame  = Coordinate.Frame config.margin size
    xRange = Coordinate.range (.point >> .x) data
    yRange = Coordinate.range (.point >> .y) data

    system =
      { frame = frame
      , x = xRange
      , y = adjustDomainRange yRange
      , xData = xRange
      , yData = yRange
      }

    adjustDomainRange domain =
      if isArea
        then Coordinate.ground domain
        else domain
  in
  { system
  | x = Range.applyX config.x.range system
  , y = Range.applyY config.y.range system
  }



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { id = "chart"
  , margin = Coordinate.Margin 30 120 90 120
  , x = Dimension.default 650 "" toX
  , y = Dimension.default 400 "" toY
  , grid = Grid.default
  , areaOpacity = 0
  , intersection = Intersection.default
  , interpolation = linear
  , line = Line.default
  , dot = Dot.default
  , legends = Legends.default
  , attributes = [ Attributes.style "font-family: monospace;" ] -- TODO: Maybe remove
  , events = Events.default
  , junk = Junk.none
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
