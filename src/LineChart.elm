module LineChart exposing
  ( view1, view2, view3
  , view, Series, line, dash
  , viewCustom, Config
  )

{-|

# Quick start
@docs view1, view2, view3

# Customizing lines
@docs view, Series, line, dash

# Customizing everything
@docs viewCustom, Config

-}

import Html
import Html.Attributes
import Svg
import Svg.Attributes as Attributes
import LineChart.Colors as Colors
import LineChart.Junk as Junk
import LineChart.Interpolation as Interpolation
import Internal.Area as Area
import Internal.Axis as Axis
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Range as Range
import Internal.Container as Container
import Internal.Coordinate as Coordinate
import Internal.Dots as Dots
import Internal.Data as Data
import Internal.Grid as Grid
import Internal.Events as Events
import Internal.Junk
import Internal.Legends as Legends
import Internal.Line as Line
import Internal.Utils as Utils
import Color

-- TODO
-- First tick should format as "changed" (for time)
-- SVG vs Svg



-- VIEW / SIMPLE


{-|

** Show a line chart **

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      LineChart.view1 .x .y
        [ Point 0 2, Point 5 5, Point 10 10 ]

_See the full example [here](https://ellie-app.com/s5M4fxFwGa1/0)._


** Choosing your variables **

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data structures, like a human with an `age`, `weight`,
`height`, and `income`, we can easily pick which two properties we want to plot:

    aliceChart : Html msg
    aliceChart =
      LineChart.view1 .age .weight
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
      LineChart.view2 .age .weight alice chuck

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
      LineChart.view3 .age .weight alice bob chuck

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
      LineChart.view .age .weight
        [ LineChart.Line "red" Dot.cross "Alice" alice
        , LineChart.Line "blue" Dot.square "Bob" bob
        , LineChart.Line "green" Dot.circle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/sgL9mdF7ra1/1)._

See `viewCustom` for all other customizations.

-}
view : (data -> Float) -> (data -> Float) -> List (Series data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)


{-| -}
type alias Series data =
  Line.Series data


{-|

** Customize a solid line **

Try changing the color or explore all the available dot shapes from `LineChart.Dot`!

    humanChart : Html msg
    humanChart =
      LineChart.view .age .weight
        [ LineChart.Line "darkslateblue" Dot.cross "Alice" alice
        , LineChart.Line "darkturquoise" Dot.diamond "Bob" bob
        , LineChart.Line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

_See the full example [here](https://ellie-app.com/stWdWjqGZa1/0)._


** Regarding the title **

The string title will show up in the legends. If you are interested in
customizing your legends, dot size or line width, check out `viewCustom`.
For now though, I'd recommend you stick to `view` and get your lines and
data right first, and then stepping up the complexity.

 -}
line : Color.Color -> Dots.Shape -> String -> List data -> Series data
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
      LineChart.view .age .weight
        [ LineChart.dash "rebeccapurple" Dot.none "Average" [ 2, 4 ] average
        , LineChart.Line "darkslateblue" Dot.cross "Alice" alice
        , LineChart.Line "darkturquoise" Dot.diamond "Bob" bob
        , LineChart.Line "darkgoldenrod" Dot.triangle "Chuck" chuck
        ]

    -- Try passing different numbers!

_See the full example [here](https://ellie-app.com/syMhqfR8qa1/1)._

** When should I use a dashed line? **

Dashed lines are especially good for visualizing processed data like
averages or predicted values.

-}
dash : Color.Color -> Dots.Shape -> String -> List Float -> List data -> Series data
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
    See `LineChart.Coordinate` for more information and examples.

  - **x**: Customizes your horizontal axis.
    See `LineChart.Dimension` for more information and examples.

  - **y**: Customizes your vertical axis.
    See `LineChart.Dimension` for more information and examples.

  - **grid**: Customizes the style of your grid.
    See `LineChart.Grid` for more information and examples.

  - **areaOpacity**: Determines the opacity of the area under your line.
    The area is always the same color as your line, but the transparency
    can be altered with this property. Takes a number between 0 and 1.

  - **intersection**: Determines where your axes meet.
    See `LineChart.Axis.Intersection` for more information and examples.

  - **interpolation**: Customizes the curve of your LineChart.
    See the `Interpolation` type for more information and examples.

  - **line**: Customizes your lines' width and color.
    See `LineChart.Line` for more information and examples.

  - **dot**: Customizes your dots' size and style.
    See `LineChart.Dots` for more information and examples.

  - **legends**: Customizes your chart's legends.
    See `LineChart.Legends` for more information and examples.

  - **attributes**: Customizes the SVG attributes added to the `svg` element
    containing your chart.

  - **events**: Customizes your chart's events, allowing you easily.
    make your chart interactive (adding tooltips, hover states etc.).
    See `LineChart.Events` for more information and examples.

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.
    See `LineChart.Junk` for more information and examples.


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
      , interpolation = LineChart.Linear
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
  { x : Axis.Config data msg
  , y : Axis.Config data msg
  , container : Container.Config msg
  , intersection : Intersection.Config
  , interpolation : Interpolation.Config
  , legends : Legends.Config data msg
  , events : Events.Config data msg
  , area : Area.Config
  , grid : Grid.Config
  , line : Line.Config data
  , dots : Dots.Config data
  , junk : Junk.Config msg
  }



{-|

** Customize everything **

See the `Config` type for information about the available customizations
... or copy the example below if you're lazy. No one will tell.

** Example customiztion **

The example below adds color to the area below the LineChart.

    chart : Html msg
    chart =
      LineChart.viewCustom chartConfig
        [ LineChart.Line "darkslateblue" Dot.cross "Alice" alice
        , LineChart.Line "darkturquoise" Dot.diamond "Bob" bob
        , LineChart.Line "darkgoldenrod" Dot.triangle "Chuck" chuck
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
      , interpolation = LineChart.Linear
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
viewCustom : Config data msg -> List (Series data) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Data
    data = toDataPoints config lines
    dataSafe = List.map (List.filter .isReal) data
    dataAll = List.concat data
    dataAllSafe = List.concat dataSafe

    -- System
    system =
      toSystem config dataAllSafe

    -- Junk
    junk =
      Internal.Junk.getLayers system config.junk
        |> Internal.Junk.addBelow (Grid.view system config.x config.y config.grid)

    -- View
    viewLines =
      Line.view
        { system = system
        , interpolation = config.interpolation
        , dotsConfig = config.dots
        , lineConfig = config.line
        , area = config.area
        }

    viewLegends =
      Legends.view
        { system = system
        , legends = config.legends
        , x = Axis.variable config.x
        , y = Axis.variable config.y
        , dotsConfig = config.dots
        , lineConfig = config.line
        , area = config.area
        , data = dataSafe
        , lines = lines
        }

    attributes =
      List.concat
        [ Container.properties config.container |> .attributesSVG
        , Events.toContainerAttributes dataAll system config.events
        , [ viewBoxAttribute system ]

        ]
  in
  container config system junk.html <|
    Svg.svg attributes
      [ Svg.defs [] [ clipPath system ]
      , Svg.g [ Attributes.class "chart__junk--below" ] junk.below
      , viewLines lines data
      , chartAreaPlatform config dataAll system
      , Axis.viewHorizontal system config.intersection config.x
      , Axis.viewVertical   system config.intersection config.y
      , viewLegends
      , Svg.g [ Attributes.class "chart__junk--above" ] junk.above
      ]



-- INTERNAL


viewBoxAttribute : Coordinate.System -> Html.Attribute msg
viewBoxAttribute { frame } =
  Attributes.viewBox <|
    "0 0 " ++ toString frame.size.width ++ " " ++ toString frame.size.height


container : Config data msg -> Coordinate.System -> List (Html.Html msg) -> Html.Html msg -> Html.Html msg
container config { frame } junkHtml plot  =
  let
    userAttributes =
      Container.properties config.container |> .attributesHtml

    sizeStyles =
      Container.sizeStyles config.container frame.size.width frame.size.height

    styles =
      Html.Attributes.style <| ( "position", "relative" ) :: sizeStyles
  in
  Html.div (styles :: userAttributes) (plot :: junkHtml)


chartAreaAttributes : Coordinate.System -> List (Svg.Attribute msg)
chartAreaAttributes system =
  [ Attributes.x <| toString system.frame.margin.left
  , Attributes.y <| toString system.frame.margin.top
  , Attributes.width <| toString (Coordinate.lengthX system)
  , Attributes.height <| toString (Coordinate.lengthY system)
  ]


chartAreaPlatform : Config data msg -> List (Data.Data data) -> Coordinate.System -> Svg.Svg msg
chartAreaPlatform config data system =
  let
    attributes =
      List.concat
        [ [ Attributes.fill "transparent" ]
        , chartAreaAttributes system
        , Events.toChartAttributes data system config.events
        ]
  in
  Svg.rect attributes []


clipPath : Coordinate.System ->  Svg.Svg msg
clipPath system =
  Svg.clipPath
    [ Attributes.id (Utils.toChartAreaId system.id) ]
    [ Svg.rect (chartAreaAttributes system) [] ]


toDataPoints : Config data msg -> List (Series data) -> List (List (Data.Data data))
toDataPoints config lines =
  let
    x = Axis.variable config.x
    y = Axis.variable config.y

    data =
      List.map (Line.data >> List.filterMap addPoint) lines

    addPoint datum =
      case ( x datum, y datum ) of
        ( Just x, Just y )   -> Just <| Data.Data datum (Data.Point x y) True
        ( Just x, Nothing )  -> Just <| Data.Data datum (Data.Point x 0) False
        ( Nothing, Just y )  -> Nothing -- TODO not allowed
        ( Nothing, Nothing ) -> Nothing
  in
  case config.area of
    Area.None         -> data
    Area.Normal _     -> data
    Area.Stacked _    -> stack data
    Area.Percentage _ -> normalize (stack data)


stack : List (List (Data.Data data)) -> List (List (Data.Data data))
stack dataset =
  let
    stackBelows dataset result =
      case dataset of
        data :: belows ->
          stackBelows belows <|
            List.foldl addBelows data belows :: result

        [] ->
          result
  in
  List.reverse (stackBelows dataset [])


addBelows : List (Data.Data data) -> List (Data.Data data) -> List (Data.Data data)
addBelows data belows =
  let
    iterate prevD data belows result =
      case ( data, belows ) of
        ( datum :: data, below :: belows ) ->
          if datum.point.x > below.point.x
            then iterate prevD (datum :: data) belows (add below prevD :: result)
            else iterate datum data (below :: belows) result

        ( [], below :: belows ) ->
          if prevD.point.x <= below.point.x
            then iterate prevD [] belows (add below prevD :: result)
            else iterate prevD [] belows (below :: result)

        ( datum :: data, [] ) ->
          result

        ( [], [] ) ->
          result

    add below datum =
      setY below (below.point.y + datum.point.y)
  in
  List.reverse <| Maybe.withDefault [] <| Utils.withFirst data <| \first rest ->
    iterate first rest belows []


-- TODO
normalize : List (List (Data.Data data)) -> List (List (Data.Data data))
normalize dataset =
  case dataset of
    highest :: belows ->
      let
        toPercentage highest datum =
          setY datum (100 * datum.point.y / highest.point.y)
      in
      List.map (List.map2 toPercentage highest) (highest :: belows)

    [] ->
      dataset


setY : Data.Data data -> Float -> Data.Data data
setY datum y =
  Data.Data datum.user (Data.Point datum.point.x y) datum.isReal


toSystem : Config data msg -> List (Data.Data data) -> Coordinate.System
toSystem config data =
  let
    container = Container.properties config.container
    hasArea = Area.hasArea config.area
    size   = Coordinate.Size (Axis.pixels config.x) (Axis.pixels config.y)
    frame  = Coordinate.Frame container.margin size
    xRange = Coordinate.range (.point >> .x) data
    yRange = Coordinate.range (.point >> .y) data

    system =
      { frame = frame
      , x = xRange
      , y = adjustDomainRange yRange
      , xData = xRange
      , yData = yRange
      , id = container.id
      }

    adjustDomainRange domain =
      if hasArea
        then Coordinate.ground domain
        else domain
  in
  { system
  | x = Range.applyX (Axis.range config.x) system
  , y = Range.applyY (Axis.range config.y) system
  }



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { y = Axis.default 400 "" toY
  , x = Axis.default 700 "" toX
  , container = Container.default "line-chart-1"
  , interpolation = Interpolation.default
  , intersection = Intersection.default
  , legends = Legends.default
  , events = Events.default
  , junk = Junk.default
  , grid = Grid.default
  , area = Area.default
  , line = Line.default
  , dots = Dots.default
  }


defaultLines : List (List data) -> List (Series data)
defaultLines =
  List.map4 Line.line defaultColors defaultShapes defaultLabel


defaultColors : List Color.Color
defaultColors =
  [ Colors.pink
  , Colors.blue
  , Colors.gold
  ]


defaultShapes : List Dots.Shape
defaultShapes =
  [ Dots.Circle
  , Dots.Triangle
  , Dots.Cross
  ]


defaultLabel : List String
defaultLabel =
  [ "First"
  , "Second"
  , "Third"
  ]
