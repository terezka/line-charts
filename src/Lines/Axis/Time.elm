module Lines.Axis.Time exposing (default, Unit(..), Value, mark, values, formatting)

{-| -}

import Svg exposing (..)
import Internal.Axis as Axis
import Internal.Coordinate as Coordinate
import Date
import Date.Extra as Date
import Date.Extra.Facts as Date
import Date.Format
import Time


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
type alias Value =
  { unit : Unit
  , multiple : Int
  , position : Time.Time
  }


{-| -}
default : Float -> Coordinate.Limits -> List (Axis.Mark msg)
default length =
  let
    numOfTicks =
      round (length / 170)
  in
  List.map mark << values numOfTicks


{-| -}
values : Int -> Coordinate.Limits -> List Value
values amountRough limits =
  let
    range =
      limits.max - limits.min

    intervalRough =
      range / toFloat amountRough

    unit =
      findBestUnit intervalRough all

    multiple =
      findBestMultiple intervalRough unit

    interval =
      toMs unit * toFloat multiple

    beginning =
      beginAt limits.min unit multiple

    positions_ acc m =
      let next_ = next beginning unit (m * multiple)
      in if next_ > limits.max then acc else positions_ (next_ :: acc) (m + 1)
  in
  List.map (Value unit multiple) (positions_ [] 0)


{-| -}
mark : Value -> Axis.Mark msg
mark { unit, position } =
  let
    date =
      Date.fromTime position

    label =
      formatting unit date -- TODO how to format

    viewLabel =
      text_ [] [ tspan [] [ text label ] ]
  in
  { position = position
  , label = Just viewLabel
  , tick = Just (Axis.Tick [] 5)
  }


{-| -}
formatting : Unit -> Date.Date -> String
formatting unit =
  case unit of
    Millisecond -> toString << Date.toTime
    Second      -> Date.Format.format "%S"
    Minute      -> Date.Format.format "%H:%M"
    Hour        -> Date.Format.format "%l%P"
    Day         -> Date.Format.format "%d/%m"
    Week        -> Date.toFormattedString "'Week' w, y"
    Month       -> Date.Format.format "%b %y"
    Year        -> Date.Format.format "%Y"



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


{-| -}
next : Float -> Unit -> Int -> Float
next timestamp unit multiple =
  Date.fromTime timestamp
    |> Date.add (toExtraUnit unit) multiple
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
      max 1 (Axis.getMagnitude interval)

    _ ->
      1
