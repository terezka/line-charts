module Internal.Utils exposing (..)

{-| -}

import Html
import Svg
import Lines.Coordinate as Coordinate



-- GENERAL


{-| -}
apply : a -> (a -> b) -> b
apply stuff toNewStuff =
    toNewStuff stuff


{-| -}
apply2 : a -> b -> (a -> b -> c) -> c
apply2 stuff1 stuff2 toNewStuff =
    toNewStuff stuff1 stuff2


{-| -}
concat : List a -> List a -> List a -> List a
concat first second third =
  first ++ second ++ third


{-| -}
viewIf : Bool -> (() -> Svg.Svg msg) -> Svg.Svg msg
viewIf condition view =
  if condition then
    view ()
  else
    Svg.text ""


{-| -}
viewMaybe : Maybe a -> (a -> Svg.Svg msg) -> Svg.Svg msg
viewMaybe a view =
    Maybe.withDefault (Svg.text "") (Maybe.map view a)


{-| -}
viewMaybeHtml : Maybe a -> (a -> Html.Html msg) -> Html.Html msg
viewMaybeHtml a view =
    Maybe.withDefault (Html.text "") (Maybe.map view a)


{-| -}
nonEmptyList : List a -> Maybe (List a)
nonEmptyList list =
    if List.isEmpty list
      then Nothing
      else Just list


{-| -}
withFirst : List a -> (a -> List a -> b) -> Maybe b
withFirst stuff process =
    case stuff of
        first :: rest -> Just (process first rest)
        _             -> Nothing


{-| -}
towardsZero : Coordinate.Range -> Float
towardsZero { max, min } =
  clamp min max 0


{-| -}
last : List a -> Maybe a
last list =
  List.head (List.drop (List.length list - 1) list)


{-| -}
toClipPathId : String -> String
toClipPathId id =
  "clip-path__" ++ id


{-| -}
magnitude : Float -> Float
magnitude num =
  toFloat <| 10 ^ (floor (logBase e num / logBase e 10))
