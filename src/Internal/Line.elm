module Internal.Line exposing
  ( Line(..), LineConfig, lineConfig, line, dash, grad
  , Look, default, wider, static, emphasizable
  , Style, style
  , view, viewGradient, viewSample
  )

{-| -}

import Svg
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate exposing (DataPoint)
import Internal.Dot as Dot
import Internal.Interpolation as Interpolation
import Internal.Path as Path
import Internal.Utils as Utils



{-| -}
type Line data =
  Line (LineConfig data)


{-| -}
type alias LineConfig data =
  { color : List Color.Color
  , angle : Int
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
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line color shape label data =
  Line <| LineConfig [ color ] 0 shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| LineConfig [ color ] 0 shape dashing label data


{-| -}
grad : List Color.Color -> Int -> Dot.Shape -> String -> List data -> Line data
grad colors angle shape label data =
  Line <| LineConfig colors angle shape [] label data



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
    { normal = style 2 identity
    , emphasized = style 3 identity
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
    , emphasized = style 2 identity
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
    , color : List Color.Color -> List Color.Color
    }


{-| -}
style : Int -> (List Color.Color -> List Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- VIEW


{-| -}
view
  :  Coordinate.System
  -> Dot.Look data
  -> Interpolation.Interpolation
  -> Look data
  -> Float
  -> String
  -> Int
  -> Line data
  -> List (DataPoint data)
  -> Svg.Svg msg
view system dotLook interpolation lineLook areaOpacity id index (Line line) dataPoints =
  let
    color = -- TODO
      List.head line.color |> Maybe.withDefault "black"

    viewDot =
      Dot.view dotLook line.shape color system
  in
  -- TODO prefix classes
  Svg.g [ Attributes.class "line" ]
    [ Utils.viewIf (areaOpacity > 0) <| \() ->
        viewArea system lineLook interpolation line.color areaOpacity id index dataPoints
    , viewLine system lineLook interpolation line.color areaOpacity line.dashing id index dataPoints
    , Svg.g [ Attributes.class "dots" ] <| List.map viewDot dataPoints
    ]



-- VIEW / DEFS


{-| -}
viewGradient : Int -> Line data -> Svg.Svg msg
viewGradient index (Line line) =
  let total = List.length line.color - 1 in
  if total > 1 then
    Svg.linearGradient
      [ Attributes.id <| Utils.toGradientId index
      , Attributes.gradientTransform <| Utils.rotate line.angle
      ] <|
      List.indexedMap (viewGradientColor total) line.color
  else
    Svg.text ""


viewGradientColor : Int -> Int -> Color.Color -> Svg.Svg msg
viewGradientColor total index color =
  Svg.stop
    [ Attributes.stopColor color
    , Attributes.offset <| toString (index * 100 // total) ++ "%"
    ]
    []


-- VIEW / LINE


viewLine
  :  Coordinate.System
  -> Look data
  -> Interpolation.Interpolation
  -> List Color.Color
  -> Float
  -> List Float
  -> String
  -> Int
  -> List (DataPoint data)
  -> Svg.Svg msg
viewLine system look interpolation mainColors areaOpacity dashing id index dataPoints =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest -> Path.Move first.point :: interpolationCommands
        [] -> []

    lineAttributes =
      toLineAttributes look mainColors areaOpacity dashing index dataPoints ++
        [ Attributes.clipPath <| Utils.idRef (Utils.toClipPathId id) ]
  in
  Path.view system lineAttributes commands


toLineAttributes
  :  Look data
  -> List Color.Color
  -> Float
  -> List Float
  -> Int
  -> List (DataPoint data)
  -> List (Svg.Attribute msg)
toLineAttributes (Look look) mainColors areaOpacity dashing index dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal

    width =
      toFloat style.width / 2

    stroke =
      if areaOpacity > 0 then
        "transparent"
      else
        case style.color mainColors of
          [] -> "black"
          [ solid ] -> solid
          gradients -> Utils.idRef <| Utils.toGradientId index
  in
      [ Attributes.style "pointer-events: none;"
      , Attributes.class "interpolation__line"
      , Attributes.stroke stroke
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Attributes.fill "transparent"
      ]



-- VIEW / AREA


viewArea
  :  Coordinate.System
  -> Look data
  -> Interpolation.Interpolation
  -> List Color.Color
  -> Float
  -> String
  -> Int
  -> List (DataPoint data)
  -> Svg.Svg msg
viewArea system look interpolation mainColors opacity id index dataPoints =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest ->
          [ Path.Move (Point first.point.x (Utils.towardsZero system.y))
          , Path.Line first.point
          ]
          ++ interpolationCommands ++
          [ Path.Line (Point (getLastX first rest) (Utils.towardsZero system.y)) ]

        [] ->
          []

    getLastX first rest =
      Maybe.withDefault first (Utils.last rest) |> .point |> .x

    attributes =
      toAreaAttributes look mainColors opacity index dataPoints ++
        [ Attributes.clipPath <| "url(#" ++ Utils.toClipPathId id ++ ")" ]
  in
  Path.view system attributes commands


toAreaAttributes : Look data -> List Color.Color -> Float -> Int -> List (DataPoint data) -> List (Svg.Attribute msg)
toAreaAttributes (Look look) mainColors opacity index dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal

    fill =
      case style.color mainColors of
        [] -> "black"
        [ solid ] -> solid
        gradients -> Utils.idRef <| Utils.toGradientId index
  in
  [ Attributes.class "interpolation__area"
  , Attributes.fill fill
  , Attributes.fillOpacity (toString opacity)
  ]



-- VIEW / SAMPLE


{-| TODO gradients dont work on Svg.line -}
viewSample : Look data -> List Color.Color -> List Float -> Float -> Float -> Int -> Svg.Svg msg
viewSample look mainColors dashing areaOpacity sampleWidth index =
  let
    lineAttributes =
      toLineAttributes look mainColors areaOpacity dashing index []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes =
      toAreaAttributes look mainColors areaOpacity index []

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width <| toString sampleWidth
      ]

    viewRectangle () =
      Svg.rect (areaAttributes ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewIf (areaOpacity > 0) viewRectangle
    ]
