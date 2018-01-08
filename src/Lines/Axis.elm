module Lines.Axis exposing
  ( Axis
  , int, time, float
  , intCustom, timeCustom, floatCustom, custom
  )

{-|

# Quick start
@docs Axis, int, time, float

# Customiztion
@docs intCustom, timeCustom, floatCustom, custom

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
int : Int -> Axis data msg
int =
   Axis.int


{-| -}
time : Int -> Axis data msg
time =
   Axis.time


{-| -}
float : Int -> Axis data msg
float =
   Axis.float


{-| -}
intCustom : Int -> Line.Line msg -> (Int -> Tick.Tick msg) -> Axis data msg
intCustom =
  Axis.intCustom


{-| -}
floatCustom : Int -> Line.Line msg -> (Float -> Tick.Tick msg) -> Axis data msg
floatCustom =
  Axis.floatCustom


{-| -}
timeCustom : Int -> Line.Line msg -> (Tick.Time -> Tick.Tick msg) -> Axis data msg
timeCustom =
  Axis.timeCustom


{-| -}
custom : Line.Line msg -> (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) -> Axis data msg
custom =
  Axis.custom
