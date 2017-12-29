module Internal.Axis.Intersection exposing (Intersection, default, at, custom, getX, getY)

import Internal.Coordinate as Coordinate


{-| -}
type Intersection =
  Intersection (Coordinate.System -> Coordinate.Point)


{-| -}
default : Intersection
default =
  Intersection <| \{ x, y } ->
    Coordinate.Point (towardsZero y) (towardsZero x)


{-| -}
at : (Float, Float) -> Intersection
at (x, y) =
  Intersection <| \_ ->
    Coordinate.Point x y


{-| -}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Intersection
custom toX toY =
  Intersection <| \{ x, y } ->
    Coordinate.Point (toX y) (toY x)



-- HELPER


towardsZero : Coordinate.Range -> Float
towardsZero { max, min } =
  clamp min max 0



--


{-| -}
getX : Intersection -> Coordinate.System -> Float
getX (Intersection func) =
  .x << func


{-| -}
getY : Intersection -> Coordinate.System -> Float
getY (Intersection func) =
  .y << func
