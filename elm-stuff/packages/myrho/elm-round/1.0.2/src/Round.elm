module Round exposing 
  ( round, ceiling, floor
  , roundCom, ceilingCom, floorCom
  , roundNum, floorNum, ceilingNum
  , roundNumCom, floorNumCom, ceilingNumCom
  , toDecimal, truncate
  )

{-| This library empowers you to convert a `Float` to a `String` with ultimate 
control how many digits after the decimal point are shown and how the remaining 
digits are rounded. You can round, round up and round down the mathematical or 
the commerical way. For example:

    x = 3.141592653589793

    round 2 x -- "3.14"
    round 4 x -- "3.1416"
    
    ceiling 2 x -- "3.15"
    floor 4 x -- "3.1415"

The number of digits after decimal point can also be negative.

    x = 213.14

    round -2 x -- "200"
    round -1 x -- "210"
    
    ceiling -2 x -- "300"
    floor -3 x -- "0"

[Commercial 
rounding](https://en.wikipedia.org/wiki/Rounding#Round_half_away_from_zero) 
means that negative and positive numbers are treated symmetrically. It affects 
numbers whose last digit equals 5. For example:

    x = -0.5

    round 0 x -- "0"
    roundCom 0 x -- "-1"

    floor 0 x -- "-1"
    floorCom 0 x -- "0"

    ceiling 0 x -- "0"
    ceilingCom 0 x -- "-1"

Have a look at the tests for more examples!

Under the hood the `Float` is 

  * converted to a string
  * normalized (if it is in scientific notation, eg `1.234e-23`)
  * splitted at the comma.
  * Then the part after comma is truncated to the number of desired digits + 1
  * inserting a comma before the last digit,
  * turning this into a `Float` again,
  * apply a rounding function on it,
  * attach it the part before comma again.
  * By the way handles cases with already rounded numbers, zero and the sign.

Why aren't we just doing `x * 1000 |> round |> toFloat |> (flip (/)) 1000` in 
order to round to 3 digits after comma? Because due to floating point 
arithmetic it might happen that it outputs someting like `3.1416000000001`, 
although we just wanted `3.1416`. Ugly.

# Round to String
@docs round, ceiling, floor, roundCom, ceilingCom, floorCom

# Round to Float
@docs roundNum, ceilingNum, floorNum, roundNumCom, ceilingNumCom, floorNumCom

# Utility functions
@docs toDecimal, truncate

-}

import String

{-| Like Elm's basic `truncate` but works on the full length of a float's 64 
bits. So it's more precise.

    x = 9007199254740.99

    Basics.truncate x -- 652835028 (which is not correct)
    Round.truncate x -- 9007199254740 (which is)
-}
truncate : Float -> Int
truncate n =
  if n < 0
    then Basics.ceiling n
    else Basics.floor n

{-| Transforms a `Float` in scientific notation into its decimal representation 
as a `String`.

    x = 1e30
    toDecimal x -- outputs "1000000000000000000000000000000"

    x = 1.2345e-30
    toDecimal x -- outputs "0.0000000000000000000000000000012345"
-}
toDecimal : Float -> String
toDecimal fl =
  case String.split "e"
        <| Basics.toString fl of
    num :: exp :: _ ->
      let
        e = 
          ( if String.startsWith "+" exp
              then String.dropLeft 1 exp
              else exp
          ) |> String.toInt
            |> Result.toMaybe
            |> Maybe.withDefault 0
        (sign, before,after) =
          let
            (b,a) =
              splitComma num
            hasSign =
              fl < 0
          in
            ( if hasSign
                then 
                  "-"
                else 
                  ""
            , if hasSign
                then 
                  String.dropLeft 1 b
                else
                  b
            , a
            )

        newBefore = 
          if e >= 0
            then 
              before
            else
              if abs e < String.length before
                then
                  String.left (String.length before - abs e) before
                  ++
                  "."
                  ++
                  String.right (abs e) before
                else
                  "0."
                  ++
                  String.repeat (abs e - String.length before) "0"
                  ++
                  before

        newAfter =
          if e <= 0
            then 
              after
            else
              if e < String.length after
                then
                  String.left e after
                  ++
                  "."
                  ++
                  String.right (String.length after - e) after
                else
                  after
                  ++
                  String.repeat (e - String.length after) "0"
      in
        sign ++ newBefore ++ newAfter
    num :: _ ->
      num
    _ ->
      ""

splitComma : String -> (String,String)
splitComma str =
  case String.split "." str of
    before :: after :: _ ->
      (before,after)
    before :: _ ->
      (before, "0")
    _ ->
      ("0","0")


roundFun : (Float -> Int) -> Int -> Float -> String
roundFun functor s fl =
  if s == 0 then 
    functor fl |> Basics.toString
  else if s < 0 then
    toFloat s
      |> abs 
      |> (^) 10
      |> (/) fl
      |> roundFun functor 0
      |> (\r ->
            if r /= "0" then
              r ++ (String.repeat (abs s) "0")
            else
              r
         )
  else
      let
        (before, after) =
          toDecimal fl
            |> splitComma 
        a = 
          after
            |> String.padRight (s+1) '0'

        b = String.left s a
        c = String.dropLeft s a 
        e = 10^s
        f =
          ( if fl < 0
            then "-"
            else ""
          ) ++"1"++b++"."++c
            |> String.toFloat
            |> Result.toMaybe
            |> Maybe.withDefault (toFloat e)
            |> functor
        n =
          if fl < 0
            then -1
            else 1
        dd =
          if fl < 0
            then 2
            else 1
        g =
          Basics.toString f |> String.dropLeft dd

        h =
          truncate fl
          + ( if f - (e*n) == (e*n)
                then 
                  if fl < 0
                    then -1
                    else 1
                else
                  0
            )

        j = Basics.toString h

        i =
          if j == "0" && f-(e*n) /= 0 && fl < 0 && fl > -1
            then "-" ++ j
            else j
      in
        i
          ++ "."
          ++ g

{-| Turns a `Float` into a `String` and rounds it to the given number of digits 
after decimal point.

    x = 3.141592653589793

    round 2 x -- "3.14"
    round 4 x -- "3.1416"

The number of digits after decimal point can also be negative.

    x = 213.35

    round -2 x -- "200"
    round -1 x -- "210"
-}
round : Int -> Float -> String
round =
  roundFun Basics.round

{-| Turns a `Float` into a `String` and rounds it up to the given number of 
digits after decimal point.

    x = 3.141592653589793

    ceiling 2 x -- "3.15"
    ceiling 4 x -- "3.1416"

The number of digits after decimal point can also be negative.

    x = 213.35

    ceiling -2 x -- "300"
    ceiling -1 x -- "220"
-}
ceiling : Int -> Float -> String
ceiling =
  roundFun Basics.ceiling

{-| Turns a `Float` into a `String` and rounds it down to the given number of 
digits after decimal point.

    x = 3.141592653589793

    floor 2 x -- "3.14"
    floor 4 x -- "3.1415"

The number of digits after decimal point can also be negative.

    x = 213.35

    floor -2 x -- "200"
    floor -1 x -- "210"
-}
floor : Int -> Float -> String
floor =
  roundFun Basics.floor

{-| Turns a `Float` into a `String` and rounds it to the given number of digits 
after decimal point the commercial way.

    x = -0.5

    round 0 x -- "0"
    roundCom 0 x -- "-1"

The number of digits after decimal point can also be negative.
-}
roundCom : Int -> Float -> String
roundCom =
  roundFun 
    (\fl ->
      let
        dec = 
          fl - (toFloat <| truncate fl)
      in
        if dec >= 0.5
          then
            Basics.ceiling fl
        else if dec <= -0.5
          then 
            Basics.floor fl
          else
            Basics.round fl
    )

{-| Turns a `Float` into a `String` and rounds it down to the given number of 
digits after decimal point the commercial way.

    x = -0.5

    floor 0 x -- "-1"
    floorCom 0 x -- "0"

The number of digits after decimal point can also be negative.
-}
floorCom : Int -> Float -> String
floorCom s fl =
  if fl < 0
    then 
      ceiling s fl
    else
      floor s fl

{-| Turns a `Float` into a `String` and rounds it up to the given number of 
digits after decimal point the commercial way.

    x = -0.5

    ceiling 0 x -- "0"
    ceilingCom 0 x -- "-1"

The number of digits after decimal point can also be negative.
-}
ceilingCom : Int -> Float -> String
ceilingCom s fl =
  if fl < 0
    then 
      floor s fl
    else
      ceiling s fl

{-| As `round` but turns the resulting `String` back to a `Float`.
-}
roundNum : Int -> Float -> Float
roundNum =
  funNum round

{-| As `floor` but turns the resulting `String` back to a `Float`.
-}
floorNum : Int -> Float -> Float
floorNum =
  funNum floor

{-| As `ceiling` but turns the resulting `String` back to a `Float`.
-}
ceilingNum : Int -> Float -> Float
ceilingNum =
  funNum ceiling

{-| As `roundCom` but turns the resulting `String` back to a `Float`.
-}
roundNumCom : Int -> Float -> Float
roundNumCom =
  funNum roundCom

{-| As `floorCom` but turns the resulting `String` back to a `Float`.
-}
floorNumCom : Int -> Float -> Float
floorNumCom =
  funNum floorCom

{-| As `ceilingCom` but turns the resulting `String` back to a `Float`.
-}
ceilingNumCom : Int -> Float -> Float
ceilingNumCom =
  funNum ceilingCom

funNum : (Int -> Float -> String) -> Int -> Float -> Float
funNum fun s fl =
  Maybe.withDefault (1/0)
  <| Result.toMaybe
  <| String.toFloat
  <| fun s fl

