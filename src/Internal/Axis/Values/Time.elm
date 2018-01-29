module Internal.Axis.Values.Time exposing (values)

{-| -}

import Internal.Coordinate as Coordinate
import Internal.Utils as Utils
import Date
import Date.Extra as Date
import Date.Extra.Facts as Date
import LineChart.Axis.Tick exposing (Time, Unit(..), Interval)



-- PRODUCTION


{-| -}
values : Int -> Coordinate.Range -> List Time
values amountRough range =
  let
    intervalRough =
      (range.max - range.min) / toFloat amountRough

    unit =
      findBestUnit intervalRough all

    multiple =
      findBestMultiple intervalRough unit

    interval =
      toMs unit * toFloat multiple

    beginning =
      beginAt range.min unit multiple

    toPositions acc i =
      let next_ = next beginning unit (i * multiple) in
      if next_ > range.max then acc else toPositions (acc ++ [ next_ ]) (i + 1)

    toTimes values unitChange acc =
      case values of
        value :: next :: rest ->
          let
            isFirst = List.isEmpty acc
            newAcc = toTime unitChange value isFirst :: acc
            newUnitChange = getUnitChange unit value next
          in
          toTimes (next :: rest) newUnitChange newAcc

        [ value ] ->
           toTime unitChange value (List.isEmpty acc) :: acc

        [] ->
          acc

    toTime unitChange value isFirst =
      { change = unitChange
      , interval = Interval unit multiple
      , timestamp = value
      , isFirst = isFirst
      }

  in
  toTimes (toPositions [] 0) Nothing []



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
findBestMultiple : Float -> Unit -> Int
findBestMultiple interval unit =
  let
    findBest_ multiples =
      case multiples of
        m1 :: m2 :: rest ->
          if interval <= (middleOfNext m1 m2)
            then m1
            else findBest_ (m2 :: rest)

        m :: _ -> m
        []     -> 1

    middleOfNext m1 m2 =
      (toFloat m1 * toMs unit + toFloat m2 * toMs unit) / 2
  in
  findBest_ (multiples unit)


{-| Find the best position for the first tick.
-}
beginAt : Float -> Unit -> Int -> Float
beginAt min unit multiple =
  let
    date =
      Date.ceiling (toExtraUnit unit) (Date.fromTime min)

    (y, m, d, hh, mm, ss, _) =
      toParts date

    interval =
      toMs unit * toFloat multiple
  in
  case unit of
    Millisecond -> ceilingTo min interval
    Second      -> ceilingTo min interval
    Minute      -> ceilingTo min interval
    Hour        -> Date.toTime <| Date.fromParts y m d (ceilingToInt hh multiple) 0 0 0
    Day         -> Date.toTime <| Date.fromParts y m (ceilingToInt d multiple) 0 0 0 0
    Week        -> Date.toTime <| ceilingToWeek date multiple
    Month       -> Date.toTime <| Date.fromParts y (ceilingToMonth date multiple) 1 0 0 0 0
    Year        -> Date.toTime <| Date.fromParts (ceilingToInt y multiple) Date.Jan 1 0 0 0 0


ceilingTo : Float -> Float -> Float
ceilingTo number prec =
  prec * toFloat (ceiling (number / prec))


ceilingToInt : Int -> Int -> Int
ceilingToInt number prec =
  ceiling <| ceilingTo (toFloat number) (toFloat prec)


ceilingToWeek : Date.Date -> Int -> Date.Date
ceilingToWeek date multiple =
  let weekNumber = ceilingToInt (Date.weekNumber date) multiple in
  Date.fromSpec Date.utc Date.noTime (Date.weekDate (Date.year date) weekNumber 1)


ceilingToMonth : Date.Date -> Int -> Date.Month
ceilingToMonth date multiple =
  Date.monthFromMonthNumber <| ceilingToInt (Date.monthNumber date) multiple


next : Float -> Unit -> Int -> Float
next timestamp unit multiple =
  Date.fromTime timestamp
    |> Date.add (toExtraUnit unit) multiple
    |> Date.toTime


getUnitChange : Unit -> Float -> Float -> Maybe Unit
getUnitChange interval value next =
  let
    equalBy unit =
      Date.equalBy (toExtraUnit unit) (Date.fromTime value) (Date.fromTime next)

    unitChange_ units =
      case units of
        Week :: rest -> -- Skip week
          unitChange_ rest

        unit :: rest ->
          if toMs unit <= toMs interval then Nothing
          else if not (equalBy unit) then Just unit
          else unitChange_ rest

        [] ->
          Nothing
  in
  unitChange_ allReversed



-- HELPERS


all : List Unit
all =
  [ Millisecond, Second, Minute, Hour, Day, Week, Month, Year ]


allReversed : List Unit
allReversed =
  List.reverse all


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


multiples : Unit -> List Int
multiples unit =
  case unit of
    Millisecond -> [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 500 ]
    Second      -> [ 1, 2, 5, 10, 15, 30 ]
    Minute      -> [ 1, 2, 5, 10, 15, 30 ]
    Hour        -> [ 1, 2, 3, 4, 6, 8, 12 ]
    Day         -> [ 1, 2 ]
    Week        -> [ 1, 2 ]
    Month       -> [ 1, 2, 3, 4, 6 ]
    Year        -> [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 500, 1000, 10000 ]


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


highestMultiple : List Int -> Float
highestMultiple =
  List.reverse >> List.head >> Maybe.withDefault 0 >> toFloat


magnitude : Float -> Unit -> Float
magnitude interval unit =
  case unit of
    Year ->
      max 1 (Utils.magnitude interval)

    _ ->
      1
