module Ticks exposing (Model, init, Msg, update, view)

import Html
import Random
import LineChart
import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Title as Title
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Line as AxisLine
import LineChart.Junk as Junk
import LineChart.Dots as Dots
import LineChart.Grid as Grid
import LineChart.Dots as Dots
import LineChart.Line as Line
import LineChart.Colors as Colors
import LineChart.Events as Events
import LineChart.Legends as Legends
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection



main : Program Never Model Msg
main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }



-- MODEL


type alias Model =
    { data : Data
    , hinted : Maybe Coordinate.Point
    }


type alias Data =
  { nora : List Coordinate.Point
  , noah : List Coordinate.Point
  , nina : List Coordinate.Point
  }



-- INIT


init : ( Model, Cmd Msg )
init =
  ( { data = Data [] [] []
    , hinted = Nothing
    }
  , getNumbers
  )


getNumbers : Cmd Msg
getNumbers =
  let
    genNumbers min max =
      Random.list 10 (Random.float min max)
  in
  Random.map3 (,,) (genNumbers 9 12) (genNumbers 7 10) (genNumbers 2 10)
    |> Random.generate RecieveNumbers



-- API


setData : ( List Float, List Float, List Float ) -> Model -> Model
setData ( n1, n2, n3 ) model =
  { model | data = Data (toData n1) (toData n2) (toData n3) }


toData : List Float -> List Coordinate.Point
toData numbers =
  List.indexedMap (\i -> Coordinate.Point (toFloat i)) numbers


setHint : Maybe Coordinate.Point -> Model -> Model
setHint hinted model =
  { model | hinted = hinted }



-- UPDATE


type Msg
  = RecieveNumbers ( List Float, List Float, List Float )
  | Hint (Maybe Coordinate.Point)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RecieveNumbers numbers ->
      model
        |> setData numbers
        |> addCmd Cmd.none

    Hint point ->
      model
        |> setHint point
        |> addCmd Cmd.none


addCmd : Cmd Msg -> Model -> ( Model, Cmd Msg )
addCmd cmd model =
  ( model, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div []
    [ chart model ]



-- CHART


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { x = xAxisConfig model
    , y = yAxisConfig model
    , container =
        Container.custom
          { attributesHtml = []
          , attributesSvg = []
          , size = Container.relative
          , margin = Container.Margin 60 100 30 70
          , id = "line-chart-ticks"
          }
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverOne Hint
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.custom (Dots.disconnected 7 2)
    }
    [ LineChart.line Colors.blue Dots.plus "Nora" model.data.nora
    , LineChart.line Colors.cyan Dots.cross "Noah" model.data.noah
    , LineChart.dash Colors.pink Dots.none "Class" [ 5, 2 ] model.data.nina
    ]


xAxisConfig : Model -> Axis.Config Coordinate.Point msg
xAxisConfig model =
  let formatX =
        \x -> if x == 0 then "K" else toString x
  in
  Axis.custom
    { title = Title.default "Year"
    , variable = Just << .x
    , pixels = 800
    , range = Range.padded 50 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = ticksConfig .x formatX model.hinted
    }


yAxisConfig : Model -> Axis.Config Coordinate.Point msg
yAxisConfig model =
  let formatY =
        toString << round10
  in
  Axis.custom
    { title = Title.atAxisMax 10 0 "Grade avg."
    , variable = Just << .y
    , pixels = 450
    , range = Range.padded 50 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = ticksConfig .y formatY model.hinted
    }


ticksConfig : (Coordinate.Point -> Float) -> (Float -> String) -> Maybe Coordinate.Point -> Ticks.Config msg
ticksConfig toValue format maybeHovered =
  let
    hoverOne =
      case maybeHovered of
        Just hovered ->
          [ opposite format (toValue hovered) ]

        Nothing ->
          []

    framing range =
      List.map (gridless format) [ range.min, range.max ]
  in
  Ticks.custom <| \dataRange axisRange ->
    framing dataRange ++ hoverOne


opposite : (Float -> String) -> Float -> Tick.Config msg
opposite format n =
  Tick.custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Tick.positive
    , label = Just <| Junk.label Colors.black (format n)
    }


gridless : (Float -> String) -> Float -> Tick.Config msg
gridless format n =
  Tick.custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = False
    , direction = Tick.negative
    , label = Just <| Junk.label Colors.black (format n)
    }



-- UTILS


round10 : Float -> Float
round10 float =
  toFloat (round (float * 10)) / 10
