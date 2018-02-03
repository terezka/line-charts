module Docs.LineChart.Example2 exposing (main)


import Html
import LineChart


main : Html.Html msg
main =
  chart


type alias Human =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


chart : Html.Html msg
chart =
  LineChart.view1 .age .weight -- Try changing to .height or bmi
    [ Human  4 24 0.94 0
    , Human 25 75 1.73 25000
    , Human 43 83 1.75 40000
    ]


bmi : Human -> Float
bmi human =
  human.weight / human.height ^ 2
