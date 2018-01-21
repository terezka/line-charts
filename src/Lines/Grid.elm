module Lines.Grid exposing (Grid, default, dotted, lines)

{-|

# Quick start
@docs default

# Customizing
@docs Grid, dotted, lines

# How do I change the grid?
By default there is a grid by every tick. If you want to change
the position of the grid or remove it all together, alter your tick
configuration of your axis.

The path to the tick in the configuration does through the `x` or `y`
property for vertical and horizontal grids respectivily and then in the
`axis` property.

See `Lines.Dimension` -> `Lines.Axis` -> `Lines.Axis.Tick`.

-}

import Internal.Grid as Grid
import Color


{-| -}
type alias Grid =
  Grid.Grid


{-| -}
default : Grid
default =
  Grid.default


{-| Gets you a dotted grid of a given color.
-}
dotted : Color.Color -> Grid
dotted =
  Grid.dotted


{-| Gets you grid lines of a given width and color.
-}
lines : Float -> Color.Color -> Grid
lines =
  Grid.lines
