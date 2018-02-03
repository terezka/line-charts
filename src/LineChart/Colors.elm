module LineChart.Colors exposing
  ( pink, blue, gold, red, green, turquoise, purple
  , pinkLight, blueLight, goldLight, purpleLight
  , black, gray, grayLight, grayLightest, transparent
  )

{-|

@docs pink, blue, gold, red, green, turquoise, purple

## Light
@docs pinkLight, blueLight, goldLight, purpleLight

## Gray scale
@docs black, gray, grayLight, grayLightest, transparent

-}

import Color



{-| -}
pink : Color.Color
pink =
  Color.rgb 245 105 215


{-| -}
pinkLight : Color.Color
pinkLight =
  Color.rgb 244 143 177


{-| -}
gold : Color.Color
gold =
  Color.rgb 205 145 60


{-| -}
goldLight : Color.Color
goldLight =
  Color.rgb 255 204 128


{-| -}
blue : Color.Color
blue =
  Color.rgb 3 169 244


{-| -}
blueLight : Color.Color
blueLight =
  Color.rgb 128 222 234


{-| -}
green : Color.Color
green =
  Color.rgb 29 233 182


{-| -}
red : Color.Color
red =
  Color.rgb 216 27 96


{-| -}
purple : Color.Color
purple =
  Color.rgb 156 39 176


{-| -}
purpleLight : Color.Color
purpleLight =
  Color.rgb 206 147 216


{-| -}
turquoise : Color.Color
turquoise =
  Color.rgb 40 235 199



-- GRAY SCALE


{-| -}
black : Color.Color
black =
  Color.rgb 0 0 0


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
