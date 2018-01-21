module LineChart.Axis.Intersection exposing (Config, default, at, custom)

{-|

# Quick start
@docs Config, default

# Customiztion
@docs at, custom

-}


import Internal.Axis.Intersection as Intersection
import LineChart.Coordinate as Coordinate


{-| -}
type alias Config =
  Intersection.Config


{-| Sets the intersection as close to the origin as your range and domain allows.
-}
default : Config
default =
  Intersection.default


{-| Sets the intersection to your chosen x and y respectivily.
-}
at : Float -> Float -> Config
at =
  Intersection.at


{-| Sets the intersection to your chosen x and y, given the range and domain
respectivily.
-}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Config
custom =
  Intersection.custom
