module Docs.LineChart.Example3 exposing (main)


import Html
import LineChart


main : Html.Html msg
main =
  chart


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


chart : Html.Html msg
chart =
  LineChart.view2 .age .weight alice chuck


alice : List Data
alice =
  [ Data 4 24 0.94 0
  , Data 25 75 1.73 25000
  , Data 43 83 1.75 40000
  ]


chuck : List Data
chuck =
  [ Data 4 21 0.98 0
  , Data 25 89 1.83 85000
  , Data 43 95 1.84 120000
  ]
