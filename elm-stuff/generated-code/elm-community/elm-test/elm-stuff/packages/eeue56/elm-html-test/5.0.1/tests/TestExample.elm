module TestExample exposing (all)

import Expect
import Html.Attributes exposing (href)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (..)
import ExampleApp exposing (exampleModel, view)


all : Test
all =
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
            , test "expect header to have 3 links in it" <|
                \() ->
                    output
                        |> Query.findAll [ tag "a" ]
                        |> Query.count (Expect.equal 3)
            , test "expect header to have a link to the Elm homepage" <|
                \() ->
                    output
                        |> Query.find [ id "heading" ]
                        |> Query.has [ attribute <| href "http://elm-lang.org" ]
            , test "expect footer to have footer text" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.has [ tag "footer", text "this is the footer" ]
            , test "expect each <li> to have classes list-item and themed" <|
                \() ->
                    output
                        |> Query.find [ tag "ul" ]
                        |> Query.findAll [ tag "li" ]
                        |> Query.each (Query.has [ classes [ "list-item", "themed" ] ])
            ]
