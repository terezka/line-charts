module Internal.DateTime.Unit exposing (Unit, interval)

{-| -}

import Internal.Numbers as Numbers
import Internal.Coordinate as Coordinate


{-| -}
type Unit
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Week
  | Month
  | Year


{-| -}
interval : Int -> Coordinate.Limits -> List Float
interval amountRough limits =
  let
    range =
      limits.max - limits.min |> Debug.log "range"

    intervalRough =
      range / toFloat amountRough |> Debug.log "intervalRough"

    unit =
      findBest intervalRough all |> Debug.log "unit"

    multiple =
      findBestMultiple intervalRough unit |> Debug.log "multiple"

    interval =
      toMs unit * multiple |> Debug.log "interval"

    beginning =
      interval * toFloat (ceiling (limits.min / interval)) |> Debug.log "beginning"

    amount =
      (limits.max - beginning) / interval |> floor |> Debug.log "amount"

    position m =
      beginning + toFloat m * interval
  in
  List.map position (List.range 0 amount) |> Debug.log "positions"



-- INTERNAL


findBest : Float -> List Unit -> Unit
findBest interval units =
  let
    findBest_ units u0 =
      case units of
        u1 :: u2 :: rest ->
          if interval <= middleOfNext u1 u2
            then u1
            else findBest_ (u2 :: rest) u1

        u :: _ -> u
        []     -> Year

    middleOfNext u1 u2 =
      (toMs u1 * highestMultiple (multiples u1) + toMs u2) / 2
  in
  findBest_ units Year


findBestMultiple : Float -> Unit -> Float
findBestMultiple interval unit =
  let
    findBest_ multiples =
      case multiples of
        m1 :: m2 :: rest ->
          if interval <= (middleOfNext m1 m2)
            then m1
            else findBest_ (m2 :: rest)

        m :: _ -> m
        [] -> 1

    middleOfNext m1 m2 =
      (m1 * toMs unit + m2 * toMs unit) / 2
  in
  findBest_ (multiples unit)



-- HELPERS


all : List Unit
all =
  [ Millisecond, Second, Minute, Hour, Day, Week, Month, Year ]


toMs : Unit -> Float
toMs unit =
  case unit of
    Millisecond -> 1
    Second      -> 1000
    Minute      -> 60000
    Hour        -> 3600000
    Day         -> 24 * 3600000
    Week        -> 7 * 24 * 3600000
    Month       -> 28 * 24 * 3600000
    Year        -> 364 * 24 * 3600000


multiples : Unit -> List Float
multiples unit =
  case unit of
    Millisecond -> [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 500 ]
    Second      -> [ 1, 2, 5, 10, 15, 30 ]
    Minute      -> [ 1, 2, 5, 10, 15, 30 ]
    Hour        -> [ 1, 2, 3, 4, 6, 8, 12 ]
    Day         -> [ 1, 2 ]
    Week        -> [ 1, 2 ]
    Month       -> [ 1, 2, 3, 4, 6 ]
    Year        -> [] -- TODO prevent 2.5


highestMultiple : List Float -> Float -- TODO What about Years
highestMultiple =
  List.reverse >> List.head >> Maybe.withDefault 0


floorTo : Float -> Float -> Float
floorTo number prec =
  prec * toFloat (floor (number / prec))


magnitude : Float -> Unit -> Float
magnitude interval unit =
  case unit of
    Year ->
      max 1 (Numbers.magnitude interval)

    _ ->
      1
