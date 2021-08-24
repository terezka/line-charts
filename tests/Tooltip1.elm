module Tooltip1 exposing (..)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import Svg.Attributes
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Junk as Junk
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area
import Color
import Html.Attributes exposing (class)
import Test exposing (test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, tag, attribute)
import Expect
import Test.Html.Event as Event
import Json.Encode


-- MODEL


type alias Model =
    { hovered : Maybe Info }


nonHoveringModel : Model
nonHoveringModel =
    { hovered = Nothing }


hoveringModel : Model
hoveringModel =
    { hovered =
        List.head alice
    }



-- UPDATE


type Msg
    = Hover (Maybe Info)


chart : Model -> Html.Html Msg
chart model =
    LineChart.viewCustom
        { y = Axis.default 450 "Weight" .weight
        , x = Axis.default 700 "Age" .age
        , container = Container.default "line-chart-1"
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.hoverOne Hover
        , junk =
            Junk.hoverOne model.hovered
                [ ( "Age", toString << .age )
                , ( "Weight", toString << .weight )
                ]
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.hoverOne model.hovered
        }
        [ LineChart.line Color.orange Dots.triangle "Chuck" chuck
        , LineChart.line Color.yellow Dots.circle "Bobby" bobby
        , LineChart.line Color.purple Dots.diamond "Alice" alice
        ]


tooltipIsNotVisibleWhenNothingIsHoveredOver : Test.Test
tooltipIsNotVisibleWhenNothingIsHoveredOver =
    Test.describe "Tooltips don't exist unless you hover over things"
        [ test "Hover tooltip for age does not show up" <|
            \() ->
                chart nonHoveringModel
                    |> Query.fromHtml
                    |> Query.findAll [ Test.Html.Selector.text "Age: 10" ]
                    |> Query.count (Expect.equal 0)
        , test "Hover tooltip for weight does not show up" <|
            \() ->
                chart nonHoveringModel
                    |> Query.fromHtml
                    |> Query.findAll [ Test.Html.Selector.text "Weight: 34" ]
                    |> Query.count (Expect.equal 0)
        ]


tooltipIsVisibleWhenNothingIsHoveredOver : Test.Test
tooltipIsVisibleWhenNothingIsHoveredOver =
    Test.describe "The tooltip shows up when being hovered over"
        [ test "Hover tooltip for age does show up" <|
            \() ->
                chart hoveringModel
                    |> Query.fromHtml
                    |> Query.findAll [ Test.Html.Selector.text "Age: 10" ]
                    |> Query.count (Expect.equal 1)
        , test "Hover tooltip for weight does show up" <|
            \() ->
                chart hoveringModel
                    |> Query.fromHtml
                    |> Query.findAll [ Test.Html.Selector.text "Weight: 34" ]
                    |> Query.count (Expect.equal 1)
        ]


changingHoverOverAPointTriggersAHoverChange : Test.Test
changingHoverOverAPointTriggersAHoverChange =
    Test.describe "When hovering over a point, a change is triggered"
        [ test "The mouse leaving makes nothing come from the hover event" <|
            \() ->
                chart hoveringModel
                    |> Query.fromHtml
                    |> Query.find [ tag "rect", attribute (Svg.Attributes.fill "transparent") ]
                    |> Event.simulate (Event.mouseLeave)
                    |> Event.expect (Hover Nothing)
        ]



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
