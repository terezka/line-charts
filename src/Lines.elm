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
import Svg
import Svg.Attributes as SvgA
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Junk as Junk
import Lines.Color as Color
import Lines.Container as Container
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Interpolation as Interpolation
import Internal.Coordinate as Coordinate
import Internal.Attributes as IntA
import Internal.Path as Path
import Internal.Axis as Axis
import Internal.Junk


{-| -}
type alias Config data msg =
  { container : Container.Config msg
  , junk : Junk.Junk msg
  , x : Axis.Axis data msg
  , y : Axis.Axis data msg
  , interpolation : Interpolation
  }


{-| -}
type Interpolation
  = Linear
  | Monotone



-- LINE


{-| -}
type Line data msg =
  Line (LineConfig data msg)


{-| -}
line : Color.Color -> Int -> Dot.Dot msg -> List data -> Line data msg
line color width dot data =
  Line <| LineConfig color width dot "" data


{-| -}
dash : Color.Color -> Int -> Dot.Dot msg -> String -> List data -> Line data msg
dash color width dot dashing data =
  Line <| LineConfig color width dot dashing data



-- VIEW


{-| -}
viewSimple : (data -> Float) -> (data -> Float) -> List (List data) -> Svg.Svg msg
viewSimple toX toY datas =
  view toX toY (List.map3 defaultConfig defaultDots defaultColors datas)


{-| -}
view : (data -> Float) -> (data -> Float) -> List (Line data msg) -> Svg.Svg msg
view toX toY =
  viewCustom
    { container = Container.default
    , x = Axis.Axis Axis.defaultLook toX
    , y = Axis.Axis Axis.defaultLook toY
    , junk = Junk.none
    , interpolation = Linear
    }


{-| -}
viewCustom : Config data msg -> List (Line data msg) -> Svg.Svg msg
viewCustom config lines =
  let
    -- Points
    points =
      List.map (List.map point << .data << lineConfig) lines

    point datum =
      Point
        (config.x.variable datum)
        (config.y.variable datum)

    -- System
    allPoints =
      List.concat points

    system =
      { frame = config.container.frame
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
        [ IntA.toSvgAttributes system config.container.attributes
        , [ SvgA.width <| toString system.frame.size.width
          , SvgA.height <| toString system.frame.size.height
          ]
        ]

    viewLines =
      List.map2 (viewLine config system) lines points
  in
  container <|
    Svg.svg attributes
      [ Svg.defs [] config.container.defs
      , Svg.g [ SvgA.class "junk--below" ] junk.below
      , Svg.g [ SvgA.class "lines" ] viewLines
      , Axis.viewHorizontal system config.x.look
      , Axis.viewVertical system config.y.look
      , Svg.g [ SvgA.class "junk--above" ] junk.above
      ]



-- INTERNAL


type alias LineConfig data msg =
  { color : Color.Color
  , width : Int
  , dot : Dot.Dot msg
  , dashing : String
  , data : List data
  }


lineConfig : Line data msg -> LineConfig data msg
lineConfig (Line lineConfig) =
  lineConfig


defaultConfig : Dot.Dot msg -> Color.Color -> List data -> Line data msg
defaultConfig dot color data =
  Line
    { dot = dot
    , color = color
    , width = 2
    , dashing = ""
    , data = data
    }


viewLine : Config data msg -> Coordinate.System -> Line data msg -> List Point -> Svg.Svg msg
viewLine config system line points =
  Svg.g
    [ SvgA.class "line" ]
    [ viewInterpolation config system line points
    , viewDots system line points
    ]


viewInterpolation : Config data msg -> Coordinate.System -> Line data msg -> List Point -> Svg.Svg msg
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

    attributes =
      [ SvgA.class "interpolation"
      , SvgA.stroke line.color
      , SvgA.strokeWidth (toString line.width)
      , SvgA.strokeDasharray line.dashing
      , SvgA.fill "transparent"
      ]
  in
  Path.view system attributes commands


viewDots : Coordinate.System -> Line data msg -> List Point -> Svg.Svg msg
viewDots system (Line line) points =
   Svg.g [ SvgA.class "dots" ] <|
    List.map (Dot.view line.dot line.color system) points



-- DEFAULTS


defaultColors : List Color.Color
defaultColors =
  [ Color.pink
  , Color.blue
  , Color.orange
  ]


defaultDots : List (Dot.Dot msg)
defaultDots =
  [ Dot.default1
  , Dot.default2
  , Dot.default3
  ]
