module Lines.Dimension exposing (Dimension, default)

{-|

# Quick start
@docs default

# Customizing
@docs Dimension

-}


import Lines.Axis.Title as Title
import Lines.Axis.Range as Range
import Lines.Axis as Axis
import Lines.Axis.Line as AxisLine
import Lines.Axis.Tick as Tick
import Lines.Axis.Values as Values
import Internal.Coordinate as Coordinate


{-|

** Customize a dimension **

  - **title**: Adds a title on your axis.
    See `Lines.Axis.Title` for more information and examples.

  - **variable**: Determines what data is drawn in the chart!

  - **pixels**: The length of the dimension.

  - **range**: Determines the range of your dimension.
    See `Lines.Axis.Range` for more information and examples.

  - **axis**: Customizes your axis line and ticks.
    See `Lines.Axis` for more information and examples.


    xDimension : Dimension Info msg
    xDimension =
      { title = Title.default "Age (years)"
      , variable = .age
      , pixels = 700
      , range = Range.default
      , axis = Axis.float 10
      }
-}
type alias Dimension data msg =
  { title : Title.Title msg
  , variable : data -> Float
  , pixels : Int
  , range : Range.Range
  , axis : Axis.Axis data msg
  }


{-|

** Customize a dimension lightly **

Takes the length of your dimension, the title and it's variable.

      chartConfig : Config data msg
      chartConfig =
        { id = "chart"
        , ...
        , x = Dimension.default 650 "Age (years)" .age
        , y = Dimension.default 400 "Weight (kg)" .weight
        , ...
        }

        -- Try changing the length or the title!


_See the full example [here](https://ellie-app.com/smkVxrpMfa1/2)._

-}
default : Int -> String -> (data -> Float) -> Dimension data msg
default pixels title variable =
  { title = Title.default title
  , variable = variable
  , pixels = pixels
  , range = Range.default
  , axis =
      Axis.custom AxisLine.rangeFrame <| \data range ->
        let smallest = Coordinate.smallestRange data range
            rangeLong = range.max - range.min
            rangeSmall = smallest.max - smallest.min
            diff = 1 - (rangeLong - rangeSmall) / rangeLong
            amount = round <| diff * toFloat pixels / 90
        in
        List.map Tick.float <| Values.float (Values.around amount) smallest
  }
