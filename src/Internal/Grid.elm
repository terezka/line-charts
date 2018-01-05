module Internal.Grid exposing (Grid, default, dotted, lines, view)


{-| -}

import Svg
import Svg.Attributes as Attributes
import Internal.Svg as Svg
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Internal.Axis as Axis


{-| -}
type Grid
  = Dots Color.Color
  | Lines Float Color.Color


{-| -}
default : Grid
default =
  lines 1 Color.grayLight


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
view : Coordinate.System -> Axis.Dimension data msg -> Axis.Dimension data msg -> Grid -> List (Svg.Svg msg)
view system xDimension yDimension grid =
  let
    verticals =
      Axis.ticks system.xData system.x xDimension
        |> List.filterMap hasGrid

    horizontals =
      Axis.ticks system.yData system.y yDimension
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

    dot at1 at2 =
      Coordinate.toSVG system <| Coordinate.Point at1 at2

    circle point =
      Svg.circle
        [ Attributes.cx (toString point.x)
        , Attributes.cy (toString point.y)
        , Attributes.r "1"
        , Attributes.fill color
        ]
        []
  in
    List.map circle dots


viewLines : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewLines system verticals horizontals width color =
  let
    attributes =
      [ Attributes.strokeWidth (toString width), Attributes.stroke color ]
  in
    List.map (Svg.horizontalGrid system attributes) horizontals ++
    List.map (Svg.verticalGrid system attributes) verticals
