module Selection exposing (Model, init, Msg, update, view, source)

import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Time
import Date
import Date.Format
import Random
import Random.Pipeline
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
  , hinted : Maybe Datum
  }


type alias Selection =
  { xStart : Float
  , xEnd : Float
  }


type alias Data =
  { sanJose : List Datum
  , sanDiego : List Datum
  , sanFransisco : List Datum
  }


type alias Datum =
  { time : Time.Time
  , displacement : Float
  }


-- INIT


init : ( Model, Cmd Msg )
init =
  ( { data = Data [] [] []
    , hovered = Nothing
    , selection = Nothing
    , dragging = False
    , hinted = Nothing
    }
  , generateData
  )


generateData : Cmd Msg
generateData =
  let
    genNumbers min max =
      Random.list 201 (Random.float min max)

    compile a b c =
      Data (toData a) (toData b) (toData c)
  in
  Random.Pipeline.generate compile
    |> Random.Pipeline.with (genNumbers -10 10)
    |> Random.Pipeline.with (genNumbers -7 7)
    |> Random.Pipeline.with (genNumbers -8 8)
    |> Random.Pipeline.send RecieveData


toData : List Float -> List Datum
toData numbers =
  let
    toDatum index displacement =
      Datum (indexToTime index) displacement
  in
  List.indexedMap toDatum numbers


indexToTime : Int -> Time.Time
indexToTime index =
  Time.hour * 24 * 365 * 45 + -- 45 years
  Time.hour * 24 * 30 + -- a month
  Time.minute * 15 * toFloat index -- hours from first datum



-- MODEL API


setData : Data -> Model -> Model
setData data model =
  { model | data = data }


setSelection : Maybe Selection -> Model -> Model
setSelection selection model =
  { model | selection = selection }


setDragging : Bool -> Model -> Model
setDragging dragging model =
  { model | dragging = dragging }


setHovered : Maybe Float -> Model -> Model
setHovered hovered model =
  { model | hovered = hovered }


setHint : Maybe Datum -> Model -> Model
setHint hinted model =
  { model | hinted = hinted }


getSelectionXStart : Float -> Model -> Float
getSelectionXStart hovered model =
  case model.selection of
    Just selection -> selection.xStart
    Nothing        -> hovered



-- UPDATE


type Msg
  = RecieveData Data
  -- Chart Main
  | Hold Coordinate.Point
  | Move Coordinate.Point
  | Drop Coordinate.Point
  | LeaveChart Coordinate.Point
  | LeaveContainer Coordinate.Point
  -- Chart Zoom
  | Hint (Maybe Datum)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    RecieveData data ->
      model
        |> setData data
        |> addCmd Cmd.none

    Hold point ->
      model
        |> setSelection Nothing
        |> setDragging True
        |> addCmd Cmd.none

    Move point ->
      if model.dragging then
        let
          start = getSelectionXStart point.x model
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
      if point.x == getSelectionXStart point.x model then
        model
          |> setSelection Nothing
          |> setDragging False
          |> addCmd Cmd.none
      else
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

    Hint datum ->
      model
        |> setHint datum
        |> addCmd Cmd.none


addCmd : Cmd Msg -> Model -> ( Model, Cmd Msg )
addCmd cmd model =
  ( model, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div [] <|
    case model.selection of
      Nothing ->
        [ viewPlaceholder
        , viewChartMain model
        ]

      Just selection ->
        if selection.xStart == selection.xEnd then
          [ viewPlaceholder
          , viewChartMain model
          ]
        else
          [ viewChartZoom model selection
          , viewChartMain model
          ]


viewPlaceholder : Html.Html Msg
viewPlaceholder =
  Html.div
    [ Html.Attributes.class "view__selection__placeholder" ]
    [ viewInnerPlaceholder ]


viewInnerPlaceholder : Html.Html Msg
viewInnerPlaceholder =
  Html.div
    [ Html.Attributes.class "view__selection__placeholder__inner" ]
    [ viewPlaceholderText ]


viewPlaceholderText : Html.Html Msg
viewPlaceholderText =
  Html.div
    [ Html.Attributes.class "view__selection__placeholder__inner__text" ]
    [ Html.text "Select a range on the chart to the right!" ]



-- MAIN CHART


viewChartMain : Model -> Html.Html Msg
viewChartMain model =
  viewChart model.data
    { range = Range.default
    , junk = junkConfig model
    , legends = Legends.default
    , events = events
    , width = 670
    , margin = Container.Margin 30 165 30 70
    , dots = Dots.custom (Dots.full 0)
    , id = "line-chart-selection-main"
    }


events : Events.Config Datum Msg
events =
  let
    options bool =
      { stopPropagation = True
      , preventDefault = True
      , catchOutsideChart = bool
      }
  in
  Events.custom
    [ Events.onWithOptions "mousedown"  (options False) Hold           Events.getData
    , Events.onWithOptions "mousemove"  (options False) Move           Events.getData
    , Events.onWithOptions "mouseup"    (options True)  Drop           Events.getData
    , Events.onWithOptions "mouseleave" (options False) LeaveChart     Events.getData
    , Events.onWithOptions "mouseleave" (options True)  LeaveContainer Events.getData
    ]


junkConfig : Model -> Junk.Config Datum msg
junkConfig model =
  Junk.custom <| \system ->
    { below = below system model.selection
    , above = above system model.hovered
    , html = []
    }


below : Coordinate.System -> Maybe Selection -> List (Svg.Svg msg)
below system selection =
  case selection of
    Just { xStart, xEnd } ->
      let
        attributes =
          [ Svg.Attributes.fill "#4646461a" ]

        ( yStart, yEnd ) =
          ( system.y.min, system.y.max )

        viewSelection =
          Junk.rectangle system attributes xStart xEnd yStart yEnd
      in
      [ viewSelection ]

    Nothing ->
      []


above : Coordinate.System -> Maybe Float -> List (Svg.Svg msg)
above system hovered =
  case hovered of
    Just hovered ->
      [ Junk.vertical system [] hovered
      , title system
      ]

    Nothing ->
      [ title system ]


title : Coordinate.System -> Svg.Svg msg
title system =
  Junk.labelAt system system.x.max system.y.max 20 -5 "start" Colors.black "Earthquake in"



-- ZOOM CHART


viewChartZoom : Model -> Selection -> Html.Html Msg
viewChartZoom model selection =
  viewChart model.data
    { range = xAxisRangeConfig selection
    , junk =
        Junk.hoverOne model.hinted
          [ ( "time", formatX )
          , ( "displacement", formatY )
          ]
    , events = Events.hoverOne Hint
    , legends = Legends.none
    , dots = Dots.hoverOne model.hinted
    , width = 670
    , margin = Container.Margin 30 60 30 75
    , id = "line-chart-zoom"
    }


xAxisRangeConfig : Selection -> Range.Config
xAxisRangeConfig selection =
  let
    xStart =
      min selection.xStart selection.xEnd

    xEnd =
      max selection.xStart selection.xEnd
  in
  Range.window xStart xEnd


formatX : Datum -> String
formatX datum =
  Date.Format.format "%l:%M%P, %e. %b, %Y" (Date.fromTime datum.time)


formatY : Datum -> String
formatY datum =
  toString (round100 datum.displacement)




-- VIEW CHART


type alias Config =
  { range : Range.Config
  , junk : Junk.Config Datum Msg
  , events : Events.Config Datum Msg
  , legends : Legends.Config Datum Msg
  , dots : Dots.Config Datum
  , margin : Container.Margin
  , width : Int
  , id : String
  }


viewChart : Data -> Config -> Html.Html Msg
viewChart data { range, junk, events, legends, dots, width, margin, id } =
  let
    containerStyles =
      [ ( "display", "inline-block" )
      , ( "width", "50%" )
      , ( "height", "100%" )
      ]
  in
  LineChart.viewCustom
    { y =
        Axis.custom
          { title = Title.atAxisMax 50 0 "displacement"
          , variable = Just << .displacement
          , pixels = 450
          , range = Range.padded 20 20
          , axisLine = AxisLine.rangeFrame Colors.gray
          , ticks = Ticks.float 5
          }
    , x =
        Axis.custom
          { title = Title.default "time"
          , variable = Just << .time
          , pixels = width
          , range = range
          , axisLine = AxisLine.rangeFrame Colors.gray
          , ticks = Ticks.time 5
          }
    , container =
        Container.custom
          { attributesHtml = [ Html.Attributes.style containerStyles ]
          , attributesSvg = []
          , size = Container.static
          , margin = margin
          , id = id
          }
    , interpolation = Interpolation.monotone
    , intersection = Intersection.default
    , legends = legends
    , events = events
    , junk = junk
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = dots
    }
    [ LineChart.line Colors.pink Dots.circle "San Jose" data.sanJose
    , LineChart.line Colors.cyan Dots.circle "San Fransisco" data.sanFransisco
    , LineChart.line Colors.blue Dots.circle "San Diego" data.sanDiego
    ]



-- UTILS


round100 : Float -> Float
round100 float =
  toFloat (round (float * 100)) / 100




-- SOURCE


source : String
source =
  """
  -- MODEL


  type alias Model =
    { data : Data
    , hovered : Maybe Float
    , selection : Maybe Selection
    , dragging : Bool
    , hinted : Maybe Datum
    }


  type alias Selection =
    { xStart : Float
    , xEnd : Float
    }


  type alias Data =
    { nora : List Datum
    , noah : List Datum
    , nina : List Datum
    }



  -- INIT


  init : ( Model, Cmd Msg )
  init =
    ( { data = Data [] [] []
      , hovered = Nothing
      , selection = Nothing
      , dragging = False
      , hinted = Nothing
      }
    , generateData
    )


  generateData : Cmd Msg
  generateData =
    let
      genNumbers =
        Random.list 201 (Random.float 0 20)
    in
    Random.map3 (,,) genNumbers genNumbers genNumbers
      |> Random.generate RecieveData



  -- MODEL API


  setData : ( List Float, List Float, List Float ) -> Model -> Model
  setData ( n1, n2, n3 ) model =
    { model | data = Data (toData n1) (toData n2) (toData n3) }


  toData : List Float -> List Datum
  toData numbers =
    List.indexedMap (\\i -> Datum (toFloat i)) numbers


  setSelection : Maybe Selection -> Model -> Model
  setSelection selection model =
    { model | selection = selection }


  setDragging : Bool -> Model -> Model
  setDragging dragging model =
    { model | dragging = dragging }


  setHovered : Maybe Float -> Model -> Model
  setHovered hovered model =
    { model | hovered = hovered }


  setHint : Maybe Datum -> Model -> Model
  setHint hinted model =
    { model | hinted = hinted }


  getSelectionXStart : Float -> Model -> Float
  getSelectionXStart hovered model =
    case model.selection of
      Just selection -> selection.xStart
      Nothing        -> hovered



  -- UPDATE


  type Msg
    = RecieveData ( List Float, List Float, List Float )
    -- Chart Main
    | Hold Datum
    | Move Datum
    | Drop Datum
    | LeaveChart Datum
    | LeaveContainer Datum
    -- Chart Zoom
    | Hint (Maybe Datum)


  update : Msg -> Model -> ( Model, Cmd Msg )
  update msg model =
    case msg of
      RecieveData numbers ->
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
            start = getSelectionXStart point.x model
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
        if point.x == getSelectionXStart point.x model then
          model
            |> setSelection Nothing
            |> setDragging False
            |> addCmd Cmd.none
        else
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
    let
      style =
        [ ( "display", "flex" ) ]

      content =
        case model.selection of
          Nothing ->
            [ viewPlaceholder
            , viewChartMain model
            ]

          Just selection ->
            if selection.xStart == selection.xEnd then
              [ viewPlaceholder
              , viewChartMain model
              ]
            else
              [ viewChartZoom model selection
              , viewChartMain model
              ]
    in
    Html.div [ Html.Attributes.style style ] content


  viewPlaceholder : Html.Html Msg
  viewPlaceholder =
    Html.div
      [ Html.Attributes.style
          [ ( "margin", "40px 25px 30px 70px" )
          , ( "width", "505px" )
          , ( "height", "360px" )
          , ( "background", "#4646461a" )
          , ( "text-align", "center" )
          , ( "line-height", "340px" )
          ]
      ]
      [ Html.text "Select a range on the graph to the right!" ]



  -- MAIN CHART


  viewChartMain : Model -> Html.Html Msg
  viewChartMain model =
    viewChart model.data
      { range = Range.default
      , junk = junkConfig model
      , legends = Legends.default
      , events = events
      , width = 670
      , margin = Container.Margin 30 100 60 70
      , dots = Dots.custom (Dots.full 0)
      , id = "line-chart"
      }


  events : Events.Config Datum Msg
  events =
    let
      options bool =
        { stopPropagation = True
        , preventDefault = True
        , catchOutsideChart = bool
        }
    in
    Events.custom
      [ Events.onWithOptions "mousedown"  (options False) Hold           Events.getData
      , Events.onWithOptions "mousemove"  (options False) Move           Events.getData
      , Events.onWithOptions "mouseup"    (options True)  Drop           Events.getData
      , Events.onWithOptions "mouseleave" (options False) LeaveChart     Events.getData
      , Events.onWithOptions "mouseleave" (options True)  LeaveContainer Events.getData
      ]


  junkConfig : Model -> Junk.Config Datum msg
  junkConfig model =
    Junk.custom <| \\system ->
      { below = below system model.selection
      , above = above system model.hovered
      , html = []
      }


  below : Coordinate.System -> Maybe Selection -> List (Svg.Svg msg)
  below system selection =
    case selection of
      Just { xStart, xEnd } ->
        let
          attributes =
            [ Svg.Attributes.fill "#4646461a" ]

          ( yStart, yEnd ) =
            ( system.y.min, system.y.max )

          viewSelection =
            Junk.rectangle system attributes xStart xEnd yStart yEnd
        in
        [ viewSelection ]

      Nothing ->
        []


  above : Coordinate.System -> Maybe Float -> List (Svg.Svg msg)
  above system hovered =
    case hovered of
      Just hovered ->
        [ Junk.vertical system [] hovered ]

      Nothing ->
        []



  -- ZOOM CHART


  viewChartZoom : Model -> Selection -> Html.Html Msg
  viewChartZoom model selection =
    viewChart model.data
      { range = xAxisRangeConfig selection
      , junk =
          Junk.hoverOne model.hinted
            [ ( "x", toString << round100 << .x )
            , ( "y", toString << round100 << .y )
            ]
      , events = Events.hoverOne Hint
      , legends = Legends.none
      , dots = Dots.hoverOne model.hinted
      , width = 600
      , margin = Container.Margin 30 25 60 70
      , id = "line-chart-zoom"
      }


  xAxisRangeConfig : Selection -> Range.Config
  xAxisRangeConfig selection =
    let
      xStart =
        min selection.xStart selection.xEnd

      xEnd =
        max selection.xStart selection.xEnd
    in
    Range.window xStart xEnd




  -- VIEW CHART


  type alias Config =
    { range : Range.Config
    , junk : Junk.Config Datum Msg
    , events : Events.Config Datum Msg
    , legends : Legends.Config Datum Msg
    , dots : Dots.Config Datum
    , margin : Container.Margin
    , width : Int
    , id : String
    }


  viewChart : Data -> Config -> Html.Html Msg
  viewChart data { range, junk, events, legends, dots, width, margin, id } =
    LineChart.viewCustom
      { y = Axis.default 450 "y" .y
      , x =
          Axis.custom
            { title = Title.default "x"
            , variable = Just << .x
            , pixels = width
            , range = range
            , axisLine = AxisLine.rangeFrame Colors.gray
            , ticks = Ticks.float 5
            }
      , container =
          Container.custom
            { attributesHtml = [ Html.Attributes.style [ ( "display", "inline-block" ) ] ]
            , attributesSvg = []
            , size = Container.static
            , margin = margin
            , id = "chart-id"
            }
      , interpolation = Interpolation.monotone
      , intersection = Intersection.default
      , legends = legends
      , events = events
      , junk = junk
      , grid = Grid.default
      , area = Area.default
      , line = Line.default
      , dots = dots
      }
      [ LineChart.line Colors.pink Dots.circle "Nora" data.nora
      , LineChart.line Colors.cyan Dots.circle "Noah" data.noah
      , LineChart.line Colors.blue Dots.circle "Nina" data.nina
      ]



  -- UTILS


  round100 : Float -> Float
  round100 float =
    toFloat (round (float * 100)) / 100


  """
