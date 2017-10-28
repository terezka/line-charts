module Internal.Dot exposing (view, viewConfig, default)

import Svg
import Plot.Dot as Dot
import Plot.Color as Color
import Plot.Coordinate as Coordinate
import Internal.Primitives as Primitives


{-| -}
view : Dot.Dot msg -> Coordinate.System -> Coordinate.Point -> Svg.Svg msg
view dot =
  case dot of
    Dot.Dot config ->
      viewConfig config

    Dot.None ->
      \_ _ -> Svg.text ""


viewConfig : Dot.Config msg -> Coordinate.System -> Coordinate.Point -> Svg.Svg msg
viewConfig config =
  case config.shape of
    Dot.Circle (Dot.NoOutline) ->
      Primitives.viewCircle config.color config.size Nothing

    Dot.Circle (Dot.Outline outline) ->
      Primitives.viewCircle config.color config.size (Just outline) -- TODO: Add event attributes

    _ ->
      \_ _ -> Svg.text ""


{-| -}
default : Color.Color -> Dot.Config msg
default color =
  Dot.Config (Dot.Circle Dot.NoOutline) [] 5 color
