module Internal.Axis.Values.Time exposing (values)

{-| -}

import Internal.Coordinate as Coordinate
import Internal.Utils as Utils
import Time
import Time.Extra
import LineChart.Axis.Tick exposing (Time, Unit(..), Interval)



-- PRODUCTION


{-| -}
values : Time.Zone -> Int -> Coordinate.Range -> List Time
values zone amountRough range =
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
      beginAt zone (floatToPosix range.min) unit multiple

    toPositions acc i =
      let next_ = next zone beginning unit (i * multiple) in
      if posixsToFloat next_ > range.max then acc else toPositions (acc ++ [ next_ ]) (i + 1)

    toTimes values_ unitChange acc =
      case values_ of
        value :: next_ :: rest ->
          let
            isFirst = List.isEmpty acc
            newAcc = toTime unitChange value isFirst :: acc
            newUnitChange = getUnitChange unit zone value next_
          in
          toTimes (next_ :: rest) newUnitChange newAcc

        [ value ] ->
           toTime unitChange value (List.isEmpty acc) :: acc

        [] ->
          acc

    toTime unitChange value isFirst =
      { change = unitChange
      , interval = Interval unit multiple
      , timestamp = value
      , isFirst = isFirst
      , zone = zone
      }

  in
  toTimes (toPositions [] 0) Nothing []



-- INTERNAL


{-| Find the best fitted unit for a given interval and unit options.
-}
findBestUnit : Float -> List Unit -> Unit
findBestUnit interval units_ =
  let
    findBest_ units__ u0 =
      case units__ of
        u1 :: u2 :: rest ->
          if interval <= middleOfNext u1 u2
            then u1
            else findBest_ (u2 :: rest) u1

        u :: _ -> u
        []     -> Year

    middleOfNext u1 u2 =
      (toMs u1 * highestMultiple (multiples u1) + toMs u2) / 2
  in
  findBest_ units_ Year


{-| Finds the best fit multiple given the interval and it's best fit unit.
-}
findBestMultiple : Float -> Unit -> Int
findBestMultiple interval unit =
  let
    findBest_ multiples_ =
      case multiples_ of
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
beginAt : Time.Zone -> Time.Posix -> Unit -> Int -> Time.Posix
beginAt zone min unit multiple =
  min
    |> Time.Extra.add (toExtraUnit unit) multiple zone
    |> Time.Extra.ceiling (toExtraUnit unit) zone


next : Time.Zone -> Time.Posix -> Unit -> Int -> Time.Posix
next zone timestamp unit multiple =
  Time.Extra.add (toExtraUnit unit) multiple zone timestamp


getUnitChange : Unit -> Time.Zone -> Time.Posix -> Time.Posix -> Maybe Unit
getUnitChange interval zone value next_ =
  let
    equalBy unit =
      Time.Extra.diff (toExtraUnit unit) zone
        (Time.Extra.floor (toExtraUnit unit) zone value)
        (Time.Extra.floor (toExtraUnit unit) zone next_) == 0

    unitChange_ units =
      case units of
        unit :: rest ->
          if toMs unit <= toMs interval then unitChange_ rest
          else if not (equalBy unit) then Just unit
          else Nothing

        [] ->
          Nothing
  in
  unitChange_ all



-- HELPERS


all : List Unit
all =
  [ Millisecond, Second, Minute, Hour, Day, Month, Year ]


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
    Month       -> [ 1, 2, 3, 4, 6 ]
    Year        -> [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 500, 1000, 10000 ]


toExtraUnit : Unit -> Time.Extra.Interval
toExtraUnit unit =
  case unit of
    Millisecond -> Time.Extra.Millisecond
    Second      -> Time.Extra.Second
    Minute      -> Time.Extra.Minute
    Hour        -> Time.Extra.Hour
    Day         -> Time.Extra.Day
    Month       -> Time.Extra.Month
    Year        -> Time.Extra.Year


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


floatToPosix : Float -> Time.Posix
floatToPosix ms =
  Time.millisToPosix (Basics.round ms)


posixsToFloat : Time.Posix -> Float
posixsToFloat posix =
  Basics.toFloat (Time.posixToMillis posix)
