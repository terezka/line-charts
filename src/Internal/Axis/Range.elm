module Internal.Axis.Range exposing (Range, default, padded, window, custom, applyX, applyY)

import Lines.Coordinate as Coordinate


{-| -}
type Range
  = Padded Float Float
  | Window Float Float
  | Custom (Coordinate.Range -> Coordinate.Range)


{-| -}
default : Range
default =
  padded 20 20


{-| -}
padded : Float -> Float -> Range
padded =
  Padded


{-| -}
window : Float -> Float -> Range
window =
  Window


{-| -}
custom : (Coordinate.Range -> ( Float, Float )) -> Range
custom editRange =
  Custom <| \range ->
    let ( min, max ) = editRange range in
    Coordinate.Range min max



-- INTERNAL


{-| -}
applyX : Range -> Coordinate.System -> Coordinate.Range
applyX range system =
  case range of
    Padded padMin padMax ->
      let
        { frame } = system
        { size } = frame
        system_ = { system | frame = { frame | size = { size | width = size.width - padMin - padMax |> Basics.max 1 } } }
        scale = Coordinate.scaleDataX system_
      in
      Coordinate.Range (system.x.min - scale padMin) (system.x.max + scale padMax)

    Window min max -> Coordinate.Range min max
    Custom toRange -> toRange system.x


{-| -}
applyY : Range -> Coordinate.System -> Coordinate.Range
applyY range system =
  case range of
    Padded padMin padMax ->
      let
        { frame } = system
        { size } = frame
        system_ = { system | frame = { frame | size = { size | height = size.height - padMin - padMax |> Basics.max 1 } } }
        scale = Coordinate.scaleDataY system_
      in
      Coordinate.Range (system.y.min - scale padMin) (system.y.max + scale padMax)

    Window min max -> Coordinate.Range min max
    Custom toRange -> toRange system.y
