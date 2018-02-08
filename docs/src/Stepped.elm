module Stepped exposing (Model, init, Msg, update, view)

import Html
import Html.Attributes
import Time
import Random
import Date
import Date.Format
import Color.Convert
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
      Random.list 30 (Random.int -70 100)
  in
  Random.map3 (,,) genNumbers genNumbers genNumbers
    |> Random.generate RecieveNumbers



-- API


setData : ( List Int, List Int, List Int ) -> Model -> Model
setData ( n1, n2, n3 ) model =
  { model | data = Data (toData n1) (toData n2) (toData n3) }


toData : List Int -> List Coordinate.Point
toData numbers =
  List.indexedMap (\i n -> Coordinate.Point (toDate i) (toFloat n)) numbers


toDate : Int -> Time.Time
toDate index =
  Time.hour * 24 * 356 * 45 + xInterval * toFloat index


xInterval : Time.Time
xInterval =
  Time.hour * 24


setHint : Maybe Coordinate.Point -> Model -> Model
setHint hinted model =
  { model | hinted = hinted }



-- UPDATE


type Msg
  = RecieveNumbers ( List Int, List Int, List Int )
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
          { title = Title.default "LoC"
          , variable = Just << .y
          , pixels = 450
          , range = Range.padded 20 20
          , axisLine = AxisLine.full Colors.gray
          , ticks = Ticks.float 8
          }
    , x =
        Axis.custom
          { title = Title.default "Time"
          , variable = Just << .x
          , pixels = 1270
          , range = Range.padded 20 60
          , axisLine = AxisLine.full Colors.gray
          , ticks = Ticks.time 10
          }
    , container = Container.spaced "line-chart-area" 30 100 60 70
    , interpolation = Interpolation.stepped
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverMany (Hint << List.head)
    , junk =
        case model.hinted of
          Nothing ->
            Junk.default

          Just hinted ->
            Junk.custom <| \system ->
              let x = hinted.x + xInterval / 2 in
              { below = [ Junk.vertical system [] x ]
              , above = []
              , html  = [ Junk.hoverAt system x system.y.max [] (viewHint hinted) ]
              }
    , grid = Grid.default
    , area = Area.normal 0.5
    , line = Line.default
    , dots = Dots.custom (Dots.empty 5 1)
    }
    [ LineChart.line Colors.pink Dots.none "Nora" model.data.nora ]


viewHint :  Coordinate.Point -> List (Html.Html msg)
viewHint { x, y } =
  let
    xString =
       Date.Format.format "%e. %b, %Y" (Date.fromTime x)

    pStyle other =
      Html.Attributes.style <| ( "margin", "3px" ) :: other

    ( loCStyle, loC ) =
        if y == 0 then
         ( [ ( "color", "black" ) ]
         , "0"
         )
        else if y < 0 then
         ( [ ( "color", Color.Convert.colorToHex Colors.red ) ]
         , toString y
         )
        else
         ( [ ( "color", Color.Convert.colorToHex Colors.green ) ]
         , "+" ++ toString y
         )
  in
  [ Html.p
      [ pStyle
          [ ( "border-bottom", "1px solid rgb(163, 163, 163)" )
          , ( "padding-bottom", "3px" )
          , ( "margin-bottom", "5px" )
          ]
      ]
      [ Html.text xString ]
  , Html.p
    [ pStyle [] ]
    [ Html.span [ Html.Attributes.style loCStyle ] [ Html.text loC ]
    , Html.span [] [ Html.text " lines of code" ]
    ]
  ]



-- UTILS


round100 : Float -> Float
round100 float =
  toFloat (round (float * 100)) / 100
