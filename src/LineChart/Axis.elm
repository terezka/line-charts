module LineChart.Axis exposing (Config, default, full, time, custom, none, quick)

{-|

** Axis range vs. data range?**

This module uses the words "axis range" and "data" range a bunch.
Check out `Axis.Range` for an explanation!

@docs Config, default, full, time, none, quick, custom

-}


import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Ticks as Ticks
import Internal.Axis as Axis
import Internal.Axis.Title as Title



{-| Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : Config data msg
    chartConfig =
      { ...
      , x = Axis.default 650 "Age (years)" .age
      , y = Axis.default 400 "Weight (kg)" .weight
      , ...
      }

-}
type alias Config data msg =
  Axis.Config data msg


{-| Draws a line the full length of your _data range_ and adds a little space on
both sides of that line. Also adds some nice ticks to it.

Pass the length of your axis in pixels, the title and it's variable.

    xAxisConfig : Config data msg
    xAxisConfig =
      Axis.default 650 "Age (years)" .age

    -- Try changing the length or the title!


_See the full example [here](https://ellie-app.com/smkVxrpMfa1/2)._

-}
default : Int -> String -> (data -> Float) -> Config data msg
default =
  Axis.default


{-| Draws a line the full length of your _axis range_ and adds some nice ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    axisConfig : AxisConfig Data msg
    axisConfig =
      Axis.full 650 "Age (years)" .age

-}
full : Int -> String -> (data -> Float) -> Config data msg
full =
  Axis.full


{-| Draws a line the full length of your _data range_ and adds some nice datetime ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    axisConfig : AxisConfig Data msg
    axisConfig =
      Axis.time 650 "Date" .date

-}
time : Int -> String -> (data -> Float) -> Config data msg
time =
  Axis.time


{-| Doesn't draw the axis at all.

Pass the length of your axis in pixels and it's variable.


    axisConfig : AxisConfig Data msg
    axisConfig =
      Axis.none 650 .age
-}
none : Int -> (data -> Float) -> Config data msg
none =
  Axis.none


{-| Draws the full length of your axis and adds some ticks at the positions
specified in the last argument.

Pass the length of your axis in pixels, the title, it's variable and the
numbers where you'd like ticks to show up.


    axisConfig : AxisConfig Data msg
    axisConfig =
      Axis.quick 650 "Age (years)" .age [ 10, 15, 25, 34 ]

-}
quick : Int -> String -> (data -> Float) -> List Float -> Config data msg
quick =
  Axis.quick


{-|

Properties:

  - **title**: Adds a title on your axis.
    See `LineChart.Axis.Title` for more information and examples.
  - **variable**: Determines what data is drawn in the chart!
  - **pixels**: The length of the dimension.
  - **range**: Determines the axis range.
    See `LineChart.Axis.Range` for more information and examples.
  - **axisLine**: Customizes your axis line.
    See `LineChart.Axis.Line` for more information and examples.
  - **ticks**: Customizes your ticks.
    See `LineChart.Axis.Ticks` for more information and examples.


    xAxis : Axis.Config Data msg
    xAxis =
      Axis.custom
        { title = Title.default "Age (years)"
        , variable = Just << .age
        , pixels = 700
        , range = Range.default
        , axisLine = AxisLine.full Color.black
        , ticks = Ticks.float 5
        }

_See full example [here](https://ellie-app.com/fb6BqXBmba1/1)._

-}
custom : Properties data msg -> Config data msg
custom =
  Axis.custom


{-| -}
type alias Properties data msg =
  { title : Title.Config msg
  , variable : data -> Maybe Float
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }
