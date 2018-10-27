module Internal.Dots exposing
  ( Config, default, custom, customAny
  , Shape(..)
  , Style, style, empty, disconnected, aura, full
  , Variety
  , view, viewSample
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Data as Data
import Color



{-| -}
type Config data =
  Config
    { legend : List data -> Style
    , individual : data -> Style
    }


{-| -}
default : Config data
default =
  Config
    { legend = \_ -> disconnected 10 2
    , individual = \_ -> disconnected 10 2
    }


{-| -}
custom : Style -> Config data
custom style_ =
  Config
    { legend = \_ -> style_
    , individual = \_ -> style_
    }


{-| -}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Config



-- STYLE


{-| -}
type Style =
  Style StyleConfig


{-| -}
type alias StyleConfig =
  { radius : Float
  , variety : Variety
  }


{-| -}
type Variety
  = Empty Int
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
style : Float -> Variety -> Style
style radius variety =
  Style
    { radius = radius
    , variety = variety
    }


{-| -}
empty : Float -> Int -> Style
empty radius border =
  style radius (Empty border)


{-| -}
disconnected : Float -> Int -> Style
disconnected radius border =
  style radius (Disconnected border)


{-| -}
aura : Float -> Int -> Float -> Style
aura radius aura_ opacity =
  style radius (Aura aura_ opacity)


{-| -}
full : Float -> Style
full radius =
  style radius Full


-- INTERNAL / VIEW


{-| -}
type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Config data
  , shape : Shape
  , color : Color.Color
  }


{-| -}
view : Arguments data -> Data.Data data -> Svg msg
view { system, dotsConfig, shape, color } data =
  let
    (Config config) =
      dotsConfig

    (Style style_) =
      config.individual data.user
  in
  viewShape system style_ shape color data.point


{-| -}
viewSample : Config data -> Shape -> Color.Color -> Coordinate.System -> List (Data.Data data) -> Coordinate.Point -> Svg msg
viewSample (Config config) shape color system data =
  let
    (Style style_) =
       config.legend (List.map .user data)
  in
  viewShape system style_ shape color



-- INTERNAL / VIEW / PARTS


viewShape : Coordinate.System -> StyleConfig -> Shape -> Color.Color -> Point -> Svg msg
viewShape system { radius, variety } shape color point =
  let size = 2 * pi * radius
      pointSvg = toSvg system point
      view_ =
        case shape of
          Circle   -> viewCircle
          Triangle -> viewTriangle
          Square   -> viewSquare
          Diamond  -> viewDiamond
          Cross    -> viewCross
          Plus     -> viewPlus
          None     -> \_ _ _ _ _ -> Svg.text ""
  in
  view_ [] variety color size pointSvg



viewCircle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCircle events variety color area point =
  let
    radius = sqrt (area / pi)
    attributes =
      [ Attributes.cx (String.fromFloat point.x)
      , Attributes.cy (String.fromFloat point.y)
      , Attributes.r (String.fromFloat radius)
      ]
  in
  Svg.circle (events ++ attributes ++ varietyAttributes color variety) []


viewTriangle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewTriangle events variety color area point =
  let
    attributes =
      [ Attributes.d (pathTriangle area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewSquare : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewSquare events variety color area point =
  let
    side = sqrt area
    attributes =
      [ Attributes.x <| String.fromFloat (point.x - side / 2)
      , Attributes.y <| String.fromFloat (point.y - side / 2)
      , Attributes.width <| String.fromFloat side
      , Attributes.height <| String.fromFloat side
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewDiamond : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewDiamond events variety color area point =
  let
    side = sqrt area
    rotation = "rotate(45 " ++ String.fromFloat point.x ++ " " ++ String.fromFloat point.y  ++ ")"
    attributes =
      [ Attributes.x <| String.fromFloat (point.x - side / 2)
      , Attributes.y <| String.fromFloat (point.y - side / 2)
      , Attributes.width <| String.fromFloat side
      , Attributes.height <| String.fromFloat side
      , Attributes.transform rotation
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewPlus : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewPlus events variety color area point =
  let
    attributes =
      [ Attributes.d (pathPlus area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewCross : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCross events variety color area point =
  let
    rotation = "rotate(45 " ++ String.fromFloat point.x ++ " " ++ String.fromFloat point.y  ++ ")"
    attributes =
      [ Attributes.d (pathPlus area point)
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []



-- INTERNAL / PATHS


pathTriangle : Float -> Point -> String
pathTriangle area point =
  let
    side = sqrt <| area * 4 / (sqrt 3)
    height = (sqrt 3) * side / 2
    fromMiddle = height - tan (degrees 30) * side / 2

    commands =
      [ "M" ++ String.fromFloat point.x ++ " " ++ String.fromFloat (point.y - fromMiddle)
      , "l" ++ String.fromFloat (-side / 2) ++ " " ++ String.fromFloat height
      , "h" ++ String.fromFloat side
      , "z"
      ]
  in
  String.join " " commands


pathPlus : Float -> Point -> String
pathPlus area point =
  let
    side = sqrt (area / 5)
    r3 = side
    r6 = side / 2

    commands =
      [ "M" ++ String.fromFloat (point.x - r6) ++ " " ++ String.fromFloat (point.y - r3 - r6)
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat r3
      ]
  in
  String.join " " commands



-- INTERNAL / STYLE ATTRIBUTES


varietyAttributes : Color.Color -> Variety -> List (Svg.Attribute msg)
varietyAttributes color variety =
  case variety of
    Empty width ->
      [ Attributes.stroke (Color.toCssString color)
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.fill "white"
      ]

    Aura width opacity ->
      [ Attributes.stroke (Color.toCssString color)
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.strokeOpacity (String.fromFloat opacity)
      , Attributes.fill (Color.toCssString color)
      ]

    Disconnected width ->
      [ Attributes.stroke "white"
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.fill (Color.toCssString color)
      ]

    Full ->
      [ Attributes.fill (Color.toCssString color) ]
