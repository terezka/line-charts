module LinesExample exposing (main)

import Svg exposing (Svg, Attribute, g, text, text_)
import Svg.Attributes as Attributes
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Axis.Time as AxisTime
import Lines.Coordinate as Coordinate
import Lines.Events as Events
import Lines.Legends as Legends
import Lines.Line as Line
import Lines.Legends as Legends


main : Svg msg
main =
  -- Lines.viewSimple .magnesium .heartattacks [ data1, data2, data3 ]
  Lines.viewCustom
    { margin = Coordinate.Margin 40 150 90 150
    , attributes = [ Attributes.style "font-family: monospace;" ]
    , events = Events.none
    , junk = Junk.none
    , x = AxisTime.default 850 "Time" .date
    , y = Axis.default 400 "Heart attacks" .heartattacks
    , interpolation = Lines.linear
    , legends = Legends.default
    , line = Line.default
    , dot = Dot.default
    , areaOpacity = 0
    , id = "achart"
    }
    [ Lines.line Color.blue Dot.triangle "" data1
    , Lines.line Color.pink Dot.diamond "" data2
    , Lines.line Color.orange Dot.cross "" data3
    ]


-- DATA


type alias Data =
  { magnesium : Float
  , heartattacks : Float
  , date : Float
  }


data1 : List Data
data1 =
  [ Data 1 4 (269849424300 + 0 * 7 * 24 * 3600000)
  , Data 2 7 (269849424300 + 1 * 7 * 24 * 3600000)
  , Data 3 6 (269849424300 + 2 * 7 * 24 * 3600000)
  , Data 9 3 (269849424300 + 3 * 7 * 24 * 3600000)
  ]


data2 : List Data
data2 =
  [ Data 2 2 (269849424300 + 0 * 7 * 24 * 3600000)
  , Data 3 4 (269849424300 + 1 * 7 * 24 * 3600000)
  , Data 4 6 (269849424300 + 2 * 7 * 24 * 3600000)
  , Data 5 8 (269849424300 + 3 * 7 * 24 * 3600000)
  ]


data3 : List Data
data3 =
  [ Data 2 5 (269849424300 + 0 * 7 * 24 * 3600000)
  , Data 3 2 (269849424300 + 1 * 7 * 24 * 3600000)
  , Data 4 8 (269849424300 + 2 * 7 * 24 * 3600000)
  , Data 5 6 (269849424300 + 3 * 7 * 24 * 3600000)
  ]


data3_5 : List Data
data3_5 =
  [ Data 6 6 (269849424300 + 4 * 7 * 24 * 3600000)
  , Data 7 6 (269849424300 + 5 * 7 * 24 * 3600000)
  ]


data4 : List Data
data4 =
  [ Data 5 6 (1512495283 + 2 * 28 * 24 * 3633400)
  , Data 6 9 (1512495283 + 3 * 28 * 24 * 3633400)
  ]


data5 : List Data
data5 =
  [ Data 6 9 (1512495283 + 2 * 3600000)
  , Data 7 3 (1512495283 + 3 * 3600000)
  ]
