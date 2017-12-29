module Internal.Axis.Tick exposing
  ( Tick, int, time, float
  , Direction(..), negative, positive
  )


import Svg exposing (Svg, Attribute)
import Lines.Color as Color
import Internal.Axis.Values.Time as Time



-- TICKS


{-| -}
type alias Tick msg =
  { color : Color.Color
  , width : Float
  , events : List (Attribute msg)
  , length : Float
  , label : Maybe (Svg msg)
  }


{-| -}
int : Int -> Int -> Tick msg
int _ n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  }


{-| -}
time : Int -> Time.Time -> Tick msg
time _ time =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (Time.toString time)
  }



{-| -}
float : Int -> Float -> Tick msg
float _ n =
  { color = Color.gray
  , width = 1
  , events = []
  , length = 5
  , label = Just <| viewText (toString n)
  }



-- DIRECTION


{-| -}
type Direction
  = Negative
  | Positive


{-| -}
negative : Direction
negative =
  Negative


{-| -}
positive : Direction
positive =
  Positive


-- INTERNAL


viewText : String -> Svg msg
viewText string =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text string ] ]
