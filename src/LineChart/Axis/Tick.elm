module LineChart.Axis.Tick exposing
  ( Config, Properties
  , Direction, negative, positive
  , int, float, long, gridless
  , time, Time, Unit(..), Interval, format
  , custom
  )

{-|

@docs Config, int, float, time, long, gridless

# Customiztion
@docs custom, Properties, Direction, negative, positive

# Time formatting
@docs format, Time, Interval, Unit

-}

import Svg exposing (Svg, Attribute)
import Internal.Axis.Tick as Tick
import Internal.Svg as Svg
import Date
import Date.Extra as Date
import Date.Format
import Color



{-| Used in the configuration in `Ticks`.

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.intCustom 7 Tick.int
      -- or
      Ticks.timeCustom 7 Tick.time
      -- or
      Ticks.floatCustom 7 Tick.float
      -- or
      Ticks.floatCustom 7 Tick.long
      -- or
      Ticks.floatCustom 7 Tick.gridless
      -- or
      Ticks.floatCustom 7 customTick

-}
type alias Config msg =
  Tick.Config msg



-- NUMBERS


{-| -}
int : Int -> Config msg
int =
  Tick.int


{-| -}
float : Float -> Config msg
float =
  Tick.float


{-| -}
gridless : Float -> Config msg
gridless =
  Tick.gridless


{-| -}
long : Float -> Config msg
long =
  Tick.long


-- TIME


{-| -}
type Unit
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Week
  | Month
  | Year



{-| Explanation:

  - ** timestamp ** is the position where the tick goes on the axis.
  - ** isFirst ** is whether this is the first tick or not.
  - ** interval ** is the interval at which all the ticks are spaced.
  - ** change ** is a `Just` when the tick is changing to a larger unit
    than used in the interval. E.g. if the interval is 2 hours, then
    this will be a `Just Day` when the day changes. Useful if you
    want a different formatting for those ticks!

-}
type alias Time =
  { timestamp : Float
  , isFirst : Bool
  , interval : Interval
  , change : Maybe Unit
  }


{-| The interval at which ticks are spaced. If ticks a spaced with two hours,
this will be `{ unit = Hour, multiple = 2 }`.
-}
type alias Interval =
  { unit : Unit
  , multiple : Int
  }


{-| -}
time : Time -> Config msg
time time =
  custom
    { position = time.timestamp
    , color = Color.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = negative
    , label = Just <| Svg.label "inherit" (format time)
    }


{-| This is the default formatting of the time type. Useful when you want to
change other properties of your time tick, but won't bother with the formatting.

    tickConfig : Tick.Time -> Tick.Config msg
    tickConfig time =
      Ticks.custom
        { position = time.timestamp
        , color = Color.blue
        , width = 1
        , length = 7
        , grid = True
        , direction = Tick.positive
        , label = Just <|
            Junk.text Color.blue (Tick.format time)
        }

-}
format : Time -> String
format { change, interval, timestamp, isFirst } =
  if isFirst then
    formatBold (nextUnit interval.unit) timestamp
  else
    case change of
      Just change -> formatBold change timestamp
      Nothing     -> formatNorm interval.unit timestamp



-- CUSTOM


{-| Explanation:

  - **position** is the position on the axis.
  - **color** is the color of the little line.
  - **width** is the width of the little line.
  - **length** is the length of the little line.
  - **grid** is whether a grid will be placed by the tick or not.
  - **direction** is the direction of the little line. If the tick in question
    is on the x-axis that means that positive means the tick points up,
    and negative points down.
  - **label** is the label. If set to `Nothing`, no label will be drawn.

-}
type alias Properties msg =
  { position : Float
  , color : Color.Color
  , width : Float
  , length : Float
  , grid : Bool
  , direction : Direction
  , label : Maybe (Svg msg)
  }


{-| -}
type alias Direction =
  Tick.Direction


{-| -}
negative : Direction
negative =
  Tick.Negative


{-| -}
positive : Direction
positive =
  Tick.Positive


{-| Make your own tick!

    customTick : Float -> Tick.Config msg
    customTick number =
      Ticks.custom
        { position = number
        , color = Color.blue
        , width = 1
        , length = 7
        , grid = True
        , direction = Tick.positive
        , label = Just <|
            Junk.text Color.blue (toString number)
        }

-}
custom : Properties msg -> Config msg
custom =
  Tick.custom



-- INTERNAL


formatNorm : Unit -> Float -> String
formatNorm unit =
  Date.fromTime >>
    case unit of
      Millisecond -> Basics.toString << Date.toTime
      Second      -> Date.Format.format "%S"
      Minute      -> Date.Format.format "%M"
      Hour        -> Date.Format.format "%l%P"
      Day         -> Date.Format.format "%e"
      Week        -> Date.toFormattedString "'Week' w"
      Month       -> Date.Format.format "%b"
      Year        -> Date.Format.format "%Y"


formatBold : Unit -> Float -> String
formatBold unit =
  Date.fromTime >>
    case unit of
      Millisecond -> Basics.toString << Date.toTime
      Second      -> Date.Format.format "%S"
      Minute      -> Date.Format.format "%M"
      Hour        -> Date.Format.format "%l%P"
      Day         -> Date.Format.format "%a"
      Week        -> Date.toFormattedString "'Week' w"
      Month       -> Date.Format.format "%b"
      Year        -> Date.Format.format "%Y"


nextUnit : Unit -> Unit
nextUnit unit =
  case unit of
    Millisecond -> Second
    Second      -> Minute
    Minute      -> Hour
    Hour        -> Day
    Day         -> Week
    Week        -> Month
    Month       -> Year
    Year        -> Year
