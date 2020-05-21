module LineChart.Axis.Range exposing (Config, default, padded, window, custom)

{-|

## Axis ranges and data ranges

Considering the following data:

    data =
      [ { x = -1, y = -2 }
      , { x = 5, y = 6 }
      ]

From this we can see that the smallest x is -1 and the largest x is 5. We
call this the x-data range. By default, the axis range is the same as your
data range, but we can make it far more complicated than that.

Opposite your data range which is only calculated from  from your data,
**your axis range can be edited** with this module. For example, you can make
it larger than your data range, as illustrated below.

<img alt="Ranges explained" width="610" src="https://github.com/terezka/line-charts/blob/master/images/ranges.png?raw=true"></src>

_Notice how the data range begins and ends where the pink line begins and ends._

This is cool because it looks good. You can also make the axis range
smaller than the data range, and the result will we a "zoomed in" view of
one section of the data, which can also be useful.

Take a look at some of these functions if these effects interests you.

@docs Config, default, window, padded, custom

-}

import Internal.Axis.Range as Range
import LineChart.Coordinate as Coordinate



{-| First of all, this configuration is part of the
configuration in `Axis.custom`.

    axisConfig : Axis.Config Data msg
    axisConfig =
      Axis.custom
        { ..
        , range = Range.default
        , ...
        }

-}
type alias Config =
  Range.Config


{-| Set the axis range to the full length of your data range.

    rangeConfig : Range.Config
    rangeConfig =
      Range.default


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Range/Example1.elm)._

<img alt="Ranges explained" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ranges3.png?raw=true"></src>

-}
default : Config
default =
  Range.default


{-| Add a given amount of pixels to the minimum and maximum of your axis range,
respectively.

    rangeConfig : Range.Config
    rangeConfig =
      Range.padded 40 40


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Range/Example1.elm)._

<img alt="Ranges explained" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ranges.png?raw=true"></src>

-}
padded : Float -> Float -> Config
padded =
  Range.padded


{-| Straight up set your axis range by specifying the minimum and maximum,
respectively.


    rangeConfig : Range.Config
    rangeConfig =
      Range.window -0.5 4.5


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Range/Example1.elm)._

<img alt="Ranges explained" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ranges2.png?raw=true"></src>

-}
window : Float -> Float -> Config
window =
  Range.window


{-| Given your data range, produce your desired axis range.

    rangeConfig : Range.Config
    rangeConfig =
      Range.custom specialRange

    specialRange : Coordinate.Range -> Coordinate.Range
    specialRange { min, max } =
      { min = min - 1, max = max + 2 }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Range/Example1.elm)._

<img alt="Ranges explained" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ranges4.png?raw=true"></src>

-}
custom : (Coordinate.Range -> Coordinate.Range) -> Config
custom =
  Range.custom
