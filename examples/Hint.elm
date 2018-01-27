module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Title as Title
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis as Axis
import LineChart.Coordinate as Coordinate
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Svg.Attributes as SvgA
import Color


-- MODEL


type alias Model =
    { hovering : Maybe Info
    , point : Maybe Coordinate.Point
    , hoveringX : List Info
    }


initialModel : Model
initialModel =
    { hovering = Nothing
    , point = Nothing
    , hoveringX = []
    }



-- UPDATE


type Msg
    = Hover (List Info, Coordinate.Point)
    | HoverX (List Info)
    | HoverSingle (Maybe Info)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover (infos, point) ->
            { model
            | point = Just point
            , hoveringX = infos
            }

        HoverX infos ->
          { model | hoveringX = infos }

        HoverSingle hovering ->
          { model | hovering = hovering }



-- VIEW


view : Model -> Svg Msg
view model =
  LineChart.viewCustom
    { y = -- Axis.default 670 "age" .age
        Axis.custom
          { title = Title.atDataMax ( 15, 0 ) "age"
          , variable = .age
          , pixels = 670
          , range = Range.padded 20 20
          , axisLine = AxisLine.rangeFrame
          , ticks = Ticks.float 5
          }
    , x = -- Axis.default 750 "income" .income
        Axis.custom
          { title = Title.atDataMax ( 15, 0 ) "income"
          , variable = Just << .income
          , pixels = 750
          , range = Range.padded 20 20
          , axisLine = AxisLine.rangeFrame
          , ticks = Ticks.float 5
          }
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.stepped
    , intersection = Intersection.custom .min .min
    , legends = Legends.default
    , events = Events.hoverOne HoverSingle
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.gold Dots.diamond "alice" alice1
    ]



viewLegend : Int -> Legends.Legend msg -> Svg.Svg msg
viewLegend index { sample, label } =
   Svg.g
    [ Junk.transform [ Junk.offset 20 (toFloat index * 20) ] ]
    [ sample
    , Svg.g
        [ Junk.transform [ Junk.offset 40 4 ] ]
        [ Junk.label Color.black label ]
    ]


junkX : List Info -> Junk.Config Msg
junkX hovering =
  Junk.custom <| \system ->
    { below = []
    , above = List.map (\info -> Junk.vertical system [] info.income) hovering
    , html = []
    }


junkSingle : Info -> Junk.Config Msg
junkSingle hovering =
    Junk.custom <| \system ->
      { below = []
      , above = [ tooltip system 0 hovering   ]
      , html = []
      }


junk : List Info -> Coordinate.Point -> Info -> Junk.Config Msg
junk hintx point hovering =
    Junk.custom <| \system ->
      { below = []
      , above =
          [ Svg.g [] (List.indexedMap (tooltip system) hintx)
          , tooltip system 0 hovering
          , Svg.circle
            [ SvgA.cx (toString point.x)
            , SvgA.cy (toString point.y)
            , SvgA.r "2"
            , SvgA.fill "red"
            ]
            []
          ]
      , html = []
      }



tooltip : Coordinate.System -> Int -> Info -> Svg msg
tooltip system index hovered =
  Svg.g
    [ Junk.transform [ Junk.offset 520 (100 + toFloat index * 40) ] ]
    [ Svg.text_ []
        [ dimension "age" (Maybe.withDefault 0 hovered.age)
        ]
    ]

dimension : String -> Float -> Svg msg
dimension label value =
  Svg.tspan
    [ SvgA.x "0", SvgA.dy "1em" ]
    [ Svg.text <| label ++ ": " ++ toString value ]



-- DATA


type alias Info =
  { age : Maybe Float
  , income : Float
  }


type alias Info2 =
  { age : Float
  , income : Float
  }


alice1 : List Info
alice1 =
  [ Info (Just -1) -3
  , Info (Just -2) -2
  , Info (Just -3) -1
  , Info (Nothing) 0
  , Info (Just 5) 1
  , Info (Just 3) 2
  , Info (Just 7) 3
  ]


alice : List Info2
alice =
  [ Info2 ( -1) -3.2
  , Info2 ( -2) -2.4
  , Info2 ( -3) -1.1
  , Info2 ( 4) 4
  , Info2 ( 5) 5.2
  ]


bob : List Info2
bob =
  [ Info2 ( -1) -3
  , Info2 ( -1) -2.5
  , Info2 ( -1) -1
  , Info2 ( 1) 4
  , Info2 ( 1) 5.1
  ]


chuck : List Info2
chuck =
  [ Info2 ( 2) 1
  , Info2 ( 3) 2
  , Info2 ( 5) 3
  , Info2 ( 2) 4
  , Info2 ( 4) 5.5
  ]



-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (Svg.text "")
