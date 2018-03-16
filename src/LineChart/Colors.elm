module LineChart.Colors exposing
  ( pink, blue, gold, red, green, cyan, teal, purple
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
  Color.rgba 245 105 215 1


{-| -}
pinkLight : Color.Color
pinkLight =
  Color.rgba 244 143 177 1


{-| -}
gold : Color.Color
gold =
  Color.rgba 205 145 60 1


{-| -}
goldLight : Color.Color
goldLight =
  Color.rgba 255 204 128 1


{-| -}
blue : Color.Color
blue =
  Color.rgba 3 169 244 1


{-| -}
blueLight : Color.Color
blueLight =
  Color.rgba 128 222 234 1


{-| -}
green : Color.Color
green =
  Color.rgba 67 160 71 1


{-| -}
greenLight : Color.Color
greenLight =
  Color.rgba 197 225 165 1


{-| -}
red : Color.Color
red =
  Color.rgba 216 27 96 1


{-| -}
redLight : Color.Color
redLight =
  Color.rgba 239 154 154 1


{-| -}
rust : Color.Color
rust =
  Color.rgb 205 102 51 1


{-| -}
purple : Color.Color
purple =
  Color.rgba 156 39 176 1


{-| -}
purpleLight : Color.Color
purpleLight =
  Color.rgba 206 147 216 1


{-| -}
cyan : Color.Color
cyan =
  Color.rgba 0 229 255 1


{-| -}
cyanLight : Color.Color
cyanLight =
  Color.rgba 128 222 234 1


{-| -}
teal : Color.Color
teal =
  Color.rgba 29 233 182 1


{-| -}
tealLight : Color.Color
tealLight =
  Color.rgba 128 203 196 1


{-| -}
strongBlue : Color.Color
strongBlue =
  Color.rgba 89 51 204 1





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
