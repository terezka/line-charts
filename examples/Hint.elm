module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Colors
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
import Lines.Area as Area
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
    Lines.viewCustom
      { margin = Coordinate.Margin 150 150 150 150
      , attributes = [ SvgA.style "font: caption;" ]
      , events = Events.hoverOne HoverSingle
      , x = Dimension.default 750 "income" .income
      , y = Dimension.default 670 "age" .age
      , intersection = Intersection.default
      , junk = junkX model.hoveringX
          --Maybe.map junkSingle model.hovering
          --Maybe.map2 (junk model.hoveringX) model.point model.hovering
            --|> Maybe.withDefault Junk.none
      , interpolation = Lines.monotone
      , legends = Legends.default
      , line = Line.default
      , dot =
          Dot.hoverable
            { normal = Dot.disconnected 10 2
            , hovered = Dot.aura 6 5 0.3
            , isHovered = Just >> (==) model.hovering
            }
      , grid = Grid.dots Colors.grayLight
      , area = Area.none
      , id = "chart"
      }
      [ Lines.line Colors.pink Dot.square "chuck" chuck
      , Lines.line Colors.blue Dot.circle "bob" bob
      , Lines.line Colors.orange Dot.triangle "alice" alice
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
    , above = List.map (\info -> Junk.vertical system [] info.income system.y.min system.y.max) hovering
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
