module LineChart.Axis.Values exposing (Amount, around, exactly, int, time, float, custom)

{-|

Use in `Ticks.custom` for creating "nice" values.

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.custom <| \dataRange axisRange ->
        List.map Tick.int (valuesWithin dataRange)

    valuesWithin : Coordinate.Range -> List Int
    valuesWithin =
      Values.int (Values.around 3)


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Values/Example1.elm)._

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
import Time



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

    valuesWithin : Coordinate.Range -> List Int
    valuesWithin =
      Values.int (Values.around 3)


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Values/Example1.elm)._

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

  1. A number which must be in your resulting numbers (commonly 0).
  2. The interval between your numbers.
  3. The range which your numbers must be between.


    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.custom <| \dataRange axisRange ->
        List.map Tick.float (Values.custom 45 10 dataRange) ++
        -- ^ Makes [ 25, 45, 55, 65, 75, 85, 95 ]

        List.map Tick.long (Values.custom 30 20 dataRange)
        -- ^ Makes [ 30, 50, 70, 90 ]


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Values/Example3.elm)._

-}
custom : Float -> Float -> Coordinate.Range -> List Float
custom =
  Values.custom



-- TIME


{-| Makes nice times.

    valuesWithin : Coordinate.Range -> List Float
    valuesWithin =
      Values.time 5


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Values/Example2.elm)._

-}
time : Time.Zone -> Int -> Coordinate.Range -> List Tick.Time
time =
  Values.time
