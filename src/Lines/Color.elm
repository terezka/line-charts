module Lines.Color exposing (Color, pink, blue, orange, gray, grayLight, grayLighest, black, inherit)

{-|

# Defaults
@docs Color, pink, blue, orange, gray, grayLight, grayLighest, black, inherit

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
grayLighest : Color
grayLighest =
  "#d3d3d3"


{-| -}
transparent : Color
transparent =
  "transparent"


{-| -}
inherit : Color
inherit =
  "inherit"


{-| -}
black : Color
black =
  "black"
