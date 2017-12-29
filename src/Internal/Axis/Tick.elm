module Internal.Axis.Tick exposing
  ( Tick, int, time, float
  , Direction(..), negative, positive
  )


import Svg exposing (Svg, Attribute)
import Date
import Date.Format
import Date.Extra as Date
import Lines.Color as Color
import Internal.Axis.Values.Time as Time



-- TICK


{-| -}
type alias Tick msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , length : Float
  , label : Maybe (Svg msg)
  }


-- TICK / INT


{-| -}
int : Int -> Int -> Tick msg
int _ n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  }



-- TICK / TIME


{-| -}
time : Int -> Time.Time -> Tick msg
time _ { change, interval, timestamp } =
  let
    label =
      case change of
        Just change -> timeFormatEmphasized change timestamp
        Nothing     -> timeFormat interval.unit timestamp
  in
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText label
  }


timeFormat : Time.Unit -> Float -> String
timeFormat unit =
  Date.fromTime >>
    case unit of
      Time.Millisecond -> toString << Date.toTime
      Time.Second      -> Date.Format.format "%S"
      Time.Minute      -> Date.Format.format "%M"
      Time.Hour        -> Date.Format.format "%l%P"
      Time.Day         -> Date.Format.format "%e"
      Time.Week        -> Date.toFormattedString "'Week' w"
      Time.Month       -> Date.Format.format "%b"
      Time.Year        -> Date.Format.format "%Y"


timeFormatEmphasized : Time.Unit -> Float -> String
timeFormatEmphasized unit =
  Date.fromTime >>
    case unit of
      Time.Millisecond -> toString << Date.toTime
      Time.Second      -> Date.Format.format "%S"
      Time.Minute      -> Date.Format.format "%M"
      Time.Hour        -> Date.Format.format "%l%P"
      Time.Day         -> Date.Format.format "%a"
      Time.Week        -> Date.toFormattedString "'Week' w"
      Time.Month       -> Date.Format.format "%b"
      Time.Year        -> Date.Format.format "%Y"




-- TICK / FLOAT


{-| -}
float : Int -> Float -> Tick msg
float _ n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  }



-- DIRECTION


{-| -}
type Direction
  = Negative
  | Positive


{-| -}
negative : Direction
negative =
  Negative


{-| -}
positive : Direction
positive =
  Positive


-- INTERNAL


viewText : String -> Svg msg
viewText string =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text string ] ]
