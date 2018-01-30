module BrokenData exposing (main)


import Html
import Html.Attributes exposing (class)
import Color
import LineChart
import LineChart.Dots as Dots
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Title as Title
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.viewCustom
      { y =
        Axis.custom
          { title = Title.default ( 0, 0 ) "Weight"
          , variable = .income -- as opposed to `Just << .weight`
          , pixels = 450
          , range = Range.default
          , axisLine = AxisLine.default
          , ticks = Ticks.default
          }
      , x = Axis.default 700 "Age" .age
      , container = Container.default "line-chart-1"
      , interpolation = Interpolation.monotone
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.default
      , line = Line.default
      , dots = Dots.default
      }
      [ LineChart.line Color.red Dots.diamond "Alice" alice
      , LineChart.line Color.blue Dots.circle "Bob" bob
      , LineChart.line Color.green Dots.plus "Chuck" chuck
      ]



-- DATA


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Maybe Float -- This is now a Maybe!
  }


alice : List Info
alice =
  [ Info 10 34 1.34 (Just 0)
  , Info 16 42 1.62 (Just 3000)
  , Info 25 75 1.73 (Just 25000)
  , Info 43 83 1.75 (Just 40000)
  , Info 53 83 1.75 (Just 80000)
  ]


bob : List Info
bob =
  [ Info 10 38 1.32 (Just 0)
  , Info 17 69 1.75 (Just 2000)
  , Info 25 75 1.87 (Just 32000)
  , Info 43 77 1.87 (Just 52000)
  , Info 53 77 1.87 (Just 82000)
  ]


chuck : List Info
chuck =
  [ Info 10 42 1.35 (Just 0)
  , Info 15 72 1.72 (Just 1800)
  , Info 20 72 1.72 (Just 90800)
  , Info 25 89 1.83 Nothing
  , Info 43 95 1.84 (Just 120000)
  , Info 53 95 1.84 (Just 130000)
  ]
