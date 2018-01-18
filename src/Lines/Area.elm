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


{-| Stacks your values and colors the area in the line color. The color is
always the color of your line, but you can pass the opacity.

**Warning: Right now, this only works if all your lines have the
same set of x values! If not, the area will not add properly.**
-}
stacked : Float -> Area
stacked =
  Area.stacked


{-| Same as stacked, but the areas takes up the whole graph and your values
are made into percentages. The color is always the color of your line, but
you can pass the opacity.

**Warning: Right now, this only works if all your lines have the
same set of x values! If not, the area will not add properly.**
-}
percentage : Float -> Area
percentage =
  Area.percentage
