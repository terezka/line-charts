module Events1 exposing (main)

import Browser
import Color
import Color.Manipulate
import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import LineChart as LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line
import Svg exposing (Attribute, Svg, g, text_, tspan)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { hovering : Maybe Info }


init : Model
init =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Info)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover hovering ->
            { model | hovering = hovering }



-- VIEW


view : Model -> Svg Msg
view model =
    Html.div
        [ class "container" ]
        [ chart model ]


chart : Model -> Html.Html Msg
chart model =
    LineChart.viewCustom
        { y = Axis.default 450 "Weight" .weight
        , x = Axis.default 700 "Age" .age
        , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.hoverOne Hover
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line =
            Line.hoverOne model.hovering

        -- customLineConfig model.hovering
        , dots =
            Dots.hoverOne model.hovering

        -- customDotsConfig model.hovering
        }
        [ LineChart.line Color.orange Dots.triangle "Chuck" chuck
        , LineChart.line Color.yellow Dots.circle "Bobby" bobby
        , LineChart.line Color.purple Dots.diamond "Alice" alice
        ]


customLineConfig : Maybe Info -> Line.Config Info
customLineConfig maybeHovered =
    let
        styleDefault =
            Line.style 1 identity

        styleHovered =
            Line.style 2 identity

        styleNotHovered =
            Line.style 1 (Color.Manipulate.lighten 0.3)

        lineConfig data =
            -- `data` being all the data for a line
            case maybeHovered of
                Just hovered ->
                    if
                        List.any (dotIsHovered maybeHovered) data
                        -- This line is hovered
                    then
                        styleHovered
                        -- Some line is hovered, but not this one

                    else
                        styleNotHovered

                Nothing ->
                    -- No line is hovered
                    styleDefault
    in
    Line.custom lineConfig


customDotsConfig : Maybe Info -> Dots.Config Info
customDotsConfig maybeHovered =
    let
        styleDefault =
            Dots.empty 5 2

        styleHover =
            Dots.full 8

        styleLegend data =
            -- `data` being all the data for a line
            if List.any (dotIsHovered maybeHovered) data then
                styleHover

            else
                styleDefault

        styleIndividual datum =
            -- `datum` being a single data point on a line
            if dotIsHovered maybeHovered datum then
                styleHover

            else
                styleDefault
    in
    Dots.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }



-- HELPERS


dotIsHovered : Maybe Info -> Info -> Bool
dotIsHovered maybeHovered datum =
    Just datum == maybeHovered



-- DATA


type alias Info =
    { age : Float
    , weight : Float
    , height : Float
    , income : Float
    }


alice : List Info
alice =
    [ Info 10 34 1.34 0
    , Info 16 42 1.62 3000
    , Info 25 75 1.73 25000
    , Info 43 83 1.75 40000
    ]


bobby : List Info
bobby =
    [ Info 10 38 1.32 0
    , Info 17 69 1.75 2000
    , Info 25 75 1.87 32000
    , Info 43 77 1.87 52000
    ]


chuck : List Info
chuck =
    [ Info 10 42 1.35 0
    , Info 15 72 1.72 1800
    , Info 25 89 1.83 85000
    , Info 43 95 1.84 120000
    ]
