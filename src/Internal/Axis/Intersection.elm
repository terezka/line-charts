module Internal.Axis.Intersection exposing
  ( Intersection
  , default, at, custom
  -- INTERNAL
  , getX, getY
  )

import Internal.Coordinate as Coordinate
import Internal.Data as Data


{-| -}
type Intersection =
  Intersection (Coordinate.System -> Data.Point)


{-| -}
default : Intersection
default =
  custom towardsZero towardsZero


{-| -}
at : Float -> Float -> Intersection
at x y =
  custom (always x) (always y)


{-| -}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Intersection
custom toX toY =
  Intersection <| \{ x, y } ->
    Data.Point (toX x) (toY y)



-- HELPER


towardsZero : Coordinate.Range -> Float
towardsZero { max, min } =
  clamp min max 0



-- INTERNAL


{-| -}
getX : Intersection -> Coordinate.System -> Float
getX (Intersection func) =
  .x << func


{-| -}
getY : Intersection -> Coordinate.System -> Float
getY (Intersection func) =
  .y << func
