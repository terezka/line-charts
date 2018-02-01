module LineChart.Axis.Intersection exposing (Config, default, at, custom)

{-|

# Quick start
@docs Config, default, at

# Customiztion
@docs custom

-}


import Internal.Axis.Intersection as Intersection
import LineChart.Coordinate as Coordinate



{-| Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , intersection = Intersection.default
      , ...
      }

-}
type alias Config =
  Intersection.Config


{-| Sets the intersection as close to the origin as your range and domain allows.

    intersectionConfig : Intersection.Config msg
    intersectionConfig =
      Intersection.default

-}
default : Config
default =
  Intersection.default


{-| Sets the intersection to your chosen x and y respectivily.

    intersectionConfig : Intersection.Config msg
    intersectionConfig =
      Intersection.at 0 3

-}
at : Float -> Float -> Config
at =
  Intersection.at


{-| Sets the intersection to your chosen x and y, given the range and domain
respectivily.

    intersectionConfig : Intersection.Config msg
    intersectionConfig =
      Intersection.custom .min .max

-}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Config
custom =
  Intersection.custom
