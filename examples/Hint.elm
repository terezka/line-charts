module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis.Intersection as Intersection
import Lines.Coordinate as Coordinate
import Lines.Legends as Legends
import Lines.Line as Line
import Lines.Events as Events
import Lines.Grid as Grid
import Lines.Dimension as Dimension
import Lines.Legends as Legends
import Svg exposing (Attribute, Svg, g, text_, tspan)
import Svg.Attributes as SvgA


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


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover (infos, point) ->
            { model
            | point = Just point
            , hoveringX = infos
            }



-- VIEW


view : Model -> Svg Msg
view model =
    Lines.viewCustom
      { margin = Coordinate.Margin 40 150 90 150
      , attributes = [ SvgA.style "font-family: monospace;" ]
      , events =
          Events.custom
            [ Events.onMouseMove Hover <|
                Events.map2 (,) Events.getNearestX Events.getSvg
            ]
      , x = Dimension.default 650 "age (years)" .age
      , y = Dimension.default 400 "weight (kg)" .weight
      , intersection = Intersection.default
      , junk =
          Maybe.map (junk model.hoveringX) model.point
            |> Maybe.withDefault Junk.none
      , interpolation = Lines.monotone
      , legends = Legends.default
      , line =
          Line.emphasizable
            { normal = Line.style 2 identity
            , emphasized = Line.style 4 identity
            , isEmphasized = \data -> List.any (flip List.member data) model.hoveringX
            }
      , dot =
          Dot.emphasizable
            { normal = Dot.disconnected 10 2
            , emphasized = Dot.aura 7 5 0.25
            , isEmphasized = \data -> List.member data model.hoveringX
            }
      , areaOpacity = 0
      , grid = Grid.default
      , id = "chart"
      }
      [ Lines.line Color.blue Dot.circle "bob" bob
      , Lines.line Color.orange Dot.triangle "alice" alice
      , Lines.line Color.pink Dot.square "chuck" chuck
      ]


viewLegend : Int -> Legends.Legend msg -> Svg.Svg msg
viewLegend index { sample, label } =
   Svg.g
    [ Junk.transform [ Junk.offset 20 (toFloat index * 20) ] ]
    [ sample
    , Svg.g
        [ Junk.transform [ Junk.offset 40 4 ] ]
        [ Junk.text Color.black label ]
    ]


junk : List Info ->Coordinate.Point -> Junk.Junk Msg
junk hintx point =
    Junk.custom <| \system ->
      { below = []
      , above =
          [ Svg.g [] (List.indexedMap (tooltip system) hintx)
          , Svg.g [] (List.concatMap (line system) hintx)
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


line : Coordinate.System -> Info -> List (Svg msg)
line system hint =
  [ Junk.horizontal system [ SvgA.strokeDasharray "1 4" ] hint.weight system.x.min system.x.max
  , Junk.vertical system [ SvgA.strokeDasharray "1 4" ] hint.age system.y.min system.y.max
  ]



tooltip : Coordinate.System -> Int -> Info -> Svg msg
tooltip system index hovered =
  Svg.g
    [ Junk.transform [ Junk.offset 520 (100 + toFloat index * 40) ] ]
    [ Svg.text_ []
        [ dimension "Age" hovered.age
        , dimension "Weight" hovered.weight
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
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Info
alice =
  [ Info -14 24 0.94 0
  , Info 25 75 1.73 25000
  , Info 30 56 1.75 44000
  , Info 43 83 1.75 40000
  ]


bob : List Info
bob =
  [ Info -4 22 1.01 0
  , Info 25 75 1.87 28000
  , Info 32 79 1.85 45000
  , Info 43 77 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 4 21 0.98 0
  , Info 25 89 1.83 85000
  , Info 33 90 1.85 90000
  , Info 43 95 1.84 120000
  ]


-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (Svg.text "")
