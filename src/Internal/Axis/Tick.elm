module Internal.Axis.Tick exposing
  ( Config, Properties, Direction(..), isPositive
  , custom, int, float
  , properties
  )

{-| -}

import Svg exposing (Svg, Attribute)
import Internal.Svg as Svg
import Color



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { position : Float
  , color : Color.Color
  , width : Float
  , length : Float
  , grid : Bool
  , direction : Direction
  , label : Maybe (Svg msg)
  }



-- DIRECTION


{-| -}
type Direction
  = Negative
  | Positive



-- INTERNAL


isPositive : Direction -> Bool
isPositive direction =
  case direction of
    Positive -> True
    Negative -> False



-- TICKS


{-| -}
int : Int -> Config msg
int n =
  custom
    { position = toFloat n
    , color = Color.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Just <| Svg.label "inherit" (toString n)
    }


{-| -}
float : Float -> Config msg
float n =
  custom
    { position = n
    , color = Color.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Just <| Svg.label "inherit" (toString n)
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
properties : Config msg -> Properties msg
properties (Config properties) =
  properties
