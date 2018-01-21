module Lines.Area exposing (Config, none, percentage, normal, stacked)

{-| -}

import Internal.Area as Area


{-| -}
type alias Config =
  Area.Config


{-| No color below your lines.
-}
none : Config
none =
  Area.none


{-| Color the area below your lines. The color is always the color of
your line, but you can pass the opacity.
-}
normal : Float -> Config
normal =
  Area.normal


{-| Stacks your values and colors the area in the line color. The color is
always the color of your line, but you can pass the opacity.

**Warning: Right now, this only works if all your lines have the
same set of x values! If not, the area will not add properly.**
-}
stacked : Float -> Config
stacked =
  Area.stacked


{-| Same as stacked, but the areas takes up the whole graph and your values
are made into percentages. The color is always the color of your line, but
you can pass the opacity.

**Warning: Right now, this only works if all your lines have the
same set of x values! If not, the area will not add properly.**
-}
percentage : Float -> Config
percentage =
  Area.percentage
