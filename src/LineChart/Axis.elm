module LineChart.Axis exposing (Config, default, full, time, custom)

{-|

# Quick start
@docs default, full, time

# Customizing
@docs Config, custom

-}


import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Ticks as Ticks
import Internal.Axis as Axis
import Internal.Axis.Title as Title



{-|

** Customize a dimension **

  - **title**: Adds a title on your axis.
    See `LineChart.Axis.Title` for more information and examples.

  - **variable**: Determines what data is drawn in the chart!

  - **pixels**: The length of the dimension.

  - **range**: Determines the range of your dimension.
    See `LineChart.Axis.Range` for more information and examples.

  - **axis**: Customizes your axis line and ticks.
    See `LineChart.Axis` for more information and examples.


    xDimension : Dimension Info msg
    xDimension =
      { title = Title.default "Age (years)"
      , variable = .age
      , pixels = 700
      , range = Range.default
      , axis = Axis.float 10
      }
-}
type alias Config data msg =
  Axis.Config data msg


{-| -}
type alias Properties data msg =
  { title : Title.Title msg
  , variable : data -> Maybe Float
  , pixels : Int
  , range : Range.Range
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config data msg
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
default : Int -> String -> (data -> Float) -> Config data msg
default =
  Axis.default


{-| -}
full : Int -> String -> (data -> Float) -> Config data msg
full =
  Axis.full


{-| -}
time : Int -> String -> (data -> Float) -> Config data msg
time =
  Axis.time


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Axis.custom
