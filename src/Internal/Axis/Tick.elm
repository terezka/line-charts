module Internal.Axis.Tick exposing (Direction(..), isPositive)


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
