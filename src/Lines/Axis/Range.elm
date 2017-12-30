module Lines.Axis.Range exposing (Range, default, padded, window, custom)

{-|

@docs Range, default, padded, window, custom

-}

import Internal.Axis.Range as Range
import Lines.Coordinate as Coordinate


{-| -}
type alias Range =
  Range.Range


{-| -}
default : Range
default =
  Range.default


{-| -}
padded : Float -> Float -> Range
padded =
  Range.padded


{-| -}
window : Float -> Float -> Range
window =
  Range.window


{-| -}
custom : (Coordinate.Range -> (Float, Float)) -> Range
custom =
  Range.custom
