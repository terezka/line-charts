module Lines.Axis.Intersection exposing (Intersection, default, at, custom)

{-|

@docs Intersection, default, at, custom

-}


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
at : ( Float, Float ) -> Intersection
at =
  Intersection.at


{-| TODO shoudl this be a tuple? -}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Intersection
custom =
  Intersection.custom
