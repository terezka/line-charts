module LineChart.Axis.Ticks exposing
  ( Config
  , int, time, float
  , intCustom, timeCustom, floatCustom, custom
  , hoverOne, frame
  )

{-|

# Quick start
@docs Axis, int, time, float

# Customiztion
@docs intCustom, timeCustom, floatCustom, custom

## Custom helpers
@docs hoverOne, frame

-}

import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Values as Values
import LineChart.Axis.Tick as Tick



{-| -}
type alias Config data msg =
  Ticks.Config data msg


{-| -}
type alias Amount =
  Values.Amount


-- API / AXIS


{-| -}
int : Int -> Config data msg
int =
   Ticks.int


{-| -}
time : Int -> Config data msg
time =
   Ticks.time


{-| -}
float : Int -> Config data msg
float =
   Ticks.float


{-| -}
intCustom : Int -> (Int -> Tick.Tick msg) -> Config data msg
intCustom =
  Ticks.intCustom


{-| -}
floatCustom : Int -> (Float -> Tick.Tick msg) -> Config data msg
floatCustom =
  Ticks.floatCustom


{-| -}
timeCustom : Int -> (Tick.Time -> Tick.Tick msg) -> Config data msg
timeCustom =
  Ticks.timeCustom


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Tick.Tick msg)) -> Config data msg
custom =
  Ticks.custom



-- CUSTOM HELP


{-| -}
hoverOne : (data -> Tick.Tick msg) -> Maybe data -> List (Tick.Tick msg)
hoverOne tick =
  Maybe.map (tick >> List.singleton) >> Maybe.withDefault []


{-| -}
frame : (Float -> Tick.Tick msg) -> Coordinate.Range -> List (Tick.Tick msg)
frame tick data =
  List.map tick [ data.min, data.max ]
