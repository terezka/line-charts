module Internal.Line exposing (Look, Style, style,  default, wider, static, emphasizable, view, viewSample)

{-| -}

import Svg
import Svg.Attributes
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Interpolation as Interpolation
import Internal.Path as Path



{-| -}
type Look data =
  Look
    { normal : Style
    , emphasized : Style
    , isEmphasized : List data -> Bool
    }


{-| -}
default : Look data
default =
  Look
    { normal = style 1 identity
    , emphasized = style 2 identity
    , isEmphasized = always False
    }


{-| -}
wider : Int -> Look data
wider width =
  Look
    { normal = style width identity
    , emphasized = style width identity
    , isEmphasized = always False
    }


{-| -}
static : Style -> Look data
static normal =
  Look
    { normal = normal
    , emphasized = style 1 identity
    , isEmphasized = always False
    }


{-| -}
emphasizable : Style -> Style -> (List data -> Bool) -> Look data
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
    { width : Int -- TODO Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Int -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }


{-| -}
view : Look data -> Interpolation.Interpolation -> Coordinate.System -> Color.Color -> List Float -> List (DataPoint data) -> Svg.Svg msg
view look interpolation system mainColor dashing dataPoints =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest ->
          Path.Move first.point :: interpolationCommands

        [] ->
          []

    attributes =
      toAttributes look mainColor dashing dataPoints
  in
  Path.view system attributes commands


toAttributes : Look data -> Color.Color -> List Float -> List (DataPoint data) -> List (Svg.Attribute msg)
toAttributes (Look look) mainColor dashing dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized then
        look.emphasized
      else
        look.normal

    width =
      toFloat style.width / 2
  in
      [ Svg.Attributes.style "pointer-events: none;"
      , Svg.Attributes.class "interpolation"
      , Svg.Attributes.stroke (style.color mainColor)
      , Svg.Attributes.strokeWidth (toString width)
      , Svg.Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Svg.Attributes.fill "transparent"
      ]


{-| -}
viewSample : Look data -> Color.Color -> List Float -> Float -> Svg.Svg msg
viewSample look mainColor dashing sampleWidth =
  let
    lookAttributes =
      toAttributes look mainColor dashing []

    sizeAttributes =
      [ Svg.Attributes.x1 "0"
      , Svg.Attributes.y1 "0"
      , Svg.Attributes.x2 <| toString sampleWidth
      , Svg.Attributes.y2 "0"
      ]
  in
  Svg.line (lookAttributes ++ sizeAttributes) []
