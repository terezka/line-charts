module LinesExample exposing (main)

import Svg exposing (Svg, Attribute, g, text, text_)
import Lines as Lines


main : Svg msg
main =
  Lines.viewSimple .magnesium .heartattacks [ data1, data2, data3 ]



-- DATA


type alias Data =
  { magnesium : Float
  , heartattacks : Float
  }


data1 : List Data
data1 =
  [ Data 1 4
  , Data 2 7
  , Data 3 6
  , Data 9 3
  ]


data2 : List Data
data2 =
  [ Data 2 2
  , Data 3 4
  , Data 4 6
  , Data 5 8
  ]


data3 : List Data
data3 =
  [ Data 2 5
  , Data 3 2
  , Data 4 8
  , Data 5 4
  ]
