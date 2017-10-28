module Internal.Primitives exposing (..)

import Internal.Utils exposing (..)
import Svg exposing (Attribute, Svg, g)
import Svg.Attributes as Attributes exposing (class, fill, style, x1, x2, y1, y2, stroke, d)
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Color as Color
import Internal.Path as Path exposing (..)



-- AXIS


horizontal : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Svg msg
horizontal system userAttributes y x1 x2 =
  let
    attributes =
      concat [ stroke Color.gray ] userAttributes []
  in
    Path.view system attributes
      [ Move { x = x1, y = y }
      , Line { x = x1, y = y }
      , Line { x = x2, y = y }
      ]


vertical : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Svg msg
vertical system userAttributes x y1 y2 =
  let
    attributes =
      concat [ stroke Color.gray ] userAttributes []
  in
    Path.view system attributes
      [ Move { x = x, y = y1 }
      , Line { x = x, y = y1 }
      , Line { x = x, y = y2 }
      ]


xTicks : Coordinate.System -> Int -> List (Attribute msg) -> Float -> List Float -> Svg msg
xTicks system height userAttributes y xs =
  g [ class "x-ticks" ] (List.map (xTick system height userAttributes y) xs)


xTick : Coordinate.System -> Int -> List (Attribute msg) -> Float -> Float -> Svg msg
xTick system height userAttributes y x =
  let
    attributes =
      concat
        [ stroke Color.gray ]
        userAttributes
        [ Attributes.x1 <| toString (toSVG X system x)
        , Attributes.x2 <| toString (toSVG X system x)
        , Attributes.y1 <| toString (toSVG Y system y)
        , Attributes.y2 <| toString (toSVG Y system y + toFloat height)
        ]
  in
    Svg.line attributes []


yTicks : Coordinate.System -> Int -> List (Attribute msg) -> Float -> List Float -> Svg msg
yTicks system width userAttributes x ys =
  g [ class "y-ticks" ] (List.map (yTick system width userAttributes x) ys)


yTick : Coordinate.System -> Int -> List (Attribute msg) -> Float -> Float -> Svg msg
yTick system width userAttributes x y =
  let
    attributes =
      concat
        [ class "tick", stroke Color.gray ]
        userAttributes
        [ Attributes.x1 <| toString (toSVG X system x)
        , Attributes.x2 <| toString (toSVG X system x - toFloat width)
        , Attributes.y1 <| toString (toSVG Y system y)
        , Attributes.y2 <| toString (toSVG Y system y)
        ]
  in
    Svg.line attributes []



-- BARS


{-| -}
horizontalBarCommands : Coordinate.System -> Int -> Float -> Point -> List Command
horizontalBarCommands system borderRadius width { x, y }  =
  let
    b =
      toFloat borderRadius

    rx =
      scaleCartesian X system b

    ry =
      scaleCartesian Y system b
  in
  [ Move <| Point 0 y
  , Line <| Point (x - rx) y
  , Arc b b -45 False True <| Point x (y - ry)
  , Line <| Point x (y - width + ry)
  , Arc b b 45 False True <| Point (x - rx) (y - width)
  , Line <| Point 0 (y - width)
  ]


{-| -}
verticalBarCommands : Coordinate.System -> Int -> Float -> Point -> List Command
verticalBarCommands system borderRadius width { x, y }  =
  let
    b =
      toFloat borderRadius

    rx =
      scaleCartesian X system b

    ry =
      scaleCartesian Y system b
  in
  [ Move <| Point x 0
  , Line <| Point x (y - ry)
  , Arc b b -45 False True <| Point (x + rx) y
  , Line <| Point (x + width - rx) y
  , Arc b b -45 False True <| Point (x + width) (y - ry)
  , Line <| Point (x + width) 0
  ]
