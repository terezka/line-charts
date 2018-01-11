module Lines.Area exposing (Area, none, percentage, normal, stacked)

{-| -}

import Internal.Area as Area


{-| -}
type alias Area =
  Area.Area


{-| No color below your lines.
-}
none : Area
none =
  Area.none


{-| Color the area below your lines. The color is always the color of
your line, but you can pass the opacity.
-}
normal : Float -> Area
normal =
  Area.normal


{-| Stacks your values and colors the area in the line color.

**Important: Right now, this only works if all your lines have the
same set of x values!**
-}
stacked : Area
stacked =
  Area.stacked


{-| Same as stacked, but the areas takes up the whole graph and your values
are made into percentages.

**Important: Right now, this only works if all your lines have the
same set of x values!**

-}
percentage : Area
percentage =
  Area.percentage
