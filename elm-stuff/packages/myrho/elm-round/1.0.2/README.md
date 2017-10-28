# elm-round 

This [Elm](http://elm-lang.org) library empowers you to convert a `Float` to a `String` with ultimate control how many digits after the decimal point are shown and how the remaining digits are rounded. You can round, round up and round down the mathematical or the commerical way. For example:

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

[Commercial rounding](https://en.wikipedia.org/wiki/Rounding#Round_half_away_from_zero) means that negative and positive numbers are treated symmetrically. It affects numbers whose last digit equals 5. For example:

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

Why aren't we just doing `x * 1000 |> round |> toFloat |> (flip (/)) 1000` in order to round to 3 digits after comma? Because due to floating point arithmetic it might happen that it outputs someting like `3.1416000000001`, although we just wanted `3.1416`. Ugly.

## Installation

From the root of your [Elm](http://elm-lang.org) project run

    elm package install myrho/elm-round

## Releases

| Version | Notes |
| ------- | ----- |
| 1.0.1   | Upgrade to Elm 0.18 |
| 1.0.0   | First official release, streamlined API and tests, docs added |
