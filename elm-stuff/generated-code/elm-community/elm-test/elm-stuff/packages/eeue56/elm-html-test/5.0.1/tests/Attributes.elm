module Attributes exposing (..)

import Expect
import Html.Attributes as Attr
import Json.Encode as Encode
import Test exposing (..)
import Test.Html.Selector as Selector
import Test.Html.Selector.Internal exposing (Selector(..), namedAttr, namedBoolAttr)


all : Test
all =
    describe "Selector.attribute"
        [ test "can generate a StringAttribute selector" <|
            \() ->
                Attr.title "test"
                    |> Selector.attribute
                    |> Expect.equal (namedAttr "title" "test")
        , test "works for things like `value` which are technically properties" <|
            \() ->
                Attr.value "test"
                    |> Selector.attribute
                    |> Expect.equal (namedAttr "value" "test")
        , test "can generate a BoolAttribute selector" <|
            \() ->
                Attr.checked True
                    |> Selector.attribute
                    |> Expect.equal (namedBoolAttr "checked" True)
        , test "can generate a Style selector" <|
            \() ->
                Attr.style [ ( "margin", "0" ) ]
                    |> Selector.attribute
                    |> Expect.equal (Style [ ( "margin", "0" ) ])
        , describe "classes" <|
            [ test "can generate a Classes selector" <|
                \() ->
                    Attr.class "hello world"
                        |> Selector.attribute
                        |> Expect.equal (Classes [ "hello", "world" ])
            , test "catches a situation where the user passes classes using Html.Attr.attribute \"class\" \"the-class\"" <|
                \() ->
                    Attr.attribute "class" "hello world"
                        |> Selector.attribute
                        |> Expect.equal (Classes [ "hello", "world" ])
            , test "can find a class attribute in a case insensitive manner" <|
                \() ->
                    Attr.attribute "CLASS" "hello world"
                        |> Selector.attribute
                        |> Expect.equal (Classes [ "hello", "world" ])
            , test "finds className property only by exact match" <|
                \() ->
                    Attr.property "classname" (Encode.string "hello world")
                        |> Selector.attribute
                        |> Expect.all
                            [ Expect.notEqual (Classes [ "hello world" ])
                            , Expect.equal (Attribute { name = "classname", value = "hello world" })
                            ]
            ]
        , test "anything else fails" <|
            \() ->
                Attr.property "unknown" (Encode.int 1)
                    |> Selector.attribute
                    |> Expect.equal Invalid
        ]
