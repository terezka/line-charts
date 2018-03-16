module Lines exposing (Model, init, Msg, update, view, source)

import Html
import Svg
import Random
import Random.Pipeline
import Time
import Color.Manipulate as Manipulate
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



-- MODEL


type alias Model =
  { data : Data
  , hinted : Maybe Datum
  }


type alias Data =
  { denmark : List Datum
  , sweden : List Datum
  , iceland : List Datum
  , greenland : List Datum
  , norway : List Datum
  , finland : List Datum
  }


type alias Datum =
  { time : Time.Time
  , rain : Float
  }



-- INIT


init : ( Model, Cmd Msg )
init =
  ( { data = Data [] [] [] [] [] []
    , hinted = Nothing
    }
  , generateData
  )



-- API


setData : Data -> Model -> Model
setData data model =
  { model | data = data }


setHint : Maybe Datum -> Model -> Model
setHint hinted model =
  { model | hinted = hinted }



-- UPDATE


type Msg
  = RecieveData Data
  | Hint (Maybe Datum)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RecieveData numbers ->
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
    [ LineChart.viewCustom (chartConfig model)
        [ LineChart.line (Manipulate.lighten 0.2 Colors.cyan) Dots.circle "Denmark"   model.data.denmark
        , LineChart.line (Manipulate.lighten 0   Colors.cyan) Dots.circle "Sweden"    model.data.sweden
        , LineChart.line (Manipulate.lighten 0.2 Colors.blue) Dots.circle "Iceland"   model.data.iceland
        , LineChart.line (Manipulate.lighten 0   Colors.blue) Dots.circle "Greenland" model.data.greenland
        , LineChart.line (Manipulate.lighten 0   Colors.pink) Dots.circle "Norway"    model.data.norway
        , LineChart.line (Manipulate.darken  0.2 Colors.pink) Dots.circle "Finland"   model.data.finland
        ]
    ]



-- CHART CONFIG


chartConfig : Model -> LineChart.Config Datum Msg
chartConfig model =
  { y = yAxisConfig
  , x = xAxisConfig
  , container = containerConfig
  , interpolation = Interpolation.monotone
  , intersection = Intersection.default
  , legends = Legends.default
  , events = eventsConfig
  , junk = Junk.default
  , grid = Grid.default
  , area = Area.default
  , line = lineConfig model.hinted
  , dots = Dots.custom (Dots.disconnected 4 2)
  }



-- CHART CONFIG / AXES


yAxisConfig : Axis.Config Datum Msg
yAxisConfig =
  Axis.custom
    { title = Title.atDataMax -10 -10 "Rain"
    , variable = Just << .rain
    , pixels = 450
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = Ticks.custom <| \dataRange axisRange ->
        [ tickRain ( dataRange.min, "bits" )
        , tickRain ( middle dataRange, "some" )
        , tickRain ( dataRange.max, "lots" )
        ]
    }


xAxisConfig : Axis.Config Datum Msg
xAxisConfig =
  Axis.custom
    { title = Title.default "Time"
    , variable = Just << .time
    , pixels = 1270
    , range = Range.padded 20 20
    , axisLine = AxisLine.none
    , ticks = Ticks.timeCustom 10 tickTime
    }



-- CHART CONFIG / AXES / TICKS


tickRain : ( Float, String ) -> Tick.Config msg
tickRain ( value, label ) =
  Tick.custom
    { position = value
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Tick.negative
    , label = Just (tickLabel label)
    }


tickTime : Tick.Time -> Tick.Config msg
tickTime time =
  let label = Tick.format time in
  Tick.custom
    { position = time.timestamp
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = False
    , direction = Tick.negative
    , label = Just (tickLabel label)
    }


tickLabel : String -> Svg.Svg msg
tickLabel =
  Junk.label Colors.black



-- CHART CONFIG / CONTIANER


containerConfig : Container.Config Msg
containerConfig =
  Container.custom
    { attributesHtml = []
    , attributesSvg = []
    , size = Container.relative
    , margin = Container.Margin 30 180 30 70
    , id = "line-chart-lines"
    }



-- CHART CONFIG / EVENTS


eventsConfig : Events.Config Datum Msg
eventsConfig =
  Events.custom
    [ Events.onMouseMove Hint Events.getNearest
    , Events.onMouseLeave (Hint Nothing)
    ]



-- CHART CONFIG / LINE


lineConfig : Maybe Datum -> Line.Config Datum
lineConfig maybeHovered =
  Line.custom (toLineStyle maybeHovered)


toLineStyle : Maybe Datum -> List Datum -> Line.Style
toLineStyle maybeHovered lineData =
  case maybeHovered of
    Nothing ->
      Line.style 1 identity

    Just hovered ->
      if List.any ((==) hovered) lineData then
        Line.style 2 identity
      else
        Line.style 1 (Manipulate.grayscale)



-- UTILS


round10 : Float -> Float
round10 float =
  toFloat (round (float * 10)) / 10


middle : Coordinate.Range -> Float
middle r =
  r.min + (r.max - r.min) / 2



-- GENERATE DATA


generateData : Cmd Msg
generateData =
  let
    genNumbers min max =
      Random.list 10 (Random.float min max)

    compile a b c d e f =
      Data (toData a) (toData b) (toData c) (toData d) (toData e) (toData f)
  in
  Random.Pipeline.generate compile
    |> Random.Pipeline.with (genNumbers 50 90)
    |> Random.Pipeline.with (genNumbers 20 60)
    |> Random.Pipeline.with (genNumbers 30 60)
    |> Random.Pipeline.with (genNumbers 40 90)
    |> Random.Pipeline.with (genNumbers 80 100)
    |> Random.Pipeline.with (genNumbers 70 90)
    |> Random.Pipeline.send RecieveData


toData : List Float -> List Datum
toData numbers =
  let
    toDatum index rain =
      Datum (indexToTime index) rain
  in
  List.indexedMap toDatum numbers


indexToTime : Int -> Time.Time
indexToTime index =
  Time.hour * 24 * 365 * 30 + xInterval * toFloat index


xInterval : Time.Time
xInterval =
  Time.hour * 24 * 31



-- PROGRAM


main : Program Never Model Msg
main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }




-- SOURCE


source : String
source =
  """
  -- MODEL


  type alias Model =
    { data : Data
    , hinted : Maybe Datum
    }


  type alias Data =
    { denmark : List Datum
    , sweden : List Datum
    , iceland : List Datum
    , greenland : List Datum
    , norway : List Datum
    , finland : List Datum
    }


  type alias Datum =
    { time : Time.Time
    , rain : Float
    }



  -- INIT


  init : ( Model, Cmd Msg )
  init =
    ( { data = Data [] [] [] [] [] []
      , hinted = Nothing
      }
    , generateData
    )



  -- API


  setData : Data -> Model -> Model
  setData data model =
    { model | data = data }


  setHint : Maybe Datum -> Model -> Model
  setHint hinted model =
    { model | hinted = hinted }



  -- UPDATE


  type Msg
    = RecieveData Data
    | Hint (Maybe Datum)


  update : Msg -> Model -> ( Model, Cmd Msg )
  update msg model =
    case msg of
      RecieveData numbers ->
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
      [ LineChart.viewCustom (chartConfig model)
          [ LineChart.line (Manipulate.lighten 0.2 Colors.cyan) Dots.circle "Denmark"   model.data.denmark
          , LineChart.line (Manipulate.lighten 0   Colors.cyan) Dots.circle "Sweden"    model.data.sweden
          , LineChart.line (Manipulate.lighten 0.2 Colors.blue) Dots.circle "Iceland"   model.data.iceland
          , LineChart.line (Manipulate.lighten 0   Colors.blue) Dots.circle "Greenland" model.data.greenland
          , LineChart.line (Manipulate.lighten 0   Colors.pink) Dots.circle "Norway"    model.data.norway
          , LineChart.line (Manipulate.darken  0.2 Colors.pink) Dots.circle "Finland"   model.data.finland
          ]
      ]



  -- CHART CONFIG


  chartConfig : Model -> LineChart.Config Datum Msg
  chartConfig model =
    { y = yAxisConfig
    , x = xAxisConfig
    , container = containerConfig
    , interpolation = Interpolation.monotone
    , intersection = Intersection.default
    , legends = Legends.default
    , events = eventsConfig
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = lineConfig model.hinted
    , dots = Dots.custom (Dots.disconnected 4 2)
    }



  -- CHART CONFIG / AXES


  yAxisConfig : Axis.Config Datum Msg
  yAxisConfig =
    Axis.custom
      { title = Title.atDataMax -10 -10 "Rain"
      , variable = Just << .rain
      , pixels = 450
      , range = Range.padded 20 20
      , axisLine = AxisLine.rangeFrame Colors.gray
      , ticks = Ticks.custom <| \\dataRange axisRange ->
          [ tickRain ( dataRange.min, "bits" )
          , tickRain ( middle dataRange, "some" )
          , tickRain ( dataRange.max, "lots" )
          ]
      }


  xAxisConfig : Axis.Config Datum Msg
  xAxisConfig =
    Axis.custom
      { title = Title.default "Time"
      , variable = Just << .time
      , pixels = 1270
      , range = Range.padded 20 20
      , axisLine = AxisLine.none
      , ticks = Ticks.timeCustom 10 tickTime
      }



  -- CHART CONFIG / AXES / TICKS


  tickRain : ( Float, String ) -> Tick.Config msg
  tickRain ( value, label ) =
    Tick.custom
      { position = value
      , color = Colors.gray
      , width = 1
      , length = 5
      , grid = True
      , direction = Tick.negative
      , label = Just (tickLabel label)
      }


  tickTime : Tick.Time -> Tick.Config msg
  tickTime time =
    let label = Tick.format time in
    Tick.custom
      { position = time.timestamp
      , color = Colors.gray
      , width = 1
      , length = 5
      , grid = False
      , direction = Tick.negative
      , label = Just (tickLabel label)
      }


  tickLabel : String -> Svg.Svg msg
  tickLabel =
    Junk.label Colors.black



  -- CHART CONFIG / CONTIANER


  containerConfig : Container.Config Msg
  containerConfig =
    Container.custom
      { attributesHtml = []
      , attributesSvg = []
      , size = Container.relative
      , margin = Container.Margin 30 180 30 70
      , id = "line-chart-lines"
      }



  -- CHART CONFIG / EVENTS


  eventsConfig : Events.Config Datum Msg
  eventsConfig =
    Events.custom
      [ Events.onMouseMove Hint Events.getNearest
      , Events.onMouseLeave (Hint Nothing)
      ]



  -- CHART CONFIG / LINE


  lineConfig : Maybe Datum -> Line.Config Datum
  lineConfig maybeHovered =
    Line.custom (toLineStyle maybeHovered)


  toLineStyle : Maybe Datum -> List Datum -> Line.Style
  toLineStyle maybeHovered lineData =
    case maybeHovered of
      Nothing ->
        Line.style 1 identity

      Just hovered ->
        if List.any ((==) hovered) lineData then
          Line.style 2 identity
        else
          Line.style 1 (Manipulate.grayscale)



  -- UTILS


  round10 : Float -> Float
  round10 float =
    toFloat (round (float * 10)) / 10


  middle : Coordinate.Range -> Float
  middle r =
    r.min + (r.max - r.min) / 2



  -- GENERATE DATA


  generateData : Cmd Msg
  generateData =
    let
      genNumbers min max =
        Random.list 10 (Random.float min max)

      compile a b c d e f =
        Data (toData a) (toData b) (toData c) (toData d) (toData e) (toData f)
    in
    Random.Pipeline.generate compile
      |> Random.Pipeline.with (genNumbers 50 90)
      |> Random.Pipeline.with (genNumbers 20 60)
      |> Random.Pipeline.with (genNumbers 30 60)
      |> Random.Pipeline.with (genNumbers 40 90)
      |> Random.Pipeline.with (genNumbers 80 100)
      |> Random.Pipeline.with (genNumbers 70 90)
      |> Random.Pipeline.send RecieveData


  toData : List Float -> List Datum
  toData numbers =
    let
      toDatum index rain =
        Datum (indexToTime index) rain
    in
    List.indexedMap toDatum numbers


  indexToTime : Int -> Time.Time
  indexToTime index =
    Time.hour * 24 * 365 * 30 + xInterval * toFloat index


  xInterval : Time.Time
  xInterval =
    Time.hour * 24 * 31



  -- PROGRAM


  main : Program Never Model Msg
  main =
    Html.program
      { init = init
      , update = update
      , view = view
      , subscriptions = always Sub.none
      }

  """
