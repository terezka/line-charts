module Docs.Dots.Example2 exposing (main)


import Html
import LineChart
import LineChart.Colors as Colors
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



main : Html.Html msg
main =
  chart


chart : Html.Html msg
chart =
  LineChart.viewCustom
    { x = Axis.default 700 "Age" .age
    , y = Axis.default 400 "Income" .income
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots =
        -- Dots.default
        Dots.custom (Dots.full 8)
    }
    [ LineChart.line Colors.blueLight Dots.square "Chuck" chuck
    , LineChart.line Colors.pinkLight Dots.plus "Alice" alice
    , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
    ]



-- DATA


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Data
alice =
  [ Data 4 24 0.94 0
  , Data 25 75 1.73 25000
  , Data 43 83 1.75 40000
  ]


bobby : List Data
bobby =
  [ Data 4 22 1.01 0
  , Data 25 75 1.87 28000
  , Data 43 77 1.87 52000
  ]


chuck : List Data
chuck =
  [ Data 4 21 0.98 0
  , Data 25 89 1.83 85000
  , Data 43 95 1.84 120000
  ]


average : List Data
average =
  [ Data 4 22.3 1.0 0
  , Data 25 79.7 1.8 46000
  , Data 43 85 1.82 70667
  ]
