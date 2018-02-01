module LineChart.Axis.Range exposing (Config, default, padded, window, custom)

{-|

# Quick start
@docs Config, default, padded, window

# Customiztion
@docs custom

-}

import Internal.Axis.Range as Range
import LineChart.Coordinate as Coordinate



{-| -}
type alias Config =
  Range.Config


{-| Set the range to the full range of your data.
-}
default : Config
default =
  Range.default


{-| Add a given amount of pixels to the minimum and maximum respectivily.
-}
padded : Float -> Float -> Config
padded =
  Range.padded


{-| Set the minimum and maximum of your range respectivily.
-}
window : Float -> Float -> Config
window =
  Range.window


{-| Given your data's range, produce your desired minimum and maximum
respectivily.
-}
custom : (Coordinate.Range -> ( Float, Float )) -> Config
custom =
  Range.custom
