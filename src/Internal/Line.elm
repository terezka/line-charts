module Internal.Line exposing
  ( Line(..), LineConfig, lineConfig, defaultLine, line, dash
  , Look, default, wider, static, emphasizable
  , Style, style
  , view, viewSample
  )

{-| -}

import Svg
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Dot as Dot
import Internal.Interpolation as Interpolation
import Internal.Path as Path



{-| -}
type Line data =
  Line (LineConfig data)


{-| -}
type alias LineConfig data =
  { color : Color.Color
  , shape : Dot.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
lineConfig : Line data -> LineConfig data
lineConfig (Line line) =
  line


{-| -}
defaultLine : Dot.Shape -> Color.Color -> String -> List data -> Line data
defaultLine shape color label data =
  Line <| LineConfig color shape [] label data


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line color shape label data =
  Line <| LineConfig color shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| LineConfig color shape dashing label data



-- LOOK


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
view
  :  Coordinate.System
  -> Dot.Look data
  -> Interpolation.Interpolation
  -> Look data
  -> Line data
  -> List (Coordinate.DataPoint data)
  -> Svg.Svg msg
view system dotLook interpolation lineLook (Line line) dataPoints =
  let
    viewDot =
      Dot.view dotLook line.shape line.color system
  in
  Svg.g
    [ Attributes.class "line" ] -- TODO prefix classes
    [ viewInterpolation system lineLook interpolation line.color line.dashing dataPoints
    , Svg.g [ Attributes.class "dots" ] <| List.map viewDot dataPoints
    ]


{-| -}
viewInterpolation : Coordinate.System -> Look data -> Interpolation.Interpolation -> Color.Color -> List Float -> List (DataPoint data) -> Svg.Svg msg
viewInterpolation system look interpolation mainColor dashing dataPoints =
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
      [ Attributes.style "pointer-events: none;"
      , Attributes.class "interpolation"
      , Attributes.stroke (style.color mainColor)
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Attributes.fill "transparent"
      ]


{-| -}
viewSample : Look data -> Color.Color -> List Float -> Float -> Svg.Svg msg
viewSample look mainColor dashing sampleWidth =
  let
    lookAttributes =
      toAttributes look mainColor dashing []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]
  in
  Svg.line (lookAttributes ++ sizeAttributes) []
