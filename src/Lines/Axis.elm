module Lines.Axis exposing
  ( Axis, default
  , exactly, around
  , int, time, float
  , intCustom, timeCustom, floatCustom
  , dashed
  , Config
  )

{-|

@docs Axis, default, exactly, around, int, time, float, intCustom, timeCustom, floatCustom, dashed, Config

-}

import Lines.Coordinate as Coordinate exposing (..)
import Internal.Axis as Axis
import Internal.Axis.Values as Values
import Lines.Axis.Tick as Tick
import Lines.Axis.Line as Line


{-| -}
type alias Axis data msg =
  Axis.Axis data msg


{-| -}
type alias Amount =
  Values.Amount


-- API / AXIS


{-| -}
default : Axis data msg
default =
   Axis.default


{-| -}
exactly : Int -> Amount
exactly =
  Axis.exactly


{-| -}
around : Int -> Amount
around =
  Axis.around


{-| -}
int : Amount -> Axis data msg
int =
   Axis.int


{-| TODO Change amount to int? -}
time : Amount -> Axis data msg
time =
   Axis.time


{-| -}
float : Amount -> Axis data msg
float =
   Axis.float


{-| -}
intCustom : Amount -> Config Int msg -> Axis data msg
intCustom =
  Axis.intCustom


{-| -}
timeCustom : Amount -> Config Tick.Time msg -> Axis data msg
timeCustom =
  Axis.timeCustom


{-| -}
floatCustom : Amount -> Config Float msg -> Axis data msg
floatCustom =
  Axis.floatCustom


{-| -}
dashed : Config data msg -> Axis data msg
dashed =
   Axis.dashed


{-| -}
custom : (Coordinate.Range -> List Float) -> Config Float msg -> Axis data msg
custom =
  Axis.custom



-- API / CONFIG


{-| -}
type alias Config unit msg =
  { line : Maybe (Line.Line msg)
  , tick : Int -> unit -> Tick.Tick msg
  , direction : Tick.Direction
  }
