module LineChart.Axis.Values exposing (Amount, around, exactly, int, time, float, custom)

{-|

Use in `Ticks.custom` for creating "nice" values.

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.custom <| \dataRange axisRange ->
        List.map Tick.float (valuesWithin dataRange)

    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      Values.int (Values.around 3)


_See full example [here](https://ellie-app.com/dqLn8tZZ6a1/1)._

** What are "nice" numbers/integers/datetimes? **

When I say "nice", I just mean that I try to calculate intervals which begin
with 10, 5, 3, 2, 1 (adjusted to magnitude, of course!). For dates, I try to
hit whole days, weeks, months or hours, minutes, and seconds.

# Nice numbers
@docs int, float, Amount, around, exactly

# Nice times
@docs time

# Custom numbers
@docs custom

-}

import LineChart.Axis.Tick as Tick
import Internal.Axis.Values as Values
import LineChart.Coordinate as Coordinate



{-| -}
type alias Amount =
  Values.Amount


{-| Will get you around the amount of numbers you pass it, although it will
prioritize getting "nice" numbers.
-}
around : Int -> Amount
around =
  Values.around


{-| Will get you _closer_ to the amount of numbers you pass it,
although not actually _exactly_, since you still want decently "nice" numbers.

P.S. If you have a better name for this function, please contact me.
-}
exactly : Int -> Amount
exactly =
  Values.exactly



-- NUMBERS


{-| Makes nice integers.

    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      -- something like [ 1, 2, 3, 4 ]
      Values.int (Values.around 3)

-}
int : Amount -> Coordinate.Range -> List Int
int =
  Values.int


{-| Makes nice floats.

    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      -- something like [ 1, 1.5, 2, 2.5 ]
      Values.float (Values.exactly 4)

-}
float : Amount -> Coordinate.Range -> List Float
float =
  Values.float


{-| Makes evenly spaced floats.

Arguments:

  1. A number which must be in your resulting numbers (Commonly 0).
  2. The interval between your numbers.
  3. The range which your numbers must be between.


    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      -- makes [ -3, 1, 5, 9, 13, ... ]
      Values.custom 1 4

-}
custom : Float -> Float -> Coordinate.Range -> List Float
custom =
  Values.custom



-- TIME


{-| Makes nice times.

    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      Values.time 5

-}
time : Int -> Coordinate.Range -> List Tick.Time
time =
  Values.time
