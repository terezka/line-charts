module Lines.Line exposing
  ( Look, default
  , wider, custom
  , Style, style
  )

{-|

# Quick start
@docs default

# Customizations
@docs Look, wider, custom

# Styles
@docs Style, style

-}

import Internal.Line as Line
import Color



{-| -}
type alias Look data =
  Line.Look data


{-| -}
default : Look data
default =
  Line.default


{-| -}
wider : Float -> Look data
wider =
  Line.wider


{-| -}
custom : (List data -> Style) -> Look data
custom =
  Line.custom


{-| -}
type alias Style =
  Line.Style


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style
