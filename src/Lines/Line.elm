module Lines.Line exposing
  ( Look, Style, default, wider, static, style, emphasizable, hasMaybe )

{-|

# Quick start
@docs default

# Customizations
@docs Look, Style, wider, static, style, emphasizable

### Emphasizable helpers
@docs hasMaybe

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
static : Style -> Look data
static =
  Line.static


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style


{-| -}
emphasizable : Style -> Style -> (List data -> Bool) -> Look data
emphasizable =
  Line.emphasizable


{-| -}
hasMaybe : Maybe data -> List data -> Bool
hasMaybe hovering data =
  case hovering of
    Just hovering -> List.member hovering data
    Nothing       -> False
