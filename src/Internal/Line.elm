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
import Lines.Junk as Junk
import Internal.Area as Area
import Internal.Coordinate exposing (DataPoint, Data)
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
    { normal = style 1 identity
    , emphasized = style 2 identity
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
  , area : Area.Area
  , id : String
  }


{-| -}
view : Arguments data -> Line data -> Data data -> Svg.Svg msg
view arguments (Line lineConfig) dataPoints =
  let
    system =
      arguments.system

    isWithinRange ({ point } as dataPoint) =
      if clamp system.x.min system.x.max point.x == point.x &&
         clamp system.y.min system.y.max point.y == point.y
      then Just dataPoint else Nothing

    dataPointsWithinRange =
      List.filterMap (Maybe.andThen isWithinRange) dataPoints

    hasArea =
      Area.hasArea arguments.area

    viewDot =
      Dot.view
        { system = arguments.system
        , dotLook = arguments.dotLook
        , shape = lineConfig.shape
        , color = lineConfig.color
        }

    toParts points current parts =
      case points of
        Just point :: rest -> toParts rest (point :: current) parts
        Nothing :: rest    -> toParts rest [] (current :: parts)
        []                 -> current :: parts

    parts =
      toParts dataPoints [] []

    commands =
      Interpolation.toCommands arguments.interpolation <|
        List.map (List.map .point) parts

    viewAreaParts () =
      Svg.g [ Attributes.class "chart__area-parts" ] <|
        List.map2 (viewArea arguments lineConfig dataPoints) commands parts
  in
  Svg.g [ Attributes.class "chart__line" ]
    [ Utils.viewIf hasArea viewAreaParts
    , Svg.g [ Attributes.class "chart__line-parts" ] <|
        List.map2 (viewLine arguments lineConfig dataPoints) commands parts
    , Svg.g [ Attributes.class "chart__dots" ] <|
        List.map viewDot dataPointsWithinRange
    ]



-- VIEW / LINE


viewLine : Arguments data -> Config data -> Data data -> List Path.Command -> List (DataPoint data) -> Svg.Svg msg
viewLine { system, lineLook, interpolation, id } lineConfig data commands dataPoints =
  let
    lineAttributes =
      toLineAttributes lineLook lineConfig data ++
        [ Junk.withinChartArea system ]
  in
  case dataPoints of
    first :: rest ->
      Path.view system lineAttributes (Path.Move first.point :: commands)

    [] ->
      Path.view system lineAttributes []


toLineAttributes : Look data -> Config data -> Data data -> List (Svg.Attribute msg)
toLineAttributes (Look look) { color, dashing } dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data <| List.filterMap identity dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal
  in
      [ Attributes.style "pointer-events: none;"
      , Attributes.class "chart__interpolation__line"
      , Attributes.stroke (style.color color)
      , Attributes.strokeWidth (toString style.width)
      , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Attributes.fill "transparent"
      ]



-- VIEW / AREA


viewArea : Arguments data -> Config data -> Data data -> List Path.Command -> List (DataPoint data) -> Svg.Svg msg
viewArea { system, lineLook, interpolation, area, id } lineConfig data commands dataPoints =
  let
    getLastX first rest =
      Maybe.withDefault first (Utils.last rest) |> .point |> .x

    attributes =
      toAreaAttributes lineLook lineConfig area data ++
        [ Attributes.clipPath <| "url(#" ++ Utils.toChartAreaId id ++ ")" ]
  in
  case dataPoints of
    first :: rest ->
      Path.view system attributes <|
        [ Path.Move (Point first.point.x (Utils.towardsZero system.y))
        , Path.Line first.point
        ]
        ++ commands ++
        [ Path.Line (Point (getLastX first rest) (Utils.towardsZero system.y)) ]

    [] ->
      Path.view system attributes []


toAreaAttributes : Look data -> Config data -> Area.Area -> Data data -> List (Svg.Attribute msg)
toAreaAttributes (Look look) { color } area dataPoints =
  let
    isEmphasized =
      look.isEmphasized (List.map .data <| List.filterMap identity dataPoints)

    (Style style) =
      if isEmphasized
        then look.emphasized
        else look.normal
  in
  [ Attributes.class "chart__interpolation__area"
  , Attributes.fill (style.color color)
  , Attributes.fillOpacity (toString <| Area.opacity area)
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Config data -> Area.Area -> Float -> Svg.Svg msg
viewSample look lineConfig area sampleWidth =
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
      toAreaAttributes look lineConfig area []

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
    , Utils.viewIf (Area.hasArea area) viewRectangle
    ]
