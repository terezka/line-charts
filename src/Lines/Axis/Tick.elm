module Lines.Axis.Tick exposing
  ( Tick, int, time, float
  , Direction, negative, positive
  )

{-|

@docs Tick, int, time, float
@docs Direction, negative, positive

-}

import Svg exposing (Svg, Attribute)
import Lines.Color as Color
import Internal.Axis.Values.Time as Time
import Internal.Axis.Tick as Tick



-- TICKS


{-| -}
type alias Tick msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , length : Float
  , label : Maybe (Svg msg)
  }


{-| -}
int : Int -> Int -> Tick msg
int =
  Tick.int


{-| TODO expose time units -}
time : Int -> Time.Time -> Tick msg
time =
  Tick.time


{-| -}
float : Int -> Float -> Tick msg
float =
  Tick.float



-- DIRECTION


{-| -}
type alias Direction =
  Tick.Direction


{-| -}
negative : Direction
negative =
  Tick.negative


{-| -}
positive : Direction
positive =
  Tick.positive
