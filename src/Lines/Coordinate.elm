module Lines.Coordinate exposing
  ( Frame, Size, Margin
  , System, Range
  , Point, toSVG, toData
  , toSVGX, toSVGY
  , toDataX, toDataY
  , scaleSVGX, scaleSVGY
  , scaleDataX, scaleDataY
  )

{-|

# Frame
@docs Frame, Size, Margin

# System
@docs System, Range

# Translation

## Point
@docs Point, toSVG, toData

## Single value
@docs toSVGX, toSVGY, toDataX, toDataY

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

    dataPoint : Point
    dataPoint =
      Point 2 3

    dataXinSVG : Float
    dataXinSVG =
      toSVGX system dataPoint.x    -- 30 (margin.left + 2 * 100 / 10)

    dataXinSVG : Float
    dataXinSVG =
      scaleSVGX system dataPoint.x -- 20 (2 * 100 / 10)

@docs scaleSVGX, scaleSVGY, scaleDataX, scaleDataY

-}

import Internal.Coordinate exposing (..)


{-| Specifies the size and margins of your chart.
-}
type alias Frame =
  { margin : Margin
  , size : Size
  }


{-| The size (px) of your chart.
-}
type alias Size =
  { width : Float
  , height : Float
  }


{-| The margins (px) of your chart. Margins are useful when you have stuff like
axes, legends or titles around outside the actual lines and you want more or
less space for them.
-}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }



-- SYSTEM


{-| The system holds informations about the dimensions of your chart.

  - The `frame` which is information about the size and margins of your chart.
  - The `x` which is the minimum and maximum of your range.
  - The `y` which is the minimum and maximum of your domain.

This is all the information we need for translating your data coordinates into
SVG coordinates.
-}
type alias System =
  { frame : Frame
  , x : Range
  , y : Range
  , xData : Range
  , yData : Range
  , id : String
  }


{-| These are minimum and maximum values of a dimension.
-}
type alias Range =
  { min : Float
  , max : Float
  }



-- TRANSLATION


{-| Translate a x-coordinate from cartesian to SVG.
-}
toSVGX : System -> Float -> Float
toSVGX system value =
  scaleSVGX system (value - system.x.min) + system.frame.margin.left


{-| Translate a y-coordinate from cartesian to SVG.
-}
toSVGY : System -> Float -> Float
toSVGY system value =
  scaleSVGY system (system.y.max - value) + system.frame.margin.top


{-| Translate a x-coordinate from SVG to cartesian.
-}
toDataX : System -> Float -> Float
toDataX system value =
  system.x.min + scaleDataX system (value - system.frame.margin.left)


{-| Translate a y-coordinate from SVG to cartesian.
-}
toDataY : System -> Float -> Float
toDataY system value =
  system.y.max - scaleDataY system (value - system.frame.margin.top)



-- Scaling


{-| Scale a x-value from cartesian to SVG.
-}
scaleSVGX : System -> Float -> Float
scaleSVGX system value =
  value * (lengthX system) / (reachX system)


{-| Scale a y-value from cartesian to SVG.
-}
scaleSVGY : System -> Float -> Float
scaleSVGY system value =
  value * (lengthY system) / (reachY system)


{-| Scale a x-value from SVG to cartesian.
-}
scaleDataX : System -> Float -> Float
scaleDataX system value =
  value * (reachX system) / (lengthX system)


{-| Scale a y-value from SVG to cartesian.
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


{-| Translates a data point to a SVG point.
-}
toSVG : System -> Point -> Point
toSVG system point =
  { x = toSVGX system point.x
  , y = toSVGY system point.y
  }


{-| Translates a SVG point to a data point.
-}
toData : System -> Point -> Point
toData system point =
  { x = toDataX system point.x
  , y = toDataY system point.y
  }
