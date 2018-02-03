module Internal.Axis.Intersection exposing
  ( Config
  , default, atOrigin, at, custom
  -- INTERNAL
  , getX, getY
  )

import Internal.Coordinate as Coordinate
import Internal.Data as Data



{-| -}
type Config =
  Config (Coordinate.System -> Data.Point)


{-| -}
default : Config
default =
  custom .min .min


{-| -}
atOrigin : Config
atOrigin =
  custom towardsZero towardsZero


{-| -}
at : Float -> Float -> Config
at x y =
  custom (always x) (always y)


{-| -}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Config
custom toX toY =
  Config <| \{ x, y } ->
    Data.Point (toX x) (toY y)



-- HELPER


towardsZero : Coordinate.Range -> Float
towardsZero { max, min } =
  clamp min max 0



-- INTERNAL


{-| -}
getX : Config -> Coordinate.System -> Float
getX (Config func) =
  .x << func


{-| -}
getY : Config -> Coordinate.System -> Float
getY (Config func) =
  .y << func
