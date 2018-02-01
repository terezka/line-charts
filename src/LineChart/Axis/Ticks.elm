module LineChart.Axis.Ticks exposing
  ( Config, default
  , int, time, float
  , intCustom, timeCustom, floatCustom, custom
  , hoverOne, frame
  )

{-|

# Quick start
@docs Config, default, int, time, float

# Customiztion
@docs intCustom, timeCustom, floatCustom

# Wild customiztion
@docs custom

## Helpers
@docs hoverOne, frame

-}

import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Values as Values
import LineChart.Axis.Tick as Tick



{-| -}
type alias Config msg =
  Ticks.Config msg


{-| -}
type alias Amount =
  Values.Amount



-- API / AXIS


{-| -}
default : Config msg
default =
   Ticks.float 5


{-| -}
int : Int -> Config msg
int =
   Ticks.int


{-| -}
time : Int -> Config msg
time =
   Ticks.time


{-| -}
float : Int -> Config msg
float =
   Ticks.float


{-| -}
intCustom : Int -> (Int -> Tick.Config msg) -> Config msg
intCustom =
  Ticks.intCustom


{-| -}
floatCustom : Int -> (Float -> Tick.Config msg) -> Config msg
floatCustom =
  Ticks.floatCustom


{-| -}
timeCustom : Int -> (Tick.Time -> Tick.Config msg) -> Config msg
timeCustom =
  Ticks.timeCustom


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Tick.Config msg)) -> Config msg
custom =
  Ticks.custom



-- CUSTOM HELP


{-| -}
hoverOne : (data -> Tick.Config msg) -> Maybe data -> List (Tick.Config msg)
hoverOne tick =
  Maybe.map (tick >> List.singleton) >> Maybe.withDefault []


{-| -}
frame : (Float -> Tick.Config msg) -> Coordinate.Range -> List (Tick.Config msg)
frame tick data =
  List.map tick [ data.min, data.max ]
