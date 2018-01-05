module Lines.Axis.Tick exposing
  ( Tick
  , Direction, negative, positive
  , int, float
  , time, Time, Unit(..), Interval, format
  , hover, frame
  )

{-|

# Quick start
@docs Tick, int, float

# Definition
@docs Tick, Direction, negative, positive

# Time tick
@docs time, Time, Unit, Interval, format

# Groups
@docs hover, frame

-}

import Svg exposing (Svg, Attribute)
import Lines.Color as Color
import Lines.Junk as Junk
import Lines.Coordinate as Coordinate
import Internal.Axis.Tick as Tick
import Date
import Date.Extra as Date
import Date.Format



{-| -}
type alias Tick msg =
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
int : Int -> Tick msg
int n =
  { position = toFloat n
  , color = Color.gray
  , width = 1
  , length = 5
  , grid = True
  , direction = negative
  , label = Just <| Junk.text Color.inherit (toString n)
  }


{-| -}
float : Float -> Tick msg
float n =
  { position = n
  , color = Color.gray
  , width = 1
  , length = 5
  , grid = True
  , direction = negative
  , label = Just <| Junk.text Color.inherit (toString n)
  }



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
  }


{-| -}
type alias Interval =
  { unit : Unit
  , multiple : Int
  }


{-| -}
time : Time -> Tick msg
time time =
  { position = time.timestamp
  , color = Color.gray
  , width = 1
  , length = 5
  , grid = True
  , direction = negative
  , label = Just <| Junk.text Color.inherit (format time)
  }



-- TIME / FORMATTING


{-| -}
format : Time -> String
format { change, interval, timestamp } =
  case change of
    Just change -> formatBold change timestamp
    Nothing     -> formatNorm interval.unit timestamp



-- GROUPS


{-| -}
hover : (data -> Tick msg) -> Maybe data -> List (Tick msg)
hover tick =
  Maybe.map (tick >> List.singleton) >> Maybe.withDefault []


{-| -}
frame : (Float -> Tick msg) -> Coordinate.Range -> List (Tick msg)
frame tick data =
  List.map tick [ data.min, data.max ]



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
