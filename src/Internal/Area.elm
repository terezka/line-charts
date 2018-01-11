module Internal.Area exposing (Area(..), none, full, normal, stacked, hasArea, opacity)

{-| -}


{-| TODO Use maybe instead of none -}
type Area
  = None
  | Normal Float
  | Stacked
  | Full


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
full : Area
full =
  Full



-- INTERNAL


{-| -}
hasArea : Area -> Bool
hasArea area =
  case area of
    None     -> False
    Normal _ -> True
    Stacked  -> True
    Full     -> True


{-| -}
opacity : Area -> Float
opacity area =
  case area of
    None           -> 0
    Normal opacity -> opacity
    Stacked        -> 1
    Full           -> 1
