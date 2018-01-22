module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Title as Title
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis as Axis
import LineChart.Coordinate as Coordinate
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Svg.Attributes as SvgA
import Color


-- MODEL


type alias Model =
    { hovering : Maybe Info
    , point : Maybe Coordinate.Point
    , hoveringX : List Info
    }


initialModel : Model
initialModel =
    { hovering = Nothing
    , point = Nothing
    , hoveringX = []
    }



-- UPDATE


type Msg
    = Hover (List Info, Coordinate.Point)
    | HoverX (List Info)
    | HoverSingle (Maybe Info)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover (infos, point) ->
            { model
            | point = Just point
            , hoveringX = infos
            }

        HoverX infos ->
          { model | hoveringX = infos }

        HoverSingle hovering ->
          { model | hovering = hovering }



-- VIEW


view : Model -> Svg Msg
view model =
  LineChart.viewCustom
    { y = Axis.default 670 "age" .age
    , x = Axis.default 750 "income" .income
    , container = Container.default "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.gold Dots.diamond "alice" alice
    , LineChart.line Colors.blue Dots.circle  "bobby" bob
    , LineChart.line Colors.pink Dots.square  "chuck" chuck
    ]



viewLegend : Int -> Legends.Legend msg -> Svg.Svg msg
viewLegend index { sample, label } =
   Svg.g
    [ Junk.transform [ Junk.offset 20 (toFloat index * 20) ] ]
    [ sample
    , Svg.g
        [ Junk.transform [ Junk.offset 40 4 ] ]
        [ Junk.label Color.black label ]
    ]


junkX : List Info -> Junk.Config Msg
junkX hovering =
  Junk.custom <| \system ->
    { below = []
    , above = List.map (\info -> Junk.vertical system [] info.income) hovering
    , html = []
    }


junkSingle : Info -> Junk.Config Msg
junkSingle hovering =
    Junk.custom <| \system ->
      { below = []
      , above = [ tooltip system 0 hovering   ]
      , html = []
      }


junk : List Info -> Coordinate.Point -> Info -> Junk.Config Msg
junk hintx point hovering =
    Junk.custom <| \system ->
      { below = []
      , above =
          [ Svg.g [] (List.indexedMap (tooltip system) hintx)
          , tooltip system 0 hovering
          , Svg.circle
            [ SvgA.cx (toString point.x)
            , SvgA.cy (toString point.y)
            , SvgA.r "2"
            , SvgA.fill "red"
            ]
            []
          ]
      , html = []
      }



tooltip : Coordinate.System -> Int -> Info -> Svg msg
tooltip system index hovered =
  Svg.g
    [ Junk.transform [ Junk.offset 520 (100 + toFloat index * 40) ] ]
    [ Svg.text_ []
        [ dimension "age" hovered.age
        ]
    ]

dimension : String -> Float -> Svg msg
dimension label value =
  Svg.tspan
    [ SvgA.x "0", SvgA.dy "1em" ]
    [ Svg.text <| label ++ ": " ++ toString value ]



-- DATA


type alias Info =
  { age : Float
  , income : Float
  }


alice : List Info
alice =
  [ Info ( -1) -3.2
  , Info ( -2) -2.4
  , Info ( -3) -1.1
  , Info ( 4) 4
  , Info ( 5) 5.2
  ]


bob : List Info
bob =
  [ Info ( -1) -3
  , Info ( -1) -2.5
  , Info ( -1) -1
  , Info ( 1) 4
  , Info ( 1) 5.1
  ]


chuck : List Info
chuck =
  [ Info ( 2) 1
  , Info ( 3) 2
  , Info ( 5) 3
  , Info ( 2) 4
  , Info ( 4) 5.5
  ]



-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (Svg.text "")
