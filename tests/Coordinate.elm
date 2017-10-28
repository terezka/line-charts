module Coordinate exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, float, string)
import Test exposing (..)
import Svg.Coordinate exposing (..)


-- MATERIAL


frame : Frame
frame =
  { margin = Margin 0 0 0 0
  , size = Size 100 100
  }


system : System
system =
  { frame = frame
  , x = Limits 0 10
  , y = Limits 0 10
  }




-- TESTS


coordinates : Test
coordinates =
  describe "Defaults"
    [ test "Length should default to 1" <|
        \() ->
          Expect.equal 0.9 (toSVG Y (updateFrame system { frame | size = Size 0 0 }) 1)
    , fuzz float "x-coordinate produced should always be a number" <|
        \number ->
          toSVG X system number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    , fuzz float "y-coordinate produced should always be a number" <|
        \number ->
          toSVG Y system number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    ]


horizontal : Test
horizontal =
  describe "Horizontal translation"
    [ test "toSVG" <|
        \() ->
          Expect.equal 10 (toSVG X system 1)
    , test "toSVG with lower margin" <|
        \() ->
          Expect.equal 28 (toSVG X (updateFrame system { frame | margin = Margin 0 0 0 20 }) 1)
    , test "toSVG with upper margin" <|
        \() ->
          Expect.equal 8 (toSVG X (updateFrame system { frame | margin = Margin 0 20 0 0 }) 1)
    , test "toCartesian" <|
        \() ->
          Expect.equal 1 (toCartesian X system 10)
    , test "toCartesian with lower margin" <|
        \() ->
          Expect.equal 1 (toCartesian X (updateFrame system { frame | margin = Margin 0 0 0 20 }) 28)
    , test "toCartesian with upper margin" <|
        \() ->
          Expect.equal 1 (toCartesian X (updateFrame system { frame | margin = Margin 0 20 0 0 }) 8)
    ]


vertical : Test
vertical =
  describe "Vertical translation"
    [ test "toSVG" <|
        \() ->
          Expect.equal 90 (toSVG Y system 1)
    , test "toSVG with lower margin" <|
        \() ->
          Expect.equal 72 (toSVG Y (updateFrame system { frame | margin = Margin 0 0 20 0 }) 1)
    , test "toSVG with upper margin" <|
        \() ->
          Expect.equal 92 (toSVG Y (updateFrame system { frame | margin = Margin 20 0 0 0 }) 1)
    , test "toCartesian" <|
        \() ->
          Expect.equal 1 (toCartesian Y system 90)
    , test "toCartesian with lower margin" <|
        \() ->
          Expect.equal 1 (toCartesian Y (updateFrame system { frame | margin = Margin 0 0 20 0 }) 72)
    , test "toCartesian with upper margin" <|
        \() ->
          Expect.equal 1 (toCartesian Y (updateFrame system { frame | margin = Margin 20 0 0 0 }) 92)
    ]


updateFrame : System -> Frame -> System
updateFrame system frame =
  { system | frame = frame }
