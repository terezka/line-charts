module LineChart.Axis exposing
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

import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Axis as Axis
import Internal.Axis.Values as Values
import LineChart.Axis.Tick as Tick



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
intCustom : Int -> (Int -> Tick.Tick msg) -> Axis data msg
intCustom =
  Axis.intCustom


{-| -}
floatCustom : Int -> (Float -> Tick.Tick msg) -> Axis data msg
floatCustom =
  Axis.floatCustom


{-| -}
timeCustom : Int -> (Tick.Time -> Tick.Tick msg) -> Axis data msg
timeCustom =
  Axis.timeCustom


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) -> Axis data msg
custom =
  Axis.custom
