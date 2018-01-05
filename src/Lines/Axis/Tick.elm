module Lines.Axis.Tick exposing
  ( Tick, int, time, Time, Unit(..), Interval, float
  , hover, frame
  , Direction, negative, positive
  , format
  )

{-|

@docs Tick, int, float
@docs time, Time, Unit, Interval, format
@docs hover, frame
@docs Direction, negative, positive

-}

import Svg exposing (Svg, Attribute)
import Lines.Color as Color
import Lines.Junk as Junk
import Lines.Coordinate as Coordinate
import Internal.Axis.Tick as Tick
import Date
import Date.Extra as Date
import Date.Format


-- TICKS


{-| -}
type alias Tick msg =
  { position : Float
  , color : Color.Color
  , width : Float
  , length : Float
  , label : Maybe (Svg msg)
  , direction : Direction
  , grid : Bool
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
  { color = Color.gray
  , width = 1
  , length = 5
  , label = Just <| Junk.text Color.inherit (toString n)
  , grid = True
  , direction = negative
  , position = toFloat n
  }


{-| -}
float : Float -> Tick msg
float n =
  { color = Color.gray
  , width = 1
  , length = 5
  , label = Just <| Junk.text Color.inherit (toString n)
  , grid = True
  , direction = negative
  , position = n
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
  { color = Color.gray
  , width = 1
  , length = 5
  , label = Just <| Junk.text Color.inherit (format time)
  , grid = True
  , direction = negative
  , position = time.timestamp
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
