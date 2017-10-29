module LinesExample exposing (main)

import Svg exposing (Svg, Attribute, g, text, text_)
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Container as Container


main : Svg msg
main =
  Lines.viewCustom
    { container = Container.default
    , junk = Junk.none
    , y = Lines.Axis Axis.defaultLook .heartattacks
    , x = Lines.Axis Axis.defaultLook .magnesium
    , interpolation = Lines.Linear
    }
    [ Lines.line Color.pink 1 Dot.default1 data3
    , Lines.dash Color.pink 2 Dot.default1 "1 4 3" data5
    , Lines.line Color.pink 4 default1Bang data4
    ]


default1Bang : Dot.Dot msg
default1Bang =
  Dot.circle [] 5 (Dot.disconnected 3)


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
  , Data 5 6
  ]


data4 : List Data
data4 =
  [ Data 5 6
  , Data 6 9
  ]


data5 : List Data
data5 =
  [ Data 6 9
  , Data 7 3
  ]
