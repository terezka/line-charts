module Lines.Color exposing (Color, pink, blue, orange, gray, grayLight, black)

{-|

# Defaults
@docs Color, pink, blue, orange, gray, grayLight, black

-}



{-| -}
type alias Color =
  String


{-| -}
pink : Color
pink =
  "#f569d7"


{-| -}
orange : Color
orange =
  "#cd913c"


{-| -}
blue : Color
blue =
  "#28ebc7"


{-| -}
gray : Color
gray =
  "#a3a3a3"


{-| -}
grayLight : Color
grayLight =
  "#f3f3f3"


{-| -}
transparent : Color
transparent =
  "transparent"


{-| -}
black : Color
black =
  "black"
