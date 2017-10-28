module Plot.Axis exposing (..)

{-| # Axis

## Config


-}

import Svg exposing (..)
import Svg.Attributes exposing (stroke, style)
import Plot.Coordinate as Coordinate exposing (..)
import Plot.Color as Color
import Internal.Numbers as Numbers


{-| -}
type alias Look msg =
  { offset : Float
  , position : Limits -> Float
  , line : Maybe (Limits -> Line msg)
  , marks : Limits -> List (Mark msg)
  , direction : Direction
  }


{-| -}
type alias Mark msg =
  { label : Maybe (Svg msg)
  , tick : Maybe (Tick msg)
  , position : Float
  }


{-| -}
type alias Line msg =
  { attributes : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| -}
type alias Tick msg =
  { attributes : List (Attribute msg)
  , length : Int
  }


{-| -}
type Direction
  = Negative
  | Positive



-- DEFAULTS


{-| -}
defaultLook : Look msg
defaultLook =
  { offset = 0
  , position = towardsZero
  , line = Just (defaultLine [ stroke Color.black ])
  , marks = List.map defaultMark << defaultInterval
  , direction = Negative
  }


{-| -}
towardsZero : Coordinate.Limits -> Float
towardsZero { max, min } =
  clamp 0 min max


{-| -}
defaultMark : Float -> Mark msg
defaultMark position =
  { position = position
  , tick = Just defaultTick
  , label = Just (defaultLabel position)
  }


{-| -}
defaultTick : Tick msg
defaultTick =
  { length = 5
  , attributes = [ stroke Color.black ]
  }


{-| -}
defaultLabel : Float -> Svg msg
defaultLabel position =
  text_ [] [ tspan [] [ text (toString position) ] ]


{-| -}
defaultStringLabel : String -> Svg msg
defaultStringLabel position =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text position ] ]


{-| -}
defaultLine : List (Attribute msg) -> Limits -> Line msg
defaultLine attributes limits =
    { attributes = Svg.Attributes.style "pointer-events: none;" :: attributes
    , start = limits.min
    , end = limits.max
    }



-- INTERVALS


{-| -}
defaultInterval : Coordinate.Limits -> List Float
defaultInterval =
  Numbers.defaultInterval


{-| -}
customInterval : Float -> Float -> Coordinate.Limits -> List Float
customInterval =
  Numbers.customInterval
