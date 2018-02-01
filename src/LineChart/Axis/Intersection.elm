module LineChart.Axis.Intersection exposing (Config, default, at, custom)

{-|

## Where is the intersection?

The intersection is where your two axis lines meet. By default this is at
the origin (0, 0), but it need not be as illustated below.

<img alt="Ranges explained" width="610" src="https://github.com/terezka/lines/blob/master/images/intersection1.png?raw=true"></src>

@docs Config, default, at, custom

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
