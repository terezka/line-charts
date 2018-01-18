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
unzip3 : List (a,b,c) -> (List a, List b, List c)
unzip3 pairs =
  let
    step (a,b,c) (aas,bs,cs) =
      (a :: aas, b :: bs, c :: cs)
  in
  List.foldr step ([], [], []) pairs


{-| -}
stackBy : (a -> Float) -> (a -> a -> a) -> List a -> List a -> List a
stackBy toNumber f data belows =
  let
    iterate xp data belows result =
      case ( data, belows ) of
        ( datum :: data, below :: belows ) ->
          if toNumber datum > toNumber below
            then iterate xp (datum :: data) belows (f below xp :: result)
            else iterate datum data (below :: belows) result

        ( [], below :: belows ) ->
          if toNumber xp <= toNumber below
            then iterate xp [] belows (f below xp :: result)
            else iterate xp [] belows (below :: result)

        ( datum :: data, [] ) ->
          result

        ( [], [] ) ->
          result
  in
  List.reverse <| Maybe.withDefault [] <| withFirst data <| \x0 data ->
    iterate x0 data belows []



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
part : (a -> Bool) -> List a -> List a -> List (List a) -> List (List a)
part isReal points current parts =
  case points of
    first :: rest ->
      if isReal first then
        part isReal rest (first :: current) parts
      else
        part isReal rest [] (current :: parts)

    [] ->
      current :: parts
