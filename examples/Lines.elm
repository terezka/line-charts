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
import Lines.Dimension as Dimension

main : Svg msg
main =
  -- Lines.view3 .magnesium .heartattacks data1 data2 data3_a
  Lines.viewCustom
    { margin = Coordinate.Margin 150 150 150 150
    , attributes = [ Attributes.style "font-family: monospace;" ]
    , events = Events.none
    , x = Dimension.time 750 "Time" .date
    , y =
        { title = Title.default "Heart attacks"
        , variable = .heartattacks >> Maybe.map ((+) 10)
        , pixels = 650
        , range = Range.padded 0 20
        , axis = Axis.float 5
        }
    , intersection = Intersection.default
    , junk = Junk.none
    , interpolation = Lines.steppedAfter
    , legends = Legends.default
    , line = Line.default
    , dot = Dot.static (Dot.bordered 10 2)
    , grid = Grid.lines 1 Color.grayLight
    , area = Area.stacked 0.5
    , id = "chart"
    }
    [ Lines.line Color.pink Dot.none "1" data1
    , Lines.line Color.orange Dot.none "2" data2
    , Lines.line Color.blue Dot.none "3" data3_a
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
  , heartattacks : Maybe Float
  , date : Float
  }


data1 : List Data
data1 =
  [ Data 1 (Just 1) (269810504300 + (1 + 0) * 3600000)
  , Data 2 (Just 2) (269810504300 + (1 + 1) * 3600000)
  , Data 3 (Just 4) (269810504300 + (1 + 2) * 3600000)
  , Data 9 (Just 2) (269810504300 + (1 + 3) * 3600000)
  , Data 8 (Just 5) (269810504300 + (1 + 4) * 3600000)
  , Data 8 (Just 1) (269810504300 + (1 + 5) * 3600000)
  , Data 2 (Just 3) (269810504300 + (1 + 6) * 3600000)
  , Data 3 (Just 3) (269810504300 + (1 + 7) * 3600000)
  , Data 9 (Just 8) (269810504300 + (1 + 8) * 3600000)
  ]


data2 : List Data
data2 =
  [ Data 2 (Just 1) (269810504300 + (1 + 0) * 3600000)
  , Data 3 (Just 2) (269810504300 + (1 + 1) * 3600000)
  , Data 4 (Just 3) (269810504300 + (1 + 2) * 3600000)
  , Data 5 (Just 2) (269810504300 + (1 + 3) * 3600000)
  , Data 4 (Nothing) (269810504300 + (1 + 4) * 3600000)
  , Data 6 (Just 3) (269810504300 + (1 + 5) * 3600000)
  , Data 4 (Just 5) (269810504300 + (1 + 6) * 3600000)
  , Data 9 (Just 8) (269810504300 + (1 + 7) * 3600000)
  , Data 4 (Just 3) (269810504300 + (1 + 8) * 3600000)
  ]


data3_a : List Data
data3_a =
  [ Data 2 (Just 1) (269810504300 + (1 + 0) * 3600000)
  , Data 3 (Just 2) (269810504300 + (1 + 1) * 3600000)
  , Data 4 (Just 2) (269810504300 + (1 + 2) * 3600000)
  , Data 5 (Just 1) (269810504300 + (1 + 3) * 3600000)
  , Data 8 (Just 4) (269810504300 + (1 + 4) * 3600000)
  , Data 8 (Just 6) (269810504300 + (1 + 5) * 3600000)
  , Data 2 (Just 9) (269810504300 + (1 + 6) * 3600000)
  , Data 3 (Just 7) (269810504300 + (1 + 7) * 3600000)
  , Data 9 (Just 3) (269810504300 + (1 + 8) * 3600000)
  ]
