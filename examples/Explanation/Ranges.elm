module Explanation.Ranges exposing (main)


import Svg
import Svg.Attributes
import Html
import Html.Attributes exposing (class)
import LineChart
import LineChart.Colors as Colors
import LineChart.Coordinate as Coordinate
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Title as Title
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Color



main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.viewCustom
    { y = Axis.picky 500 "y" .y []
    , x = customAxis
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = customJunk
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.none "some data" data
    ]


customAxis : Axis.Config Data msg
customAxis =
  Axis.custom
    { title = Title.atAxisMax 0 -17 "x"
    , variable = Just << .x
    , pixels = 700
    , range =
        Range.custom <| \{ min, max } ->
          { min = min - 1, max = max + 2 }
    , axisLine = AxisLine.full Colors.gray
    , ticks =
        Ticks.custom <| \dataRange axisRange ->
          List.map (customTick Tick.negative) [ dataRange.min, dataRange.max ] ++
          List.map (customTick Tick.negative) [ axisRange.min, axisRange.max ]
    }


customTick : Tick.Direction -> Float -> Tick.Config msg
customTick direction n =
  let labelNumber = toFloat (round (n * 100)) / 100 in
  Tick.custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 10
    , grid = True
    , direction = direction
    , label = Just <| Junk.label Color.black (toString labelNumber)
    }


customJunk : Junk.Config data msg
customJunk =
  Junk.custom <| \system ->
    { below = []
    , above =
        [ Junk.labelAt system 2  1.5 0 -10 "middle" Color.black "← axis range →"
        , Junk.labelAt system 2 -1.5 0  18 "middle" Color.black "← data range →"
        , rangeLine system  1.5 system.x.min system.x.max
        , rangeLine system -1.5 system.xData.min system.xData.max
        ]
    , html = []
    }


rangeLine : Coordinate.System -> Float -> Float -> Float -> Svg.Svg msg
rangeLine system =
  Junk.horizontalCustom system
    [ Svg.Attributes.stroke "#65d842"
    , Svg.Attributes.clipPath ""
    ]



-- DATA


type alias Data =
  { x : Float, y : Float }


data : List Data
data =
  [ Data -1  -5
  , Data  5  5
  ]
