module Explanation.ChartArea exposing (main)


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
    , x = Axis.picky 700 "x" .x []
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


customJunk : Junk.Config data msg
customJunk =
  Junk.custom <| \system ->
    { below = [ rectangle system ]
    , above =
        [ Junk.labelAt system 1   1.5 0 0 "middle" Color.black "chart area"
        , Junk.labelAt system 6.25 1.5 0 0 "middle" Color.black "not chart area"
        ]
    , html = []
    }


rectangle : Coordinate.System -> Svg.Svg msg
rectangle system =
  Junk.rectangle system
    [ Svg.Attributes.fill "#aaf8a94d"
    , Svg.Attributes.clipPath ""
    ]
    system.x.min
    system.x.max
    system.y.min
    system.y.max



-- DATA


type alias Data =
  { x : Float, y : Float }


data : List Data
data =
  [ Data -1  -5
  , Data  5  5
  ]
