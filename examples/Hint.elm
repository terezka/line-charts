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
import Internal.Primitives exposing (vertical) -- TODO


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
    { frame = Frame (Margin 40 150 90 150) (Size 650 400)
    , attributes = [ SvgA.style "font-family: monospace;" ]
    , defs = []
    , events = Events.default Hover
    , junk = Maybe.map junk model.hovering |> Maybe.withDefault Junk.none
    , x = Axis.defaultAxis (Axis.defaultTitle "Year" 0 0) .year
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
    { normal = Dot.circle [] 4 (Dot.disconnected 2)
    , hovered = Dot.cross [] 12 (Dot.disconnected 2)
    }


square : Model -> Dot.Dot Data msg
square model =
  Dot.hoverable (isHovered model)
    { normal = Dot.circle [] 4 (Dot.disconnected 2)
    , hovered = Dot.cross [] 12 (Dot.disconnected 2)
    }


circle : Model -> Dot.Dot Data msg
circle model =
  Dot.hoverable (isHovered model)
    { normal = Dot.circle [] 4 (Dot.disconnected 2)
    , hovered = Dot.cross [] 12 (Dot.disconnected 2)
    }


isHovered : Model -> Data -> Bool
isHovered model data =
  Just data == model.hovering


junk : Data -> Junk.Junk Msg
junk hint =
  Junk.custom <| \system ->
    let
      ( xOffset, styles ) =
        if hint.year < system.x.min + ((system.x.max - system.x.min) / 2) then
          ( 5, "text-anchor: start;" )
        else
          ( -5, "text-anchor: end;" )

      viewHint hint = -- TODO as html
        Svg.g
          [ placeWithOffset system hint.year hint.cats xOffset 20, SvgA.style styles ]
          [ text_ [] [ tspan [] [ text <| toString ( hint.year, hint.cats ) ] ] ]

      line =
        vertical system [] hint.year system.y.min system.y.max
    in
    { below = []
    , above = [ viewHint hint ]
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
