module Internal.Area
  exposing
    ( Area(..), none, percentage, normal, stacked
    , hasArea, singleOpacity, containerOpacity
    )

{-| -}


{-| TODO Use maybe instead of none -}
type Area
  = None
  | Normal Float
  | Stacked Float
  | Percentage Float


{-| -}
none : Area
none =
  None


{-| -}
normal : Float -> Area
normal =
  Normal


{-| -}
stacked : Float -> Area
stacked =
  Stacked


{-| -}
percentage : Float -> Area
percentage =
  Percentage



-- INTERNAL


{-| -}
hasArea : Area -> Bool
hasArea area =
  case area of
    None         -> False
    Normal _     -> True
    Stacked _    -> True
    Percentage _ -> True


{-| -}
singleOpacity : Area -> Float
singleOpacity area =
  case area of
    None               -> 0
    Normal opacity     -> opacity
    Stacked opacity    -> 1
    Percentage opacity -> 1


{-| -}
containerOpacity : Area -> Float
containerOpacity area =
  case area of
    None               -> 1
    Normal opacity     -> 1
    Stacked opacity    -> opacity
    Percentage opacity -> opacity
