module CustomLines exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart
import LineChart.Dots as Dots
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Colors as Colors
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
    { y = Axis.default 450 "Weight" .weight
    , x = Axis.default 700 "Age" .age
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area =
        -- Try out these different configs!
        -- Area.default
        -- Area.normal 0.5
        Area.stacked 0.5
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.triangle "Chuck" chuck
    , LineChart.line Colors.blue Dots.circle "Bobby" bobby
    , LineChart.line Colors.cyan Dots.diamond "Alice" alice
    ]



-- DATA


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Info
alice =
  [ Info 10 34 1.34 0
  , Info 16 42 1.62 3000
  , Info 25 75 1.73 25000
  , Info 43 83 1.75 40000
  ]


bobby : List Info
bobby =
  [ Info 10 38 1.32 0
  , Info 17 69 1.75 2000
  , Info 25 75 1.87 32000
  , Info 43 77 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 10 42 1.35 0
  , Info 15 72 1.72 1800
  , Info 25 89 1.83 85000
  , Info 43 95 1.84 120000
  ]
