module Internal.Utils exposing (..)

{-| -}

import Html
import Svg
import LineChart.Coordinate as Coordinate



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
unzip3 : List (a,b,c) -> (List a, List b, List c)
unzip3 pairs =
  let
    step (a,b,c) (aas,bs,cs) =
      (a :: aas, b :: bs, c :: cs)
  in
  List.foldr step ([], [], []) pairs


{-| -}
indexedMap2 : (Int -> a -> b -> c) -> List a -> List b -> List c
indexedMap2 f a b =
  let
    collect a_ b_ i c =
      case ( a_, b_ ) of
        ( a0 :: a__, b0 :: b__ ) -> collect a__ b__ (i + 1) <| c ++ [ f i a0 b0 ]
        ( [], _ ) -> c
        ( _, [] ) -> c
  in
  collect a b 0 []


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
    first :: rest ->
      Just (process first rest)

    _ ->
      Nothing


{-| -}
viewWithFirst : List a -> (a -> List a -> Svg.Svg msg) -> Svg.Svg msg
viewWithFirst stuff view =
  case stuff of
    first :: rest ->
      view first rest

    _ ->
      Svg.text ""


{-| -}
viewWithEdges : List a -> (a -> List a -> a -> Svg.Svg msg) -> Svg.Svg msg
viewWithEdges stuff view =
  case stuff of
    first :: rest ->
      view first rest (lastSafe first rest)

    _ ->
      Svg.text ""


{-| -}
towardsZero : Coordinate.Range -> Float
towardsZero { max, min } =
  clamp min max 0


{-| -}
last : List a -> Maybe a
last list =
  List.head (List.drop (List.length list - 1) list)


{-| -}
lastSafe : a -> List a -> a
lastSafe first rest =
  Maybe.withDefault first (last rest)


{-| -}
toChartAreaId : String -> String
toChartAreaId id =
  "chart__chart-area--" ++ id


{-| -}
magnitude : Float -> Float
magnitude num =
  toFloat <| 10 ^ (floor (logBase e num / logBase e 10))


{-| -}
part : (a -> Bool) -> List a -> List a -> List ( List a, Maybe a ) -> List ( List a, Maybe a )
part isReal points current parts =
  case points of
    first :: rest ->
      if isReal first then
        part isReal rest (current ++ [first]) parts
      else
        part isReal rest [] ( ( current, Just first ) :: parts)

    [] ->
      ( current, Nothing ) :: parts
