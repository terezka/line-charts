module LineChart.Colors exposing (pink, blue, gold, gray, grayLight, grayLightest, transparent)

{-|

# Defaults
@docs pink, blue, gold, gray, grayLight, grayLightest, transparent

-}

import Color



{-| -}
pink : Color.Color
pink =
  Color.rgb 245 105 215


{-| -}
gold : Color.Color
gold =
  Color.rgb 205 145 60


{-| -}
blue : Color.Color
blue =
  Color.rgb 40 235 199


{-| -}
gray : Color.Color
gray =
  Color.rgb 163 163 163


{-| -}
grayLight : Color.Color
grayLight =
  Color.rgb 211 211 211


{-| -}
grayLightest : Color.Color
grayLightest =
  Color.rgb 243 243 243


{-| -}
transparent : Color.Color
transparent =
  Color.rgba 0 0 0 0
