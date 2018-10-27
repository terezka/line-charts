module Docs.Junk.Example4 exposing (main)

import Html
import Time
import Date
import Date.Format
import LineChart
import LineChart.Junk as Junk
import LineChart.Area as Area
import LineChart.Axis as Axis
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
    { hovered : List Data }


init : Model
init =
    { hovered = [] }



-- UPDATE


type Msg
  = Hover (List Data)


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
    { y = Axis.default 450 "Weight" .weight
    , x = Axis.time 700 "Time" .date
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverMany Hover
    , junk =
        Junk.hoverMany model.hovered formatX formatY
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.triangle "Chuck" chuck
    , LineChart.line Colors.blue Dots.circle "Bobby" bobby
    , LineChart.line Colors.cyan Dots.diamond "Alice" alice
    ]


formatX : Data -> String
formatX =
  .date >> Date.fromTime >> Date.Format.format "%e. %b, %Y"


formatY : Data -> String
formatY data =
  toString data.weight ++ "kg"



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
