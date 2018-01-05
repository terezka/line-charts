module Lines.Axis.Tick exposing
  ( Tick, int, time, Time, Unit(..), Interval, float
  , Direction, negative, positive
  , format
  )

{-|

@docs Tick, int, time, Time, Unit, Interval, float
@docs Direction, negative, positive
@docs format

-}

import Svg exposing (Svg, Attribute)
import Lines.Color as Color
import Internal.Axis.Tick as Tick
import Date
import Date.Extra as Date
import Date.Format



-- TICKS


{-| -}
type alias Tick msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , length : Float
  , label : Maybe (Svg msg)
  , grid : Bool
  , position : Float
  }


{-| -}
int : Int -> Tick msg
int n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  , grid = True
  , position = toFloat n
  }


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
  , events = []
  , length = 5
  , label = Just <| viewText (format time)
  , grid = True
  , position = time.timestamp
  }


{-| -}
float :  Float -> Tick msg
float n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  , grid = True
  , position = n
  }



-- DIRECTION


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


{-| -}
format : Time -> String
format { change, interval, timestamp } =
  case change of
    Just change -> formatBold change timestamp
    Nothing     -> formatNorm interval.unit timestamp


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



-- INTERNAL


viewText : String -> Svg msg
viewText string =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text string ] ]
