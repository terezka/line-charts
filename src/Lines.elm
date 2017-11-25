module Lines exposing
  ( viewSimple
  , view, line, dash
  , viewCustom, Config
  , Interpolation, linear, monotone
  )

{-|

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

import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Events
import Internal.Interpolation as Interpolation
import Internal.Junk
import Internal.Legends as Legends
import Internal.Line as Line



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
type alias Line data =
  Line.Line data


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line =
  Line.line


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash =
  Line.dash


-- TODO: Add area



-- VIEW / SIMPLE


{-| -}
viewSimple : (data -> Float) -> (data -> Float) -> List (List data) -> Svg.Svg msg
viewSimple toX toY data =
  if List.length data > 3
    then viewError
    else view toX toY (defaultLines data)



-- VIEW


{-| -}
view : (data -> Float) -> (data -> Float) -> List (Line data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)



-- VIEW / CUSTOM


{-| -}
viewCustom : Config data msg -> List (Line data) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Data points
    dataPoints =
      List.map (List.map dataPoint << .data << Line.lineConfig) lines

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

    viewLine =
      Line.view system config.dot config.interpolation config.line

    viewLines =
      List.map2 viewLine lines dataPoints

    viewLegends =
      Legends.view system config.line config.dot config.legends lines dataPoints
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



-- VIEW / ERROR


viewError : Html.Html msg
viewError =
  Html.div []
    [ Html.text
        """
        If you have more than three data sets,
        you must use `view` or `viewCustom`!
        """
    ]



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
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


defaultLines : List (List data) -> List (Line data)
defaultLines =
  List.map4 Line.defaultLine defaultShapes defaultColors defaultLabel


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
