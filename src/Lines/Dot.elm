module Lines.Dot exposing (Dot, default, none, view, bordered, filled, circle)

{-| TODO: Triangle, Diamond, Square, Circle, Cross, Plus, Star
-}

import Svg exposing (Svg)
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Svg.Attributes as Attributes exposing (class, fill, style, x1, x2, y1, y2, stroke, d)
import Lines.Coordinate as Coordinate exposing (..)


-- CONFIG


{-| -}
type Dot msg
  = Dot (Maybe (View msg))


{-| -}
none : Dot msg
none =
  Dot Nothing


{-| -}
default : Dot msg
default =
  circle [] 3 filled



-- SHAPES


{-| -}
circle : List (Svg.Attribute msg) -> Int -> Coloring -> Dot msg
circle events radius coloring =
  Dot <| Just <| viewCircle events radius coloring



-- COLORING


{-| -}
type Coloring
  = Bordered Int
  | Filled


{-| -}
filled : Coloring
filled =
  Filled


{-| -}
bordered : Int -> Coloring
bordered =
  Bordered


{-| -}
view : Dot msg -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
view (Dot view) =
  case view of
    Just view ->
      view

    Nothing ->
      \_ _ _ -> Svg.text ""



-- INTERNAL


{-| -}
type alias View msg =
  Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg


viewCircle : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCircle events radius coloring color system point =
  let
    attributes =
      [ Attributes.cx (toString <| toSVG X system <| point.x)
      , Attributes.cy (toString <| toSVG Y system <| point.y)
      , Attributes.r (toString radius)
      ]

    colorAttributes =
      case coloring of
        Bordered width ->
          [ Attributes.stroke color
          , Attributes.strokeWidth (toString width)
          , Attributes.fill "white"
          ]

        Filled ->
          [ Attributes.fill color ]

  in
  Svg.circle (events ++ attributes ++ colorAttributes) []
