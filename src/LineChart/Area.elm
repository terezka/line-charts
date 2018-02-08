module LineChart.Area exposing (Config, default, normal, stacked)

{-|

@docs Config, default, normal, stacked

-}

import Internal.Area as Area



{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data Msg
    chartConfig =
      { ...
      , area = Area.default
      , ...
      }

-}
type alias Config =
  Area.Config


{-| No color below your lines.
-}
default : Config
default =
  Area.none


{-| Color the area below your lines. The color is always the color of
your line, but you can pass the opacity.

_See example [here](https://github.com/terezka/line-charts/blob/master/examples/Area.elm)._

-}
normal : Float -> Config
normal =
  Area.normal


{-| Stacks your values and colors the area in the line color. The color is
always the color of your line, but you can pass the opacity.

_See example [here](https://github.com/terezka/line-charts/blob/master/examples/Area.elm)._

**Warning:** Right now, this only works if all your lines have the
same set of x values and don't have missing data!
If not, the area will not stack properly.
It will be fixed sometime though!
-}
stacked : Float -> Config
stacked =
  Area.stacked


{-| Same as stacked, but the areas takes up the whole graph and your values
are made into percentages. The color is always the color of your line, but
you can pass the opacity.

**Warning:** Right now, this only works if all your lines have the
same set of x values! If not, the area will not add properly.
-}
percentage : Float -> Config
percentage =
  Area.percentage
