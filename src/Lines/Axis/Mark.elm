module Lines.Axis.Mark exposing (..)


{-| -}


import Lines.Coordinate as Coordinate
import Internal.Numbers as Numbers


-- INTERVALS


{-| Produces a list of evenly spaced numbers given the limits of your axis.
-}
defaultInterval : Float -> Coordinate.Limits -> List Float
defaultInterval =
  Numbers.defaultInterval


{-| Produces a list of evenly spaced numbers given an offset, and interval, and
the limits of your axis.

The offset is useful when you want two sets of ticks with different views. For
example, if you want a long tick at every 2 x and a small tick at every 2 x + 1,
you'd use

    firstInterval : Coordinate.Limits -> List Float
    firstInterval =
      Axis.customInterval 0 2

    secondInterval : Coordinate.Limits -> List Float
    secondInterval =
      Axis.customInterval 1 2

-}
customInterval : Float -> Float -> Coordinate.Limits -> List Float
customInterval =
  Numbers.customInterval
