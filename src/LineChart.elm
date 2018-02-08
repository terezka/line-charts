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
import Svg.Attributes

import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Junk as Junk
import LineChart.Dots as Dots
import LineChart.Grid as Grid
import LineChart.Dots as Dots
import LineChart.Line as Line
import LineChart.Colors as Colors
import LineChart.Events as Events
import LineChart.Legends as Legends
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection

import Internal.Area
import Internal.Axis
import Internal.Junk
import Internal.Dots
import Internal.Grid
import Internal.Line
import Internal.Events
import Internal.Legends
import Internal.Container
import Internal.Axis.Range

import Internal.Data as Data
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Color



-- VIEW / SIMPLE


{-|

** Show a line chart **

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      LineChart.view1 .x .y
        [ Point 0 2, Point 5 5, Point 10 10 ]

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example1.elm)._


** Choosing your variables **

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data structures, like a human with an `age`, `weight`,
`height`, and `income`, we can easily pick which two properties we want to plot:

    chart : Html msg
    chart =
      LineChart.view1 .age .weight
        [ Human  4 24 0.94 0
        , Human 25 75 1.73 25000
        , Human 43 83 1.75 40000
        ]

    -- Try changing .weight to .height


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example2.elm)._


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

    chart : Html msg
    chart =
      LineChart.view2 .age .weight alice chuck

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example3.elm)._

-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-|

** Show a line chart with three lines **

It works just like `view1` and `view2`.

    chart : Html msg
    chart =
      LineChart.view3 .age .weight alice bob chuck

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example4.elm)._

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

    chart : Html msg
    chart =
      LineChart.view .age .height
        [ LineChart.line Colors.purple Dots.cross "Alice" alice
        , LineChart.line Colors.blue Dots.square "Bobby" bobby
        , LineChart.line Colors.green Dots.circle "Chuck" chuck
        ]

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example5.elm)._

See `viewCustom` for all other customizations.

-}
view : (data -> Float) -> (data -> Float) -> List (Series data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)


{-| -}
type alias Series data =
  Internal.Line.Series data


{-|

** Customize a solid line **

Try changing the color or explore all the available dot shapes from `LineChart.Dots`!

    chart : Html msg
    chart =
      LineChart.view .age .weight
        [ LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
        , LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        ]

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example6.elm)._


** Regarding the title **

The string title will show up in the legends. If you are interested in
customizing your legends, dot size or line width, check out `viewCustom`.
For now though, I'd recommend you stick to `view` and get your lines and
data right first, and then stepping up the complexity.

 -}
line : Color.Color -> Dots.Shape -> String -> List data -> Series data
line =
  Internal.Line.line


{-|

** Customize a dashed line **

Works just like `line`, except it takes another argument which is an array of
floats describing your dashing pattern. I'd recommend just typing in
random numbers and see what happends, but alternativelly you can see the SVG `stroke-dasharray`
[documentation](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
for examples of patterns.

    chart : Html msg
    chart =
      LineChart.view .age .height
        [ LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
        , LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        , LineChart.dash Colors.purpleLight Dots.none "Average" [ 4, 2 ] average
        --                                                      ^^^^^^^^
        ]

    -- Try passing different numbers!

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example7.elm)._

** When should I use a dashed line? **

Dashed lines are especially good for visualizing processed data like
averages or predicted values.

-}
dash : Color.Color -> Dots.Shape -> String -> List Float -> List data -> Series data
dash =
  Internal.Line.dash



-- VIEW / CUSTOM


{-|

** Available customizations **

Use with `viewCustom`.

  - **x**: Customizes your horizontal axis.</br>
    _See `LineChart.Axis` for more information and examples._

  - **y**: Customizes your vertical axis.</br>
    _See `LineChart.Axis` for more information and examples._

  - **intersection**: Determines where your axes meet.</br>
    _See `LineChart.Axis.Intersection` for more information and examples._

  - **interpolation**: Customizes the curve of your LineChart.</br>
    _See `LineChart.Interpolation` for more information and examples._

  - **container**: Customizes the container of your chart.</br>
    _See `LineChart.Container` for more information and examples._

  - **legends**: Customizes your chart's legends.</br>
    _See `LineChart.Legends` for more information and examples._

  - **events**: Customizes your chart's events, allowing you to easily
    make your chart interactive (adding tooltips, selection states etc.).</br>
    _See `LineChart.Events` for more information and examples._

  - **grid**: Customizes the style of your grid.</br>
    _See `LineChart.Grid` for more information and examples._

  - **area**: Customizes the area under your line.</br>
    _See `LineChart.Area` for more information and examples._

  - **line**: Customizes your lines' width and color.</br>
    _See `LineChart.Line` for more information and examples._

  - **dots**: Customizes your dots' size and style.</br>
    _See `LineChart.Dots` for more information and examples._

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.</br>
    _See `LineChart.Junk` for more information and examples._


** Example configuration **

A good start would be to copy it and play around with customizations
available for each property.


    chartConfig : Config Info msg
    chartConfig =
      { y = Axis.default 400 "Age" .age
      , x = Axis.default 700 "Weight" .weight
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

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example8.elm)._

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
  , junk : Junk.Config data msg
  }



{-|

** Customize everything **

See the `Config` type for information about the available customizations.
Or copy and play with the example below. No one will tell.

** Example customiztion **

The example below makes the line chart an area chart.

    chart : Html msg
    chart =
      LineChart.viewCustom chartConfig
        [ LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        , LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
        ]

    chartConfig : Config Info msg
    chartConfig =
      { y = Axis.default 400 "Age" .age
      , x = Axis.default 700 "Weight" .weight
      , container = Container.default "line-chart-1"
      , interpolation = Interpolation.default
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.stacked 0.5 -- Changed from the default!
      , line = Line.default
      , dots = Dots.default
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example9.elm)._


** Speaking of area charts **

Remember that area charts are for data where the area under the curve _matters_.
Typically, this would be when you have a quantity accumulating over time.
Think profit over time or velocity over time!
In the case of profit over time, the area under the curve shows the total amount
of money earned in that time frame. However if that amount is not significant,
it's best to leave it out.

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
    junkLineInfo line =
       ( Internal.Line.color config.line line []
       , Internal.Line.label line
       , Internal.Line.data line
       )

    getJunk =
      Internal.Junk.getLayers
        (List.map junkLineInfo lines)
        (Internal.Axis.variable config.x)
        (Internal.Axis.variable config.y)

    addGrid =
      Internal.Junk.addBelow
        (Internal.Grid.view system config.x config.y config.grid)

    junk =
       getJunk system config.junk |> addGrid

    -- View
    viewLines =
      Internal.Line.view
        { system = system
        , interpolation = config.interpolation
        , dotsConfig = config.dots
        , lineConfig = config.line
        , area = config.area
        }

    viewLegends =
      Internal.Legends.view
        { system = system
        , legends = config.legends
        , x = Internal.Axis.variable config.x
        , y = Internal.Axis.variable config.y
        , dotsConfig = config.dots
        , lineConfig = config.line
        , area = config.area
        , data = dataSafe
        , lines = lines
        }

    attributes =
      List.concat
        [ Internal.Container.properties config.container |> .attributesSvg
        , Internal.Events.toContainerAttributes dataAll system config.events
        , [ viewBoxAttribute system ]
        ]
  in
  container config system junk.html <|
    Svg.svg attributes
      [ Svg.defs [] [ clipPath system ]
      , Svg.g [ Svg.Attributes.class "chart__junk--below" ] junk.below
      , viewLines lines data
      , chartAreaPlatform config dataAll system
      , Internal.Axis.viewHorizontal system config.intersection config.x
      , Internal.Axis.viewVertical   system config.intersection config.y
      , viewLegends
      , Svg.g [ Svg.Attributes.class "chart__junk--above" ] junk.above
      ]



-- INTERNAL


viewBoxAttribute : Coordinate.System -> Html.Attribute msg
viewBoxAttribute { frame } =
  Svg.Attributes.viewBox <|
    "0 0 " ++ toString frame.size.width ++ " " ++ toString frame.size.height


container : Config data msg -> Coordinate.System -> List (Html.Html msg) -> Html.Html msg -> Html.Html msg
container config { frame } junkHtml plot  =
  let
    userAttributes =
      Internal.Container.properties config.container |> .attributesHtml

    sizeStyles =
      Internal.Container.sizeStyles config.container frame.size.width frame.size.height

    styles =
      Html.Attributes.style <| ( "position", "relative" ) :: sizeStyles
  in
  Html.div (styles :: userAttributes) (plot :: junkHtml)


chartAreaAttributes : Coordinate.System -> List (Svg.Attribute msg)
chartAreaAttributes system =
  [ Svg.Attributes.x <| toString system.frame.margin.left
  , Svg.Attributes.y <| toString system.frame.margin.top
  , Svg.Attributes.width <| toString (Coordinate.lengthX system)
  , Svg.Attributes.height <| toString (Coordinate.lengthY system)
  ]


chartAreaPlatform : Config data msg -> List (Data.Data data) -> Coordinate.System -> Svg.Svg msg
chartAreaPlatform config data system =
  let
    attributes =
      List.concat
        [ [ Svg.Attributes.fill "transparent" ]
        , chartAreaAttributes system
        , Internal.Events.toChartAttributes data system config.events
        ]
  in
  Svg.rect attributes []


clipPath : Coordinate.System ->  Svg.Svg msg
clipPath system =
  Svg.clipPath
    [ Svg.Attributes.id (Utils.toChartAreaId system.id) ]
    [ Svg.rect (chartAreaAttributes system) [] ]


toDataPoints : Config data msg -> List (Series data) -> List (List (Data.Data data))
toDataPoints config lines =
  let
    x = Internal.Axis.variable config.x
    y = Internal.Axis.variable config.y

    data =
      List.map (Internal.Line.data >> List.filterMap addPoint) lines

    addPoint datum =
      case ( x datum, y datum ) of
        ( Just x, Just y )   -> Just <| Data.Data datum (Data.Point x y) True
        ( Just x, Nothing )  -> Just <| Data.Data datum (Data.Point x 0) False
        ( Nothing, Just y )  -> Nothing -- TODO not allowed
        ( Nothing, Nothing ) -> Nothing
  in
  case config.area of
    Internal.Area.None         -> data
    Internal.Area.Normal _     -> data
    Internal.Area.Stacked _    -> stack data
    Internal.Area.Percentage _ -> normalize (stack data)


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
addBelows data dataBelow =
  let
    iterate datum0 data dataBelow result =
      case ( data, dataBelow ) of
        ( datum1 :: data, datumBelow :: dataBelow ) ->
          -- if the data point is after the point below, add it
          if datum1.point.x > datumBelow.point.x
            then
              if datumBelow.isReal then
                iterate datum0 (datum1 :: data) dataBelow (add datumBelow datum0 :: result)
              else
                let breakdata = { datum0 | isReal = False } in
                iterate datum0 (datum1 :: data) dataBelow (add datumBelow datum0 :: result)
            -- if not, try the next
            else iterate datum1 data (datumBelow :: dataBelow) result

        ( [], datumBelow :: dataBelow ) ->
          -- if the data point is after the point below, add it
          if datum0.point.x <= datumBelow.point.x
            then iterate datum0 [] dataBelow (add datumBelow datum0 :: result)
            -- if not, try the next
            else iterate datum0 [] dataBelow (datumBelow :: result)

        ( datum1 :: data, [] ) ->
          result

        ( [], [] ) ->
          result

    add below datum =
      setY below (below.point.y + datum.point.y)
  in
  List.reverse <| Maybe.withDefault [] <| Utils.withFirst data <| \first rest ->
    iterate first rest dataBelow []


normalize : List (List (Data.Data data)) -> List (List (Data.Data data))
normalize datasets =
  case datasets of
    highest :: belows ->
      let
        toPercentage highest datum =
          setY datum (100 * datum.point.y / highest.point.y)
      in
      List.map (List.map2 toPercentage highest) (highest :: belows)

    [] ->
      datasets


setY : Data.Data data -> Float -> Data.Data data
setY datum y =
  Data.Data datum.user (Data.Point datum.point.x y) datum.isReal


toSystem : Config data msg -> List (Data.Data data) -> Coordinate.System
toSystem config data =
  let
    container = Internal.Container.properties config.container
    hasArea = Internal.Area.hasArea config.area
    size   = Coordinate.Size (Internal.Axis.pixels config.x) (Internal.Axis.pixels config.y)
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
  | x = Internal.Axis.Range.applyX (Internal.Axis.range config.x) system
  , y = Internal.Axis.Range.applyY (Internal.Axis.range config.y) system
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
  List.map4 Internal.Line.line defaultColors defaultShapes defaultLabel


defaultColors : List Color.Color
defaultColors =
  [ Colors.pink
  , Colors.blue
  , Colors.gold
  ]


defaultShapes : List Dots.Shape
defaultShapes =
  [ Internal.Dots.Circle
  , Internal.Dots.Triangle
  , Internal.Dots.Cross
  ]


defaultLabel : List String
defaultLabel =
  [ "First"
  , "Second"
  , "Third"
  ]
