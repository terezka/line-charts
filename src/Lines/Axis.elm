module Lines.Axis exposing
  ( default
  , Axis, Look, Line, Mark, Tick, Direction(..)
  , defaultLook
  , towardsZero
  , defaultLine
  , defaultTitle
  , defaultMark, defaultInterval, customInterval
  , defaultTick, defaultLabel
  )

{-| # Axis

## Quick start
@docs default

## What is an axis?
@docs Axis, Look, Line, Mark, Tick, Direction

## Defaults
@docs defaultLook, defaultTitle, towardsZero, defaultLine, defaultMark, defaultInterval, customInterval, defaultTick, defaultLabel

-}

import Svg exposing (..)
import Svg.Attributes exposing (stroke, style, fill)
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Color as Color
import Internal.Numbers as Numbers



{-| -}
type alias Axis data msg =
  { look : Look msg
  , variable : data -> Float
  }


{-| -}
type alias Look msg =
  { title : Title msg
  , offset : Float
  , position : Limits -> Float
  , line : Maybe (Limits -> Line msg)
  , marks : Limits -> List (Mark msg)
  , direction : Direction
  }


{-| -}
type alias Title msg =
    { position : Limits -> Float
    , view : Svg msg
    , xOffset : Float
    , yOffset : Float
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
default : Title msg -> (data -> Float) -> Axis data msg
default title variable =
  { variable = variable
  , look = defaultLook title
  }


{-| -}
defaultLook : Title msg -> Look msg
defaultLook title =
  { title = title
  , offset = 20
  , position = towardsZero
  , line = Just (defaultLine [ stroke Color.gray ])
  , marks = List.map defaultMark << defaultInterval
  , direction = Negative
  }


{-| -}
defaultTitle : String -> Float -> Float -> Title msg
defaultTitle title xOffset yOffset =
  Title .max (text_ [] [ tspan [] [ text title ] ]) 0 0


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
  , attributes = [ stroke Color.gray ]
  }


{-| -}
defaultLabel : Float -> Svg msg
defaultLabel position =
  text_ [] [ tspan [] [ text (toString position) ] ]


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
