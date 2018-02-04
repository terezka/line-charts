module Lines exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart
import LineChart.Dots as Dots
import Color


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.view .age .height
    [ LineChart.line Color.red Dots.diamond "Alice" alice
    , LineChart.line Color.blue Dots.circle "Bobby" bobby
    , LineChart.line Color.green Dots.plus "Chuck" chuck
    ]



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
