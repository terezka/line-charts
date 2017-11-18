module Lines.Line exposing
  ( Look, default, custom, Style, hasMaybe, normal )

{-| # Line

-}

import Lines.Color as Color


-- CONFIG


normal : Int -> Look data
normal width =
  { normal = Style width identity
  , emphasized = Style width identity
  , isEmphasized = always False
  }


{-| -}
type alias Look data =
  { normal : Style
  , emphasized : Style
  , isEmphasized : List data -> Bool
  }


type alias Style =
  { width : Int -- TODO Float
  , color : Color.Color -> Color.Color
  }


default : Look data
default =
  { normal = Style 1 identity
  , emphasized = Style 2 identity
  , isEmphasized = always False
  }


custom : Style -> Look data
custom style =
  { normal = style
  , emphasized = Style 2 identity
  , isEmphasized = always False
  }


hasMaybe : Maybe data -> List data -> Bool
hasMaybe hovering data =
  case hovering of
    Just hovering ->
      List.member hovering data

    Nothing ->
      False
