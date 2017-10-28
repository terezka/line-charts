module Internal.Utils exposing (..)

import Html exposing (Attribute, Html)
import Svg exposing (Svg, text, g)
import Lines.Coordinate as Coordinate exposing (..)


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



-- POSITION STUFF


{-| -}
distanceX : Coordinate.System -> Point -> Point -> Float
distanceX system position dot =
    abs <| toSVG X system dot.x - toSVG X system position.x


{-| -}
distanceY : Coordinate.System -> Point -> Point -> Float
distanceY system position dot =
    abs <| toSVG Y system dot.y - toSVG Y system position.y


{-| -}
distance : Coordinate.System -> Point -> Point -> Float
distance system position dot =
    sqrt <| distanceX system position dot ^ 2 + distanceY system position dot ^ 2


{-| -}
withinRadius : Coordinate.System -> Float -> Point -> Point -> Bool
withinRadius system radius position dot =
    distance system position dot <= radius


{-| -}
withinRadiusX : Coordinate.System -> Float -> Point -> Point -> Bool
withinRadiusX system radius position dot =
    distanceX system position dot <= radius
