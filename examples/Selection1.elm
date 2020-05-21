module Selection1 exposing (main)

import Html
import Svg
import Svg.Attributes
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
import LineChart.Coordinate as Coordinate
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
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
    { hovered : Maybe Coordinate.Point }


init : Model
init =
    { hovered = Nothing }



-- UPDATE


type Msg
  = Hover Coordinate.Point
  | Clear


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovered ->
      { model | hovered = Just hovered }

    Clear ->
      { model | hovered = Nothing }



-- VIEW


view : Model -> Html.Html Msg
view =
  chart


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" .weight
    , x = Axis.default 700 "Age" .age
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events =
        Events.custom
          [ Events.onMouseMove Hover Events.getData
          , Events.onMouseLeave Clear
          ]
    , junk = Junk.custom (junk model) -- Junk goes here!
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.blue Dots.triangle "Chuck" chuck
    , LineChart.line Colors.cyan Dots.circle "Bobby" bobby
    , LineChart.line Colors.pink Dots.diamond "Alice" alice
    ]


junk : Model -> Coordinate.System -> Junk.Layers msg
junk model system =
  { below =
      case model.hovered of
        Just hovered -> [ sectionBand system hovered ]
        Nothing      -> []
  , above = []
  , html = []
  }


sectionBand : Coordinate.System -> Coordinate.Point -> Svg.Svg msg
sectionBand system hovered =
  Junk.rectangle system [ Svg.Attributes.fill "#b6b6b61a" ] (hovered.x - 5) (hovered.x + 5) system.y.min system.y.max



-- DATA


type alias Data =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Data
alice =
  [ Data 10 34 1.34 0
  , Data 16 42 1.62 3000
  , Data 25 75 1.73 25000
  , Data 43 83 1.75 40000
  ]


bobby : List Data
bobby =
  [ Data 10 38 1.32 0
  , Data 17 69 1.75 2000
  , Data 25 75 1.87 32000
  , Data 43 77 1.87 52000
  ]


chuck : List Data
chuck =
  [ Data 10 42 1.35 0
  , Data 15 72 1.72 1800
  , Data 25 89 1.83 85000
  , Data 43 95 1.84 120000
  ]
