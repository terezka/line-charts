module Docs.LineChart.Example6 exposing (main)


import Html
import LineChart
import LineChart.Colors as Colors
import LineChart.Dots as Dots
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
    { x = Axis.picky 700 "" .x [ 0, 1 ]
    , y = Axis.picky 400 "" .y [ 0, 16 ]
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.stacked 0.5
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.red Dots.circle "red" data
    , LineChart.line Colors.redLight Dots.circle "redLight" data
    , LineChart.line Colors.pink Dots.circle "pink" data
    , LineChart.line Colors.pinkLight Dots.circle "pinkLight" data
    , LineChart.line Colors.gold Dots.circle "gold" data
    , LineChart.line Colors.goldLight Dots.circle "goldLight" data
    , LineChart.line Colors.green Dots.circle "green" data
    , LineChart.line Colors.greenLight Dots.circle "greenLight" data
    , LineChart.line Colors.teal Dots.circle "teal" data
    , LineChart.line Colors.tealLight Dots.circle "tealLight" data
    , LineChart.line Colors.cyan Dots.circle "cyan" data
    , LineChart.line Colors.cyanLight Dots.circle "cyanLight" data
    , LineChart.line Colors.blue Dots.circle "blue" data
    , LineChart.line Colors.blueLight Dots.circle "blueLight" data
    , LineChart.line Colors.purple Dots.circle "purple" data
    , LineChart.line Colors.purpleLight Dots.circle "purpleLight" data
    ]


data : List Coordinate.Point
data =
  [ Coordinate.Point 0 1
  , Coordinate.Point 1 1
  ]
