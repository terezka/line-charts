module Docs.Ticks.Example2 exposing (main)


import Time
import Html
import LineChart
import LineChart.Colors as Colors
import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Title as Title
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Tick as Tick
import LineChart.Junk as Junk
import LineChart.Dots as Dots
import LineChart.Grid as Grid
import LineChart.Dots as Dots
import LineChart.Line as Line
import LineChart.Colors as Colors
import LineChart.Events as Events
import LineChart.Legends as Legends
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection


main : Program Never Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovered : Maybe Data }


init : Model
init =
    { hovered = Nothing }



-- UPDATE


type Msg
  = Hover (Maybe Data)


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovered ->
      { model | hovered = hovered }



-- VIEW


view : Model -> Html.Html Msg
view =
  chart


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { x = xAxisConfig model
    , y = Axis.default 400 "($)" .income
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverOne Hover
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.blueLight Dots.square "Chuck" chuck
    , LineChart.line Colors.pinkLight Dots.plus "Alice" alice
    , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
    ]


xAxisConfig : Model -> Axis.Config Data msg
xAxisConfig model =
  Axis.custom
    { title = Title.default "Weight"
    , variable = Just << .weight
    , pixels = 700
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = ticksConfig model.hovered
    }


ticksConfig : Maybe Data -> Ticks.Config msg
ticksConfig maybeHovered =
  let
    hoverOne =
      case maybeHovered of
        Just hovered -> [ Tick.opposite hovered.weight ]
        Nothing -> []

    framing range =
      List.map Tick.gridless [ range.min, range.max ]
  in
  Ticks.custom <| \dataRange axisRange ->
    framing dataRange ++ hoverOne



-- DATA


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  , date : Time.Time
  }


alice : List Data
alice =
  [ Data 4  24 0.94 0     (dateInterval 0)
  , Data 25 75 1.73 25000 (dateInterval 1)
  , Data 46 83 1.75 40000 (dateInterval 2)
  ]


bobby : List Data
bobby =
  [ Data 4  22 1.01 0     (dateInterval 0)
  , Data 25 75 1.87 28000 (dateInterval 1)
  , Data 46 77 1.87 52000 (dateInterval 2)
  ]


chuck : List Data
chuck =
  [ Data 4  21 0.98 0      (dateInterval 0)
  , Data 25 89 1.83 85000  (dateInterval 1)
  , Data 46 95 1.84 120000 (dateInterval 2)
  ]


average : List Data
average =
  [ Data 4  22.3 1.0  0     (dateInterval 0)
  , Data 25 79.7 1.8  46000 (dateInterval 1)
  , Data 46 85   1.82 70667 (dateInterval 2)
  ]


dateInterval : Int -> Time.Time
dateInterval i =
  4 * year + toFloat i * 21 * year


day : Time.Time
day =
  24 * Time.hour


year : Time.Time
year =
  356 * day
