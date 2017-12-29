module Lines.Axis.Intersection exposing (Intersection, default, custom)

import Internal.Axis.Intersection as Intersection
import Lines.Coordinate as Coordinate


{-| -}
type alias Intersection =
  Intersection.Intersection


{-| -}
default : Intersection
default =
  Intersection.default

{-| -}
at : (Float, Float) -> Intersection
at =
  Intersection.at


{-| -}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Intersection
custom =
  Intersection.custom