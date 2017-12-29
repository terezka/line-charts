module LinesExample exposing (main)

import Svg exposing (Svg, Attribute, g, text, text_)
import Svg.Attributes as Attributes
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Coordinate as Coordinate
import Lines.Events as Events
import Lines.Legends as Legends
import Lines.Line as Line
import Lines.Legends as Legends


main : Svg msg
main =
  Lines.view1 .magnesium .heartattacks data1




-- DATA


type alias Data =
  { magnesium : Float
  , heartattacks : Float
  , date : Float
  }


data1 : List Data
data1 =
  [ Data 1 0.00034 (269810504300 + (1 + 0) * 30 * 24 * 3 * 3600000)
  , Data 2 0.00037 (269810504300 + (1 + 1) * 30 * 24 * 3 * 3600000)
  , Data 3 0.00036 (269810504300 + (1 + 2) * 30 * 24 * 3 * 3600000)
  , Data 9 0.00033 (269810504300 + (1 + 3) * 30 * 24 * 3 * 3600000)
  ]


data2 : List Data
data2 =
  [ Data 2 0.00032 (269810504300 + (1 + 0) * 30 * 24 * 3 * 3600000)
  , Data 3 0.00034 (269810504300 + (1 + 1) * 30 * 24 * 3 * 3600000)
  , Data 4 0.00036 (269810504300 + (1 + 2) * 30 * 24 * 3 * 3600000)
  , Data 5 0.00038 (269810504300 + (1 + 3) * 30 * 24 * 3 * 3600000)
  ]


data3 : List Data
data3 =
  [ Data 2 0.00035 (269810504300 + (1 + 0) * 30 * 24 * 3 * 3600000)
  , Data 3 0.00032 (269810504300 + (1 + 1) * 30 * 24 * 3 * 3600000)
  , Data 4 0.00038 (269810504300 + (1 + 2) * 30 * 24 * 3 * 3600000)
  , Data 5 0.00036 (269810504300 + (1 + 3) * 30 * 24 * 3 * 3600000)
  ]


data3_5 : List Data
data3_5 =
  [ Data 6 0.00036 (269849424300 + 4 * 2 * 3600000)
  , Data 7 0.00036 (269849424300 + 5 * 2 * 3600000)
  ]


data4 : List Data
data4 =
  [ Data 5 6 (1512495283 + 2 * 28 * 24 * 3633400)
  , Data 6 9 (1512495283 + 3 * 28 * 24 * 3633400)
  ]


data5 : List Data
data5 =
  [ Data 6 9 (1512495283 + 2 * 2 * 3600000)
  , Data 7 3 (1512495283 + 3 * 2 * 3600000)
  ]
