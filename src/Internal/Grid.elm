module Internal.Grid exposing (Grid(..), default, dotted, lines)


{-| -}

import Lines.Color as Color


{-| -}
type Grid
  = Dotted Color.Color
  | Lines Float Color.Color


{-| -}
default : Grid
default =
  lines 1 Color.grayLight


{-| -}
dotted : Color.Color -> Grid
dotted =
  Dotted


{-| -}
lines : Float -> Color.Color -> Grid
lines =
  Lines


-- INTERNAL


{- TODO -}
-- view : Grid ->
