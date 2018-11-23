module Junk exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import Svg.Attributes as SvgA
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Coordinate as Coordinate
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
    , junk = Junk.custom junk -- Junk goes here!
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Color.orange Dots.triangle "Chuck" chuck
    , LineChart.line Color.yellow Dots.circle "Bobby" bobby
    , LineChart.line Color.purple Dots.diamond "Alice" alice
    ]


junk : Coordinate.System -> Junk.Layers msg
junk system =
  { below = [ sectionBand system, picassoQuote system ]
  , above = [ picassoImage system ]
  , html = []
  }


picassoImage : Coordinate.System -> Svg msg
picassoImage system =
  let
    x =
      10 + Coordinate.toSvgX system system.x.max

    y =
      70 + Coordinate.toSvgY system system.y.max
  in
  Svg.image
    [ SvgA.xlinkHref picassoImageLink
    , SvgA.x (String.fromFloat x)
    , SvgA.y (String.fromFloat y)
    , SvgA.height "100px"
    , SvgA.width "100px"
    ]
    []


picassoImageLink : String
picassoImageLink =
  "https://s-media-cache-ak0.pinimg.com/originals/fe/a5/51/fea551e5d80a2472b6623fcfb308f661.jpg"


picassoQuote : Coordinate.System -> Svg msg
picassoQuote system =
  Svg.g
    [ Junk.transform [ Junk.move system 15 70 ] ]
    [ Junk.label Color.black "Computers are useless. They only give you answers." ]


sectionBand : Coordinate.System -> Svg msg
sectionBand system =
  Junk.rectangle system [ SvgA.fill "#b6b6b61a" ] 30 40 system.y.min system.y.max



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
