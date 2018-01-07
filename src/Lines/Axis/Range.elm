module Lines.Axis.Range exposing (Range, default, padded, window, custom)

{-|

# Quick start
@docs Range, default

# Configurations
@docs padded, window

# Customizing
@docs custom

-}

import Internal.Axis.Range as Range
import Lines.Coordinate as Coordinate



{-| -}
type alias Range =
  Range.Range


{-| Sets the range to the full range of your data plus 20 pixels on both sides.
-}
default : Range
default =
  Range.default


{-| Add a given amount of pixels to the minimum and maxium respectivily.
-}
padded : Float -> Float -> Range
padded =
  Range.padded


{-| Set the minimum and maxium of your range respectivily.
-}
window : Float -> Float -> Range
window =
  Range.window


{-| Given your data's range, produce your desired minimum and maxium
respectivily.
-}
custom : (Coordinate.Range -> ( Float, Float )) -> Range
custom =
  Range.custom
