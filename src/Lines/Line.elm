module Lines.Line exposing
  ( Look, default
  , wider, static, emphasizable
  , Style, style
  )

{-|

# Quick start
@docs default

# Customizations
@docs Look, wider, static, emphasizable

# Styles
@docs Style, style

-}

import Internal.Line as Line
import Color
import Color.Convert



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
static : Style -> Look data
static =
  Line.static


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style


{-| -}
emphasizable :
  { normal : Style
  , emphasized : Style
  , isEmphasized : List data -> Bool
  }
  -> Look data
emphasizable =
  Line.emphasizable
