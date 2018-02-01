module LineChart.Interpolation exposing (Config, default, linear, monotone, stepped)

{-|

# Quick start
@docs Config, default, linear, monotone, stepped

-}

import Internal.Interpolation as Interpolation


{-| -}
type alias Config =
  Interpolation.Config


{-| The vanilla of interpolations: Linear!
Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , interpolation = Interpolation.default
      , ...
      }

-}
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


{-| A stepped interpolation where the step comes after the dot.
-}
stepped : Config
stepped =
  Interpolation.Stepped
