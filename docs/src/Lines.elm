module Lines exposing (Model, init, Msg, update, view, source)

import Html
import Random
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
  { data : Data Coordinate.Point
  , hinted : Maybe Coordinate.Point
  }


type alias Data a =
  { a : List a
  , b : List a
  , c : List a
  , d : List a
  , e : List a
  , f : List a
  , g : List a
  }



-- INIT


init : ( Model, Cmd Msg )
init =
  ( { data = Data [] [] [] [] [] [] []
    , hinted = Nothing
    }
  , getNumbers
  )


getNumbers : Cmd Msg
getNumbers =
  let
    genNumbers min max =
      Random.list 10 (Random.float min max)

    getFirst =
      Random.map5 (,,,,)
        (genNumbers 50 90)
        (genNumbers 20 60)
        (genNumbers 30 60)
        (genNumbers 40 90)
        (genNumbers 80 100)

    getSecond =
      Random.map2 (,)
        (genNumbers 70 90)
        (genNumbers 40 70)

    together (a,b,c,d,e) (f,g) =
      Data a b c d e f g
  in
  Random.generate RecieveNumbers <|
    Random.map2 together getFirst getSecond



-- API


setData : Data Float -> Model -> Model
setData { a, b, c, d, e, f, g } model =
  { model | data = Data (toData a) (toData b) (toData c) (toData d) (toData e) (toData f) (toData g) }


toData : List Float -> List Coordinate.Point
toData numbers =
  List.indexedMap (\i n -> Coordinate.Point (toDate i) n) numbers


toDate : Int -> Time.Time
toDate index =
  Time.hour * 24 * 356 * 30 + xInterval * toFloat index


xInterval : Time.Time
xInterval =
  Time.hour * 24 * 31


setHint : Maybe Coordinate.Point -> Model -> Model
setHint hinted model =
  { model | hinted = hinted }



-- UPDATE


type Msg
  = RecieveNumbers (Data Float)
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
          { title = Title.atDataMax -10 -10 "Rain"
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
          , pixels = 1270
          , range = Range.padded 20 20
          , axisLine = AxisLine.none
          , ticks = Ticks.timeCustom 10 timeTick
          }
    , container = Container.spaced "line-chart-lines" 30 180 60 70
    , interpolation = Interpolation.monotone
    , intersection = Intersection.default
    , legends = Legends.default
    , events =
        Events.custom
          [ Events.onMouseMove Hint Events.getNearest
          , Events.onMouseLeave (Hint Nothing)
          ]
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.custom (toLineStyle model.hinted)
    , dots = Dots.custom (Dots.disconnected 4 2)
    }
    [ LineChart.line (Manipulate.lighten 0.2 Colors.cyan) Dots.circle "Denmark" model.data.a
    , LineChart.line (Manipulate.lighten 0   Colors.cyan) Dots.circle "Sweden" model.data.b
    , LineChart.line (Manipulate.lighten 0.2 Colors.blue) Dots.circle "Iceland" model.data.d
    , LineChart.line (Manipulate.lighten 0   Colors.blue) Dots.circle "Faroe Islands" model.data.f
    , LineChart.line (Manipulate.lighten 0   Colors.pink) Dots.circle "Norway" model.data.c
    , LineChart.line (Manipulate.darken  0.2 Colors.pink) Dots.circle "Finland" model.data.e
    ]


toLineStyle : Maybe Coordinate.Point -> List Coordinate.Point -> Line.Style
toLineStyle maybeHovered lineData =
  case maybeHovered of
    Nothing -> -- No line is hovered
      Line.style 1 identity

    Just hovered -> -- Some line is hovered
      if List.any ((==) hovered) lineData then
        -- It is this one, so make it pop!
        Line.style 2 identity
      else
        -- It is not this one, so hide it a bit
        Line.style 1 (Manipulate.grayscale)


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



-- SOURCE


source : String 
source =
  """
  -- MODEL


  type alias Model =
    { data : Data Coordinate.Point
    , hinted : Maybe Coordinate.Point
    }


  type alias Data a =
    { a : List a
    , b : List a
    , c : List a
    , d : List a
    , e : List a
    , f : List a
    , g : List a
    }



  -- INIT


  init : ( Model, Cmd Msg )
  init =
    ( { data = Data [] [] [] [] [] [] []
      , hinted = Nothing
      }
    , getNumbers
    )


  getNumbers : Cmd Msg
  getNumbers =
    let
      genNumbers min max =
        Random.list 10 (Random.float min max)

      getFirst =
        Random.map5 (,,,,)
          (genNumbers 50 90)
          (genNumbers 20 60)
          (genNumbers 30 60)
          (genNumbers 40 90)
          (genNumbers 80 100)

      getSecond =
        Random.map2 (,)
          (genNumbers 70 90)
          (genNumbers 40 70)

      together (a,b,c,d,e) (f,g) =
        Data a b c d e f g
    in
    Random.generate RecieveNumbers <|
      Random.map2 together getFirst getSecond



  -- API


  setData : Data Float -> Model -> Model
  setData { a, b, c, d, e, f, g } model =
    { model | data = Data (toData a) (toData b) (toData c) (toData d) (toData e) (toData f) (toData g) }


  toData : List Float -> List Coordinate.Point
  toData numbers =
    List.indexedMap (\\i n -> Coordinate.Point (toDate i) n) numbers


  toDate : Int -> Time.Time
  toDate index =
    Time.hour * 24 * 356 * 30 + xInterval * toFloat index


  xInterval : Time.Time
  xInterval =
    Time.hour * 24 * 31


  setHint : Maybe Coordinate.Point -> Model -> Model
  setHint hinted model =
    { model | hinted = hinted }



  -- UPDATE


  type Msg
    = RecieveNumbers (Data Float)
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
            { title = Title.atDataMax -10 -10 "Rain"
            , variable = Just << .y
            , pixels = 450
            , range = Range.padded 20 20
            , axisLine = AxisLine.rangeFrame Colors.gray
            , ticks = Ticks.custom <| \\dataRange axisRange ->
                List.indexedMap rainTick [ dataRange.min, middle dataRange, dataRange.max ]
            }
      , x =
          Axis.custom
            { title = Title.default "Time"
            , variable = Just << .x
            , pixels = 1270
            , range = Range.padded 20 20
            , axisLine = AxisLine.none
            , ticks = Ticks.timeCustom 10 timeTick
            }
      , container = Container.spaced "line-chart-lines" 30 180 60 70
      , interpolation = Interpolation.monotone
      , intersection = Intersection.default
      , legends = Legends.default
      , events =
          Events.custom
            [ Events.onMouseMove Hint Events.getNearest
            , Events.onMouseLeave (Hint Nothing)
            ]
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.default
      , line = Line.custom (toLineStyle model.hinted)
      , dots = Dots.custom (Dots.disconnected 4 2)
      }
      [ LineChart.line (Manipulate.lighten 0.2 Colors.cyan) Dots.circle "Denmark" model.data.a
      , LineChart.line (Manipulate.lighten 0   Colors.cyan) Dots.circle "Sweden" model.data.b
      , LineChart.line (Manipulate.lighten 0.2 Colors.blue) Dots.circle "Iceland" model.data.d
      , LineChart.line (Manipulate.lighten 0   Colors.blue) Dots.circle "Faroe Islands" model.data.f
      , LineChart.line (Manipulate.lighten 0   Colors.pink) Dots.circle "Norway" model.data.c
      , LineChart.line (Manipulate.darken  0.2 Colors.pink) Dots.circle "Finland" model.data.e
      ]


  toLineStyle : Maybe Coordinate.Point -> List Coordinate.Point -> Line.Style
  toLineStyle maybeHovered lineData =
    case maybeHovered of
      Nothing -> -- No line is hovered
        Line.style 1 identity

      Just hovered -> -- Some line is hovered
        if List.any ((==) hovered) lineData then
          -- It is this one, so make it pop!
          Line.style 2 identity
        else
          -- It is not this one, so hide it a bit
          Line.style 1 (Manipulate.grayscale)


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
  """