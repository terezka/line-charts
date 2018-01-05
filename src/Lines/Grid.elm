module Lines.Grid exposing (Grid, default, dotted, lines)


{-|

@docs Grid, default, dotted, lines

-}

import Lines.Color as Color
import Internal.Grid as Grid


{-| -}
type alias Grid =
  Grid.Grid


{-| -}
default : Grid
default =
  Grid.default


{-| -}
dotted : Color.Color -> Grid
dotted =
  Grid.dotted


{-| -}
lines : Float -> Color.Color -> Grid
lines =
  Grid.lines
