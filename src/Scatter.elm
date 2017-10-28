module Scatter exposing (Config, Axis, group, groupCustom, Trend, trend, noTrend, defaultTrendConfig, Equation, TrendConfig, viewSimple, view, viewCustom)

{-|

# Scatter

## Quick start
@docs viewSimple

## Customize individual groups
@docs view, group, groupCustom, Trend, Equation, TrendConfig, trend, noTrend, defaultTrendConfig

## Customize plot
@docs viewCustom, Config, Axis

-}

import Html exposing (div)
import Svg exposing (Svg, Attribute)
import Svg.Attributes exposing (class, stroke, fill, strokeWidth, strokeDasharray)
import Plot.Coordinate as Coordinate exposing (..)
import Plot.Axis as Axis
import Plot.Dot as Dot
import Plot.Color as Color
import Plot.Junk as Junk exposing (Junk)
import Plot.Container as Container
import Internal.Trend as Trend
import Internal.Axis as Axis
import Internal.Dot as Dot
import Internal.Coordinate as Coordinate
import Internal.Junk
import Internal.Attributes
import Internal.Coordinate


-- CONFIG


{-| -}
type alias Config data msg =
  { container : Container.Config msg
  , junk : Junk.Junk msg
  , x : Axis data msg
  , y : Axis data msg
  }


{-| -}
type alias Axis data msg =
  { look : Axis.Look msg
  , variable : data -> Float
  }



-- GROUP


{-| Represents a group of dots with the same dot and from the same dataset.
-}
type Group data msg =
  Group (GroupConfig data msg)


{-| -}
group : Dot.Config msg -> List data -> Group data msg
group dot data =
  Group <| GroupConfig dot Nothing data


{-| -}
type Trend msg
  = Trend (Maybe (Equation -> TrendConfig msg))


{-| -}
type alias Equation =
  { slope : Float
  , intercept : Float
  }


{-| -}
type alias TrendConfig msg =
    { attributes : List (Svg.Attribute msg)
    , color : Color.Color
    , space : Int
    , width : Int
    }


{-| -}
trend : TrendConfig msg -> Trend msg
trend toConfig =
  Trend (Just (always toConfig))


{-| -}
trendCustom : (Equation -> TrendConfig msg) -> Trend msg
trendCustom toConfig =
  Trend (Just toConfig)


{-| -}
defaultTrendConfig : TrendConfig msg
defaultTrendConfig =
  { attributes = []
  , color = Color.black
  , space = 2
  , width = 3
  }



{-| -}
noTrend : Trend msg
noTrend =
  Trend Nothing


{-| -}
groupCustom : Dot.Config msg -> Trend msg -> List data -> Group data msg
groupCustom dot (Trend trendConfig) data =
  Group <| GroupConfig dot trendConfig data


-- VIEW


{-| The simplest version of a scatter. Just pass in your x and y
property, and the list of your datasets.

    view : Svg msg
    view =
      Scatter.viewSimple .lineOfCode .debuggingTime [ elm, javascript ]

    type alias Data =
      { lineOfCode : Float
      , debuggingTime : Float
      }

    elm : List Data
    javascript : List Data

Each dataset will be rendered as a line of a different color.
_Max 5 lines for the simple lines!_ For more, use `view`.

-}
viewSimple : (data -> Float) -> (data -> Float) -> List (List data) -> Svg msg
viewSimple toX toY datas =
  view toX toY (List.map2 group (defaultGroups datas) datas)


{-| The simplest version of a scatter. Just pass in your x and y
property, and the list of your datasets.

    view : Svg msg
    view =
      Scatter.view .lineOfCode .debuggingTime
        [ group (circle Color.blue) elm
        , group (circle Color.green) javascript
        ]

    circle : Color.Color -> Dot.Config msg
    circle =
      Dot.Config Dot.Circle [] 3

    type alias Data =
      { lineOfCode : Float
      , debuggingTime : Float
      }

    elm : List Data
    javascript : List Data

-}
view : (data -> Float) -> (data -> Float) -> List (Group data msg) -> Svg msg
view toX toY =
  viewCustom
    { container = Container.default
    , x = Axis Axis.defaultLook toX
    , y = Axis Axis.defaultLook toY
    , junk = Junk.none
    }


{-| Customize your plot.

    viewCustom : Svg msg
    viewCustom =
      Scatter.viewCustom
        { frame = Frame (Margin 20 20 20 20) (Size 400 300)
        , x = Axis.defaultAxis .lineOfCode
        , y = Axis.defaultAxis .debuggingTime
        , junk = Junk.none
        , attributes = []
        }
        [ group (circle Color.orange) elm
        , group (circle Color.green) javascript
        ]

    circle : Color.Color -> Dot.Config msg
    circle =
      Dot.Config Dot.Circle [] 3

    type alias Data =
      { lineOfCode : Float
      , debuggingTime : Float
      }

    elm : List Data
    javascript : List Data

-}
viewCustom : Config data msg -> List (Group data msg) -> Svg msg
viewCustom config groups =
  let
    points =
      List.map (List.map point << .data << groupConfig) groups

    point datum =
      Point
        (config.x.variable datum)
        (config.y.variable datum)

    -- System
    allPoints =
      List.concat points

    system =
      { frame = config.container.frame
      , x = Internal.Coordinate.limits .x allPoints
      , y = Internal.Coordinate.limits .y allPoints
      }

    -- View
    junk =
      Internal.Junk.getLayers config.junk allPoints system

    container plot =
      div [] (plot :: junk.html)

    attributes =
      List.append
        (Internal.Attributes.toSvgAttributes system config.container.attributes)
        [ Svg.Attributes.width <| toString system.frame.size.width
        , Svg.Attributes.height <| toString system.frame.size.height
        ]

    viewGroups =
      List.map2 (viewGroup config system) groups points

    viewTrends =
      List.map2 (viewTrend config system) groups points
  in
  container <|
    Svg.svg attributes
      [ Svg.defs [] config.container.defs
      , Svg.g [ class "junk--below" ] junk.below
      , Svg.g [ class "lines" ] viewGroups
      , Axis.viewHorizontal system config.x.look
      , Axis.viewVertical system config.y.look
      , Svg.g [ class "trends" ] viewTrends
      , Svg.g [ class "junk--above" ] junk.above
      ]



-- INTERNAL


{-| -}
type alias GroupConfig data msg =
  { dot : Dot.Config msg
  , trend : Maybe (Equation -> TrendConfig msg)
  , data : List data
  }


groupConfig : Group data msg -> GroupConfig data msg
groupConfig (Group config) =
  config


defaultGroups : List a -> List (Dot.Config msg)
defaultGroups stuff =
  if List.length stuff <= 4 then
    List.map Dot.default Color.defaults
  else
    -- TODO
    []


viewGroup : Config data msg -> Coordinate.System -> Group data msg -> List Point -> Svg msg
viewGroup config system (Group group) points =
  Svg.g [ class "group" ] (List.map (Dot.viewConfig group.dot system) points)


viewTrend : Config data msg -> Coordinate.System -> Group data msg -> List Point -> Svg msg
viewTrend config system (Group group) points =
  case ( group.trend, Trend.trend points ) of
    ( Just toTrendConfig, Just trend ) ->
      let
        trendConfig =
          toTrendConfig trend

        attributes =
          trendConfig.attributes ++
            [ stroke trendConfig.color
            , strokeDasharray <| toString trendConfig.width ++ " " ++ toString trendConfig.space
            ]

        limits =
          Coordinate.limits .x points
      in
      Svg.g [ class "trend" ] [ Trend.view system attributes limits (Just trend) ]

    _ ->
      Svg.text ""
