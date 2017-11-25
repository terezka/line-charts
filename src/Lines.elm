module Lines exposing
  ( viewSimple
  , view, line, dash
  , viewCustom, Config
  , Interpolation, linear, monotone
  )

{-|

TODO: Add area
# Lines

## Quick start
@docs viewSimple

## Customize individual lines
@docs view, line, dash

## Customize plot
@docs viewCustom, Config

### Interpolations
@docs Interpolation, linear, monotone

-}

import Html
import Svg exposing (Svg)
import Svg.Attributes as Attributes

import Lines.Axis as Axis
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Lines.Events as Events
import Lines.Junk as Junk
import Lines.Legends as Legends

import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Events
import Internal.Interpolation as Interpolation
import Internal.Junk
import Internal.Legends
import Internal.Line as Line
import Internal.Utils as Utils



-- CONFIG


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



-- INTERPOLATIONS


{-| -}
type alias Interpolation =
  Interpolation.Interpolation


{-| -}
linear : Interpolation
linear =
  Interpolation.Linear


{-| -}
monotone : Interpolation
monotone =
  Interpolation.Monotone



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



-- VIEW / SIMPLE


{-| -}
viewSimple : (data -> Float) -> (data -> Float) -> List (List data) -> Svg.Svg msg
viewSimple toX toY datas =
  if List.length datas > 3 then
    Html.div [] [ Html.text "If you have more than three data sets, you must use `view` or `viewCustom`!" ]
  else
    view toX toY (List.map4 defaultConfig defaultShapes defaultColors defaultLabel datas)



-- VIEW / NORMAL


{-| -}
view : (data -> Float) -> (data -> Float) -> List (Line data) -> Svg.Svg msg
view toX toY =
  viewCustom
    { frame = Coordinate.Frame (Coordinate.Margin 40 150 90 150) (Coordinate.Size 650 400)
    , attributes = [ Attributes.style "font-family: monospace;" ] -- TODO: Maybe remove
    , events = []
    , x = Axis.defaultAxis (Axis.defaultTitle "" 0 0) toX
    , y = Axis.defaultAxis (Axis.defaultTitle "" 0 0) toY
    , junk = Junk.none
    , interpolation = linear
    , legends = Legends.bucketed .max (.min >> (+) 1) -- TODO
    , line = Line.default
    , dot = Dot.default
    }



-- VIEW / CUSTOM


{-| -}
viewCustom : Config data msg -> List (Line data) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Data points
    dataPoints =
      List.map (List.map dataPoint << .data << lineConfig) lines

    dataPoint datum =
      Coordinate.DataPoint datum (point datum)

    point datum =
      Coordinate.Point
        (config.x.variable datum)
        (config.y.variable datum)

    -- System
    allPoints =
      List.concat dataPoints

    system =
      { frame = config.frame
      , x = Coordinate.limits (.point >> .x) allPoints
      , y = Coordinate.limits (.point >> .y) allPoints
      }

    -- View
    junk =
      Internal.Junk.getLayers config.junk system

    container plot =
      Html.div [] (plot :: junk.html)

    attributes =
      List.concat
        [ config.attributes
        , Internal.Events.toSvgAttributes allPoints system config.events
        , [ Attributes.width <| toString system.frame.size.width
          , Attributes.height <| toString system.frame.size.height
          ]
        ]

    viewLines =
      List.map2 (viewLine config system) lines dataPoints

    viewLegends =
      case config.legends of -- TODO move to legends module
        Internal.Legends.Free placement view ->
          Svg.g [ Attributes.class "legends" ] <|
            List.map2 (viewLegendFree system placement view) lines dataPoints

        Internal.Legends.Bucketed sampleWidth toContainer ->
          toContainer system <|
            List.map (toLegendConfig config system sampleWidth) lines

        Internal.Legends.None ->
          Svg.text ""
  in
  container <|
    Svg.svg attributes
      [ Svg.g [ Attributes.class "junk--below" ] junk.below
      , Svg.g [ Attributes.class "lines" ] viewLines
      , Axis.viewHorizontal system config.x.look
      , Axis.viewVertical system config.y.look
      , viewLegends
      , Svg.g [ Attributes.class "junk--above" ] junk.above
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
lineConfig (Line line) =
  line


defaultConfig : Dot.Shape -> Color.Color -> String -> List data -> Line data
defaultConfig shape color label data =
  Line
    { shape = shape
    , color = color
    , dashing = []
    , data = data
    , label = label
    }


viewLine : Config data msg -> Coordinate.System -> Line data -> List (Coordinate.DataPoint data) -> Svg.Svg msg
viewLine config system (Line line) dataPoints =
  let
    viewDot dataPoint =
      Dot.view config.dot line.shape line.color system dataPoint
  in
  Svg.g
    [ Attributes.class "line" ] -- TODO prefix classes
    [ Line.view config.line config.interpolation system line.color line.dashing dataPoints
    , Svg.g [ Attributes.class "dots" ] <| List.map viewDot dataPoints
    ]


viewLegendFree : Coordinate.System -> Internal.Legends.Placement -> (String -> Svg msg) -> Line data -> List (Coordinate.DataPoint data) -> Svg.Svg msg
viewLegendFree system placement view (Line line) dataPoints =
  let
    ( orderedPoints, anchor, xOffset ) =
        case placement of
          Internal.Legends.Beginning ->
            ( dataPoints, "end", -10 )

          Internal.Legends.Ending ->
            ( List.reverse dataPoints, "start", 10 )
  in
  Utils.viewMaybe (List.head orderedPoints) <| \{ point } ->
    Svg.g
      [ Junk.transform [ Junk.move system point.x point.y, Junk.offset xOffset 3 ]
      , Attributes.style <| "text-anchor: " ++ anchor ++ ";"
      ]
      [ view line.label ]


toLegendConfig : Config data msg -> Coordinate.System -> Float -> Line data -> Legends.Pieces msg
toLegendConfig config system sampleWidth (Line line) =
  { sample = viewSample config system sampleWidth line
  , label = line.label
  }


viewSample : Config data msg -> Coordinate.System -> Float -> LineConfig data -> Svg msg
viewSample config system sampleWidth line =
  let
    middle =
      Coordinate.toCartesianPoint system <| Coordinate.Point (sampleWidth / 2) 0
  in
  Svg.g
    [ Attributes.class "sample" ]
    [ Line.viewSample config.line line.color line.dashing sampleWidth
    , Dot.viewNormal config.dot line.shape line.color system middle
    ]



-- INTERNAL / DEFAULTS


defaultColors : List Color.Color
defaultColors =
  [ Color.pink
  , Color.blue
  , Color.orange
  ]


defaultShapes : List Dot.Shape
defaultShapes =
  [ Dot.Circle
  , Dot.Triangle
  , Dot.Cross
  ]


defaultLabel : List String
defaultLabel =
  [ "Series 1"
  , "Series 2"
  , "Series 3"
  ]
