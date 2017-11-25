module Internal.Utils exposing (..)

{-| -}

import Html exposing (Attribute, Html)
import Svg exposing (Svg, text, g)



-- GENERAL


{-| -}
apply : a -> (a -> b) -> b
apply stuff toNewStuff =
    toNewStuff stuff


{-| -}
concat : List a -> List a -> List a -> List a
concat first second third =
  first ++ second ++ third


{-| -}
viewMaybe : Maybe a -> (a -> Svg msg) -> Svg msg
viewMaybe a view =
    Maybe.withDefault (text "") (Maybe.map view a)


{-| -}
viewMaybeHtml : Maybe a -> (a -> Html msg) -> Html msg
viewMaybeHtml a view =
    Maybe.withDefault (Html.text "") (Maybe.map view a)


{-| -}
nonEmptyList : List a -> Maybe (List a)
nonEmptyList list =
    if List.isEmpty list then
        Nothing
    else
        Just list


{-| -}
withFirst : List a -> (a -> List a -> b) -> Maybe b
withFirst stuff process =
    case stuff of
        first :: rest ->
            Just <| process first rest

        _ ->
            Nothing
