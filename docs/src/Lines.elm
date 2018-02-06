module Lines exposing (Model, init, Msg, update, view)

import Html
import Random
import Time
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
    genNumbers =
      Random.list 10 (Random.float 50 120)
  in
  Random.map3 (,,) genNumbers genNumbers genNumbers
    |> Random.generate RecieveNumbers



-- API


setData : ( List Float, List Float, List Float ) -> Model -> Model
setData ( n1, n2, n3 ) model =
  { model | data = Data (toData n1) (toData n2) (toData n3) }


toData : List Float -> List Coordinate.Point
toData numbers =
  List.indexedMap (\i n -> Coordinate.Point (toDate i) n) numbers


toDate : Int -> Time.Time
toDate index =
  Time.hour * 24 * 356 * 30 + xInterval * toFloat index


xInterval : Time.Time
xInterval =
  Time.hour * 24 * 356


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
  Html.div [] [ chart model ]



-- CHART


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { y =
        Axis.custom
          { title = Title.default "Rain"
          , variable = Just << .y
          , pixels = 450
          , range = Range.padded 20 20
          , axisLine = AxisLine.rangeFrame Colors.gray
          , ticks = Ticks.custom <| \dataRange axisRange ->
              List.indexedMap rainTick [ dataRange.min, middle dataRange, dataRange.max ]
          }
    , x =
        Axis.custom
          { title = Title.default "Time"
          , variable = Just << .x
          , pixels = 700
          , range = Range.padded 20 20
          , axisLine = AxisLine.none
          , ticks = Ticks.timeCustom 10 timeTick
          }
    , container = Container.default "line-chart-lines"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverOne Hint
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.hoverOne model.hinted
    , dots = Dots.custom (Dots.disconnected 3 2)
    }
    [ LineChart.line Colors.pink Dots.circle "Denmark" model.data.nora
    , LineChart.line Colors.cyan Dots.circle "Sweden" model.data.noah
    , LineChart.line Colors.blue Dots.circle "Norway" model.data.nina
    ]


rainTick : Int -> Float -> Tick.Config msg
rainTick i n =
  let
    label =
      if i == 0 then "bits"
      else if i == 1 then "some"
      else "lots"
  in
  Tick.custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Tick.negative
    , label = Just <| Junk.label Colors.black label
    }


timeTick : Tick.Time -> Tick.Config msg
timeTick time =
  Tick.custom
    { position = time.timestamp
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = False
    , direction = Tick.negative
    , label = Just <| Junk.label Colors.black (Tick.format time)
    }



-- UTILS


round10 : Float -> Float
round10 float =
  toFloat (round (float * 10)) / 10


middle : Coordinate.Range -> Float
middle r =
  r.min + (r.max - r.min) / 2
