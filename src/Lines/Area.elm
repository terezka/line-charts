module Lines.Area exposing (Area, none, percentage, normal, stacked)

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
percentage : Area
percentage =
  Area.percentage
