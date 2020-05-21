module LineChart.Grid exposing (Config, default, dots, lines)

{-|

@docs Config, default, dots, lines

# How do I change where the grid lines/dots are placed?

By default there is a grid by every tick. If you want to change
the position of the grid or remove it all together, alter your tick
configuration of your axis.

The path to the tick in the configuration does through the `x` or `y`
property for vertical and horizontal grids respectively and then in the
`axis` property.

See `LineChart.Axis` -> `LineChart.Axis.Ticks` -> `LineChart.Axis.Tick`.

-}

import Internal.Grid as Grid
import Color


{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , grid = Grid.default
      , ...
      }

-}
type alias Config =
  Grid.Config


{-| Gets you some vague gray grid lines.
-}
default : Config
default =
  Grid.default


{-| Gets you a grid dots of a given radius and color.
-}
dots : Float -> Color.Color -> Config
dots =
  Grid.dots


{-| Gets you grid lines of a given width and color.
-}
lines : Float -> Color.Color -> Config
lines =
  Grid.lines
