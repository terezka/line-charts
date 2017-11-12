module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , bordered, disconnected, aura, full
  , view, viewNormal, default, custom, Style, Look
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
type alias Look data =
  { normal : Style
  , emphasized : Style
  , isEmphasized : data -> Bool
  }


type alias Style =
  { size : Int -- TODO Float
  , variety : Variety
  }


default : Look data
default =
  { normal = Style 4 (disconnected 2)
  , emphasized = Style 4 (aura 4 0.5)
  , isEmphasized = always False
  }


custom : Style -> Look data
custom style =
  { normal = style
  , emphasized = Style 4 (aura 4 0.5)
  , isEmphasized = always False
  }


{-| -}
type Shape
  = None
  | Circle
  | Triangle
  | Square
  | Diamond
  | Cross
  | Plus


{-| -}
none : Shape
none =
  None


{-| -}
circle : Shape
circle =
  Circle


{-| -}
triangle : Shape
triangle =
  Triangle


{-| -}
square : Shape
square =
  Square


{-| -}
diamond : Shape
diamond =
  Diamond


{-| -}
plus : Shape
plus =
  Plus


{-| -}
cross : Shape
cross =
  Cross



-- DEFAULTS


{-| -}
default1 : Shape
default1 =
  circle


{-| -}
default2 : Shape
default2 =
  triangle


{-| -}
default3 : Shape
default3 =
  cross



-- VARIETY


{-| -}
type Variety
  = Bordered Int
  | Disconnected Int
  | Aura Int Float
  | Full


{-| -}
bordered : Int -> Variety
bordered =
  Bordered


{-| -}
disconnected : Int -> Variety
disconnected =
  Disconnected


{-| -}
aura : Int -> Float -> Variety
aura =
  Aura


{-| -}
full : Variety
full =
  Full



-- VIEW


{-| -}
view : Look data -> Shape -> Color.Color -> Coordinate.System -> Coordinate.DataPoint data -> Svg msg
view config shape color system dataPoint =
  let
    style =
      if config.isEmphasized dataPoint.data then
        config.emphasized
      else
        config.normal
  in
  viewShape shape style.size style.variety color system dataPoint.point


viewShape : Shape -> Int -> Variety -> Color.Color -> Coordinate.System -> Point -> Svg msg
viewShape shape =
  case shape of
    Circle ->
      viewCircle []

    Triangle ->
      viewTriangle []

    Square ->
      viewSquare []

    Diamond ->
      viewDiamond []

    Cross ->
      viewCross []

    Plus ->
      viewPlus []

    None ->
      \_ _ _ _ _ -> Svg.text ""


viewNormal : Look data -> Shape -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewNormal config shape =
    viewShape shape config.normal.size config.normal.variety



-- INTERNAL


{-| -}
type alias DotConfig data =
  { normal : Style
  , emphasized : Style
  , isEmphasized : data -> Bool
  }


viewCircle : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCircle events diameter variety color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ Attributes.cx (toString point.x)
      , Attributes.cy (toString point.y)
      , Attributes.r (toString (toFloat diameter / 2))
      ]
  in
  Svg.circle (events ++ attributes ++ varietyAttributes color variety) []


viewTriangle : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewTriangle events radiusInt variety color system cartesianPoint =
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
  Svg.polygon (events ++ attributes ++ varietyAttributes color variety) []


viewSquare : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewSquare events radiusInt variety color system cartesianPoint =
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
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewDiamond : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewDiamond events radiusInt variety color system cartesianPoint =
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
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewPlus : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewPlus events radiusInt variety color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ plusPath radiusInt point ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewCross : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCross events radiusInt variety color system cartesianPoint =
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
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


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
      , "v" ++ toString r3
      ]
  in
  Attributes.d <| String.join " " commands


varietyAttributes : Color.Color -> Variety -> List (Svg.Attribute msg)
varietyAttributes color variety =
  case variety of
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
