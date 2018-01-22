module Internal.Data exposing (..)

{-| -}

import Internal.Coordinate exposing (..)



{-| -}
type alias Data data =
  { user : data
  , point : Point
  , isReal : Bool
  }


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
isWithinRange : System -> Point -> Bool
isWithinRange system point =
  clamp system.x.min system.x.max point.x == point.x &&
  clamp system.y.min system.y.max point.y == point.y
