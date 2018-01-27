module LineChart.Line exposing
  ( Config, default
  , wider, custom
  , Style, style
  )

{-|

# Quick start
@docs default

# Customizations
@docs Config, wider, custom

# Styles
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


{-| -} -- TODO add index? label?
custom : (List data -> Style) -> Config data
custom =
  Line.custom


{-| -}
type alias Style =
  Line.Style


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style
