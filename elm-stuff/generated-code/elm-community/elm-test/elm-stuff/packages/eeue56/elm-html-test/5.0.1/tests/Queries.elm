module Queries exposing (..)

import Expect
import Html exposing (Html, a, div, footer, header, li, section, ul)
import Html.Attributes as Attr exposing (href)
import Html.Lazy as Lazy
import Test exposing (..)
import Test.Html.Query as Query exposing (Single)
import Test.Html.Selector exposing (..)


htmlTests : Test
htmlTests =
    describe "Html" <|
        List.map (\toTest -> toTest (Query.fromHtml sampleHtml)) testers


lazyTests : Test
lazyTests =
    describe "lazy Html" <|
        List.map (\toTest -> toTest (Query.fromHtml sampleLazyHtml)) testers


testers : List (Single msg -> Test)
testers =
    [ testFindAll
    , testFind
    , testRoot
    , testFirst
    , testIndex
    , testChildren
    ]


testRoot : Single msg -> Test
testRoot output =
    describe "root query without find or findAll"
        [ describe "finds itself" <|
            [ test "sees it's a <section class='root'>" <|
                \() ->
                    output
                        |> Expect.all
                            [ Query.has [ class "root" ]
                            , Query.has [ tag "section" ]
                            ]
            , test "recognizes its exact className" <|
                \() ->
                    output
                        |> Query.has [ exactClassName "root" ]
            , test "recognizes its class by classes" <|
                \() ->
                    output
                        |> Query.has [ classes [ "root" ] ]
            , test "recognizes its style by a single css property" <|
                \() ->
                    output
                        |> Query.has [ style [ ( "color", "red" ) ] ]
            , test "recognizes its style by multiple css properties" <|
                \() ->
                    output
                        |> Query.has [ style [ ( "color", "red" ), ( "background", "purple" ) ] ]
            , test "recognizes its style does not include a css property" <|
                \() ->
                    output
                        |> Query.hasNot [ style [ ( "color", "green" ) ] ]
            , test "recognizes if is has a specific descendant" <|
                \() ->
                    output
                        |> Query.contains [ someView "Such a title !" ]
            ]
        ]


testFind : Single msg -> Test
testFind output =
    describe "Query.find []"
        [ describe "finds the one child" <|
            [ test "sees it's a <div class='container'>" <|
                \() ->
                    output
                        |> Query.find []
                        |> Expect.all
                            [ Query.has [ class "container" ]
                            , Query.has [ tag "div" ]
                            ]
            , test "recognizes its exact className" <|
                \() ->
                    output
                        |> Query.find []
                        |> Query.has [ exactClassName "container" ]
            , test "recognizes its class by classes" <|
                \() ->
                    output
                        |> Query.find []
                        |> Query.has [ classes [ "container" ] ]
            , test "recognizes its style by style list" <|
                \() ->
                    output
                        |> Query.has [ style [ ( "color", "blue" ) ] ]
            , test "recognizes if is has a specific descendant" <|
                \() ->
                    output
                        |> Query.find []
                        |> Query.contains [ someView "Such a title !" ]
            ]
        ]


testFindAll : Single msg -> Test
testFindAll output =
    describe "Query.findAll []"
        [ describe "finds the one child" <|
            [ test "and only the one child" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.count (Expect.equal 1)
            , test "sees it's a <div class='container'>" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Expect.all
                            [ Query.each (Query.has [ class "container" ])
                            , Query.each (Query.has [ tag "div" ])
                            ]
            , test "recognizes its exact className" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.each (Query.has [ exactClassName "container" ])
            , test "recognizes its class by classes" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.each (Query.has [ classes [ "container" ] ])
            ]
        , describe "finds multiple descendants"
            [ test "with tag selectors that return one match at the start" <|
                \() ->
                    output
                        |> Query.findAll [ tag "header" ]
                        |> Query.count (Expect.equal 1)
            , test "with tag selectors that return multiple matches" <|
                \() ->
                    output
                        |> Query.findAll [ tag "section" ]
                        |> Query.count (Expect.equal 2)
            , test "with tag selectors that return one match at the end" <|
                \() ->
                    output
                        |> Query.find [ tag "footer" ]
                        |> Query.has [ text "this is the footer" ]
            , test "sees the nested div" <|
                \() ->
                    output
                        |> Query.findAll [ tag "div" ]
                        |> Query.count (Expect.equal 2)
            ]
        ]


testFirst : Single msg -> Test
testFirst output =
    describe "Query.first"
        [ describe "finds the one child" <|
            [ test "sees it's a <div class='container'>" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.first
                        |> Query.has [ tag "div", class "container" ]
            ]
        ]


testIndex : Single msg -> Test
testIndex output =
    describe "Query.index"
        [ describe "Query.index 0" <|
            [ test "sees it's a <div class='container'>" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.index 0
                        |> Query.has [ tag "div", class "container" ]
            ]
        , describe "Query.index -1" <|
            [ test "sees it's a <div class='container'>" <|
                \() ->
                    output
                        |> Query.findAll []
                        |> Query.index -1
                        |> Query.has [ tag "div", class "container" ]
            ]
        ]


testChildren : Single msg -> Test
testChildren output =
    describe "Query.children"
        [ describe "on the root" <|
            [ test "sees the root has one child" <|
                \() ->
                    output
                        |> Query.children []
                        |> Query.count (Expect.equal 1)
            , test "sees it's a <header id='heading'>" <|
                \() ->
                    output
                        |> Query.children []
                        |> Query.each (Query.has [ tag "header", id "heading" ])
            , test "doesn't see the nested div" <|
                \() ->
                    output
                        |> Query.children [ tag "div" ]
                        |> Query.count (Expect.equal 1)
            ]
        ]


sampleHtml : Html msg
sampleHtml =
    section [ Attr.class "root", Attr.style [ ( "color", "red" ), ( "background", "purple" ), ( "font-weight", "bold" ) ] ]
        [ div [ Attr.class "container", Attr.style [ ( "color", "blue" ) ] ]
            [ header [ Attr.class "funky themed", Attr.id "heading" ]
                [ a [ href "http://elm-lang.org" ] [ Html.text "home" ]
                , a [ href "http://elm-lang.org/examples" ] [ Html.text "examples" ]
                , a [ href "http://elm-lang.org/docs" ] [ Html.text "docs" ]
                ]
            , someView "Such a title !"
            , section [ Attr.class "funky themed", Attr.id "section" ]
                [ ul [ Attr.class "some-list" ]
                    [ li [ Attr.class "list-item themed" ] [ Html.text "first item" ]
                    , li [ Attr.class "list-item themed" ] [ Html.text "second item" ]
                    , li [ Attr.class "list-item themed selected" ] [ Html.text "third item" ]
                    , li [ Attr.class "list-item themed" ] [ Html.text "fourth item" ]
                    ]
                ]
            , section []
                [ div [ Attr.class "nested-div" ] [ Html.text "boring section" ] ]
            , footer [] [ Html.text "this is the footer" ]
            ]
        ]


sampleLazyHtml : Html msg
sampleLazyHtml =
    section [ Attr.class "root", Attr.style [ ( "color", "red" ), ( "background", "purple" ), ( "font-weight", "bold" ) ] ]
        [ div [ Attr.class "container", Attr.style [ ( "color", "blue" ) ] ]
            [ header [ Attr.class "funky themed", Attr.id "heading" ]
                [ Lazy.lazy (\str -> a [ href "http://elm-lang.org" ] [ Html.text str ]) "home"
                , Lazy.lazy (\str -> a [ href "http://elm-lang.org/examples" ] [ Html.text str ]) "examples"
                , Lazy.lazy (\str -> a [ href "http://elm-lang.org/docs" ] [ Html.text str ]) "docs"
                ]
            , someView "Such a title !"
            , section [ Attr.class "funky themed", Attr.id "section" ]
                [ ul [ Attr.class "some-list" ]
                    [ Lazy.lazy (\str -> li [ Attr.class "list-item themed" ] [ Html.text str ]) "first item"
                    , Lazy.lazy (\str -> li [ Attr.class "list-item themed" ] [ Html.text str ]) "second item"
                    , Lazy.lazy (\str -> li [ Attr.class "list-item themed selected" ] [ Html.text str ]) "third item"
                    , Lazy.lazy (\str -> li [ Attr.class "list-item themed" ] [ Html.text str ]) "fourth item"
                    ]
                ]
            , section []
                [ div [ Attr.class "nested-div" ] [ Html.text "boring section" ] ]
            , footer [] [ Lazy.lazy2 (\a b -> Html.text <| a ++ b) "this is " "the footer" ]
            ]
        ]


someView : String -> Html msg
someView str =
    Html.h1 [] [ Html.text str ]
