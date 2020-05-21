module LineChart.Colors exposing
  ( pink, blue, gold, red, green, cyan, teal, purple, rust, strongBlue
  , pinkLight, blueLight, goldLight, redLight, greenLight, cyanLight, tealLight, purpleLight
  , black, gray, grayLight, grayLightest, transparent
  )

{-|

<img alt="Colors!" width="610" src="https://github.com/terezka/line-charts/blob/master/images/colors.png?raw=true"></src>

@docs pink, blue, gold, red, green, cyan, teal, purple, rust, strongBlue

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
  Color.rgb255 245 105 215


{-| -}
pinkLight : Color.Color
pinkLight =
  Color.rgb255 244 143 177


{-| -}
gold : Color.Color
gold =
  Color.rgb255 205 145 60


{-| -}
goldLight : Color.Color
goldLight =
  Color.rgb255 255 204 128


{-| -}
blue : Color.Color
blue =
  Color.rgb255 3 169 244


{-| -}
blueLight : Color.Color
blueLight =
  Color.rgb255 128 222 234


{-| -}
green : Color.Color
green =
  Color.rgb255 67 160 71


{-| -}
greenLight : Color.Color
greenLight =
  Color.rgb255 197 225 165


{-| -}
red : Color.Color
red =
  Color.rgb255 216 27 96


{-| -}
redLight : Color.Color
redLight =
  Color.rgb255 239 154 154


{-| -}
rust : Color.Color
rust =
  Color.rgb255 205 102 51


{-| -}
purple : Color.Color
purple =
  Color.rgb255 156 39 176


{-| -}
purpleLight : Color.Color
purpleLight =
  Color.rgb255 206 147 216


{-| -}
cyan : Color.Color
cyan =
  Color.rgb255 0 229 255


{-| -}
cyanLight : Color.Color
cyanLight =
  Color.rgb255 128 222 234


{-| -}
teal : Color.Color
teal =
  Color.rgb255 29 233 182


{-| -}
tealLight : Color.Color
tealLight =
  Color.rgb255 128 203 196


{-| -}
strongBlue : Color.Color
strongBlue =
  Color.rgb255 89 51 204





-- GRAY SCALE


{-| -}
black : Color.Color
black =
  Color.rgb255 0 0 0


{-| -}
gray : Color.Color
gray =
  Color.rgb255 163 163 163


{-| -}
grayLight : Color.Color
grayLight =
  Color.rgb255 211 211 211


{-| -}
grayLightest : Color.Color
grayLightest =
  Color.rgb255 243 243 243


{-| -}
transparent : Color.Color
transparent =
  Color.rgba 0 0 0 0
