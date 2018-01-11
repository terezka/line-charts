module LinesExample exposing (main)

import Svg exposing (Svg, Attribute, g, text, text_)
import Svg.Attributes as Attributes
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Area as Area
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Axis.Tick as Tick
import Lines.Axis.Title as Title
import Lines.Axis.Range as Range
import Lines.Axis.Intersection as Intersection
import Lines.Coordinate as Coordinate
import Lines.Events as Events
import Lines.Legends as Legends
import Lines.Line as Line
import Lines.Legends as Legends
import Lines.Grid as Grid


main : Svg msg
main =
  -- Lines.view3 .magnesium .heartattacks data1 data2 data3_a
  Lines.viewCustom
    { margin = Coordinate.Margin 150 150 150 150
    , attributes = [ Attributes.style "font-family: monospace;" ]
    , events = Events.none
    , x =
        { title = Title.default "Time"
        , variable = .date
        , pixels = 750
        , range = Range.padded 30 10
        , axis = Axis.time 10
        }
    , y =
        { title = Title.default "Heart attacks"
        , variable = .heartattacks
        , pixels = 750
        , range = Range.padded 30 10
        , axis = Axis.float 10
        }
    , intersection = Intersection.default
    , junk = Junk.none
    , interpolation = Lines.monotone
    , legends = Legends.default
    , line = Line.default
    , dot = Dot.default
    , grid = Grid.lines 1 Color.grayLight
    , area = Area.stacked
    , id = "chart"
    }
    [ Lines.line Color.blue Dot.circle "1" data1
    , Lines.line Color.pink Dot.circle "2" data2
    , Lines.line Color.orange Dot.circle "3" data3_a
    ]




timeTick : Tick.Time -> Tick.Tick msg
timeTick time =
  let tick = Tick.time time in
  if time.change == Nothing then
    { tick | label = Just <| Junk.text Color.gray (Tick.format time) }
  else
    tick



-- DATA


type alias Data =
  { magnesium : Float
  , heartattacks : Float
  , date : Float
  }


data1 : List Data
data1 =
  [ Data 1 1 (269810504300 + (1 + 0) * 3600000)
  , Data 2 1 (269810504300 + (1 + 1) * 3600000)
  , Data 3 1 (269810504300 + (1 + 2) * 3600000)
  , Data 9 1 (269810504300 + (1 + 3) * 3600000)
  ]


data2 : List Data
data2 =
  [ Data 2 1 (269810504300 + (1 + 0) * 3600000)
  , Data 3 2 (269810504300 + (1 + 1) * 3600000)
  , Data 4 3 (269810504300 + (1 + 2) * 3600000)
  , Data 5 2 (269810504300 + (1 + 3) * 3600000)
  ]


data3_a : List Data
data3_a =
  [ Data 2 1 (269810504300 + (1 + 0) * 3600000)
  , Data 3 2 (269810504300 + (1 + 1) * 3600000)
  , Data 4 2 (269810504300 + (1 + 2) * 3600000)
  , Data 5 1 (269810504300 + (1 + 3) * 3600000)
  ]


data3_b : List Data
data3_b =
  [ Data 6 3.6 (269810504300 + (1 + 4) * 3600000)
  , Data 7 3.7 (269810504300 + (1 + 5) * 3600000)
  , Data 9 3.6 (269810504300 + (1 + 6) * 3600000)
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
