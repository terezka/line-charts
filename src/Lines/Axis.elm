module Lines.Axis exposing
  ( Axis
  , exactly, around
  , int, time, float
  , intCustom, timeCustom, floatCustom
  , Config
  )

{-|

@docs Axis, exactly, around, int, time, float, intCustom, timeCustom, floatCustom, Config

-}

import Lines.Coordinate as Coordinate exposing (..)
import Internal.Axis as Axis
import Internal.Axis.Values as Values
import Internal.Axis.Values.Time as Time


{-| -}
type alias Axis data msg =
  Axis.Axis data msg


{-| -}
type alias Amount =
  Values.Amount


-- API / AXIS


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
timeCustom : Amount -> Config Time.Time msg -> Axis data msg
timeCustom =
  Axis.timeCustom


{-| -}
floatCustom : Amount -> Config Float msg -> Axis data msg
floatCustom =
  Axis.floatCustom


{-| -}
dataCustom : Config data msg -> Axis data msg
dataCustom =
   Axis.dataCustom


{-| -}
custom : (Coordinate.Range -> List Float) -> Config Float msg -> Axis data msg
custom =
  Axis.custom



-- API / CONFIG


{-| -}
type alias Config unit msg =
  Axis.Config unit msg


-- TODO config makes
