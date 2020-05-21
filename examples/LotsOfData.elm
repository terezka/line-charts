module LotsOfData exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Junk as Junk
import LineChart.Colors as Colors
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Random
import Browser



main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> init
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }



-- MODEL


type alias Model =
    { data : List Coordinate.Point }


init : ( Model, Cmd Msg )
init =
    ( { data = [] }, getNumbers )



-- UPDATE


type Msg
  = ReceiveNumbers (List Float)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ReceiveNumbers numbers ->
      ( { model | data = List.indexedMap toData numbers }
      , Cmd.none
      )


toData : Int -> Float -> Coordinate.Point
toData index =
  Coordinate.Point (toFloat index)


getNumbers : Cmd Msg
getNumbers =
  Random.list 1501 (Random.float 0 20)
    |> Random.generate ReceiveNumbers



-- VIEW


view : Model -> Svg Msg
view model =
  Html.div
    [ class "container" ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { y =  Axis.default 450 "y" .y
    , x = Axis.default 1700 "x" .x
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.custom .min .min
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.none "data" model.data ]



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
