module LineChart.Interpolation exposing (Config, default, linear, monotone, stepped)

{-|

# Quick start
@docs Config, default, linear, monotone, stepped

-}

import Internal.Interpolation as Interpolation


{-| Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , interpolation = Interpolation.default
      , ...
      }

-}
type alias Config =
  Interpolation.Config


{-| The vanilla of interpolations: linear.
-}
default : Config
default =
  linear


{-| A linear interpolation.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/interpolation3.png?raw=true"></src>

-}
linear : Config
linear =
  Interpolation.Linear


{-| A monotone-x interpolation.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/interpolation2.png?raw=true"></src>

-}
monotone : Config
monotone =
  Interpolation.Monotone


{-| A stepped interpolation where the step comes after the dot.

<img alt="Legends" width="540" src="https://github.com/terezka/lines/blob/master/images/interpolation4.png?raw=true"></src>

-}
stepped : Config
stepped =
  Interpolation.Stepped
