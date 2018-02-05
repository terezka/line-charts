module LineChart.Colors exposing
  ( pink, blue, gold, red, green, cyan, teal, purple
  , pinkLight, blueLight, goldLight, redLight, greenLight, cyanLight, tealLight, purpleLight
  , black, gray, grayLight, grayLightest, transparent
  )

{-|

<img alt="Colors!" width="610" src="https://github.com/terezka/line-charts/blob/master/images/colors.png?raw=true"></src>

@docs pink, blue, gold, red, green, cyan, teal, purple

## Light
@docs pinkLight, blueLight, goldLight, redLight, greenLight, cyanLight, tealLight, purpleLight

## Gray scale
@docs black, gray, grayLight, grayLightest

## Other
@docs transparent

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
  Color.rgb 67 160 71


{-| -}
greenLight : Color.Color
greenLight =
  Color.rgb 197 225 165


{-| -}
red : Color.Color
red =
  Color.rgb 216 27 96


{-| -}
redLight : Color.Color
redLight =
  Color.rgb 239 154 154


{-| -}
purple : Color.Color
purple =
  Color.rgb 156 39 176


{-| -}
purpleLight : Color.Color
purpleLight =
  Color.rgb 206 147 216


{-| -}
cyan : Color.Color
cyan =
  Color.rgb 0 229 255


{-| -}
cyanLight : Color.Color
cyanLight =
  Color.rgb 128 222 234


{-| -}
teal : Color.Color
teal =
  Color.rgb 29 233 182


{-| -}
tealLight : Color.Color
tealLight =
  Color.rgb 128 203 196



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
