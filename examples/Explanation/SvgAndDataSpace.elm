module Explanation.Ranges exposing (main)


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
    { y = Axis.picky 500 "y" .y [ 0, 3 ]
    , x = Axis.picky 700 "x" .x [ 0, 3 ]
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.custom customJunk
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.none "some data" data
    ]


customJunk : Coordinate.System -> Junk.Layers msg
customJunk system =
  let
    dataLabel point =
      Junk.labelAt system point.x point.y 12  5 "start"

    svgLabel point =
      Junk.labelAt system point.x point.y 12 25 "start"

    circle point =
      Junk.circle system 3 Colors.cyan point.x point.y

    dataSpace point =
      "Data-space: " ++ pointToString point

    svgSpace point =
      "SVG-space: " ++ pointToString point

    pointData1 = Coordinate.Point 0 3
    pointSvg1 = Coordinate.toSvg system pointData1

    pointData2 = Coordinate.Point 0 0
    pointSvg2 = Coordinate.toSvg system pointData2

    pointData3 = Coordinate.Point 3 0
    pointSvg3 = Coordinate.toSvg system pointData3
  in
  { below = []
  , above =
      [ dataLabel pointData1 Color.black (dataSpace pointData1)
      , svgLabel pointData1 Color.black (svgSpace pointSvg1)
      , circle pointData1
      --
      , dataLabel pointData2 Color.black (dataSpace pointData2)
      , svgLabel pointData2 Color.black (svgSpace pointSvg2)
      , circle pointData2
      --
      , dataLabel pointData3 Color.black (dataSpace pointData3)
      , svgLabel pointData3 Color.black (svgSpace pointSvg3)
      , circle pointData3
      ]
  , html = []
  }


pointToString : Coordinate.Point -> String
pointToString { x, y } =
  let round10 n = toFloat (round (n * 10)) / 10 in
  "( " ++ toString (round10 x) ++ ", " ++ toString (round10 y) ++ " )"



-- DATA


type alias Data =
  { x : Float, y : Float }


data : List Data
data =
  [ Data -1  -5
  , Data  5  5
  ]
