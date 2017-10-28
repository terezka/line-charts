module Bars exposing
  ( Config, Orientation(..), Superscript, Pattern
  , defaultConfig, AxesConfig, defaultAxesConfig, pattern
  , Bar, Trend(..), bar, barCustom
  , viewSimple, view, viewCustom
  )

{-|

# Bars

## Quick start
@docs viewSimple

## Customizing individual bars
@docs view, Bar, bar, barCustom, Trend

## Customizing plot
@docs viewCustom, Config, Orientation, Superscript, Pattern, pattern, defaultConfig, AxesConfig, defaultAxesConfig

-}

import Html exposing (Html, div)
import Svg exposing (Svg, Attribute, g, text)
import Svg.Attributes exposing (class, stroke, fill, strokeWidth, strokeDasharray)
import Plot.Coordinate as Coordinate exposing (..)
import Plot.Axis as Axis exposing (defaultLook, defaultTick)
import Plot.Color as Color
import Plot.Container as Container
import Plot.Junk as Junk exposing (Junk)
import Internal.Axis as Axis
import Internal.Path as Path exposing (..)
import Internal.Junk
import Internal.Attributes
import Internal.Coordinate as Coordinate
import Internal.Utils as Utils
import Internal.Primitives as Primitives



-- CONFIG


{-| -}
type alias Config msg =
  { container : Container.Config msg
  , junk : Junk.Junk msg
  , barWidth : Float -> Float
  , barRounding : Int
  , barSuperscript : Maybe (Float -> Superscript msg)
  , barOrientation : Orientation
  , barTrendPattern : Pattern
  }


{-| -}
type alias Superscript msg =
  { attributes : List (Svg.Attribute msg)
  , xOffset : Float
  , yOffset : Float
  , text : String
  }


{-| -}
type Orientation
  = Vertical
  | Horizontal



{-| -}
type Pattern =
  Pattern
    { id : String
    , stroke : Int
    , space : Int
    }


{-| -}
pattern : String -> Int -> Int -> Pattern
pattern id stroke space =
  Pattern
    { id = id
    , stroke = stroke
    , space = space
    }


{-| -}
defaultConfig : Config msg
defaultConfig =
    { container = Container.default
    , junk = Junk.none
    , barWidth = min 100 << (*) 0.75
    , barRounding = 0
    , barOrientation = Vertical
    , barSuperscript = Nothing
    , barTrendPattern = pattern "default-pattern" 2 3
    }



-- AXES CONFIG


{-| -}
type alias AxesConfig data msg =
  { independentAxis : IndependentAxisConfig data msg
  , dependentAxis : Axis.Look msg
  }


{-| -}
type alias IndependentAxisConfig data msg =
  { line : Maybe (Limits -> Axis.Line msg)
  , tick : Maybe (Axis.Tick msg)
  , label : data -> Svg msg
  }


{-| -}
defaultAxesConfig : (data -> String) -> AxesConfig data msg
defaultAxesConfig toLabel =
  { independentAxis = defaultIndependentAxis (Axis.defaultStringLabel << toLabel)
  , dependentAxis = Axis.defaultLook
  }


defaultIndependentAxis : (data -> Svg msg) -> IndependentAxisConfig data msg
defaultIndependentAxis label =
  { line = defaultLook.line
  , tick = Just defaultTick
  , label = label
  }



-- BAR CONFIG


{-| -}
type Bar data msg =
  Bar (BarConfigWithTrend data msg)


{-| -}
type Trend data
  = NoTrend
  | Trend (data -> Float)


{-| -}
bar : Color.Color -> (data -> Float) -> Bar data msg
bar color variable =
  barCustom (always color) [] variable NoTrend


{-| -}
barCustom : (data -> Color.Color) -> List (Svg.Attribute msg) -> (data -> Float) -> Trend data -> Bar data msg
barCustom color attributes variable trend =
  Bar <| BarConfigWithTrend color attributes variable <|
    case trend of
      NoTrend ->
        Nothing

      Trend variable ->
        Just variable



-- VIEW


{-| -}
viewSimple : (data -> String) -> List (data -> Float) -> List data -> Html msg
viewSimple toLabel variables =
  viewCustom defaultConfig (defaultAxesConfig toLabel) (List.map2 defaultBar Color.defaults variables)


{-| -}
view : (data -> String) -> List (Bar data msg) -> List data -> Html msg
view toLabel =
  viewCustom defaultConfig (defaultAxesConfig toLabel)


{-| -}
viewCustom : Config msg -> AxesConfig data msg -> List (Bar data msg) -> List data -> Html msg
viewCustom config axesConfig bars data =
  let
    barConfigs =
      List.concatMap (toBarConfigs config) bars

    -- Points
    allPoints =
      List.concat (List.indexedMap barPoints data)

    barPoints datumIndex datum =
      List.map (barPoint config (DatumIndex datumIndex) datum) barConfigs

    -- System
    system =
      toSystem config data allPoints

    -- Junk
    junk =
      Internal.Junk.getLayers config.junk allPoints system

    -- Defs
    defs =
      defaultDefs config.barTrendPattern ++ config.container.defs

    -- Groups
    groups =
      viewGroups config system barConfigs data

    -- Axes
    ( horizontalAxis, verticalAxis ) =
      axes config axesConfig system data
  in
  viewHtmlContainer junk.html <|
    viewSvgContainer config system <|
      [ Svg.defs [] defs
      , Svg.g [ class "junk--below" ] junk.below
      , Svg.g [ class "groups" ] groups
      , Axis.viewHorizontal system horizontalAxis
      , Axis.viewVertical system verticalAxis
      , Svg.g [ class "junk--above" ] junk.above
      ]



-- INTERNAL / VIEW CONTAINERS


viewHtmlContainer : List (Html msg) -> Html msg -> Html msg
viewHtmlContainer htmlJunk plot =
  div [] (plot :: htmlJunk)


viewSvgContainer : Config msg -> Coordinate.System -> List (Svg msg) -> Html msg
viewSvgContainer config system =
  Svg.svg <| List.append
    (Internal.Attributes.toSvgAttributes system config.container.attributes)
    [ Svg.Attributes.width <| toString system.frame.size.width
    , Svg.Attributes.height <| toString system.frame.size.height
    ]



-- INTERNAL / AXES


axes : Config msg -> AxesConfig data msg -> Coordinate.System -> List data -> ( Axis.Look msg, Axis.Look msg )
axes config axes system data =
  let
    independentAxisLook data =
      { defaultLook
      | position = always 0
      , line = axes.independentAxis.line
      , marks = \_ -> List.indexedMap independentMark data
      }

    independentMark position datum =
      { position = toFloat position + 1
      , tick = axes.independentAxis.tick
      , label = Just (axes.independentAxis.label datum)
      }
  in
    case config.barOrientation of
      Horizontal ->
        ( axes.dependentAxis
        , independentAxisLook data
        )

      Vertical ->
        ( independentAxisLook data
        , axes.dependentAxis
        )



-- INTERNAL / BAR CONFIG


type alias BarConfigWithTrend data msg =
  { color : data -> Color.Color
  , attributes : List (Svg.Attribute msg)
  , variable : data -> Float
  , trend : Maybe (data -> Float)
  }


type alias BarConfig data msg =
  { color : data -> Color.Color
  , attributes : List (Svg.Attribute msg)
  , variable : data -> Float
  }


toBarConfigs : Config msg -> Bar data msg -> List (BarConfig data msg)
toBarConfigs config (Bar barConfig) =
  case barConfig.trend of
    Just trend ->
      [ BarConfig barConfig.color barConfig.attributes barConfig.variable
      , BarConfig barConfig.color (addStripes config barConfig.attributes) trend
      ]

    Nothing ->
      [ BarConfig barConfig.color barConfig.attributes barConfig.variable ]


addStripes : Config msg -> List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addStripes config attributes =
  attributes ++ [ Svg.Attributes.mask <| "url(#" ++ getMaskId config.barTrendPattern ++ ")" ]



-- INTERNAL / BAR POINT


barPoint : Config msg -> DatumIndex -> data -> BarConfig data msg -> Point
barPoint config (DatumIndex datumIndex) datum barConfig =
  case config.barOrientation of
    Horizontal ->
      { x = barConfig.variable datum
      , y = toFloat datumIndex + 1
      }

    Vertical ->
      { x = toFloat datumIndex + 1
      , y = barConfig.variable datum
      }



-- INTERNAL / SYSTEM


toSystem : Config msg -> List data -> List Point -> Coordinate.System
toSystem config data points =
  let
    independentLimits toHeight =
      { min = Coordinate.minimumOrZero toHeight points
      , max = Coordinate.maximum toHeight points
      }

    dependentLimits =
      { min = 0.5
      , max = toFloat (List.length data) + 0.5
      }

    ( xLimits, yLimits ) =
      case config.barOrientation of
        Horizontal ->
          ( independentLimits .x
          , dependentLimits
          )

        Vertical ->
          ( dependentLimits
          , independentLimits .y
          )
  in
    System config.container.frame xLimits yLimits



-- INTERNAL / VIEW GROUPS


type DatumIndex =
  DatumIndex Int


type BarIndex =
  BarIndex Int


type NumberOfData =
  NumberOfData Int


type NumberOfBars =
  NumberOfBars Int


viewGroups : Config msg -> Coordinate.System -> List (BarConfig data msg) -> List data -> List (Svg msg)
viewGroups config system barConfigs data =
  let
    numberOfData =
      NumberOfData (List.length data)

    numberOfBars =
      NumberOfBars (List.length barConfigs)

    viewBars datumIndex datum =
      g [ class "group" ] <| List.indexedMap (viewBar datumIndex datum) barConfigs

    viewBar datumIndex datum barIndex barConfig =
      viewBarOriented config system
        numberOfData
        numberOfBars
        (DatumIndex datumIndex)
        (BarIndex barIndex)
        barConfig
        datum

    viewBarOriented  =
      case config.barOrientation of
        Horizontal ->
          viewBarHorizontal

        Vertical ->
          viewBarVertical
  in
  List.indexedMap viewBars data


viewBarHorizontal : Config msg -> Coordinate.System -> NumberOfData -> NumberOfBars -> DatumIndex -> BarIndex -> BarConfig data msg -> data -> Svg msg
viewBarHorizontal config system numberOfData numberOfBars (DatumIndex datumIndex) barIndex barConfig datum =
  let
    value =
      barConfig.variable datum

    position =
      toFloat datumIndex + 1

    superscription =
      Maybe.map (Utils.apply value) config.barSuperscript

    offset =
      barOffset numberOfBars barIndex

    width =
      barWidth config system numberOfData numberOfBars Y

    point =
      { x = value
      , y = position - width * offset
      }

    attributes =
      barConfig.attributes ++ [ fill (barConfig.color datum) ]

    commands =
      Primitives.horizontalBarCommands system config.barRounding width point
  in
  g
    [ class "bar" ]
    [ Path.view system attributes commands
    , Utils.viewMaybe superscription (viewSuperscript system point [])
    ]


viewBarVertical : Config msg -> Coordinate.System -> NumberOfData -> NumberOfBars -> DatumIndex -> BarIndex -> BarConfig data msg -> data -> Svg msg
viewBarVertical config system numberOfData numberOfBars (DatumIndex datumIndex) barIndex barConfig datum =
  let
    value =
      barConfig.variable datum

    position =
      toFloat datumIndex + 1

    superscription =
      Maybe.map (Utils.apply value) config.barSuperscript

    offset =
      barOffset numberOfBars barIndex

    width =
      barWidth config system numberOfData numberOfBars X

    point =
      { x = position + width * offset
      , y = value
      }

    attributes =
      barConfig.attributes ++ [ fill (barConfig.color datum) ]

    commands =
      Primitives.verticalBarCommands system config.barRounding width point
  in
  g
    [ class "bar" ]
    [ Path.view system attributes commands
    , Utils.viewMaybe superscription (viewSuperscript system point [ Svg.Attributes.style "text-anchor: middle;" ])
    ]


viewSuperscript : Coordinate.System -> Point -> List (Svg.Attribute msg) -> Superscript msg -> Svg msg
viewSuperscript system { x, y } attributes superscription =
  let
    transformation =
      placeWithOffset system x y superscription.xOffset superscription.yOffset
  in
  Svg.text_
    (transformation :: attributes ++ superscription.attributes)
    [ Svg.tspan [] [ Svg.text superscription.text ] ]


barOffset : NumberOfBars -> BarIndex -> Float
barOffset (NumberOfBars numberOfBars) (BarIndex barIndex) =
  toFloat barIndex - (toFloat numberOfBars / 2)


barWidth : Config msg -> Coordinate.System -> NumberOfData -> NumberOfBars -> Coordinate.Orientation -> Float
barWidth config system (NumberOfData numberOfData) (NumberOfBars numberOfBars) orientation =
  let
    fullWidth =
      case config.barOrientation of
        Horizontal ->
          system.frame.size.height - system.frame.margin.bottom - system.frame.margin.top

        Vertical ->
          system.frame.size.width - system.frame.margin.left - system.frame.margin.right

    barWidth =
       config.barWidth (fullWidth / toFloat numberOfData)
  in
  scaleCartesian orientation system barWidth / (toFloat numberOfBars)



-- INTERNAL / DEFAULTS


defaultBar : Color.Color -> (data -> Float) -> Bar data msg
defaultBar color variable =
  Bar <| BarConfigWithTrend (always color) [] variable Nothing


defaultDefs : Pattern -> List (Svg msg)
defaultDefs (Pattern config) =
  let
    space =
      config.stroke + config.space

    patternId =
      "pattern-stripe-" ++ config.id

    maskId =
      getMaskId (Pattern config)
  in
  [ Svg.pattern
    [ Svg.Attributes.id patternId
    , Svg.Attributes.patternUnits "userSpaceOnUse"
    , Svg.Attributes.width (toString space)
    , Svg.Attributes.height (toString space)
    , Svg.Attributes.patternTransform "rotate(45)"
    ]
    [ Svg.rect
        [ Svg.Attributes.width (toString config.stroke)
        , Svg.Attributes.height (toString space)
        , Svg.Attributes.transform "translate(0,0)"
        , Svg.Attributes.fill "white"
        ]
        []
    ]
  , Svg.mask
      [ Svg.Attributes.id maskId ]
      [ Svg.rect
          [ Svg.Attributes.x "0"
          , Svg.Attributes.y "0"
          , Svg.Attributes.width "100%"
          , Svg.Attributes.height "100%"
          , Svg.Attributes.fill <| "url(#" ++ patternId ++ ")"
          ]
          []
      ]
  ]


getMaskId : Pattern -> String
getMaskId (Pattern config) =
  "mask-stripe-" ++ config.id
