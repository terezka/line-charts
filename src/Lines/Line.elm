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

import Lines.Color as Color
import Internal.Line as Line



{-| -}
type alias Look data =
  Line.Look data


{-| -}
type alias Style =
  Line.Style


{-| -}
default : Look data
default =
  Line.default


{-| -}
wider : Float -> Look data
wider =
  Line.wider


{-| -}
style : Float -> Color.Color -> Style
style =
  Line.style


{-| -}
custom : (Int -> List data -> Color.Color -> Style) -> Look data
custom =
  Line.custom
