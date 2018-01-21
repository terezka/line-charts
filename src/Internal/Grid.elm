module Internal.Grid exposing (Grid, default, dotted, lines, view)


{-| -}

import Svg
import Svg.Attributes as Attributes
import Internal.Svg as Svg
import Lines.Color as Colors
import Lines.Coordinate as Coordinate
import Lines.Dimension as Dimension
import Internal.Axis as Axis
import Color
import Color.Convert


{-| -}
type Grid
  = Dots Color.Color
  | Lines Float Color.Color


{-| -}
default : Grid
default =
  lines 1 Colors.grayLight


{-| -}
dotted : Color.Color -> Grid
dotted =
  Dots


{-| -}
lines : Float -> Color.Color -> Grid
lines =
  Lines



-- INTERNAL


{-| -}
view : Coordinate.System -> Dimension.Config data msg -> Dimension.Config data msg -> Grid -> List (Svg.Svg msg)
view system xDimension yDimension grid =
  let
    verticals =
      Axis.ticks system.xData system.x xDimension.axis
        |> List.filterMap hasGrid

    horizontals =
      Axis.ticks system.yData system.y yDimension.axis
        |> List.filterMap hasGrid

    hasGrid tick =
      if tick.grid then Just tick.position else Nothing
  in
  case grid of
    Dots color        -> viewDots  system verticals horizontals color
    Lines width color -> viewLines system verticals horizontals width color


viewDots : Coordinate.System -> List Float -> List Float -> Color.Color -> List (Svg.Svg msg)
viewDots system verticals horizontals color =
  let
    dots =
      List.concatMap dots_ verticals

    dots_ g =
      List.map (dot g) horizontals

    dot x y =
      Coordinate.toSVG system (Coordinate.Point x y)
  in
  List.map (Svg.gridDot color) dots


viewLines : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewLines system verticals horizontals width color =
  let
    attributes =
      [ Attributes.strokeWidth (toString width), Attributes.stroke (Color.Convert.colorToHex color) ]
  in
  List.map (Svg.horizontalGrid system attributes) horizontals ++
  List.map (Svg.verticalGrid system attributes) verticals
