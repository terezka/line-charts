module Lines.Axis.Values exposing (Amount, around, exactly, int, time, float, custom)

{-|

# Values
@docs int, float, time, custom

## Amount
@docs Amount, around, exactly

-}

import Lines.Axis.Tick as Tick
import Internal.Axis.Values as Values
import Internal.Coordinate as Coordinate


{-| -}
type alias Amount =
  Values.Amount


{-| Will get you around the number you pass it, although it will
prioritize getting "nice" numbers.
-}
around : Int -> Amount
around =
  Values.around


{-| Will get you _closer_ to the number you pass it, although not actually
_exactly_, since you still want decently "nice" numbers.
-}
exactly : Int -> Amount
exactly =
  Values.exactly



-- NUMBERS


{-| Given an amount indicating how many ticks you'd like and a range, you
get a list of evenly spaces "nice" integers.
-}
int : Amount -> Coordinate.Range -> List Int
int =
  Values.int


{-| Given an amount indicating how many ticks you'd like and a range, you
get a list of evenly spaces "nice" floats.
-}
float : Amount -> Coordinate.Range -> List Float
float =
  Values.float


{-| Gets you evenly spaces floats.

  Arguments:
  1. A number which must be in your resulting numbers (Commonly 0).
  2. The interval between your numbers.
  3. The range which your numbers must be between.
-}
custom : Float -> Float -> Coordinate.Range -> List Float
custom =
  Values.custom



-- TIME


{-| Given a desired number of ticks, this makes a list of `Tick.Time` values.
-}
time : Int -> Coordinate.Range -> List Tick.Time
time =
  Values.time
