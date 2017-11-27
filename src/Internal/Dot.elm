module Internal.Dot exposing
  ( Look, default, static, emphasizable
  , Shape(..)
  , Style, style, bordered, disconnected, aura, full
  , Variety
  , view, viewSample
  )

{-| -}

import Svg exposing (Svg)
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)



{-| -}
type Look data =
  Look
    { normal : Style
    , emphasized : Style
    , isEmphasized : data -> Bool
    }


{-| -}
default : Look data
default =
  Look
    { normal = disconnected 70 2
    , emphasized = aura 50 4 0.5
    , isEmphasized = always False
    }


{-| -}
static : Style -> Look data
static style =
  Look
    { normal = style
    , emphasized = aura 50 4 0.5
    , isEmphasized = always False
    }


{-| -}
emphasizable : Style -> Style -> (data -> Bool) -> Look data
emphasizable normal emphasized isEmphasized =
  Look
    { normal = normal
    , emphasized = emphasized
    , isEmphasized = isEmphasized
    }



-- STYLE


{-| -}
type Style =
  Style
    { size : Int -- TODO Float
    , variety : Variety
    }


{-| -}
type Variety
  = Bordered Int
  | Disconnected Int
  | Aura Int Float
  | Full


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
style : Int -> Variety -> Style
style size variety =
  Style
    { size = size
    , variety = variety
    }


{-| -}
bordered : Int -> Int -> Style
bordered size border =
  style size (Bordered border)


{-| -}
disconnected : Int -> Int -> Style
disconnected size border =
  style size (Disconnected border)


{-| -}
aura : Int -> Int -> Float -> Style
aura size aura opacity =
  style size (Aura aura opacity)


{-| -}
full : Int -> Style
full size =
  style size Full


-- VIEW


{-| -}
view : Look data -> Shape -> Color.Color -> Coordinate.System -> Coordinate.DataPoint data -> Svg msg
view (Look config) shape color system dataPoint =
  let
    (Style style) =
      if config.isEmphasized dataPoint.data
        then config.emphasized
        else config.normal
  in
  viewShape shape style.size style.variety color system dataPoint.point


{-| -}
viewSample : Look data -> Shape -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewSample (Look config) shape =
  let
    (Style normal) =
      config.normal
  in
  viewShape shape normal.size normal.variety



-- VIEW / INTERNAL


viewShape : Shape -> Int -> Variety -> Color.Color -> Coordinate.System -> Point -> Svg msg
viewShape shape =
  case shape of
    Circle -> viewCircle []
    Triangle -> viewTriangle []
    Square -> viewSquare []
    Diamond -> viewDiamond []
    Cross -> viewCross []
    Plus -> viewPlus []
    None -> \_ _ _ _ _ -> Svg.text ""


viewCircle : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCircle events size variety color system cartesianPoint =
  let
    point = toSVGPoint system cartesianPoint
    radius = sqrt (toFloat size / pi)

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
    point = toSVGPoint system cartesianPoint
    side = sqrt <| toFloat size * 4 / (sqrt 3)
    height = (sqrt 3) * side / 2
    fromMiddle = height - tan (degrees 30) * side / 2

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
    point = toSVGPoint system cartesianPoint
    side = sqrt <| toFloat size

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
    point = toSVGPoint system cartesianPoint
    side = sqrt <| toFloat size
    rotation = "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

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
    point = toSVGPoint system cartesianPoint

    attributes =
      [ plusPath size point ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewCross : List (Svg.Attribute msg) -> Int -> Variety -> Color.Color -> Coordinate.System -> Coordinate.Point -> Svg msg
viewCross events size variety color system cartesianPoint =
  let
    point = toSVGPoint system cartesianPoint
    rotation = "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"

    attributes =
      [ plusPath size point
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


plusPath : Int -> Point -> Svg.Attribute msg
plusPath size point =
  let
    side = sqrt (toFloat size / 5)
    r3 = side
    r6 = side / 2

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
