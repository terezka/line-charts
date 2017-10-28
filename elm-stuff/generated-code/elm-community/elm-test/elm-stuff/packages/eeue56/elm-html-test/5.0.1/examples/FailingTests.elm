port module Main exposing (..)

import ExampleApp exposing (Msg(..), exampleModel, view)
import Expect
import Json.Encode exposing (Value)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)
import Test.Runner.Node exposing (TestProgram, run)


main : TestProgram
main =
    [ testView
    ]
        |> Test.concat
        |> run emit


port emit : ( String, Value ) -> Cmd msg


testView : Test
testView =
    let
        output =
            view exampleModel
                |> Query.fromHtml
    in
        describe "view exampleModel"
            [ test "expect 4x <li> somewhere on the page" <|
                \() ->
                    output
                        |> Query.findAll [ tag "li" ]
                        |> Query.count (Expect.equal 4)
            , test "expect 4x <li> inside a <ul>" <|
                \() ->
                    output
                        |> Query.find [ tag "ul" ]
                        |> Query.findAll [ tag "li" ]
                        |> Query.count (Expect.equal 4)
            , test "(this should fail) expect header to have 4 links in it, even though it has 3" <|
                \() ->
                    output
                        |> Query.find [ id "heading" ]
                        |> Query.findAll [ tag "a" ]
                        |> Query.count (Expect.equal 4)
            , test "(this should fail) expect header to have one link in it, even though it has 3" <|
                \() ->
                    output
                        |> Query.find [ id "heading" ]
                        |> Query.find [ tag "a" ]
                        |> Query.has [ tag "a" ]
            , test "(this should fail) expect header to have one <img> in it, even though it has none" <|
                \() ->
                    output
                        |> Query.find [ id "heading" ]
                        |> Query.find [ tag "img" ]
                        |> Query.has [ tag "img" ]
            , test "(this should fail) expect footer to have a child" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.children []
                        |> Query.each (Query.has [ tag "catapult" ])
            , test "(this should fail) expect footer's nonexistant child to be a catapult" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.children []
                        |> Query.first
                        |> Query.has [ tag "catapult" ]
            , test "expect footer to have footer text" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.has [ tag "footer", text "this is the footer" ]
            , test "(this should fail) expect footer to have text it doesn't have" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.has [ tag "footer", text "this is SPARTA!!!" ]
            , test "expect each <li> to have classes list-item and themed" <|
                \() ->
                    output
                        |> Query.find [ tag "ul" ]
                        |> Query.findAll [ tag "li" ]
                        |> Query.each (Query.has [ classes [ "list-item", "themed" ] ])
            , test "expect first a to send GoToHome onClick" <|
                \() ->
                    output
                        |> Query.findAll [ tag "a" ]
                        |> Query.first
                        |> Events.simulate Click
                        |> Expect.equal (Ok GoToHome)
            , test "(this should fail) expect first a to return GoToExamples on click, even though it returns GoToHome" <|
                \() ->
                    output
                        |> Query.findAll [ tag "a" ]
                        |> Query.first
                        |> Events.simulate Click
                        |> Expect.equal (Ok GoToExamples)
            , test "(this should fail) expect first a to return a msg for a blur event, even though it doesn't have one" <|
                \() ->
                    output
                        |> Query.findAll [ tag "a" ]
                        |> Query.first
                        |> Events.simulate Blur
                        |> Expect.equal (Ok GoToHome)
            , test "(this should fail) expect text to return a msg for click, even though it is a text" <|
                \() ->
                    output
                        |> Query.find [ text "home" ]
                        |> Events.simulate Click
                        |> Expect.equal (Ok GoToHome)
            ]
