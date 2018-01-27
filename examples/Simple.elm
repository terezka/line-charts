module Simple exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart1, chart2, chart3 ]


chart1 : Html.Html msg
chart1 =
  LineChart.view1 .x .y data1


chart2 : Html.Html msg
chart2 =
  LineChart.view2 .x .y data1 data2


chart3 : Html.Html msg
chart3 =
  LineChart.view3 .x .y data1 data2 data3



-- DATA


type alias Point =
  { x : Float, y : Float }


data1 : List Point
data1 =
  [ Point 1 2, Point 6 4, Point 10 10 ]


data2 : List Point
data2 =
  [ Point 1 5, Point 6 9, Point 10 7 ]


data3 : List Point
data3 =
  [ Point 1 3, Point 6 2, Point 10 11 ]
