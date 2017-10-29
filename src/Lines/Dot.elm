module Lines.Dot exposing (Dot, default2, default3, default1, none, view, bordered, disconnected, full, circle, triangle)

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
default1 : Dot msg
default1 =
  circle [] 4 (disconnected 3)


{-| -}
default2 : Dot msg
default2 =
  circle [] 3 (bordered 2)


{-| -}
default3 : Dot msg
default3 =
  circle [] 3 (full)


-- SHAPES


{-| -}
circle : List (Svg.Attribute msg) -> Int -> Coloring -> Dot msg
circle events radius coloring =
  Dot <| Just <| viewCircle events radius coloring


{-| -}
triangle : List (Svg.Attribute msg) -> Int -> Coloring -> Dot msg
triangle events radius coloring =
  Dot <| Just <| viewTriangle events radius coloring



-- COLORING


{-| -}
type Coloring
  = Bordered Int
  | Disconnected Int
  | Full


{-| -}
bordered : Int -> Coloring
bordered =
  Bordered


{-| -}
disconnected : Int -> Coloring
disconnected =
  Disconnected


{-| -}
full : Coloring
full =
  Full


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
viewCircle events radius coloring color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ Attributes.cx (toString point.x)
      , Attributes.cy (toString point.y)
      , Attributes.r (toString radius)
      ]
  in
  Svg.circle (events ++ attributes ++ colorAttributes color coloring) []


viewTriangle : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewTriangle events radiusInt coloring color system cartesianPoint =
  let
    radius =
      toFloat radiusInt

    point =
      toSVGPoint system cartesianPoint

    -- "200,90 210,105 190,105" for Point 200 100
    shapePoints =
      [ point.x
      , point.y - radius
      , point.x + radius
      , point.y + radius / 2
      , point.x - radius
      , point.y + radius / 2
      ]

    shape =
      String.join " " <| List.map toString shapePoints

    attributes =
      [ Attributes.points shape ]
  in
  Svg.polygon (events ++ attributes ++ colorAttributes color coloring) []


colorAttributes : Color.Color -> Coloring -> List (Svg.Attribute msg)
colorAttributes color coloring =
  case coloring of
    Bordered width ->
      [ Attributes.stroke color
      , Attributes.strokeWidth (toString width)
      , Attributes.fill "white"
      ]

    Disconnected width ->
      [ Attributes.stroke "white"
      , Attributes.strokeWidth (toString width)
      , Attributes.fill color
      ]

    Full ->
      [ Attributes.fill color ]
