module Internal.Numbers exposing (interval, values, getMagnitude)

{-| -}

import Round
import Lines.Coordinate as Coordinate exposing (..)



{-| -}
values : Bool -> Int -> Coordinate.Limits -> List Float
values exact amountRough limits =
    let
      range =
        limits.max - limits.min

      intervalRough =
        range / toFloat amountRough

      interval =
        getInterval intervalRough True exact

      ceilingTo number prec =
        prec * toFloat (ceiling (number / prec))

      beginning =
        ceilingTo limits.min interval

      positions_ acc m =
        let next_ = correctFloat (beginning + (m * interval)) (precision interval)
        in if next_ > limits.max then acc else positions_ (next_ :: acc) (m + 1)
    in
    positions_ [] 0


{-| -}
interval : Float -> Float -> Coordinate.Limits -> List Float
interval intersection interval limits =
    let
        offset value =
          interval * toFloat (floor (value / interval))

        beginning =
          intersection - offset (intersection - limits.min)

        positions_ acc m =
          let next_ = correctFloat (beginning + (m * interval)) (precision interval)
          in if next_ > limits.max then acc else positions_ (next_ :: acc) (m + 1)
    in
    positions_ [] 0



-- INTERNAL


{-| Returns multiple -}
getInterval : Float -> Bool -> Bool -> Float
getInterval intervalRaw allowDecimals hasTickAmount =
  let
    magnitude =
      getMagnitude intervalRaw

    normalized =
      intervalRaw / magnitude

    multiples =
      produceMultiples magnitude allowDecimals hasTickAmount

    findMultiple multiples =
      case multiples of
        m1 :: m2 :: rest ->
          if normalized <= (m1 + m2) / 2
            then m1
            else findMultiple (m2 :: rest)

        m1 :: rest ->
          if normalized <= m1
            then m1
            else findMultiple rest

        [] ->
          1

    findMultipleExact multiples =
      case multiples of
        m1 :: rest ->
          if m1 * magnitude >= intervalRaw
            then m1
            else findMultipleExact rest

        [] ->
          1

    multiple =
      if hasTickAmount then
        findMultipleExact multiples
      else
        findMultiple multiples
  in
  correctFloat (multiple * magnitude) (precision magnitude + precision multiple)


produceMultiples : Float -> Bool -> Bool -> List Float
produceMultiples magnitude allowDecimals hasTickAmount =
  let
    defaults =
      if hasTickAmount then
        [ 1, 1.2, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10 ]
      else
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
  case String.split "." (toString number) of -- TODO
    [ before, after ] ->
        let
          afterSafe = after ++ String.repeat (prec + 2) "0"
          toFloatSafe = String.toFloat >> Result.withDefault 0
          decimals = String.slice 0 (prec + 1) <| afterSafe
        in
          toFloatSafe <| Round.round prec <| toFloatSafe <| before ++ "." ++ decimals

    _ ->
       number


{-| -}
getMagnitude : Float -> Float
getMagnitude num =
  toFloat <| 10 ^ (floor (logBase e num / logBase e 10))


{-| -}
precision : Float -> Int
precision interval =
  case String.split "." (toString interval) of -- TODO
    [ before, after ] ->
        String.length after

    _ ->
       0
