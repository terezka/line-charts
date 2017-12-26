module Lines.Axis exposing
  ( Axis, axis, axisTime, axisCustom, axisVeryCustom
  , Look, look, lookCustom, lookVeryCustom
  , Title, title, titleCustom
  , Mark, marks, mark, markCustom, values, valuesExact, interval
  , Line, line, lineCustom
  , Tick, tick, tickCustom
  , Direction, positive, negative
  , towardsZero
  )

{-|

# Configuration
@docs Axis, axis, axisTime, axisCustom, axisVeryCustom
@docs Look, look, lookCustom, lookVeryCustom
@docs Title, title, titleCustom
@docs Mark, marks, mark, markCustom, values, valuesExact, interval
@docs Line, line, lineCustom
@docs Tick, tick, tickCustom
@docs Direction, positive, negative
@docs towardsZero


-}

import Svg exposing (..)
import Lines.Coordinate as Coordinate
import Lines.Axis.Time as Time
import Internal.Axis as Axis
import Internal.Utils as Utils


{-| -}
type alias Axis data msg =
  Axis.Axis data msg


{-| -}
type alias Look msg =
  Axis.Look msg


{-| -}
type alias Title msg =
  Axis.Title msg


{-| -}
type alias Line msg =
  Axis.Line msg


{-| -}
type alias Mark msg =
  Axis.Mark msg


{-| -}
type alias Tick msg =
  Axis.Tick msg


{-| -}
type alias Direction =
  Axis.Direction



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
axis =
  Axis.axis


{-| -}
axisTime : Float -> (data -> Float) -> String -> Axis data msg
axisTime length variable title =
  let amount = round (length / 170) in
  { variable = variable
  , range = identity
  , look = look title (Time.marks Time.mark amount) -- TODO
  , length = length
  }


{-| -}
axisCustom : Float -> (data -> Float) -> Look msg -> Axis data msg
axisCustom length variable look =
  Axis.axisCustom length variable identity look


{-| -}
axisVeryCustom :
  { length : Float
  , variable : data -> Float
  , range : Coordinate.Range -> Coordinate.Range
  , look : Look msg
  }
  -> Axis data msg
axisVeryCustom { length, variable, range, look } =
  Axis.axisCustom length variable range look


{-| The visual configuration.

  - The `title` is the label that will show up by your axis.
    See the `Title` type for more information.
  - The `position` determines where on the axis intersects with the opposing
    axis, given the range of your opposing axis.
  - The `offset` is the offset _perpendicular_ to the axis's direction. This means
    that if your dealing with a x-axis then the offset moves it down, and if
    your dealing with a y-axis then the offset moves it to the left.
  - The `line` is the configuration of the axis line, given the range of your
    axis. If you don't want a line, set it to `Nothing`.
    See the `Line` type for more information.
  - The `marks` are the ticks and labels of your axis, given the range of
    your your axis.
    See the `Mark` type for more information.
  - The `direction` determines what directions your ticks and labels point.
    Options are `Negative` and `Positive`.

TODO example
-}
look : String -> (Coordinate.Range -> List (Mark msg)) -> Look msg
look =
  Axis.look


{-| -}
lookCustom :
  { title : Axis.Title msg
  , position : Coordinate.Range -> Float
  , line : Maybe (Coordinate.Range -> Line msg)
  , marks : Coordinate.Range -> List (Mark msg)
  }
  -> Axis.Look msg
lookCustom =
  Axis.lookCustom


{-| -}
lookVeryCustom :
  { title : Axis.Title msg
  , position : Coordinate.Range -> Float
  , offset : Float
  , line : Maybe (Coordinate.Range -> Line msg)
  , marks : Coordinate.Range -> List (Mark msg)
  , direction : Direction
  }
  -> Look msg
lookVeryCustom =
  Axis.lookVeryCustom


{-| The title is the label of your axis.

  - The `position` determines where the title will be on your axis, given
    the range of your axis.
  - The `view` is the SVG you'd like to show as your title.
  - The `xOffset` moves your title horizontally.
  - The `yOffset` moves your title vertically.

TODO example
-}
title : String -> (Coordinate.Range -> Float) -> Float -> Float -> Title msg
title =
  Axis.title


{-| -}
titleCustom : Svg msg -> (Coordinate.Range -> Float) -> Float -> Float -> Title msg
titleCustom =
  Axis.titleCustom


{-| -}
marks : (Float -> Mark msg) -> (Coordinate.Range -> List Float) -> Coordinate.Range -> List (Mark msg)
marks mark interval =
  List.map mark << interval


{-| -}
mark : Float -> Mark msg
mark =
  Axis.mark


{-| -}
markCustom : Maybe (Svg msg) -> Maybe (Tick msg) -> Float -> Mark msg
markCustom =
  Axis.markCustom


{-| Produces a list of evenly spaced numbers given the range of your axis.
-}
values : Int -> Coordinate.Range -> List Float
values =
  Axis.values False


{-| Produces a list of evenly spaced numbers given the range of your axis.
-}
valuesExact : Int -> Coordinate.Range -> List Float
valuesExact =
  Axis.values True


{-| Produces a list of evenly spaced numbers given an offset, and interval, and
the range of your axis.

The offset is useful when you want two sets of ticks with different views. For
example, if you want a long tick at every 2 x and a small tick at every 2 x + 1,
you'd use

    firstInterval : Coordinate.Range -> List Float
    firstInterval =
      Axis.customInterval 0 2

    secondInterval : Coordinate.Range -> List Float
    secondInterval =
      Axis.customInterval 1 2

-}
interval : Float -> Float -> Coordinate.Range -> List Float
interval =
  Axis.interval


{-| Produces the axis line.

    axisLine : Coordinate.Range -> Line msg
    axisLine { min, max } =
      { attributes = [ Attributes.stroke Color.black ]
      , start = min
      , end = 10
      }

-}
line : Coordinate.Range -> Line msg
line =
  Axis.line


{-| -}
lineCustom : List (Attribute msg) -> Coordinate.Range -> Line msg
lineCustom =
  Axis.lineCustom


{-| Produces a tick.

    tick : Tick msg
    tick =
      { attributes = [ Attributes.stroke Color.black ]
      , length = 7
      }

-}
tick : Tick msg
tick =
  Axis.tick


{-| TODO int to float -}
tickCustom : List (Attribute msg) -> Int -> Tick msg
tickCustom =
  Axis.tickCustom



-- DIRECTIONS


{-| -}
positive : Direction
positive =
  Axis.Positive


{-| -}
negative : Direction
negative =
  Axis.Negative



-- HELP


{-| Produces zero if zero is within your range, else the value closest to zero.
-}
towardsZero : Coordinate.Range -> Float
towardsZero =
  Utils.towardsZero
