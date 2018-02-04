module Selection2 exposing (main)

import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Random
import LineChart
import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Title as Title
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
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
    , hovered : Maybe Float
    , selection : Maybe Selection
    , dragging : Bool
    }


type alias Selection =
  { start : Float
  , end : Float
  }


type alias Data =
  { alice : List Coordinate.Point
  , bobby : List Coordinate.Point
  , chuck : List Coordinate.Point
  }


init : ( Model, Cmd Msg )
init =
  ( { data = Data [] [] []
    , hovered = Nothing
    , selection = Nothing
    , dragging = False
    }
  , getNumbers
  )


setData : ( List Float, List Float, List Float ) -> Model -> Model
setData ( n1, n2, n3 ) model =
  { model | data = Data (toData n1) (toData n2) (toData n3) }


toData : List Float -> List Coordinate.Point
toData numbers =
  List.indexedMap (\i -> Coordinate.Point (toFloat i)) numbers


setSelection : Maybe Selection -> Model -> Model
setSelection selection model =
  { model | selection = selection }


setDragging : Bool -> Model -> Model
setDragging dragging model =
  { model | dragging = dragging }


setHovered : Maybe Float -> Model -> Model
setHovered hovered model =
  { model | hovered = hovered }


getSelectionStart : Float -> Model -> Float
getSelectionStart hovered model =
  case model.selection of
    Just selection -> selection.start
    Nothing        -> hovered



-- UPDATE


type Msg
  = RecieveNumbers ( List Float, List Float, List Float )
  | Hold Coordinate.Point
  | Move Coordinate.Point
  | Drop Coordinate.Point
  | LeaveChart Coordinate.Point
  | LeaveContainer Coordinate.Point


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RecieveNumbers numbers ->
      model
        |> setData numbers
        |> addCmd Cmd.none

    Hold point ->
      model
        |> setSelection Nothing
        |> setDragging True
        |> addCmd Cmd.none

    Move point ->
      if model.dragging then
        let
          start = getSelectionStart point.x model
          newSelection = Selection start point.x
        in
        model
          |> setSelection (Just newSelection)
          |> setHovered (Just point.x)
          |> addCmd Cmd.none
      else
        model
          |> setHovered (Just point.x)
          |> addCmd Cmd.none


    Drop point ->
      model
        |> setDragging False
        |> addCmd Cmd.none

    LeaveChart point ->
      model
        |> setHovered Nothing
        |> addCmd Cmd.none

    LeaveContainer point ->
      model
        |> setDragging False
        |> setHovered Nothing
        |> addCmd Cmd.none


getNumbers : Cmd Msg
getNumbers =
  let
    genNumbers =
      Random.list 200 (Random.float 0 20)
  in
  Random.map3 (,,) genNumbers genNumbers genNumbers
    |> Random.generate RecieveNumbers


addCmd : Cmd Msg -> Model -> ( Model, Cmd Msg )
addCmd cmd model =
  ( model, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div [ Html.Attributes.style [ ("display", "flex") ] ] <|
    case model.selection of
      Nothing ->
        [ chart model ]

      Just selection ->
        [ chart model, chartZoom model selection ]


chart : Model -> Html.Html Msg
chart model =
  viewChart model.data
    { range = Range.default
    , junk = junkConfig model
    , events =
        Events.custom
          [ Events.onWithOptions "mousedown" (Events.Options True True False) Hold Events.getData
          , Events.onWithOptions "mousemove" (Events.Options True True False) Move Events.getData
          , Events.onWithOptions "mouseup"   (Events.Options True True True) Drop Events.getData
          , Events.onWithOptions "mouseleave" (Events.Options True True False) LeaveChart Events.getData
          , Events.onWithOptions "mouseleave" (Events.Options True True True) LeaveContainer Events.getData
          ]
    , id = "line-chart"
    }


junkConfig : Model -> Junk.Config Coordinate.Point msg
junkConfig model =
  Junk.custom <| \system ->
    { below = below system model.selection
    , above = above system model.hovered
    , html = []
    }


below : Coordinate.System -> Maybe Selection -> List (Svg.Svg msg)
below system selection =
  case selection of
    Just { start, end } ->
      [ Junk.rectangle system [ Svg.Attributes.fill "#b6b6b61a" ]
          start end system.y.min system.y.max
      ]

    Nothing ->
      []


above : Coordinate.System -> Maybe Float -> List (Svg.Svg msg)
above system hovered =
  case hovered of
    Just hovered ->
      [ Junk.vertical system [] hovered ]

    Nothing ->
      []



-- VIEW ZOOM


chartZoom : Model -> Selection -> Html.Html Msg
chartZoom model selection =
  viewChart model.data
    { range = xAxisRangeConfig selection
    , junk = Junk.default
    , events = Events.default
    , id = "line-chart-zoom"
    }


xAxisRangeConfig : Selection -> Range.Config
xAxisRangeConfig selection =
  let
    start =
      min selection.start selection.end

    end =
      if selection.start == selection.end
        then selection.start + 1
        else max selection.start selection.end
  in
  Range.window start end




-- VIEW CHART


type alias Config =
  { range : Range.Config
  , junk : Junk.Config Coordinate.Point Msg
  , events : Events.Config Coordinate.Point Msg
  , id : String
  }


viewChart : Data -> Config -> Html.Html Msg
viewChart data { range, junk, events, id } =
  LineChart.viewCustom
    { y = Axis.default 450 "y" .y
    , x =
        Axis.custom
          { title = Title.default "x"
          , variable = Just << .x
          , pixels = 700
          , range = range
          , axisLine = AxisLine.rangeFrame Colors.gray
          , ticks = Ticks.float 5
          }
    , container = Container.default id
    , interpolation = Interpolation.monotone
    , intersection = Intersection.default
    , legends = Legends.none
    , events = events
    , junk = junk
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.none "Alice" data.alice
    , LineChart.line Colors.cyan Dots.none "Bobby" data.bobby
    , LineChart.line Colors.blue Dots.none "Chuck" data.chuck
    ]
