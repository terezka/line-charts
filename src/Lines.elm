module Lines exposing
  ( viewSimple
  , view, line, dash
  , viewCustom, Config, Interpolation(..)
  )

{-|

# Lines

## Quick start
@docs viewSimple

## Customize individual lines
@docs view, line, dash

## Customize plot
@docs viewCustom, Config, Interpolation

-}

import Html
import Svg exposing (Svg)
import Svg.Attributes as SvgA
import Lines.Dot as Dot
import Lines.Line as Line
import Lines.Axis as Axis
import Lines.Junk as Junk
import Lines.Color as Color
import Lines.Events as Events
import Lines.Legends as Legends
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Legends
import Internal.Interpolation as Interpolation
import Internal.Coordinate as Coordinate
import Internal.Utils as Utils
import Internal.Path as Path
import Internal.Axis as Axis
import Internal.Junk
import Internal.Events
import Internal.Dot


{-| -}
type alias Config data msg =
  { frame : Coordinate.Frame
  , attributes : List (Svg.Attribute msg)
  , events : List (Events.Event data msg)
  , junk : Junk.Junk msg
  , x : Axis.Axis data msg
  , y : Axis.Axis data msg
  , interpolation : Interpolation
  , legends : Legends.Legends msg
  , line : Line.Look data
  , dot : Dot.Look data
  }


{-| -}
type Interpolation
  = Linear
  | Monotone


-- LINE


{-| -}
type Line data =
  Line (LineConfig data)


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line color shape label data =
  Line <| LineConfig color shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| LineConfig color shape dashing label data



-- VIEW


{-| -}
viewSimple : (data -> Float) -> (data -> Float) -> List (List data) -> Svg.Svg msg
viewSimple toX toY datas =
  if List.length datas > 3 then
    Html.div [] [ Html.text "If you have more than three data sets, you must use `view` or `viewCustom`!" ]
  else
    view toX toY (List.map4 defaultConfig defaultShapes defaultColors defaultLabel datas)


{-| -}
view : (data -> Float) -> (data -> Float) -> List (Line data) -> Svg.Svg msg
view toX toY =
  viewCustom
    { frame = Frame (Margin 40 150 90 150) (Size 650 400)
    , attributes = [ SvgA.style "font-family: monospace;" ] -- TODO: Maybe remove
    , events = []
    , x = Axis.defaultAxis (Axis.defaultTitle "" 0 0) toX
    , y = Axis.defaultAxis (Axis.defaultTitle "" 0 0) toY
    , junk = Junk.none
    , interpolation = Linear
    , legends = Legends.bucketed .max (.min >> (+) 1) -- TODO
    , line = Line.default
    , dot = Dot.default
    }


{-| -}
viewCustom : Config data msg -> List (Line data) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Points
    points =
      List.map (List.map point << .data << lineConfig) lines

    point datum =
      Point
        (config.x.variable datum)
        (config.y.variable datum)

    -- Data points
    dataPoints =
      List.concat <| List.map (List.map dataPoint << .data << lineConfig) lines

    dataPoint datum =
      DataPoint datum (point datum)

    -- System
    allPoints =
      List.concat points

    system =
      { frame = config.frame
      , x = Coordinate.limits .x allPoints
      , y = Coordinate.limits .y allPoints
      }

    -- View
    junk =
      Internal.Junk.getLayers config.junk allPoints system

    container plot =
      Html.div [] (plot :: junk.html)

    attributes =
      List.concat
        [ config.attributes
        , Internal.Events.toSvgAttributes dataPoints system config.events
        , [ SvgA.width <| toString system.frame.size.width
          , SvgA.height <| toString system.frame.size.height
          ]
        ]

    viewLines =
      List.map2 (viewLine config system) lines points

    viewLegends =
      case config.legends of
        Internal.Legends.Free placement view ->
          Svg.g [ SvgA.class "legends" ] <|
            List.map2 (viewLegendFree system placement view) lines points

        Internal.Legends.Bucketed sampleWidth toContainer ->
          toContainer system <|
            List.map (toLegendConfig config system sampleWidth) lines

        Internal.Legends.None ->
          Svg.text ""
  in
  container <|
    Svg.svg attributes
      [ Svg.g [ SvgA.class "junk--below" ] junk.below
      , Svg.g [ SvgA.class "lines" ] viewLines
      , Axis.viewHorizontal system config.x.look
      , Axis.viewVertical system config.y.look
      , viewLegends
      , Svg.g [ SvgA.class "junk--above" ] junk.above
      ]



-- INTERNAL


type alias LineConfig data =
  { color : Color.Color
  , shape : Dot.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


lineConfig : Line data -> LineConfig data
lineConfig (Line lineConfig) =
  lineConfig


defaultConfig : Dot.Shape -> Color.Color -> String -> List data -> Line data
defaultConfig shape color label data =
  Line
    { shape = shape
    , color = color
    , dashing = []
    , data = data
    , label = label
    }


viewLine : Config data msg -> Coordinate.System -> Line data -> List Point -> Svg.Svg msg
viewLine config system line points =
  Svg.g
    [ SvgA.class "line" ]
    [ viewInterpolation config system line points
    , viewDots config system line points
    ]


viewInterpolation : Config data msg -> Coordinate.System -> Line data -> List Point -> Svg.Svg msg
viewInterpolation config system (Line line) points =
  let
    interpolationCommands =
      case config.interpolation of
        Linear ->
          Interpolation.linear points

        Monotone ->
          Interpolation.monotone points

    commands =
      case points of
        first :: rest ->
          Path.Move first :: interpolationCommands

        [] ->
          []

    isEmphasized =
      config.line.isEmphasized line.data

    width =
      if isEmphasized then
        config.line.emphasized.width
      else
        config.line.normal.width

    toColor =
      if isEmphasized then
        config.line.emphasized.color
      else
        config.line.normal.color

    attributes =
      [ SvgA.style "pointer-events: none;"
      , SvgA.class "interpolation"
      , SvgA.stroke (toColor line.color)
      , SvgA.strokeWidth (toString (toFloat width / 2))
      , SvgA.strokeDasharray <| String.join " " (List.map toString line.dashing)
      , SvgA.fill "transparent"
      ]
  in
  Path.view system attributes commands


viewDots : Config data msg -> Coordinate.System -> Line data -> List Point -> Svg.Svg msg
viewDots config system (Line line) points =
  Svg.g [ SvgA.class "dots" ] <|
    List.map2 (\datum point -> Internal.Dot.view config.dot line.shape line.color system <| DataPoint datum point) line.data points


viewLegendFree : Coordinate.System -> Internal.Legends.Placement -> (String -> Svg msg) -> Line data -> List Point -> Svg.Svg msg
viewLegendFree system placement view (Line line) points =
  let
    ( orderedPoints, anchor, xOffset ) =
        case placement of
          Internal.Legends.Beginning ->
            ( points, "end", -10 )

          Internal.Legends.Ending ->
            ( List.reverse points, "start", 10 )
  in
  Utils.viewMaybe (List.head orderedPoints) <| \point ->
    Svg.g
      [ Junk.placeWithOffset system point.x point.y xOffset 3
      , SvgA.style <| "text-anchor: " ++ anchor ++ ";"
      ]
      [ view line.label ]


toLegendConfig : Config data msg -> Coordinate.System -> Float -> Line data -> Legends.Pieces msg
toLegendConfig config system sampleWidth (Line line) =
  { sample = viewSample config system sampleWidth line
  , label = line.label
  }


viewSample : Config data msg -> Coordinate.System -> Float -> LineConfig data -> Svg msg
viewSample config system sampleWidth line =
  Svg.g [ SvgA.class "sample" ]
    [ Svg.line
        [ SvgA.x1 "0"
        , SvgA.y1 "0"
        , SvgA.x2 <| toString sampleWidth
        , SvgA.y2 "0"
        , SvgA.stroke line.color
        , SvgA.strokeWidth (toString (toFloat config.line.normal.width / 2))
        , SvgA.strokeDasharray <| String.join " " (List.map toString line.dashing)
        , SvgA.fill "transparent"
        ]
        []
    , Internal.Dot.viewNormal config.dot line.shape line.color system <|
        toCartesianPoint system <| Point (sampleWidth / 2) 0
    ]



-- DEFAULTS


defaultColors : List Color.Color
defaultColors =
  [ Color.pink
  , Color.blue
  , Color.orange
  ]


defaultShapes : List Dot.Shape
defaultShapes =
  [ Dot.default1
  , Dot.default2
  , Dot.default3
  ]


defaultLabel : List String
defaultLabel =
  [ "Series 1"
  , "Series 2"
  , "Series 3"
  ]
