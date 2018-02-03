module Docs.LineChart.Example1 exposing (main)


import Html
import LineChart


main : Html.Html msg
main =
  chart


type alias Point =
  { x : Float, y : Float }


chart : Html.Html msg
chart =
  LineChart.view1 .x .y
    [ Point 1 2, Point 5 5, Point 10 10 ]
