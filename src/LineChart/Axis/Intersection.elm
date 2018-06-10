module LineChart.Axis.Intersection exposing (Config, default, atOrigin, at, custom)

{-|

## Where is the intersection?

The intersection is where your two axis lines meet. By default this is at
the smallest coordinate possible (the downmost left corner), but it need
not be as illustated below.

<img alt="Ranges explained" width="610" src="https://github.com/terezka/line-charts/blob/master/images/intersection1.png?raw=true"></src>

@docs Config, default, atOrigin, at, custom

-}


import Internal.Axis.Intersection as Intersection
import LineChart.Coordinate as Coordinate



{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , intersection = Intersection.default
      , ...
      }

-}
type alias Config =
  Intersection.Config


{-| Sets the intersection at the minimum on both the range and domain.

    intersectionConfig : Intersection.Config
    intersectionConfig =
      Intersection.default


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Intersection/Example1.elm)._

-}
default : Config
default =
  Intersection.default


{-| Sets the intersection as close to the origin as your range and domain allows.

    intersectionConfig : Intersection.Config
    intersectionConfig =
      Intersection.atOrigin


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Intersection/Example1.elm)._


-}
atOrigin : Config
atOrigin =
  Intersection.atOrigin


{-| Sets the intersection to your chosen x and y respectively.

    intersectionConfig : Intersection.Config
    intersectionConfig =
      Intersection.at 0 3


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Intersection/Example1.elm)._

-}
at : Float -> Float -> Config
at =
  Intersection.at


{-| Sets the intersection to your chosen x and y, given the range and domain
respectively.

    intersectionConfig : Intersection.Config
    intersectionConfig =
      Intersection.custom .min middle

    middle : Coordinate.Range -> Float
    middle { min, max } =
      min + (max - min) / 2

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Intersection/Example1.elm)._

-}
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Config
custom =
  Intersection.custom
