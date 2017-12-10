module Internal.DateTime.Unit exposing (Unit, interval)

{-| -}

import Internal.Numbers as Numbers
import Internal.Coordinate as Coordinate
import Date
import Date.Extra as Date
import Date.Extra.Facts as Date


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
      findBestUnit intervalRough all |> Debug.log "unit"

    multiple =
      findBestMultiple intervalRough unit |> Debug.log "multiple"

    interval =
      toMs unit * multiple |> Debug.log "interval"

    _ =
      limits.min |> Debug.log "min"

    beginning =
      beginAt limits.min unit multiple |> Debug.log "beginning"

    amount =
      (limits.max - beginning) / interval |> floor |> Debug.log "amount"

    position m =
      next beginning unit (toFloat m * multiple)
  in
  List.map position (List.range 0 amount) |> Debug.log "positions"



-- INTERNAL


{-| Find the best fitted unit for a given interval and unit options.
-}
findBestUnit : Float -> List Unit -> Unit
findBestUnit interval units =
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


{-| Finds the best fit multiple given the interval and it's best fit unit.
-}
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


{-| Find the best position for the first tick.
-}
beginAt : Float -> Unit -> Float -> Float
beginAt min unit multiple =
  let
    date =
      Date.ceiling (toExtraUnit unit) (Date.fromTime min)

    (y, m, d, hh, mm, ss, _) =
      toParts date

    interval =
      toMs unit * multiple
  in
  case unit of
    Millisecond -> ceilingTo min interval
    Second      -> ceilingTo min interval
    Minute      -> ceilingTo min interval
    Hour        -> Date.toTime <| Date.fromParts y m d (ceilingToInt hh multiple) 0 0 0
    Day         -> Date.toTime <| Date.fromParts y m (ceilingToInt d multiple) 0 0 0 0
    Week        -> min -- TODO
    Month       -> Date.toTime <| Date.fromParts y (ceilingToMonth date multiple) 1 0 0 0 0
    Year        -> Date.toTime <| Date.fromParts (ceilingToInt y multiple) Date.Jan 1 0 0 0 0


{-| -}
ceilingTo : Float -> Float -> Float
ceilingTo number prec =
  prec * toFloat (ceiling (number / prec))


ceilingToInt : Int -> Float -> Int
ceilingToInt number prec =
  ceiling <| prec * toFloat (ceiling (toFloat number / prec))


ceilingToMonth : Date.Date -> Float -> Date.Month
ceilingToMonth date multiple =
  Date.monthFromMonthNumber <| ceilingToInt (Date.monthNumber date) multiple


{-| Find the next position.
-}
next : Float -> Unit -> Float -> Float
next timestamp unit multiple =
  Date.fromTime timestamp
    |> Date.add (toExtraUnit unit) (round multiple)
    |> Date.toTime



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


multiples : Unit -> List Float -- TODO int
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


toExtraUnit : Unit -> Date.Interval
toExtraUnit unit =
  case unit of
    Millisecond -> Date.Millisecond
    Second      -> Date.Second
    Minute      -> Date.Minute
    Hour        -> Date.Hour
    Day         -> Date.Day
    Week        -> Date.Week
    Month       -> Date.Month
    Year        -> Date.Year


highestMultiple : List Float -> Float -- TODO What about Years
highestMultiple =
  List.reverse >> List.head >> Maybe.withDefault 0


magnitude : Float -> Unit -> Float
magnitude interval unit =
  case unit of
    Year ->
      max 1 (Numbers.magnitude interval)

    _ ->
      1


toParts : Date.Date -> (Int, Date.Month, Int, Int, Int, Int, Int)
toParts date =
  ( Date.year date
  , Date.month date
  , Date.day date
  , Date.hour date
  , Date.minute date
  , Date.second date
  , Date.millisecond date
  )
