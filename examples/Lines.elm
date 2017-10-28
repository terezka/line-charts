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
    , interpolation = Lines.Monotone
    }
    [ Lines.line Color.gray 1 Dot.none data1
    , Lines.line Color.blue 2 Dot.none data2
    , Lines.line Color.pink 2 pinkDot data3
    ]


pinkDot : Dot.Dot msg
pinkDot =
  Dot.dot <| Dot.Config Dot.Circle [] 3 (Dot.bordered 2)


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
