module Coordinate exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, float, string)
import Test exposing (..)
import Lines.Coordinate exposing (..)


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
          Expect.equal 0.9 (toSVGY (updateFrame system { frame | size = Size 0 0 }) 1)
    , fuzz float "x-coordinate produced should always be a number" <|
        \number ->
          toSVGX system number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    , fuzz float "y-coordinate produced should always be a number" <|
        \number ->
          toSVGY system number
            |> isNaN
            |> Expect.false "Coordinate should always be a number!"
    ]


horizontal : Test
horizontal =
  describe "Horizontal translation"
    [ test "toSVG" <|
        \() ->
          Expect.equal 10 (toSVGX system 1)
    , test "toSVG with lower margin" <|
        \() ->
          Expect.equal 28 (toSVGX (updateFrame system { frame | margin = Margin 0 0 0 20 }) 1)
    , test "toSVG with upper margin" <|
        \() ->
          Expect.equal 8 (toSVGX (updateFrame system { frame | margin = Margin 0 20 0 0 }) 1)
    , test "toCartesian" <|
        \() ->
          Expect.equal 1 (toDataX system 10)
    , test "toCartesian with lower margin" <|
        \() ->
          Expect.equal 1 (toDataX (updateFrame system { frame | margin = Margin 0 0 0 20 }) 28)
    , test "toCartesian with upper margin" <|
        \() ->
          Expect.equal 1 (toDataX (updateFrame system { frame | margin = Margin 0 20 0 0 }) 8)
    ]


vertical : Test
vertical =
  describe "Vertical translation"
    [ test "toSVG" <|
        \() ->
          Expect.equal 90 (toSVGY system 1)
    , test "toSVG with lower margin" <|
        \() ->
          Expect.equal 72 (toSVGY (updateFrame system { frame | margin = Margin 0 0 20 0 }) 1)
    , test "toSVG with upper margin" <|
        \() ->
          Expect.equal 92 (toSVGY (updateFrame system { frame | margin = Margin 20 0 0 0 }) 1)
    , test "toCartesian" <|
        \() ->
          Expect.equal 1 (toDataY system 90)
    , test "toCartesian with lower margin" <|
        \() ->
          Expect.equal 1 (toDataY (updateFrame system { frame | margin = Margin 0 0 20 0 }) 72)
    , test "toCartesian with upper margin" <|
        \() ->
          Expect.equal 1 (toDataY (updateFrame system { frame | margin = Margin 20 0 0 0 }) 92)
    ]


updateFrame : System -> Frame -> System
updateFrame system frame =
  { system | frame = frame }
