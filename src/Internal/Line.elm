module Internal.Line exposing
  ( Line(..), Config, lineConfig, line, dash
  , Look, default, wider, static, emphasizable
  , Style, style
  , view, viewSample
  )

{-|


-}

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
  Line (Config data)


{-| -}
type alias Config data =
  { color : Color.Color
  , shape : Dot.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
lineConfig : Line data -> Config data
lineConfig (Line line) =
  line


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line color shape label data =
  Line <| Config color shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| Config color shape dashing label data



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
wider : Float -> Look data
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
    , emphasized = normal
    , isEmphasized = always False
    }


{-| -}
emphasizable :
  { normal : Style
  , emphasized : Style
  , isEmphasized : List data -> Bool
  }
  -> Look data
emphasizable =
  Look



-- STYLE


{-| -}
type Style =
  Style
    { width : Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , interpolation : Interpolation.Interpolation
  , lineLook : Look data
  , areaOpacity : Float
  , id : String
  }


{-| -}
view : Arguments data -> Line data -> List (DataPoint data) -> Svg.Svg msg
view arguments (Line lineConfig) dataPoints =
  let
    isArea =
      arguments.areaOpacity > 0

    viewDot =
      Dot.view
        { system = arguments.system
        , dotLook = arguments.dotLook
        , shape = lineConfig.shape
        , color = lineConfig.color
        }
  in
  Svg.g [ Attributes.class "chart__line" ]
    [ Utils.viewIf isArea (viewArea arguments lineConfig dataPoints)
    , viewLine arguments lineConfig dataPoints
    , Svg.g [ Attributes.class "chart__dots" ] <|
        List.map viewDot dataPoints
    ]



-- VIEW / LINE


viewLine : Arguments data -> Config data -> List (DataPoint data) -> Svg.Svg msg
viewLine { system, lineLook, interpolation, id } linConfig dataPoints =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation (List.map .point dataPoints)

    commands =
      case dataPoints of
        first :: rest -> Path.Move first.point :: interpolationCommands
        [] -> []

    lineAttributes =
      toLineAttributes lineLook linConfig dataPoints ++
        [ Attributes.clipPath <| "url(#" ++ Utils.toClipPathId id ++ ")" ]
  in
  Path.view system lineAttributes commands


toLineAttributes : Look data -> Config data -> List (DataPoint data) -> List (Svg.Attribute msg)
toLineAttributes (Look look) { color, dashing } dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal

    width =
      style.width / 2
  in
      [ Attributes.style "pointer-events: none;"
      , Attributes.class "chart__interpolation__line"
      , Attributes.stroke (style.color color)
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Attributes.fill "transparent"
      ]



-- VIEW / AREA


viewArea : Arguments data -> Config data -> List (DataPoint data) -> () -> Svg.Svg msg
viewArea { system, lineLook, interpolation, areaOpacity, id } lineConfig dataPoints () =
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
      toAreaAttributes lineLook lineConfig areaOpacity dataPoints ++
        [ Attributes.clipPath <| "url(#" ++ Utils.toClipPathId id ++ ")" ]
  in
  Path.view system attributes commands


toAreaAttributes : Look data -> Config data -> Float -> List (DataPoint data) -> List (Svg.Attribute msg)
toAreaAttributes (Look look) { color } opacity dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal
  in
  [ Attributes.class "chart__interpolation__area"
  , Attributes.fill (style.color color)
  , Attributes.fillOpacity (toString opacity)
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Config data ->  Float -> Float -> Svg.Svg msg
viewSample look lineConfig areaOpacity sampleWidth =
  let
    lineAttributes =
      toLineAttributes look lineConfig []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes =
      toAreaAttributes look lineConfig areaOpacity []

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
