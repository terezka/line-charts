module Tooltip exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Junk as Junk
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Color
import Browser



main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovered : Maybe Info }


init : Model
init =
    { hovered = Nothing }



-- UPDATE


type Msg
  = Hover (Maybe Info)


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovered ->
      { model | hovered = hovered }



-- VIEW


view : Model -> Svg Msg
view model =
  Html.div
    [ class "container" ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" .weight
    , x = Axis.default 700 "Age" .age
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverOne Hover
    , junk =
        case model.hovered of
          Just info -> tooltip info
          Nothing   -> Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.hoverOne model.hovered
    }
    [ LineChart.line Color.orange Dots.triangle "Chuck" chuck
    , LineChart.line Color.yellow Dots.circle "Bobby" bobby
    , LineChart.line Color.purple Dots.diamond "Alice" alice
    ]


tooltip : Info -> Junk.Config data msg
tooltip info =
  Junk.custom <| \system ->
    { below = []
    , above = []
    , html = [ tooltipHtml system info ]
    }


tooltipHtml : Coordinate.System -> Info -> Html.Html msg
tooltipHtml system info =
  let
    shouldFlip =
      -- is point closer to the left or right side?
      -- if closer to the right, flip tooltip
      info.age - system.x.min > system.x.max - info.age

    space = if shouldFlip then -15 else 15
    xPosition = Coordinate.toSvgX system info.age + space
    yPosition = Coordinate.toSvgY system info.weight

    containerAttributes =
      [ ( "left", String.fromFloat xPosition ++ "px" )
      , ( "top", String.fromFloat yPosition ++ "px" )
      , ( "position", "absolute" )
      , ( "padding", "5px" )
      , ( "background", "rgba(247, 193, 255, 0.8)" )
      , ( "border", "1px solid #51ff5f" )
      , ( "pointer-events", "none" )
      , if shouldFlip
          then ( "transform", "translateX(-100%)" )
          else ( "transform", "translateX(0)" )
      ]
        |> List.map (\(name, value) -> Html.Attributes.style name value)

    viewValue ( label, value ) =
      Html.p
        [ Html.Attributes.style "margin" "3px" ]
        [ Html.text <| label ++ " - " ++ String.fromFloat value ]

    valuesHtml =
      List.map viewValue
        [ ( "age", info.age )
        , ( "weight", info.weight )
        ]
  in
  Html.div containerAttributes valuesHtml



-- DATA


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Info
alice =
  [ Info 10 34 1.34 0
  , Info 16 42 1.62 3000
  , Info 25 75 1.73 25000
  , Info 43 83 1.75 40000
  ]


bobby : List Info
bobby =
  [ Info 10 38 1.32 0
  , Info 17 69 1.75 2000
  , Info 25 75 1.87 32000
  , Info 43 77 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 10 42 1.35 0
  , Info 15 72 1.72 1800
  , Info 25 89 1.83 85000
  , Info 43 95 1.84 120000
  ]
