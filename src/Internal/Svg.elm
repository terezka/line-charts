module Internal.Svg exposing (..)


import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Path as Path exposing (..)
import Internal.Utils exposing (..)



-- AXIS PRIMITIVES


horizontal : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Svg msg
horizontal system userAttributes y x1 x2 =
  let
    attributes =
      concat [ Attributes.stroke Color.gray ] userAttributes []
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
      concat [ Attributes.stroke Color.gray ] userAttributes []
  in
    Path.view system attributes
      [ Move { x = x, y = y1 }
      , Line { x = x, y = y1 }
      , Line { x = x, y = y2 }
      ]


xTicks : Coordinate.System -> Int -> List (Attribute msg) -> Float -> List Float -> Svg msg
xTicks system height userAttributes y xs =
  g [ Attributes.class "x-ticks" ] (List.map (xTick system height userAttributes y) xs)


xTick : Coordinate.System -> Int -> List (Attribute msg) -> Float -> Float -> Svg msg
xTick system height userAttributes y x =
  let
    attributes =
      concat
        [ Attributes.stroke Color.gray ]
        userAttributes
        [ Attributes.x1 <| toString (toSVGX system x)
        , Attributes.x2 <| toString (toSVGX system x)
        , Attributes.y1 <| toString (toSVGY system y)
        , Attributes.y2 <| toString (toSVGY system y + toFloat height)
        ]
  in
    Svg.line attributes []


yTicks : Coordinate.System -> Int -> List (Attribute msg) -> Float -> List Float -> Svg msg
yTicks system width userAttributes x ys =
  g [ Attributes.class "y-ticks" ] (List.map (yTick system width userAttributes x) ys)


yTick : Coordinate.System -> Int -> List (Attribute msg) -> Float -> Float -> Svg msg
yTick system width userAttributes x y =
  let
    attributes =
      concat
        [ Attributes.class "tick"
        , Attributes.stroke Color.gray
        ]
        userAttributes
        [ Attributes.x1 <| toString (toSVGX system x)
        , Attributes.x2 <| toString (toSVGX system x - toFloat width)
        , Attributes.y1 <| toString (toSVGY system y)
        , Attributes.y2 <| toString (toSVGY system y)
        ]
  in
    Svg.line attributes []



-- ANCHOR


{-| -}
type Anchor
  = Start
  | Middle
  | End


{-| -}
anchorStyle : Anchor -> Svg.Attribute msg
anchorStyle anchor =
  let
    anchorString =
      case anchor of
        Start -> "start"
        Middle -> "middle"
        End -> "end"
  in
  Attributes.style <| "text-anchor: " ++ anchorString ++ ";"



-- TRANSFORM


{-| -}
type Transfrom =
  Transfrom Float Float


{-| -}
move : Coordinate.System -> Float -> Float -> Transfrom
move system x y =
  Transfrom (toSVGX system x) (toSVGY system y)


{-| -}
offset : Float -> Float -> Transfrom
offset x y =
  Transfrom x y


{-| -}
transform : List Transfrom -> Svg.Attribute msg
transform translations =
  let
    (Transfrom x y) =
      toPosition translations
  in
  Attributes.transform <|
    "translate(" ++ toString x ++ ", " ++ toString y ++ ")"


toPosition : List Transfrom -> Transfrom
toPosition =
  List.foldr addPosition (Transfrom 0 0)


addPosition : Transfrom -> Transfrom -> Transfrom
addPosition (Transfrom x y) (Transfrom xf yf) =
  Transfrom (xf + x) (yf + y)
