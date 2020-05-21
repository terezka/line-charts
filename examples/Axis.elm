module Axis exposing (main)


import Html
import Html.Attributes exposing (class)
import Svg
import Svg.Attributes as SvgA
import LineChart
import LineChart.Dots as Dots
import LineChart.Junk as Junk exposing (..)
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Title as Title
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Values as Values
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Color
import Time


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" .weight
    , x =
        -- Try out these different configs!
        -- Axis.default 700 "Age" .age
        -- Axis.full 700 "Age" .age
        Axis.time Time.utc 700 "Date" (toFloat << Time.posixToMillis << .date)
        -- customAxis
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.rust Dots.triangle "Chuck" chuck
    , LineChart.line Colors.strongBlue Dots.circle "Bobby" bobby
    , LineChart.line Colors.purple Dots.diamond "Alice" alice
    ]


customAxis : Axis.Config Info msg
customAxis =
  Axis.custom
    { title = Title.default "Age"
    , variable = Just << .age -- Try changing to .date and use Ticks.time!
    , pixels = 700
    , range =
        Range.padded 20 20
        -- Range.padded 0 10
        -- Range.padded 10 0
    , axisLine =
        AxisLine.rangeFrame Color.gray
        -- AxisLine.full
        -- AxisLine.none
        -- customAxisLine
    , ticks =
        Ticks.float 7
        -- Ticks.floatCustom 7 customFloatTick
        -- Ticks.int 7 -- Only show's integers!
        -- Ticks.intCustom 7 customIntTick
        -- Ticks.time 5 -- Try with the variable being .date!
        -- Ticks.timeCustom 7 customTimeTick
        -- customTicks
    }


customAxisLine : AxisLine.Config msg
customAxisLine =
  AxisLine.custom <| \dataRange range ->
    { color = Color.orange
    , width = 2
    , events = [ SvgA.style "pointer-events: none;" ]
    , start = 15 -- try range.min
    , end = 35   -- try dataRange.min
    }


customFloatTick : Float -> Tick.Config msg
customFloatTick position =
  Tick.custom
    { position = position
    , color = Color.orange
    , width = 2
    , length = 8
    , grid =
        -- True adds a grid line!
        False
    , direction =
        Tick.negative
        -- Tick.positive
    , label =
        -- Junk.label just produces a SVG! Try using your own SVG markup!
        Just <|
          Junk.label Color.blue (String.fromFloat position)
          -- customLabel position
    }


customLabel : Float -> Svg.Svg msg
customLabel position =
  Svg.g []
    [ Svg.text_
      [ SvgA.fill "#717171"
      , SvgA.style "pointer-events: none;"
      ]
      [ Svg.tspan [] [ Svg.text (String.fromFloat position) ] ]
    , Svg.circle
      [ SvgA.cx "15"
      , SvgA.cy "-10"
      , SvgA.r "3"
      , SvgA.fill <| if Basics.remainderBy 2 (round position) == 0 then "pink" else "lightblue"
      ]
      []
    ]


customIntTick : Int -> Tick.Config msg
customIntTick position =
  Tick.custom
    { position = toFloat position
    , color = Color.orange
    , width = 2
    , length = 8
    , grid = False
    , direction = Tick.positive
    , label = Just <| Junk.label Color.green (String.fromInt position)
    }


customTimeTick : Tick.Time -> Tick.Config msg
customTimeTick info =
  let
    label =
      Tick.format info
      -- customFormat info
      -- customFormat2 info
  in
  Tick.custom
    { position = toFloat (Time.posixToMillis info.timestamp)
    , color = Color.orange
    , width = 2
    , length = 8
    , grid = False
    , direction = Tick.positive
    , label = Just <| Junk.label Color.green label
    }


customFormat : Tick.Time -> String
customFormat info =
  case info.interval.unit of
    Tick.Millisecond -> "ms" -- TODO format info.timestamp here!
    Tick.Second      -> "s"
    Tick.Minute      -> "m"
    Tick.Hour        -> "h"
    Tick.Day         -> "d"
    Tick.Month       -> "m"
    Tick.Year        -> "y"


customFormat2 : Tick.Time -> String
customFormat2 info =
  case info.change of
    Just change -> customFormatChange info
    Nothing     -> customFormat info


customFormatChange : Tick.Time -> String
customFormatChange info =
  case info.interval.unit of
    Tick.Millisecond -> "new ms!"
    Tick.Second      -> "new s!"
    Tick.Minute      -> "new m!"
    Tick.Hour        -> "new h!"
    Tick.Day         -> "new d!"
    Tick.Month       -> "new m!"
    Tick.Year        -> "new y!"


customTicks : Ticks.Config msg
customTicks =
  Ticks.custom <| \dataRange range ->
    List.map Tick.float [ 20, 23, 25, 28 ]
    -- List.map Tick.float (Values.float (Values.exactly 14) dataRange)
    -- List.map Tick.float (Values.float (Values.around 3) dataRange)
    -- List.map customFloatTick (Values.float (Values.around 3) dataRange)
    -- List.map Tick.float [ dataRange.min, dataRange.max ]
    -- Ticks.frame Tick.float dataRange -- Helper! Same as above!





-- DATA


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  , date : Time.Posix
  }


toInfo : Float -> Float -> Float -> Float -> Int -> Info
toInfo age weight height income ms =
  Info age weight height income (Time.millisToPosix ms)


-- TODO fix date data
alice : List Info
alice =
  [ toInfo 10 34 1.34 0     (1 * 3600000)
  , toInfo 16 42 1.62 3000  (2 * 3600000)
  , toInfo 25 75 1.73 25000 (3 * 3600000)
  , toInfo 43 83 1.75 40000 (4 * 3600000)
  ]


bobby : List Info
bobby =
  [ toInfo 10 38 1.32 0     (1 * 3600000)
  , toInfo 17 69 1.75 2000  (2 * 3600000)
  , toInfo 25 75 1.87 32000 (3 * 3600000)
  , toInfo 43 77 1.87 52000 (4 * 3600000)
  ]


chuck : List Info
chuck =
  [ toInfo 10 42 1.35 0      (1 * 3600000)
  , toInfo 15 72 1.72 1800   (2 * 3600000)
  , toInfo 25 89 1.83 85000  (3 * 3600000)
  , toInfo 43 95 1.84 120000 (4 * 3600000)
  ]
