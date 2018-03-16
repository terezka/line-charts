module BrokenData exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart
import LineChart.Dots as Dots
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Colors as Colors
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
          { title = Title.default "Weight"
          , variable = .income -- or .weight -- as opposed to `Just << .height`
          , pixels = 450
          , range = Range.default
          , axisLine = AxisLine.default
          , ticks = Ticks.default
          }
      , x = Axis.default 700 "Age" .age
      , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
      , interpolation = Interpolation.linear
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.default
      , line = Line.default
      , dots = Dots.default
      }
      [ LineChart.line Colors.gold Dots.diamond "Alice" alice
      , LineChart.line Colors.pink Dots.circle "Bobby" bobby
      , LineChart.line Colors.blue Dots.plus "Chuck" chuck
      ]



-- DATA


type alias Info =
  { age : Float
  , weight : Maybe Float
  , height : Float
  , income : Maybe Float -- This is now a Maybe!
  }


alice : List Info
alice =
  [ Info 10 (Just 34) 1.34 (Just 0)
  , Info 16 (Just 42) 1.62 (Just 3000)
  , Info 22 (Just 75) 1.73 (Just 25000)
  , Info 25 (Just 75) 1.73 (Just 25000)
  , Info 43 (Just 83) 1.75 (Just 40000)
  , Info 53 (Just 83) 1.75 (Just 80000)
  ]


bobby : List Info
bobby =
  [ Info 10 (Just 38) 1.32 (Just 0)
  , Info 16 (Just 69) 1.75 (Just 2000)
  , Info 22 (Nothing) 1.87 (Just 31000)
  , Info 25 (Nothing) 1.87 (Just 32000)
  , Info 43 (Just 77) 1.87 (Just 52000)
  , Info 53 (Just 77) 1.87 (Just 82000)
  ]


chuck : List Info
chuck =
  [ Info 10 (Just 42) 1.35 (Just 0)
  , Info 16 (Just 72) 1.72 (Just 1800)
  , Info 22 (Just 82) 1.72 (Just 90800)
  , Info 25 (Just 82) 1.72 (Nothing)
  , Info 43 (Just 95) 1.84 (Just 120000)
  , Info 53 (Just 95) 1.84 (Just 130000)
  ]
