module Lines.Area exposing (Area, none, full, normal, stacked)

{-| -}

import Internal.Area as Area


{-| -}
type alias Area =
  Area.Area


{-| -}
none : Area
none =
  Area.none


{-| -}
normal : Float -> Area
normal =
  Area.normal


{-| -}
stacked : Area
stacked =
  Area.stacked


{-| -}
full : Area
full =
  Area.full
