module Lines.Dot exposing
  ( Shape, none, default1, default2, default3
  , circle, triangle, square, diamond, plus, cross
  , bordered, disconnected, aura, full
  , view, viewNormal, default, custom, Style, Look
  , isMaybe, emphasized
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
emphasized : Style -> Style -> (data -> Bool) -> Look data
emphasized normal emphasized isEmphasized =
  Look
    { normal = normal
    , emphasized = emphasized
    , isEmphasized = isEmphasized
    }


{-| -}
type Look data =
  Look
    { normal : Style
    , emphasized : Style
    , isEmphasized : data -> Bool
    }


{-| -}
type Style =
  Style
    { size : Int -- TODO Float
    , variety : Variety
    }


default : Look data
default =
  Look
    { normal = disconnected 4 2
    , emphasized = aura 4 4 0.5
    , isEmphasized = always False
    }


custom : Style -> Look data
custom style =
  Look
    { normal = style
    , emphasized = aura 20 4 0.5
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
bordered : Int -> Int -> Style
bordered size border =
  Style { size = size, variety = Bordered border }


{-| -}
disconnected : Int -> Int -> Style
disconnected size border =
  Style { size = size, variety = Disconnected border }


{-| -}
aura : Int -> Int -> Float -> Style
aura size aura opacity =
  Style { size = size, variety = Aura aura opacity }


{-| -}
full : Int -> Style
full size =
  Style { size = size, variety = Full }


-- Hover helpers


isMaybe : Maybe data -> data -> Bool
isMaybe hovering datum =
  Just datum == hovering



-- VIEW


{-| -}
view : Look data -> Shape -> Color.Color -> Coordinate.System -> Coordinate.DataPoint data -> Svg msg
view (Look config) shape color system dataPoint =
  let
    (Style style) =
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
viewNormal (Look config) shape =
    viewShape shape (getSize config.normal) (getVariety config.normal)



-- INTERNAL


{-| -}
type alias DotConfig data =
  { normal : Style
  , emphasized : Style
  , isEmphasized : data -> Bool
  }


getSize : Style -> Int
getSize (Style style) =
  style.size


getVariety : Style -> Variety
getVariety (Style style) =
  style.variety


viewCircle : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCircle events size variety color system cartesianPoint =
  let
    radius =
      sqrt (toFloat size / pi)

    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ Attributes.cx (toString point.x)
      , Attributes.cy (toString point.y)
      , Attributes.r (toString radius)
      ]
  in
  Svg.circle (events ++ attributes ++ varietyAttributes color variety) []


viewTriangle : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewTriangle events size variety color system cartesianPoint =
  let
    side =
      sqrt <| toFloat size * 4 / (sqrt 3)

    point =
      toSVGPoint system cartesianPoint

    height =
      (sqrt 3) * side / 2

    fromMiddle =
       height - tan (degrees 30) * side / 2

    path =
      Attributes.d <| String.join " "
        [ "M" ++ toString point.x ++ " " ++ toString (point.y - fromMiddle)
        , "l" ++ toString (-side / 2) ++ " " ++ toString height
        , "h" ++ toString side
        , "z"
        ]
  in
  Svg.path (events ++ [ path ] ++ varietyAttributes color variety) []


viewSquare : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewSquare events size variety color system cartesianPoint =
  let
    side =
      sqrt <| toFloat size

    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ Attributes.x <| toString (point.x - side / 2)
      , Attributes.y <| toString (point.y - side / 2)
      , Attributes.width <| toString side
      , Attributes.height <| toString side
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewDiamond : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewDiamond events size variety color system cartesianPoint =
  let
    side =
      sqrt <| toFloat size

    point =
      toSVGPoint system cartesianPoint

    rotation =
      "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

    attributes =
      [ Attributes.x <| toString (point.x - side / 2)
      , Attributes.y <| toString (point.y - side / 2)
      , Attributes.width <| toString side
      , Attributes.height <| toString side
      , Attributes.transform rotation
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewPlus : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewPlus events size variety color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    attributes =
      [ plusPath size point ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewCross : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCross events size variety color system cartesianPoint =
  let
    point =
      toSVGPoint system cartesianPoint

    rotation =
      "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

    attributes =
      [ plusPath size point
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


plusPath : Int -> Point -> Svg.Attribute msg
plusPath size point =
  let
    side =
      sqrt (toFloat size / 5)

    r3 =
      side

    r6 =
      side / 2

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
