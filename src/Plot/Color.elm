module Plot.Color exposing (Color, pink, blue, green, orange, gray, transparent, black, defaults)

{-| -}


{-| -}
type alias Color =
  String


{-| -}
pink : Color
pink =
  "#ff9edf"


{-| -}
blue : Color
blue =
  "#aec9ff"


{-| -}
green : Color
green =
  "#a5e6a0"


{-| -}
orange : Color
orange =
  "#ffcc91"


{-| -}
gray : Color
gray =
  "#a3a3a3"


{-| -}
transparent : Color
transparent =
  "transparent"


{-| -}
black : Color
black =
  "black"


{-| -}
defaults : List Color
defaults =
  [ pink
  , blue
  , orange
  , green
  ]
