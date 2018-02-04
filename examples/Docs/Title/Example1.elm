module Docs.Title.Example1 exposing (main)


import Time
import Html
import Svg
import Svg.Attributes
import LineChart
import LineChart.Colors as Colors
import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Title as Title
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Ticks as Ticks
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
    { x = xAxisConfig
    , y = Axis.default 400 "($)" .income
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
    [ LineChart.line Colors.blueLight Dots.square "Chuck" chuck
    , LineChart.line Colors.pinkLight Dots.plus "Alice" alice
    , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
    ]


xAxisConfig : Axis.Config Data msg
xAxisConfig =
  Axis.custom
    { title = titleConfig
    , variable = Just << .weight
    , pixels = 700
    , range = Range.default
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = Ticks.default
    }


titleConfig : Title.Config msg
titleConfig =
  Title.default "Weight"
  -- Title.atAxisMax 0 10 "Weight"
  -- Title.atDataMax 0 10 "Weight"
  -- customTitleConfig
  -- customTitleConfig2


customTitleConfig : Title.Config msg
customTitleConfig =
  let position dataRange axisRange = 80 in
  Title.atPosition position -15 30 "Weight" -- There are default offsets which have to be cancelled out! 😬



--


customTitleConfig2 : Title.Config msg
customTitleConfig2 =
  let position dataRange axisRange = middle axisRange in
  Title.custom position -10 35 <|
    Svg.g
      [ Svg.Attributes.style "text-anchor: middle;" ]
      [ Junk.label Colors.pink "Weight" ]


middle : Coordinate.Range -> Float
middle { min, max } =
  min + (max - min) / 2



-- DATA


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  , date : Time.Time
  }


alice : List Data
alice =
  [ Data 4  24 0.94 0     (dateInterval 0)
  , Data 25 75 1.73 25000 (dateInterval 1)
  , Data 46 83 1.75 40000 (dateInterval 2)
  ]


bobby : List Data
bobby =
  [ Data 4  22 1.01 0     (dateInterval 0)
  , Data 25 75 1.87 28000 (dateInterval 1)
  , Data 46 77 1.87 52000 (dateInterval 2)
  ]


chuck : List Data
chuck =
  [ Data 4  21 0.98 0      (dateInterval 0)
  , Data 25 89 1.83 85000  (dateInterval 1)
  , Data 46 95 1.84 120000 (dateInterval 2)
  ]


average : List Data
average =
  [ Data 4  22.3 1.0  0     (dateInterval 0)
  , Data 25 79.7 1.8  46000 (dateInterval 1)
  , Data 46 85   1.82 70667 (dateInterval 2)
  ]


dateInterval : Int -> Time.Time
dateInterval i =
  4 * year + toFloat i * 21 * year


day : Time.Time
day =
  24 * Time.hour


year : Time.Time
year =
  356 * day
