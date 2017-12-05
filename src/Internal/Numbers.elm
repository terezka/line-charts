module Internal.Numbers exposing (customInterval, defaultInterval, normalizedInterval, correctFloat, magnitude)

{-| -}

import Regex
import Round
import Lines.Coordinate as Coordinate exposing (..)



{-| -}
defaultInterval : Coordinate.Limits -> List Float
defaultInterval limits =
    let
      tickRange =
        (limits.max - limits.min) / 10

      interval =
        normalizedInterval tickRange [] (magnitude tickRange) True
    in
    customInterval 0 interval limits


{-| TODO TEST ME -}
customInterval : Float -> Float -> Coordinate.Limits -> List Float
customInterval intersection delta limits =
    let
        firstValue =
          intersection - offset (intersection - limits.min)

        offset value =
          toFloat (floor (value / delta)) * delta

        ticks result index =
          let next = position delta firstValue index in
            if next <= limits.max
              then ticks (result ++ [ next ]) (index + 1)
              else result
    in
    ticks [] 0



-- INTERNAL


position : Float -> Float -> Int -> Float
position delta firstValue index =
    firstValue + toFloat index * delta
        |> Round.round (deltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


deltaPrecision : Float -> Int
deltaPrecision delta =
    delta
        |> toString
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\.[0-9]*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.length
        |> (-) 1
        |> min 0
        |> abs



-- NORMALIZED


normalizedInterval : Float -> List Float -> Float -> Bool -> Float
normalizedInterval intervalRaw multiples_ magnitude allowDecimals =
  let
    normalized =
      intervalRaw / magnitude

    multiples =
      if List.isEmpty multiples_ then
       produceMultiples magnitude allowDecimals
      else
        multiples_

    findClosest multiples interval =
      case multiples of
        m1 :: rest ->
          if normalized <= m1 then m1 else findClosest rest interval

        [] ->
          interval

    correctBack interval =
      correctFloat (interval * magnitude) 3
  in
  correctBack <| findClosest multiples intervalRaw


produceMultiples : Float -> Bool -> List Float
produceMultiples magnitude allowDecimals =
  let
    defaults =
      [ 1, 2, 2.5, 5, 10 ]
  in
    if allowDecimals then
      defaults
    else
      if magnitude == 1 then
        List.filter (\n -> toFloat (round n) /= n) defaults
      else if magnitude <= 0.1 then
        [ 1 / magnitude ]
      else
        defaults


{-| -}
correctFloat : Float -> Int -> Float
correctFloat number prec =
  if toFloat (round number) == number then
    number
  else
    let
      toFloatSafe = String.toFloat >> Result.withDefault 0
      string = toString number ++ String.repeat (prec + 1) "0"

      ( before, after ) =
        case String.split "." string of
          [ before, after ] -> ( before, after )
          _ -> ( "0", "0" ) -- never happens

      decimals = String.slice 0 prec after
    in
      toFloatSafe <| before ++ "." ++ decimals


{-| -}
magnitude : Float -> Float
magnitude num =
  toFloat <| 10 ^ (floor (logBase e num / logBase e 10))
