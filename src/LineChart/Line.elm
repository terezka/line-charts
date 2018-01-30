module LineChart.Line exposing
  ( Config, default
  , wider, hoverOne
  , custom
  , Style, style
  )

{-|

# Quick start
@docs Config, default

# Options
@docs wider, hoverOne

# Custom
@docs custom

## Styles
@docs Style, style

-}

import Internal.Line as Line
import Color



{-| -}
type alias Config data =
  Line.Config data


{-| -}
default : Config data
default =
  Line.default


{-| -}
wider : Float -> Config data
wider =
  Line.wider


{-| -}
custom : (List data -> Style) -> Config data
custom =
  Line.custom


{-| -}
hoverOne : Maybe data -> Config data
hoverOne hovered =
  custom <| \data ->
    if List.any (Just >> (==) hovered) data then
      style 2 identity
    else
      style 1 identity



{-| -}
type alias Style =
  Line.Style


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style
