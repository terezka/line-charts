module LineChart.Axis exposing (Config, default, full, time, custom, none, picky)

{-|

_If you're confused as to what "axis range" and "data range" means,
check out `Axis.Range` for an explanation!_

@docs Config, default, full, time, none, picky, custom

-}


import Internal.Axis as Axis
import Internal.Axis.Title as Title
import LineChart.Axis.Range as Range
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Ticks as Ticks
import Time



{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config data msg
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

    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.default 650 "Age (years)" .age


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example1.elm)._

-}
default : Int -> String -> (data -> Float) -> Config data msg
default =
  Axis.default


{-| Draws a line the full length of your _axis range_ and adds some nice ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.full 650 "Age (years)" .age


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example2.elm)._

-}
full : Int -> String -> (data -> Float) -> Config data msg
full =
  Axis.full


{-| Draws a line the full length of your _data range_ and adds some nice datetime ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.time 650 "Date" .date


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example3.elm)._

-}
time : Time.Zone ->Int -> String -> (data -> Float) -> Config data msg
time =
  Axis.time


{-| Draws the full length of your axis range and adds some ticks at the positions
specified in the last argument.

Pass the length of your axis in pixels, the title, it's variable and the
numbers where you'd like ticks to show up.


    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.picky 650 "Age (years)" .age [ 4, 25, 46 ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example4.elm)._

**Note:** This is of course not the only way for you to decide exactly where the
ticks should go on the axis! If you need to customize ticks further, check out
the `ticks` property in `Axis.custom`.

-}
picky : Int -> String -> (data -> Float) -> List Float -> Config data msg
picky =
  Axis.picky


{-| Doesn't draw the axis at all.

Pass the length of your axis in pixels and it's variable.


    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.none 650 .age


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example5.elm)._

-}
none : Int -> (data -> Float) -> Config data msg
none =
  Axis.none


{-|

Properties:

  - **title**: Adds a title on your axis. </br>
    _See `LineChart.Axis.Title` for more information and examples._
  - **variable**: Determines what data is drawn in the chart! </br>
  - **pixels**: The length of the dimension.
  - **range**: Determines the axis range. </br>
    _See `LineChart.Axis.Range` for more information and examples._
  - **axisLine**: Customizes your axis line. </br>
    _See `LineChart.Axis.Line` for more information and examples._
  - **ticks**: Customizes your ticks. </br>
    _See `LineChart.Axis.Ticks` for more information and examples._


    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.custom
        { title = Title.default "Year"
        , variable = Just << .date
        , pixels = 700
        , range = Range.padded 20 20
        , axisLine = AxisLine.full Colors.black
        , ticks = Ticks.time 5
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example8.elm)._

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
