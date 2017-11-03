module Lines.Dot exposing
  ( Dot, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , bordered, disconnected, aura, full
  , hoverable
  , view, viewNormal
  )

{-| # Dots

## Quick start
@docs Dot, none, default1, default2, default3

## Customizing dots
_Note:_ When chosing a size for your dot, be aware that
even though the shapes have the same radius, they might
look bigger or smaller in terms of volume depending on
their shape.

@docs circle, triangle, square, diamond, plus, cross
@docs bordered, disconnected, full

## View
I do this for you when drawing your line, this is only if you want
to use it else where.
@docs view

-}

import Svg exposing (Svg)
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)



-- CONFIG


{-| -}
type Dot data msg
  = Dot
      { isHovered : data -> Bool
      , normal : Maybe (View msg)
      , hovered : Maybe (View msg)
      }


type alias DotConfig data msg =
  { isHovered : data -> Bool
  , hovered : Maybe (View msg)
  , normal : Maybe (View msg)
  }


unhovered : Maybe (View msg) -> DotConfig data msg
unhovered =
  DotConfig (always False) Nothing


{-| -}
none : Dot data msg
none =
  Dot (unhovered Nothing)


{-| -}
default1 : Dot data msg
default1 =
  circle [] 4 (disconnected 2)


{-| -}
default2 : Dot data msg
default2 =
  triangle [] 6 (disconnected 2)


{-| -}
default3 : Dot data msg
default3 =
  cross [] 10 (disconnected 2)



-- SHAPES TODO: Use shape type again (?) and base funcs on coloring


{-| -}
circle : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
circle events radius coloring =
  Dot <| unhovered <| Just <| viewCircle events radius coloring


{-| -}
triangle : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
triangle events radius coloring =
  Dot <| unhovered <| Just <| viewTriangle events radius coloring


{-| -}
square : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
square events radius coloring =
  Dot <| unhovered <| Just <| viewSquare events radius coloring


{-| -}
diamond : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
diamond events radius coloring =
  Dot <| unhovered <| Just <| viewDiamond events radius coloring


{-| -}
plus : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
plus events radius coloring =
  Dot <| unhovered <| Just <| viewPlus events radius coloring


{-| -}
cross : List (Svg.Attribute msg) -> Int -> Coloring -> Dot data msg
cross events radius coloring =
  Dot <| unhovered <| Just <| viewCross events radius coloring


{-| TODO -}
custom : (Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg) -> Dot data msg
custom =
  Dot << unhovered << Just



-- COLORING


{-| -}
type Coloring
  = Bordered Int
  | Disconnected Int
  | Aura Int Float
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
aura : Int -> Float -> Coloring
aura =
  Aura


{-| -}
full : Coloring
full =
  Full




-- IRREGULAR


hoverable : (data -> Bool) -> { normal : Dot data msg, hovered : Dot data msg } -> Dot data msg
hoverable isHovered { normal, hovered } =
  let
    unpack (Dot config) =
      config.normal
  in
  Dot <|
    { isHovered = isHovered
    , normal = unpack normal
    , hovered = unpack hovered
    }



-- VIEW


{-| -}
view : Dot data msg -> Color.Color -> Coordinate.System -> Coordinate.DataPoint data -> Svg msg
view (Dot config) color system dataPoint =
  let
    view =
      if config.isHovered dataPoint.data then
        config.hovered
      else
        config.normal
  in
  case view of
    Just view ->
      view color system dataPoint.point

    Nothing ->
      Svg.text ""


viewNormal : Dot data msg -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewNormal (Dot view) color system point =
  case view.normal of
    Just view ->
      view color system point

    Nothing ->
      Svg.text ""



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


viewSquare : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewSquare events radiusInt coloring color system cartesianPoint =
  let
    radius =
      toFloat radiusInt

    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ Attributes.x <| toString (point.x - radius / 2)
      , Attributes.y <| toString (point.y - radius / 2)
      , Attributes.width <| toString radius
      , Attributes.height <| toString radius
      ]
  in
  Svg.rect (events ++ attributes ++ colorAttributes color coloring) []


viewDiamond : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewDiamond events radiusInt coloring color system cartesianPoint =
  let
    radius =
      toFloat radiusInt

    point =
      toSVGPoint system cartesianPoint

    rotation =
      "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

    attributes =
      [ Attributes.x <| toString (point.x - radius / 2)
      , Attributes.y <| toString (point.y - radius / 2)
      , Attributes.width <| toString radius
      , Attributes.height <| toString radius
      , Attributes.transform rotation
      ]
  in
  Svg.rect (events ++ attributes ++ colorAttributes color coloring) []


viewPlus : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewPlus events radiusInt coloring color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ plusPath radiusInt point ]
  in
  Svg.path (events ++ attributes ++ colorAttributes color coloring) []


viewCross : List (Svg.Attribute msg) -> Int -> Coloring -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCross events radiusInt coloring color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    rotation =
      "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

    attributes =
      [ plusPath radiusInt point
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ colorAttributes color coloring) []


plusPath : Int -> Point -> Svg.Attribute msg
plusPath radiusInt point =
  let
    radius =
      toFloat radiusInt

    r3 =
      radius / 3

    r6 =
      r3 / 2

    commands =
      [ "M" ++ toString (point.x - r6) ++ " " ++ toString (point.y - r3 - r6)
      , "v" ++ toString r3
      , "h" ++ toString -r3
      , "v" ++ toString r3
      , "h" ++ toString r3
      , "v" ++ toString r3
      , "h" ++ toString r3
      , "v" ++ toString -r3
      , "h" ++ toString r3
      , "v" ++ toString -r3
      , "h" ++ toString -r3
      , "v" ++ toString -r3
      , "h" ++ toString -r3
      ]
  in
  Attributes.d <| String.join " " commands


colorAttributes : Color.Color -> Coloring -> List (Svg.Attribute msg)
colorAttributes color coloring =
  case coloring of
    Bordered width ->
      [ Attributes.stroke color
      , Attributes.strokeWidth (toString width)
      , Attributes.fill "white"
      ]

    Aura width opacity ->
      [ Attributes.stroke color
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeOpacity (toString opacity)
      , Attributes.fill color
      ]

    Disconnected width ->
      [ Attributes.stroke "white"
      , Attributes.strokeWidth (toString width)
      , Attributes.fill color
      ]

    Full ->
      [ Attributes.fill color ]
