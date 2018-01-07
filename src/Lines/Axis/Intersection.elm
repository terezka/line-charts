module Lines.Axis.Intersection exposing (Intersection, default, at, custom)

{-|

# Quick start
@docs default

# Customizing
@docs Intersection, at, custom

-}


import Internal.Axis.Intersection as Intersection
import Lines.Coordinate as Coordinate


{-| -}
type alias Intersection =
  Intersection.Intersection


{-| Sets the intersection as close to the origin as your range and domain allows.
-}
default : Intersection
default =
  Intersection.default


{-| Sets the intersection to your chosen x and y, respectivily.
-}
at : Float -> Float -> Intersection
at =
  Intersection.at


{-| Sets the intersection to your chosen x and y, given the range and domain,
respectivily.
-}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Intersection
custom =
  Intersection.custom
