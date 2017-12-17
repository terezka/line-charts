module Lines.Axis exposing
  ( Axis, axis, axisTime, axisCustom
  , look, lookCustom, lookVeryCustom
  , title, titleCustom
  , mark, markCustom
  , line, lineCustom
  , tick, tickCustom
  , positive, negative
  , towardsZero
  )

{-|

# Configuration
@docs Axis, axis, axisTime, axisCustom
@docs look, lookCustom, lookVeryCustom
@docs title, titleCustom
@docs mark, markCustom
@docs line, lineCustom
@docs tick, tickCustom
@docs positive, negative
@docs towardsZero


-}

import Svg exposing (..)
import Lines.Coordinate as Coordinate
import Lines.Axis.Mark as Mark
import Lines.Axis.Mark.Time as Time
import Internal.Axis as Axis
import Internal.Utils as Utils


{-| -}
type alias Axis data msg =
  Axis.Axis data msg


{-| The axis configuration:

  - The `variable` is a the function which extract a value from your data.
  - The `limitations` are two functions which limit the range of your axis.
    Check out the `Limitations` type for more information.
  - The `look` is visual configurations. Check out the `Look` type for more
    information.


    xAxisConfig : Axis Info msg
    xAxisConfig = -- TODO
      Axis.axis
        { variable = .age
        , limitations = Axis.Float.Limitations (always 0) (always 100)
        , look = Axis.Float.defaultLook (Axis.Float.defaultTitle "Age" 0 0)
        }

See full example [here](TODO)

-}
axis : Float -> (data -> Float) -> String -> Axis data msg
axis length variable title =
  { variable = variable
  , limits = identity
  , look = look title (List.map mark << Mark.defaultInterval length)
  , length = length
  }



{-| -}
axisTime : Float -> (data -> Float) -> String -> Axis data msg
axisTime length variable title =
  { variable = variable
  , limits = identity
  , look = look title (Time.default length)
  , length = length
  }


{-| -}
axisCustom : Float -> (data -> Float) -> (Coordinate.Limits -> Coordinate.Limits) -> Axis.Look msg -> Axis data msg
axisCustom length variable limits look =
  { variable = variable
  , limits = limits
  , look = look
  , length = length
  }


{-| The visual configuration.

  - The `title` is the label that will show up by your axis.
    See the `Title` type for more information.
  - The `position` determines where on the axis intersects with the opposing
    axis, given the limits of your opposing axis.
  - The `offset` is the offset _perpendicular_ to the axis's direction. This means
    that if your dealing with a x-axis then the offset moves it down, and if
    your dealing with a y-axis then the offset moves it to the left.
  - The `line` is the configuration of the axis line, given the limits of your
    axis. If you don't want a line, set it to `Nothing`.
    See the `Line` type for more information.
  - The `marks` are the ticks and labels of your axis, given the limits of
    your your axis.
    See the `Mark` type for more information.
  - The `direction` determines what directions your ticks and labels point.
    Options are `Negative` and `Positive`.

TODO example
-}
look : String -> (Coordinate.Limits -> List (Axis.Mark msg)) -> Axis.Look msg
look title_ marks =
  { title = title title_ .max 0 0
  , position = towardsZero
  , offset = 0
  , line = Just line
  , marks = marks
  , direction = negative
  }


{-| -}
lookCustom :
  { title : Axis.Title msg
  , position : Coordinate.Limits -> Float
  , line : Maybe (Coordinate.Limits -> Axis.Line msg)
  , marks : Coordinate.Limits -> List (Axis.Mark msg)
  }
  -> Axis.Look msg
lookCustom { title, position, line, marks} =
  { title = title
  , position = position
  , offset = 0
  , line = line
  , marks = marks
  , direction = negative
  }


{-| -}
lookVeryCustom :
  { title : Axis.Title msg
  , position : Coordinate.Limits -> Float
  , offset : Float
  , line : Maybe (Coordinate.Limits -> Axis.Line msg)
  , marks : Coordinate.Limits -> List (Axis.Mark msg)
  , direction : Axis.Direction
  }
  -> Axis.Look msg
lookVeryCustom look =
  look


{-| The title is the label of your axis.

  - The `position` determines where the title will be on your axis, given
    the limits of your axis.
  - The `view` is the SVG you'd like to show as your title.
  - The `xOffset` moves your title horizontally.
  - The `yOffset` moves your title vertically.

TODO example
-}
title : String -> (Coordinate.Limits -> Float) -> Float -> Float -> Axis.Title msg
title title =
  Axis.Title (Axis.defaultTitle title)


{-| -}
titleCustom : Svg msg -> (Coordinate.Limits -> Float) -> Float -> Float -> Axis.Title msg
titleCustom =
  Axis.Title


{-| Produces a mark (a tick, a label, or both) on your axis.

    aMark : Float -> Mark msg
    aMark position =
      { label = Just (Axis.defaultLabel position)
      , tick = Just Axis.defaultTick
      , position = position
      }

To produce a list of marks, you can use the interval helpers, like this:

    marks : Coordinate.Limits -> List (Mark msg)
    marks =
      List.map aMark << Axis.defaultInterval

To learn more about intervals, see `defaultInterval` and `customInterval`.
You can also produce your own irregular intervals like this:

    marks : Coordinate.Limits -> List (Mark msg)
    marks _ =
      List.map aMark [ 0, 3, 4, 7 ]


TODO example
-}
mark : Float -> Axis.Mark msg
mark position =
  { label = Just (Axis.defaultLabel position)
  , tick = Just tick
  , position = position
  }


{-| -}
markCustom : Maybe (Svg msg) -> Maybe (Axis.Tick msg) -> Float -> Axis.Mark msg
markCustom label tick position =
  { label = label
  , tick = tick
  , position = position
  }


{-| Produces the axis line.

    axisLine : Coordinate.Limits -> Line msg
    axisLine { min, max } =
      { attributes = [ Attributes.stroke Color.black ]
      , start = min
      , end = 10
      }

-}
line : Coordinate.Limits -> Axis.Line msg
line limits =
  { attributes = []
  , start = limits.min
  , end = limits.max
  }


{-| -}
lineCustom : List (Attribute msg) -> Coordinate.Limits -> Axis.Line msg
lineCustom attributes limits =
  { attributes = attributes
  , start = limits.min
  , end = limits.max
  }


{-| Produces a tick.

    tick : Tick msg
    tick =
      { attributes = [ Attributes.stroke Color.black ]
      , length = 7
      }

-}
tick : Axis.Tick msg
tick =
  { attributes = []
  , length = 5
  }


{-| TODO int to float -}
tickCustom : List (Attribute msg) -> Int -> Axis.Tick msg
tickCustom =
  Axis.Tick



-- DIRECTIONS


{-| -}
positive : Axis.Direction
positive =
  Axis.Positive


{-| -}
negative : Axis.Direction
negative =
  Axis.Negative



-- HELP


{-| Produces zero if zero is within your limits, else the value closest to zero.
-}
towardsZero : Coordinate.Limits -> Float
towardsZero =
  Utils.towardsZero
