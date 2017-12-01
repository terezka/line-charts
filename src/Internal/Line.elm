module Internal.Line exposing
  ( Line(..), LineConfig, lineConfig, line, dash, area
  , Look, default, wider, static, emphasizable
  , Style, style
  , view, viewSample
  , setAreaDomain
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
import Internal.Utils as Utils



{-| -}
type Line data =
  Line (LineConfig data)


{-| -}
type alias LineConfig data =
  { color : Color.Color
  , areaOpacity : Maybe Float
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
  Line <| LineConfig color Nothing shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| LineConfig color Nothing shape dashing label data


{-| -}
area : Color.Color -> Dot.Shape -> String -> Float -> List data -> Line data
area color shape label areaOpacity data =
  Line <| LineConfig color (Just areaOpacity) shape [] label data



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
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Int -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- SYSTEM


{-| -}
setAreaDomain : List (Line data) -> Coordinate.Limits -> Coordinate.Limits
setAreaDomain lines limits =
    if List.any isArea lines then
        { limits | min = Basics.min limits.min 0 }
    else
        limits


isArea : Line data -> Bool
isArea (Line line) =
    case line.areaOpacity of
        Just opacity ->
            True

        Nothing ->
            False



-- VIEW


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
  -- TODO prefix classes
  Svg.g [ Attributes.class "line" ]
    [ Utils.viewMaybe line.areaOpacity <|
        viewArea system lineLook interpolation line.color dataPoints
    , viewLine system lineLook interpolation line.color line.dashing dataPoints
    , Svg.g [ Attributes.class "dots" ] <| List.map viewDot dataPoints
    ]


viewLine
  :  Coordinate.System
  -> Look data
  -> Interpolation.Interpolation
  -> Color.Color
  -> List Float
  -> List (DataPoint data)
  -> Svg.Svg msg
viewLine system look interpolation mainColor dashing dataPoints =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest -> Path.Move first.point :: interpolationCommands
        [] -> []

    lineAttributes =
      toLineAttributes look mainColor dashing dataPoints
  in
  Path.view system lineAttributes commands


toLineAttributes : Look data -> Color.Color -> List Float -> List (DataPoint data) -> List (Svg.Attribute msg)
toLineAttributes (Look look) mainColor dashing dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal

    width =
      toFloat style.width / 2
  in
      [ Attributes.style "pointer-events: none;"
      , Attributes.class "interpolation__line"
      , Attributes.stroke (style.color mainColor)
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Attributes.fill "transparent"
      ]


viewArea
  :  Coordinate.System
  -> Look data
  -> Interpolation.Interpolation
  -> Color.Color
  -> List (DataPoint data)
  -> Float
  -> Svg.Svg msg
viewArea system look interpolation mainColor dataPoints opacity =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest ->
          [ Path.Move (Point first.point.x (Utils.towardsZero system.x))
          , Path.Line first.point
          ]
          ++ interpolationCommands ++
          [ Path.Line (Point (getLastX first rest) (Utils.towardsZero system.x)) ]

        [] ->
          []

    getLastX first rest =
      Maybe.withDefault first (Utils.last rest) |> .point |> .x

    attributes =
      toAreaAttributes look mainColor opacity dataPoints
  in
  Path.view system attributes commands


toAreaAttributes : Look data -> Color.Color -> Float -> List (DataPoint data) -> List (Svg.Attribute msg)
toAreaAttributes (Look look) mainColor opacity dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal

    color =
      style.color mainColor
  in
  [ Attributes.class "interpolation__area"
  , Attributes.fill color
  , Attributes.fillOpacity (toString opacity)
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Color.Color -> List Float -> Maybe Float -> Float -> Svg.Svg msg
viewSample look mainColor dashing areaOpacity sampleWidth =
  let
    lineAttributes =
      toLineAttributes look mainColor dashing []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes opacity =
      toAreaAttributes look mainColor opacity []

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width <| toString sampleWidth
      ]

    viewRectangle opacity =
      Svg.rect (areaAttributes opacity ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewMaybe areaOpacity viewRectangle
    ]
