module HintExample exposing (main)

import Lines as Lines exposing (..)
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Legends as Legends
import Lines.Events as Events
import Lines.Coordinate as Coordinate exposing (..)
import Html exposing (Html, div, h1, node, p, text)
import Svg exposing (Svg, Attribute, text_, tspan, g)
import Svg.Attributes as SvgA



-- MODEL


type alias Model =
    { hovering : Maybe Data }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Data)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover point ->
            { model | hovering = point }




-- VIEW


view : Model -> Svg Msg
view model =
  Lines.viewCustom
    { container =
        { frame = Frame (Margin 40 150 90 150) (Size 650 400)
        , attributes = [ SvgA.style "font-family: monospace;" ]
        , defs = []
        }
    , events = Events.simple Hover
    , junk = Maybe.withDefault Junk.none (Maybe.map junk model.hovering)
    , x = Axis.defaultAxis (Axis.defaultTitle "Year" 0 3) .year
    , y = Axis.defaultAxis (Axis.defaultTitle "Cats" 0 0) .cats
    , interpolation = Lines.Monotone
    , legends = Legends.default
    }
    [ Lines.line Color.blue 1 (plus model) "Non-binary" data1
    , Lines.line Color.orange 1 (circle model) "Women" data3
    , Lines.line Color.pink 1 (square model) "Men" data2
    ]


plus : Model -> Dot.Dot Data msg
plus model =
  Dot.hoverable (isHovered model)
    { normal = Dot.triangle [] 5 (Dot.disconnected 2)
    , hovered = Dot.triangle [] 5 (Dot.aura 5 0.5)
    }


square : Model -> Dot.Dot Data msg
square model =
  Dot.hoverable (isHovered model)
    { normal = Dot.square [] 7 (Dot.disconnected 2)
    , hovered = Dot.square [] 7 (Dot.aura 5 0.5)
    }


circle : Model -> Dot.Dot Data msg
circle model =
  Dot.hoverable (isHovered model)
    { normal =  Dot.circle [] 4 (Dot.disconnected 2)
    , hovered = Dot.circle [] 4 (Dot.aura 5 0.5)
    }


isHovered : Model -> Data -> Bool
isHovered model data =
  Just data == model.hovering


junk : Data -> Junk.Junk Msg
junk hint =
  Junk.custom <| \system ->
    let
      viewHint = -- TODO as html
        Svg.g [ placeWithOffset system hint.year hint.cats 5 20 ]
          [ Svg.rect [ SvgA.fill "white", SvgA.y "-12", SvgA.width "80", SvgA.height "18", SvgA.opacity "0.5" ] []
          , text_ [] [ tspan [] [ text <| toString ( hint.year, hint.cats ) ] ]
          ]

      dot =
        Dot.circle [ SvgA.style "cursor: default;" ] 3 (Dot.disconnected 0)
    in
    { below = []
    , above =
        [ viewHint ]
    , html = []
    }



-- DATA


type alias Data =
  { year : Float
  , cats : Float
  }


data1 : List Data
data1 =
  [ Data 1 3
  , Data 2 4
  , Data 3 4.5
  , Data 4 5
  , Data 5 4.3
  , Data 6 5
  , Data 7 6.4
  , Data 8 6.7
  , Data 9 6.9
  , Data 10 9
  ]


data2 : List Data
data2 =
  [ Data 1 1
  , Data 2 2
  , Data 3 4
  , Data 4 7
  , Data 5 8
  , Data 6 8.2
  , Data 7 7
  , Data 8 4
  , Data 9 3
  , Data 10 6
  ]


data3 : List Data
data3 =
  [ Data 1 5
  , Data 2 5.7
  , Data 3 5.2
  , Data 4 6
  , Data 5 5.8
  , Data 6 5.2
  , Data 7 4
  , Data 8 3.6
  , Data 9 6
  , Data 10 7
  ]



-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (text "")
