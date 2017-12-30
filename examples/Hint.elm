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
import Lines.Events as Events
import Lines.Legends as Legends
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
          , axis = Axis.time (Axis.around 4)
          }
      , y =
          { title = Title.default "weight (kg)"
          , variable = .weight
          , pixels = 400
          , padding = 20
          , range = Range.default
          , axis = Axis.float (Axis.exactly 10)
          }
      , intersection = Intersection.default
      , junk = Maybe.map junk model.hovering |> Maybe.withDefault Junk.none
      , interpolation = Lines.monotone
      , legends = Legends.default
      , line = Line.wider 2
      , dot = Dot.emphasizable (Dot.disconnected 10 2) (Dot.aura 7 5 0.25) (Dot.isMaybe model.hovering)
      , areaOpacity = 0
      , id = "chart"
      }
      [ Lines.line Color.blue Dot.circle "bob" bob
      , Lines.line Color.orange Dot.triangle "alice" alice
      , Lines.line Color.pink Dot.square "chuck" chuck
      ]


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
      { below = List.map (Junk.gridHorizontal system []) [ 0, 1, 2 ]
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
  , Info 43 83 1.75 40000
  ]


bob : List Info
bob =
  [ Info 4 22 1.01 0
  , Info 25 75 1.87 28000
  , Info 43 77 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 4 21 0.98 0
  , Info 25 89 1.83 85000
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
