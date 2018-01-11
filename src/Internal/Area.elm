module Internal.Area exposing (Area(..), none, percentage, normal, stacked, hasArea, opacity)

{-| -}


{-| TODO Use maybe instead of none -}
type Area
  = None
  | Normal Float
  | Stacked
  | Percentage


{-| -}
none : Area
none =
  None


{-| -}
normal : Float -> Area
normal =
  Normal


{-| -}
stacked : Area
stacked =
  Stacked


{-| -}
percentage : Area
percentage =
  Percentage



-- INTERNAL


{-| -}
hasArea : Area -> Bool
hasArea area =
  case area of
    None     -> False
    Normal _ -> True
    Stacked  -> True
    Percentage     -> True


{-| -}
opacity : Area -> Float
opacity area =
  case area of
    None           -> 0
    Normal opacity -> opacity
    Stacked        -> 1
    Percentage           -> 1
