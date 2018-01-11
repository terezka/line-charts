module Internal.Area exposing (Area(..), none, percentage, normal, stacked, hasArea, opacity)

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
opacity : Area -> Float
opacity area =
  case area of
    None               -> 0
    Normal opacity     -> opacity
    Stacked opacity    -> opacity
    Percentage opacity -> opacity
