module Internal.Grid exposing (Config, default, dots, lines, view)


{-| -}

import Svg
import Svg.Attributes as Attributes
import Internal.Svg as Svg
import LineChart.Colors as Colors
import LineChart.Coordinate as Coordinate
import Internal.Axis as Axis
import Internal.Axis.Ticks as Ticks
import Color



{-| -}
type Config
  = Dots Float Color.Color
  | Lines Float Color.Color


{-| -}
default : Config
default =
  lines 1 Colors.grayLightest


{-| -}
dots : Float -> Color.Color -> Config
dots =
  Dots


{-| -}
lines : Float -> Color.Color -> Config
lines =
  Lines



-- INTERNAL


{-| -}
view : Coordinate.System -> Axis.Config data msg -> Axis.Config data msg -> Config -> List (Svg.Svg msg)
view system xAxis yAxis grid =
  let
    verticals =
      Ticks.ticks system.xData system.x (Axis.ticks xAxis)
        |> List.filterMap hasGrid

    horizontals =
      Ticks.ticks system.yData system.y (Axis.ticks yAxis)
        |> List.filterMap hasGrid

    hasGrid tick =
      if tick.grid then Just tick.position else Nothing
  in
  case grid of
    Dots radius color -> viewDots  system verticals horizontals radius color
    Lines width color -> viewLines system verticals horizontals width color


viewDots : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewDots system verticals horizontals radius color =
  let
    alldots =
      List.concatMap dots_ verticals

    dots_ g =
      List.map (dot g) horizontals

    dot x y =
      Coordinate.toSvg system (Coordinate.Point x y)
  in
  List.map (Svg.gridDot radius color) alldots


viewLines : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewLines system verticals horizontals width color =
  let
    attributes =
      [ Attributes.strokeWidth (String.fromFloat width), Attributes.stroke (Color.toCssString color) ]
  in
  List.map (Svg.horizontalGrid system attributes) horizontals ++
  List.map (Svg.verticalGrid system attributes) verticals
