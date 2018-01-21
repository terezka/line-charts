module LineChart.Interpolation exposing (Config, default, linear, monotone, steppedBefore, steppedAfter)

{-|

## Interpolations
@docs Config, default, linear, monotone, steppedBefore, steppedAfter

-}

import Internal.Interpolation as Interpolation


{-| -}
type alias Config =
  Interpolation.Config


{-| -}
default : Config
default =
  linear


{-| A linear interpolation.
-}
linear : Config
linear =
  Interpolation.Linear


{-| A monotone-x interpolation.
-}
monotone : Config
monotone =
  Interpolation.Monotone

{-| A stepped interpolation where the step comes before the point.
-}
steppedBefore : Config
steppedBefore =
  Interpolation.SteppedBefore


{-| A stepped interpolation where the step comes after the point.
-}
steppedAfter : Config
steppedAfter =
  Interpolation.SteppedAfter
