module Lines.Line exposing
  ( Look, default, custom, Style )

{-| # Line

-}

import Lines.Color as Color


-- CONFIG


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
