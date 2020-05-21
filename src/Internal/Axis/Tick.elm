module Internal.Axis.Tick exposing
  ( Config, Properties, Direction(..), isPositive
  , custom, int, float, long, gridless, labelless, opposite
  , properties
  )

{-| -}

import Svg exposing (Svg, Attribute)
import Internal.Svg as Svg
import LineChart.Colors as Colors
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
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Just <| Svg.label "inherit" (String.fromInt n)
    }


{-| -}
float : Float -> Config msg
float n =
  custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Just <| Svg.label "inherit" (String.fromFloat n)
    }


{-| -}
gridless : Float -> Config msg
gridless n =
  custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = False
    , direction = Negative
    , label = Just <| Svg.label "inherit" (String.fromFloat n)
    }


{-| -}
labelless : Float -> Config msg
labelless n =
  custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Nothing
    }


{-| -}
long : Float -> Config msg
long n =
  custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 20
    , grid = True
    , direction = Negative
    , label = Just <| Svg.label "inherit" (String.fromFloat n)
    }


{-| -}
opposite : Float -> Config msg
opposite n =
  custom
    { position = n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Positive
    , label = Just <| Svg.label "inherit" (String.fromFloat n)
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
properties : Config msg -> Properties msg
properties (Config properties_) =
  properties_
