module Tests exposing (..)

import Test exposing (..)
import Expect exposing (equal)

import TestRound exposing (..)
import TestRoundCom exposing (..)
import TestFloor exposing (..)
import TestFloorCom exposing (..)
import TestCeil exposing (..)
import TestCeilCom exposing (..)
import TestDecimal exposing (..)

all : Test
all =
  describe "All"
    [ roundTest
    , roundComTest
    , ceilTest
    , ceilComTest
    , floorTest
    , floorComTest
    , decimalTest 
    ]

elmTest : Test
elmTest =
  describe "elmTest"
    [ test "test Basics.round" <| \() -> equal -5 (Basics.round -5.5)
    , test "test Basics.ceil" <| \() -> equal -1 (Basics.ceiling -1.1)
    , test "test Basics.ceil" <| \() -> equal -1 (Basics.ceiling -1.9)
    , test "test Basics.floor" <| \() -> equal -2 (Basics.floor -1.1)
    , test "test Basics.floor" <| \() -> equal -2 (Basics.floor -1.9)
    ]
