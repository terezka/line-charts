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
import Lines.Area as Area
import Lines.Axis as Axis
import Lines.Axis.Title as Title
import Lines.Axis.Range as Range


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
      { margin = Coordinate.Margin 150 50 150 150
      , attributes = []
      , events = Events.hoverX HoverX
      , x = Dimension.time 750 "income" .income
      , y =
          { title = Title.default "age"
          , variable = .age
          , pixels = 650
          , range = Range.padded 20 20
          , axis = Axis.float 5
          }
      , intersection = Intersection.default
      , junk = junkX model.hoveringX
          --Maybe.map junkSingle model.hovering
          --Maybe.map2 (junk model.hoveringX) model.point model.hovering
            --|> Maybe.withDefault Junk.none
      , interpolation = Lines.linear
      , legends = Legends.default
      , line = Line.default
      , dot = Dot.static (Dot.bordered 10 2)
      , grid = Grid.lines 1 Color.grayLight
      , area = Area.none
      , id = "chart"
      }
      [ Lines.line Color.pink Dot.square "chuck" chuck
      , Lines.line Color.blue Dot.circle "bob" bob
      , Lines.line Color.orange Dot.triangle "alice" alice
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


junkX : List Info -> Junk.Junk Msg
junkX hovering =
  Junk.custom <| \system ->
    { below = []
    , above = List.map (\info -> Junk.vertical system [] info.income system.y.min system.y.max) hovering
    , html = []
    }


junkSingle : Info -> Junk.Junk Msg
junkSingle hovering =
    Junk.custom <| \system ->
      { below = []
      , above = [ tooltip system 0 hovering   ]
      , html = []
      }


junk : List Info -> Coordinate.Point -> Info -> Junk.Junk Msg
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

dimension : String -> Maybe Float -> Svg msg
dimension label value =
  Svg.tspan
    [ SvgA.x "0", SvgA.dy "1em" ]
    [ Svg.text <| label ++ ": " ++ (Maybe.map toString value |> Maybe.withDefault "unknown") ]



-- DATA


type alias Info =
  { age : Maybe Float
  , income : Float
  }


alice : List Info
alice =
  [ Info (Just -1) -1
  , Info (Just -2) -2
  , Info (Just -3) -3
  , Info (Just 4) 4
  , Info (Just 5) 5
  ]


bob : List Info
bob =
  [ Info (Just -1) -1
  , Info (Just -1) -2.5
  , Info (Just -1) -3
  , Info (Just 1) 4
  , Info (Just 1) 5
  ]


chuck : List Info
chuck =
  [ Info (Just 2) 1
  , Info (Just 3) 2
  , Info (Just 5) 3
  , Info (Just 2) 4
  , Info (Just 4) 5
  ]



-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (Svg.text "")
