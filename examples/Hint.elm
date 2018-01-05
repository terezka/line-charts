module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Lines as Lines
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Axis.Title as Title
import Lines.Axis.Range as Range
import Lines.Axis.Intersection as Intersection
import Lines.Coordinate as Coordinate
import Lines.Legends as Legends
import Lines.Line as Line
import Lines.Axis.Tick as Tick
import Lines.Axis.Line as AxisLine
import Lines.Events as Events
import Lines.Grid as Grid
import Lines.Legends as Legends
import Internal.Axis.Values as Values -- TODO
import Svg exposing (Attribute, Svg, g, text_, tspan)
import Svg.Attributes as SvgA


-- MODEL


type alias Model =
    { hovering : Maybe Info }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Info)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover point ->
            { model | hovering = point }



-- VIEW

-- TODO tick offset and direction
view : Model -> Svg Msg
view model =
    Lines.viewCustom
      { margin = Coordinate.Margin 40 150 90 150
      , attributes = [ SvgA.style "font-family: monospace;" ]
      , events = Events.default Hover
      , x =
          { title = Title.default "age (years)"
          , variable = .age
          , pixels = 650
          , padding = 20
          , range = Range.default
          , axis =
              Axis.custom AxisLine.default <| \data range ->
                (Maybe.map (hoverTick >> List.singleton) model.hovering |> Maybe.withDefault []) ++
                List.map Tick.float (Values.float (Values.Around 4) range) ++
                List.map Tick.float [ data.min, data.max ]
          }
      , y =
          { title = Title.default "weight (kg)"
          , variable = .weight
          , pixels = 400
          , padding = 20
          , range = Range.default
          , axis = Axis.dashed AxisLine.default dataTick <| \_ _ -> []
          }
      , intersection = Intersection.default
      , junk = Maybe.map junk model.hovering |> Maybe.withDefault Junk.none
      , interpolation = Lines.monotone
      , legends = Legends.default
      , line = Line.wider 2
      , dot = Dot.emphasizable (Dot.disconnected 10 2) (Dot.aura 7 5 0.25) (Dot.isMaybe model.hovering)
      , areaOpacity = 0
      , grid = Grid.lines 1 Color.grayLight
      , id = "chart"
      }
      [ Lines.line Color.blue Dot.circle "bob" bob
      , Lines.line Color.orange Dot.triangle "alice" alice
      , Lines.line Color.pink Dot.square "chuck" chuck
      ]


dataTick : Info -> Tick.Tick msg
dataTick n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| Junk.text (toString n.weight)
  , grid = True
  , position = n.weight
  }


hoverTick : Info -> Tick.Tick msg
hoverTick n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = -7
  , label = Just <| g [ transform [ offset 0 -30 ] ] [ Junk.text (toString n.age) ]
  , grid = True
  , position = n.age
  }


junk : Info -> Junk.Junk Msg
junk hint =
    Junk.custom <| \system ->
      let
          viewHint =
              g [ transform [ move system hint.age hint.weight, offset 20 10 ] ]
                [ text_ []
                    [ viewDimension "weight" hint.weight
                    , viewDimension "age" hint.age
                    ]
                ]

          viewDimension label value =
            tspan
              [ SvgA.x "0", SvgA.dy "1em" ]
              [ Svg.text <| label ++ ": " ++ toString value ]
      in
      { below = []
      , above = [ viewHint ]
      , html = []
      }


tooltip : Coordinate.System -> Info -> Svg msg
tooltip system hovered =
  Svg.g
    [ Junk.transform
        [ Junk.move system hovered.age hovered.weight
        , Junk.offset 20 10
        ]
    ]
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
  [ Info 4 24 0.94 0
  , Info 25 75 1.73 25000
  , Info 30 56 1.75 44000
  , Info 43 83 1.75 40000
  ]


bob : List Info
bob =
  [ Info 4 22 1.01 0
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
