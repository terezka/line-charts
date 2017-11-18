module Lines.Line exposing
  ( Look, Style, default, wider, static, emphasizable, hasMaybe )

{-|

# Line

## Quick start
@docs default

## Customizing
@docs Look, Style, wider, static, emphasizable, hasMaybe

-}

import Internal.Line as Line exposing (Look, Style)



{-| -}
type alias Look data =
  Line.Look data


{-| -}
type alias Style =
  Line.Style


{-| -}
default : Look data
default =
  Line.look
    { normal = Line.style 1 identity
    , emphasized = Line.style 2 identity
    , isEmphasized = always False
    }


{-| -}
wider : Int -> Look data
wider width =
  Line.look
    { normal = Line.style width identity
    , emphasized = Line.style width identity
    , isEmphasized = always False
    }


{-| -}
static : Style -> Look data
static normal =
  Line.look
    { normal = normal
    , emphasized = Line.style 1 identity
    , isEmphasized = always False
    }


{-| -}
emphasizable : Style -> Style -> (List data -> Bool) -> Look data
emphasizable normal emphasized isEmphasized =
  Line.look
    { normal = normal
    , emphasized = emphasized
    , isEmphasized = isEmphasized
    }


{-| -}
hasMaybe : Maybe data -> List data -> Bool
hasMaybe hovering data =
  case hovering of
    Just hovering ->
      List.member hovering data

    Nothing ->
      False
