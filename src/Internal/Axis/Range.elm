module Internal.Axis.Range exposing (Range, default, padded, window, custom, applyX, applyY)

import Lines.Coordinate as Coordinate


{-| -}
type Range
  = Range ((Float -> Float) -> Coordinate.Range -> Coordinate.Range)


{-| -}
default : Range
default =
  padded 20 20


{-| -}
padded : Float -> Float -> Range
padded padMin padMax =
  Range <| \scale { min, max } ->
    let range = max - min in
    Coordinate.Range (min - scale padMin) (max + scale padMax)


{-| -}
window : Float -> Float -> Range
window min max =
  Range <| \_ _ ->
    Coordinate.Range min max


{-| -}
custom : (Coordinate.Range -> (Float, Float)) -> Range
custom editRange =
  Range <| \_ range ->
    let ( min, max ) = editRange range in
    Coordinate.Range min max



-- INTERNAL


{-| -}
applyX : Range -> Coordinate.System -> Coordinate.Range
applyX (Range func) system =
  func (Coordinate.scaleDataX system) system.x


{-| -}
applyY : Range -> Coordinate.System -> Coordinate.Range
applyY (Range func) system =
  func (Coordinate.scaleDataY system) system.y
