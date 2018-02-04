module Docs.Junk.Example3 exposing (main)

import Html
import Svg
import LineChart
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
import LineChart.Coordinate as Coordinate
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection



main : Html.Html msg
main =
  chart


chart : Html.Html msg
chart =
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" .weight
    , x = Axis.default 700 "Age" .age
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.custom junk
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.blue Dots.triangle "Chuck" chuck
    , LineChart.line Colors.cyan Dots.circle "Bobby" bobby
    , LineChart.line Colors.pink Dots.diamond "Alice" alice
    ]


junk : Coordinate.System -> Junk.Layers msg
junk system =
  { below = []
  , above = [ movedStuff system ]
  , html = []
  }


someDataPoint : Data
someDataPoint =
  Data 25 73 1.73 25000


movedStuff : Coordinate.System -> Svg.Svg msg
movedStuff system =
  Svg.g
    [ Junk.transform
        [ Junk.move system someDataPoint.age someDataPoint.weight
        , Junk.offset 20 10
        -- Try changing the offset!
        ]
    ]
    [ Junk.label Colors.blue "stuff" ]



-- DATA


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Data
alice =
  [ Data 10 34 1.34 0
  , Data 16 42 1.62 3000
  , Data 25 73 1.73 25000
  , Data 43 83 1.75 40000
  ]


bobby : List Data
bobby =
  [ Data 10 38 1.32 0
  , Data 17 69 1.75 2000
  , Data 25 76 1.87 32000
  , Data 43 77 1.87 52000
  ]


chuck : List Data
chuck =
  [ Data 10 42 1.35 0
  , Data 15 72 1.72 1800
  , Data 25 89 1.83 85000
  , Data 43 95 1.84 120000
  ]
