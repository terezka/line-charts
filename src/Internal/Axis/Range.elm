module Internal.Axis.Range exposing (Range, default, padded, window, custom, apply)

import Internal.Coordinate as Coordinate


{-| -}
type Range =
  Range (Coordinate.Range -> Coordinate.Range)


{-| -}
default : Range
default =
  Range identity


{-| TODO check this -}
padded : Float -> Float -> Range
padded padMin padMax =
  Range <| \{ min, max } ->
    let range = max - min in
    Coordinate.Range (min - range * padMin) (max + range * padMax)


{-| -}
window : Float -> Float -> Range
window min max =
  Range <| \_ ->
    Coordinate.Range min max


{-| -}
custom : (Coordinate.Range -> (Float, Float)) -> Range
custom editRange =
  Range <| \range ->
    let ( min, max ) = editRange range in
    Coordinate.Range min max


-- INTERNAL


{-| -}
apply : Range -> Coordinate.Range -> Coordinate.Range
apply (Range func) =
  func
