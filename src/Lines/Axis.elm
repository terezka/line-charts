module Lines.Axis exposing
  ( default, defaultForDates
  , Axis, Limitations, Look, Line, Mark, Tick, Direction(..)
  , defaultLook
  , towardsZero
  , defaultLine
  , defaultTitle
  , defaultMark, defaultInterval, customInterval
  , defaultTick, defaultLabel
  )

{-|

# Quick start
@docs default, defaultTitle, defaultForDates

# Configuration
@docs Axis, Limitations

# Look
@docs Look, defaultLook

## Axis line
@docs Line, defaultLine

## Ticks and labels
@docs Mark, defaultMark, defaultLabel, Tick, defaultTick, Direction

## Intervals
@docs defaultInterval, customInterval

## Helpers
@docs towardsZero

-}

import Svg exposing (..)
import Svg.Attributes as Attributes
import Date
import Date.Format
import Lines.Coordinate as Coordinate
import Lines.Color as Color
import Internal.Numbers as Numbers
import Internal.DateTime.Unit as Unit
import Internal.Utils as Utils



{-| The axis configuration:

  - The `variable` is a the function which extract a value from your data.
  - The `limitations` are two functions which limit the range of your axis.
    Check out the `Limitations` type for more information.
  - The `look` is visual configurations. Check out the `Look` type for more
    information.


    xAxisConfig : Axis Info msg
    xAxisConfig =
      { variable = .age
      , limitations = Axis.Limitations (always 0) (always 100)
      , look = Axis.defaultLook (Axis.defaultTitle "Age" 0 0)
      }

See full example [here](TODO)

-}
type alias Axis data msg =
  { variable : data -> Float
  , limitations : Limitations
  , look : Look msg
  }


{-| Limits the range of your axis, given the minimum and maximum of your values.

Imagine you have a data set where the lowest value is 4 and the highest is 12.
Now, normally that would make your axis start at 4 and end at 12, but if you'd
like it go from 0 to 12, you could add the folloring limitations to your
axis configuration:

    xAxisConfig : Axis Info msg
    xAxisConfig =
      { variable = .age
      , limitations =
          { min = always 0  -- Axis always starts at 0
          , max = always 15 -- Axis always ends at 15
          }
      , look = Axis.defaultLook (Axis.defaultTitle "Age" 0 0)
      }

See full example [here](TODO)

-}
type alias Limitations =
  { min : Float -> Float
  , max : Float -> Float
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
type alias Look msg =
  { title : Title msg
  , position : Coordinate.Limits -> Float
  , offset : Float
  , line : Maybe (Coordinate.Limits -> Line msg)
  , marks : Coordinate.Limits -> List (Mark msg)
  , direction : Direction
  }


{-| The title is the label of your axis.

  - The `position` determines where the title will be on your axis, given
    the limits of your axis.
  - The `view` is the SVG you'd like to show as your title.
  - The `xOffset` moves your title horizontally.
  - The `yOffset` moves your title vertically.

TODO example
-}
type alias Title msg =
    { position : Coordinate.Limits -> Float
    , view : Svg msg
    , xOffset : Float
    , yOffset : Float
    }


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
type alias Mark msg =
  { position : Float
  , label : Maybe (Svg msg)
  , tick : Maybe (Tick msg)
  }


{-| Produces the axis line.

    axisLine : Coordinate.Limits -> Line msg
    axisLine { min, max } =
      { attributes = [ Attributes.stroke Color.black ]
      , start = min
      , end = 10
      }

-}
type alias Line msg =
  { attributes : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| Produces a tick.

    tick : Tick msg
    tick =
      { attributes = [ Attributes.stroke Color.black ]
      , length = 7
      }

-}
type alias Tick msg =
  { attributes : List (Attribute msg)
  , length : Int
  }


{-| -}
type Direction
  = Negative
  | Positive



-- DEFAULTS


{-| The default axis configuration.

  - First argument is a `Title`, which you don't have to bother too
    much to figure out if you just use `defaultTitle`.
  - Second argument is the axis variable. This is a fuction to extract
    a value from your data.


    axis : Axis data msg
    axis =
      Axis.default (Axis.defaultTitle "Age" 0 0) .age
-}
default : Title msg -> (data -> Float) -> Axis data msg
default title variable =
  { variable = variable
  , limitations = Limitations identity identity
  , look = defaultLook title
  }


{-| -}
defaultForDates : Title msg -> (data -> Float) -> Axis data msg
defaultForDates title variable =
  let
    look =
      defaultLook title
  in
  { variable = variable
  , limitations = Limitations identity identity
  , look = { look | marks = List.map defaultDateMark << Unit.interval 5 }
  }


{-| The default title configuration.

  - First argument is the title you'd like to see on your axis.
  - Second and third argument are the x and y offsets respectively of your
    title in SVG space. Use this when you want to move your title around
    slightly.


    title : Title msg
    title =
      Axis.defaultTitle "Age" 0 0
-}
defaultTitle : String -> Float -> Float -> Title msg
defaultTitle title xOffset yOffset =
  Title .max (text_ [] [ tspan [] [ text title ] ]) 0 0


{-| The default look configuration is the following.

    defaultLook : Title msg -> Look msg
    defaultLook title =
      { title = title
      , offset = 20
      , position = Axis.towardsZero
      , line = Just (Axis.defaultLine [ Attributes.stroke Color.gray ])
      , marks = List.map Axis.defaultMark << Axis.defaultInterval
      , direction = Negative
      }

I recommend you copy the snippet into your code and mess around with it for a
but or check out the examples [here](TODO)

-}
defaultLook : Title msg -> Look msg
defaultLook title =
  { title = title
  , offset = 20
  , position = towardsZero
  , line = Just (defaultLine [ Attributes.stroke Color.gray ])
  , marks = List.map defaultMark << defaultInterval
  , direction = Negative
  }


{-| The default mark configuration is the following.

    defaultMark : Float -> Mark msg
    defaultMark position =
      { position = position
      , label = Just (defaultLabel position)
      , tick = Just defaultTick
      }
-}
defaultMark : Float -> Mark msg
defaultMark position =
  { position = position
  , label = Just (defaultLabel position)
  , tick = Just defaultTick
  }


defaultDateMark : Float -> Mark msg
defaultDateMark position =
  let
    date =
      Date.fromTime position

    label =
      Date.Format.format "%H:%M" date

    viewLabel =
      text_ [] [ tspan [] [ text label ] ]
  in
  { position = position
  , label = Just viewLabel
  , tick = Just defaultTick
  }


{-| The default tick configuration is the following.

    defaultTick : Tick msg
    defaultTick =
      { length = 5
      , attributes = [ Attributes.stroke Color.gray ]
      }
-}
defaultTick : Tick msg
defaultTick =
  { length = 5
  , attributes = [ Attributes.stroke Color.gray ]
  }


{-| The default label configuration is the following.

    defaultLabel : Float -> Svg msg
    defaultLabel position =
      text_ [] [ tspan [] [ text (toString position) ] ]
-}
defaultLabel : Float -> Svg msg
defaultLabel position =
  text_ [] [ tspan [] [ text (toString position) ] ]


{-| The default line configuration is the following.

    defaultLine : List (Attribute msg) -> Coordinate.Limits -> Line msg
    defaultLine attributes limits =
        { attributes = Attributes.style "pointer-events: none;" :: attributes
        , start = limits.min
        , end = limits.max
        }
-}
defaultLine : List (Attribute msg) -> Coordinate.Limits -> Line msg
defaultLine attributes limits =
    { attributes = Attributes.style "pointer-events: none;" :: attributes
    , start = limits.min
    , end = limits.max
    }



-- INTERVALS


{-| Produces a list of evenly spaced numbers given the limits of your axis.
-}
defaultInterval : Coordinate.Limits -> List Float
defaultInterval =
  Numbers.defaultInterval


{-| Produces a list of evenly spaced numbers given an offset, and interval, and
the limits of your axis.

The offset is useful when you want two sets of ticks with different views. For
example, if you want a long tick at every 2 x and a small tick at every 2 x + 1,
you'd use

    firstInterval : Coordinate.Limits -> List Float
    firstInterval =
      Axis.customInterval 0 2

    secondInterval : Coordinate.Limits -> List Float
    secondInterval =
      Axis.customInterval 1 2

-}
customInterval : Float -> Float -> Coordinate.Limits -> List Float
customInterval =
  Numbers.customInterval



-- HELPERS


{-| Produces zero if zero is within your limits, else the value closest to zero.
-}
towardsZero : Coordinate.Limits -> Float
towardsZero =
  Utils.towardsZero
