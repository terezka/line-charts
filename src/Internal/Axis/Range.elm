module Internal.Axis.Range exposing (Config, default, padded, window, custom, applyX, applyY)

import LineChart.Coordinate as Coordinate



{-| -}
type Config
  = Padded Float Float
  | Window Float Float
  | Custom (Coordinate.Range -> Coordinate.Range)


{-| -}
default : Config
default =
  padded 0 0


{-| -}
padded : Float -> Float -> Config
padded =
  Padded


{-| -}
window : Float -> Float -> Config
window =
  Window


{-| -}
custom : (Coordinate.Range -> Coordinate.Range) -> Config
custom =
  Custom



-- INTERNAL


{-| -}
applyX : Config -> Coordinate.System -> Coordinate.Range
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
applyY : Config -> Coordinate.System -> Coordinate.Range
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
