module Lines.Line exposing
  ( Look, Style, default, wider, static, emphasizable, hasMaybe )

{-|

# Line

## Quick start
@docs default

## Customizing
@docs Look, Style, wider, static, emphasizable

### Emphasizable helpers
@docs hasMaybe

-}

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
wider : Int -> Look data
wider =
  Line.wider


{-| -}
static : Style -> Look data
static =
  Line.static


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
