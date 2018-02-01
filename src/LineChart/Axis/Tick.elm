module LineChart.Axis.Tick exposing
  ( Config, Properties
  , Direction, negative, positive
  , int, float
  , time, Time, Unit(..), Interval, format
  , custom
  )

{-|

# Quick start
@docs Config, int, float

## For time axes
@docs time, Time, Unit, Interval, format

# Customiztion
@docs Properties, custom

## Direction
@docs Direction, negative, positive

-}

import Svg exposing (Svg, Attribute)
import Internal.Axis.Tick as Tick
import Internal.Svg as Svg
import Date
import Date.Extra as Date
import Date.Format
import Color



{-| -}
type alias Config msg =
  Tick.Config msg


{-| -}
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
custom : Properties msg -> Config msg
custom =
  Tick.custom



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



{-| -}
type alias Time =
  { change : Maybe Unit
  , interval : Interval
  , timestamp : Float
  , isFirst : Bool
  }


{-| -}
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



-- TIME / FORMATTING


{-| -}
format : Time -> String
format { change, interval, timestamp, isFirst } =
  if isFirst then
    formatBold (nextUnit interval.unit) timestamp
  else
    case change of
      Just change -> formatBold change timestamp
      Nothing     -> formatNorm interval.unit timestamp



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
