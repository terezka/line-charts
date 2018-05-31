module LineChart.Coordinate exposing
  ( Frame, Size
  , System, Range
  , Point, toSvg, toData
  , toSvgX, toSvgY
  , toDataX, toDataY
  , scaleSvgX, scaleSvgY
  , scaleDataX, scaleDataY
  )

{-|

**Data-space and SVG-space**

Data-space is the regular cartesian coordinate system, the coordinate system you
probably learned about in school. The x axis goes horizontally and the numbers
grow larger as we progress to the right. The y axis goes vertically and the numbers
grow larger as we progress upwards.

SVG-space is different because here, the y axis numbers grow larger as we
progress _downwards_, and there coordinates are relative to the pixel height and
width of the chart, not your data.

<img alt="Space" width="610" src="https://github.com/terezka/line-charts/blob/master/images/space.png?raw=true"></src>

Since SVG only understand SVG-space coordinates, when we have data-space coordinates
we need to translate them in order the use them for drawing. For this we need some
info which I calculate for you and is stored in the `System` type. With the `System` we
can use the translating functions contained in this module.

Furthermore, the `System` holds your axis range minimum and maximum, as well as
that off your data range. This can be useful info when moving stuff in `Junk`!

**Note:** Most of the functions in `Junk` takes data-space coordinates, so it's
only when you do your own crazy junk in pure SVG that you have to worry about
this module!


# System

@docs System, Frame, Size, Range

# Translation

## Point
@docs Point, toSvg, toData

## Single value
@docs toSvgX, toSvgY, toDataX, toDataY

# Scaling

Scaling is different from translating in that it does not take a position as
it's input, but a _distance_. Translating a position takes the frame into
account, scaling doesn't.

    system : System
    system =
      { frame = Frame (Margin 10 10 10 10) (Size 100 100)
      , x = Range 0 10
      , y = Range 0 10
      }

    data : Point
    data =
      Point 2 3

    dataXinSvg : Float
    dataXinSvg =
      toSvgX system data.x    -- 30 (margin.left + 2 * 100 / 10)

    dataXinSvg : Float
    dataXinSvg =
      scaleSvgX system data.x -- 20 (2 * 100 / 10)

@docs scaleSvgX, scaleSvgY, scaleDataX, scaleDataY

-}

import Internal.Coordinate exposing (..)
import LineChart.Container as Container



{-| Specifies the size and margins of your chart.
-}
type alias Frame =
  { margin : Container.Margin
  , size : Size
  }


{-| The size (px) of your chart.
-}
type alias Size =
  { width : Float
  , height : Float
  }



-- SYSTEM


{-| The system holds informations about the dimensions of your chart.

  - **frame** is information about the size and margins of your chart.
  - **x** is the minimum and maximum of your axis range.
  - **y** is the minimum and maximum of your axis domain.
  - **xData** is the minimum and maximum of your data range.
  - **yData** is the minimum and maximum of your data domain.
  - **id** is the id of your chart.

This is all the information we need for translating your data coordinates into
SVG coordinates.

_If you're confused as to what "axis range" and "data range" means,
check out `Axis.Range` for an explanation!_

-}
type alias System =
    Internal.Coordinate.System


{-| These are minimum and maximum values that make up a range.
-}
type alias Range =
  { min : Float
  , max : Float
  }



-- TRANSLATION


{-| Translate a x-coordinate from data-space to SVG-space.
-}
toSvgX : System -> Float -> Float
toSvgX system value =
  scaleSvgX system (value - system.x.min) + system.frame.margin.left


{-| Translate a y-coordinate from data-space to SVG-space.
-}
toSvgY : System -> Float -> Float
toSvgY system value =
  scaleSvgY system (system.y.max - value) + system.frame.margin.top


{-| Translate a x-coordinate from SVG-space to data-space.
-}
toDataX : System -> Float -> Float
toDataX system value =
  system.x.min + scaleDataX system (value - system.frame.margin.left)


{-| Translate a y-coordinate from SVG-space to data-space.
-}
toDataY : System -> Float -> Float
toDataY system value =
  system.y.max - scaleDataY system (value - system.frame.margin.top)



-- Scaling


{-| Scale a x-value from data-space to SVG-space.
-}
scaleSvgX : System -> Float -> Float
scaleSvgX system value =
  value * (lengthX system) / (reachX system)


{-| Scale a y-value from data-space to SVG-space.
-}
scaleSvgY : System -> Float -> Float
scaleSvgY system value =
  value * (lengthY system) / (reachY system)


{-| Scale a x-value from SVG-space to data-space.
-}
scaleDataX : System -> Float -> Float
scaleDataX system value =
  value * (reachX system) / (lengthX system)


{-| Scale a y-value from SVG-space to data-space.
-}
scaleDataY : System -> Float -> Float
scaleDataY system value =
  value * (reachY system) / (lengthY system)



-- Points


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| Translates a data-space point to a SVG-space point.
-}
toSvg : System -> Point -> Point
toSvg system point =
  { x = toSvgX system point.x
  , y = toSvgY system point.y
  }


{-| Translates a SVG-space point to a data-space point.
-}
toData : System -> Point -> Point
toData system point =
  { x = toDataX system point.x
  , y = toDataY system point.y
  }
