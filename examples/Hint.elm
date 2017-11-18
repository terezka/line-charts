module HintExample exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Internal.Primitives exposing (vertical)
import Lines as Lines exposing (..)
import Lines.Axis as Axis
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Dot as Dot
import Lines.Events as Events
import Lines.Junk as Junk exposing (..)
import Lines.Legends as Legends
import Lines.Line as Line
import Svg exposing (Attribute, Svg, g, text_, tspan)
import Svg.Attributes as SvgA


-- TODO
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
        , junk = Maybe.map junk model.hovering |> Maybe.withDefault Junk.none
        , x = Axis.defaultAxis (Axis.defaultTitle "Year" 0 0) .year
        , y = Axis.defaultAxis (Axis.defaultTitle "Cats" 0 0) .cats
        , interpolation = Lines.monotone
        , events = Events.default Hover
        , legends = Legends.default
        , line = Line.wider 2
        , dot = Dot.emphasizable (Dot.disconnected 20 2) (Dot.aura 10 10 0.5) (Dot.isMaybe model.hovering)
        }
        [ Lines.line Color.blue Dot.circle "Non-binary" data1
        , Lines.line Color.orange Dot.triangle "Women" data3
        , Lines.line Color.pink Dot.square "Men" data2
        ]


junk : Data -> Junk.Junk Msg
junk hint =
    Junk.custom <|
        \system ->
            let
                viewHint =
                    Svg.g
                        [ placeWithOffset system system.x.max (system.y.max - 1) 20 10 ]
                        [ text_ []
                            [ tspan [ SvgA.x "0", SvgA.dy "1em" ] [ text <| "Year: " ++ toString hint.year ]
                            , tspan [ SvgA.x "0", SvgA.dy "1em" ] [ text <| "Cats: " ++ toString hint.cats ]
                            ]
                        ]

                line =
                    vertical system [] hint.year system.y.min system.y.max
            in
            { below = []
            , above = [ viewHint ]
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
