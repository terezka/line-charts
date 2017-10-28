module Events exposing (..)

import Expect
import Html exposing (Html, button, div, input, text)
import Html.Attributes as Attr exposing (href)
import Html.Events exposing (..)
import Html.Lazy as Lazy
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Test exposing (..)
import Test.Html.Event as Event exposing (Event)
import Test.Html.Query as Query exposing (Single)
import Test.Html.Selector exposing (tag)


all : Test
all =
    describe "trigerring events"
        [ test "returns msg for click on element" <|
            \() ->
                Query.fromHtml sampleHtml
                    |> Query.findAll [ tag "button" ]
                    |> Query.first
                    |> Event.simulate Event.click
                    |> Event.expect SampleMsg
        , test "returns msg for click on lazy html" <|
            \() ->
                Query.fromHtml sampleLazyHtml
                    |> Query.findAll [ tag "button" ]
                    |> Query.first
                    |> Event.simulate Event.click
                    |> Event.expect SampleMsg
        , test "returns msg for click on mapped html" <|
            \() ->
                Query.fromHtml sampleMappedHtml
                    |> Query.findAll [ tag "button" ]
                    |> Query.first
                    |> Event.simulate Event.click
                    |> Event.expect MappedSampleMsg
        , test "returns msg for click on deep mapped html" <|
            \() ->
                Query.fromHtml deepMappedHtml
                    |> Query.findAll [ tag "input" ]
                    |> Query.first
                    |> Event.simulate (Event.input "foo")
                    |> Event.expect (SampleInputMsg "foobar")
        , test "returns msg for input with transformation" <|
            \() ->
                input [ onInput (String.toUpper >> SampleInputMsg) ] []
                    |> Query.fromHtml
                    |> Event.simulate (Event.input "cats")
                    |> Event.expect (SampleInputMsg "CATS")
        , test "returns msg for check event" <|
            \() ->
                input [ onCheck SampleCheckedMsg ] []
                    |> Query.fromHtml
                    |> Event.simulate (Event.check True)
                    |> Event.expect (SampleCheckedMsg True)
        , test "returns msg for custom event" <|
            \() ->
                input [ on "keyup" (Json.Decode.map SampleKeyUpMsg keyCode) ] []
                    |> Query.fromHtml
                    |> Event.simulate ( "keyup", Encode.object [ ( "keyCode", Encode.int 5 ) ] )
                    |> Event.expect (SampleKeyUpMsg 5)
        , testEvent onDoubleClick Event.doubleClick
        , testEvent onMouseDown Event.mouseDown
        , testEvent onMouseUp Event.mouseUp
        , testEvent onMouseLeave Event.mouseLeave
        , testEvent onMouseOver Event.mouseOver
        , testEvent onMouseOut Event.mouseOut
        , testEvent onSubmit Event.submit
        , testEvent onBlur Event.blur
        , testEvent onFocus Event.focus
        , test "event result" <|
            \() ->
                Query.fromHtml sampleHtml
                    |> Query.find [ tag "button" ]
                    |> Event.simulate Event.click
                    |> Event.toResult
                    |> Expect.equal (Ok SampleMsg)
        ]


type Msg
    = SampleMsg
    | MappedSampleMsg
    | SampleInputMsg String
    | SampleCheckedMsg Bool
    | SampleKeyUpMsg Int


sampleHtml : Html Msg
sampleHtml =
    div [ Attr.class "container" ]
        [ button [ onClick SampleMsg ] [ text "click me" ]
        ]


sampleLazyHtml : Html Msg
sampleLazyHtml =
    div [ Attr.class "container" ]
        [ Lazy.lazy
            (\str -> button [ onClick SampleMsg ] [ text str ])
            "click me"
        ]


sampleMappedHtml : Html Msg
sampleMappedHtml =
    div [ Attr.class "container" ]
        [ Html.map (always MappedSampleMsg) (button [ onClick SampleMsg ] [ text "click me" ])
        ]


deepMappedHtml : Html Msg
deepMappedHtml =
    div []
        [ Html.map (SampleInputMsg)
            (div []
                [ Html.map (\msg -> msg ++ "bar")
                    (div []
                        [ input [ onInput identity ] []
                        ]
                    )
                ]
            )
        ]


testEvent : (Msg -> Html.Attribute Msg) -> ( String, Value ) -> Test
testEvent testOn (( eventName, eventValue ) as event) =
    test ("returns msg for " ++ eventName ++ "(" ++ toString eventValue ++ ") event") <|
        \() ->
            input [ testOn SampleMsg ] []
                |> Query.fromHtml
                |> Event.simulate event
                |> Event.expect SampleMsg
