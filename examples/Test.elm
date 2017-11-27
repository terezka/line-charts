module Test exposing (..)


import Html exposing (Html)
import Svg.Attributes as Attributes
import Lines
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Dot as Dot
import Lines.Events as Events
import Lines.Junk as Junk exposing (..)
import Lines.Legends as Legends
import Lines.Line as Line


main : Html msg
main =
  humanChart


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }

alice : List Info
alice =
  [ Info 4 24 0.94 0
  , Info 25 75 1.73 25000
  , Info 43 83 1.75 40000
  ]

bob : List Info
bob =
  [ Info 4 22 1.01 0
  , Info 25 75 1.87 28000
  , Info 43 77 1.87 52000
  ]

chuck : List Info
chuck =
  [ Info 4 21 0.98 0
  , Info 25 89 1.83 85000
  , Info 43 95 1.84 120000
  ]

humanChart : Html msg
humanChart =
  Lines.view .age .income
    [ Lines.line "red" Dot.cross "Alice" alice
    , Lines.line "blue" Dot.diamond "Bob" bob
    , Lines.line "green" Dot.circle "Chuck" chuck
    ]


chartConfig : (data -> Float) -> (data -> Float) -> Lines.Config data msg
chartConfig toXValue toYValue =
  { frame = Coordinate.Frame (Coordinate.Margin 40 150 90 150) (Coordinate.Size 650 400)
  , attributes = [ Attributes.style "font-family: monospace;" ] -- Changed from the default!
  , events = Events.none
  , junk = Junk.none
  , x = Axis.default (Axis.defaultTitle "" 0 0) toXValue
  , y = Axis.default (Axis.defaultTitle "" 0 0) toYValue
  , interpolation = Lines.linear
  , legends = Legends.default
  , line = Line.default
  , dot = Dot.default
  }


diabetesChart : Html msg
diabetesChart =
  Lines.viewCustom (chartConfig .year .riskOfDiabetes)
    [ Lines.line "pink" Dot.square "U.S." healthDataUSA
    , Lines.dash "darkviolet" Dot.none "Avg." [ 2, 3 ] healthDataAvg
    ]

type alias Health =
  { year : Float
  , riskOfDiabetes : Float
  }


healthDataUSA : List Health
healthDataUSA =
  [ Health 1950 0.02, Health 2000 0.04, Health 2005 0.12, Health 2010 0.19 ]

healthDataAvg : List Health
healthDataAvg =
  [ Health 1950 0.01, Health 2000 0.02, Health 2005 0.09, Health 2010 0.12 ]


bmi : Info -> Float
bmi person =
  person.weight / person.height ^ 2
