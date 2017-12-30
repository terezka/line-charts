module Internal.Axis.Values exposing (Amount(..), int, time, float, interval)


import Round
import Lines.Axis.Tick exposing (Time, Unit(..), Interval)
import Internal.Axis.Values.Time as Time
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate


{-| -}
type Amount
  = Exactly Int
  | Around Int


{-| -}
int : Amount -> Coordinate.Range -> List Int
int amount =
  case amount of
    Exactly amount -> List.map round << values False True amount
    Around amount  -> List.map round << values False False amount


{-| -}
time : Amount -> Coordinate.Range -> List Time
time amount =
  case amount of
    Exactly amount -> Time.values amount
    Around amount  -> Time.values amount


{-| -}
float : Amount -> Coordinate.Range -> List Float
float amount =
  case amount of
    Exactly amount -> values True True amount
    Around amount  -> values True False amount


{-| -}
interval : Float -> Float -> Coordinate.Range -> List Float
interval intersection interval range =
    let
        offset value =
          interval * toFloat (floor (value / interval))

        beginning =
          intersection - offset (intersection - range.min)
    in
    positions range beginning interval 0 []



-- INTERNAL


values : Bool -> Bool -> Int -> Coordinate.Range -> List Float
values allowDecimals exact amountRough range =
    let
      intervalRough =
        (range.max - range.min) / toFloat amountRough

      interval =
        getInterval intervalRough allowDecimals exact

      ceilingTo number prec =
        prec * toFloat (ceiling (number / prec))

      beginning =
        ceilingTo range.min interval
    in
    positions range beginning interval 0 []


positions : Coordinate.Range -> Float -> Float -> Float -> List Float -> List Float
positions range beginning interval m acc =
  let next = correctFloat (beginning + (m * interval)) (getPrecision interval)
  in if next > range.max then acc else positions range beginning interval (m + 1) (acc ++ [ next ])


getInterval : Float -> Bool -> Bool -> Float
getInterval intervalRaw allowDecimals hasTickAmount =
  let
    magnitude =
      Utils.magnitude intervalRaw

    normalized =
      intervalRaw / magnitude

    multiples =
      getMultiples magnitude allowDecimals hasTickAmount

    findMultiple multiples =
      case multiples of
        m1 :: m2 :: rest ->
          if normalized <= (m1 + m2) / 2
            then m1 else findMultiple (m2 :: rest)

        m1 :: rest ->
          if normalized <= m1
            then m1 else findMultiple rest

        [] ->
          1

    findMultipleExact multiples =
      case multiples of
        m1 :: rest ->
          if m1 * magnitude >= intervalRaw
            then m1 else findMultipleExact rest

        [] ->
          1

    multiple =
      if hasTickAmount then
        findMultipleExact multiples
      else
        findMultiple multiples
  in
  correctFloat (multiple * magnitude) (getPrecision magnitude + getPrecision multiple)


getMultiples : Float -> Bool -> Bool -> List Float
getMultiples magnitude allowDecimals hasTickAmount =
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
getPrecision : Float -> Int
getPrecision interval =
  case String.split "." (toString interval) of -- TODO
    [ before, after ] ->
        String.length after

    _ ->
       0
