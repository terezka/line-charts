module Lines.Coordinate exposing
  ( Frame, Size, Margin
  , System, Limits
  , toSVGX, toSVGY
  , toCartesianX, toCartesianY
  , scaleSVGX, scaleSVGY
  , scaleCartesianX, scaleCartesianY
  , Point, toSVGPoint, toCartesianPoint
  )

{-|

# Frame
@docs Frame, Size, Margin

# System
@docs System, Limits

## Single value
@docs toSVGX, toSVGY, toCartesianX, toCartesianY

## Point
@docs Point, toSVGPoint, toCartesianPoint

## Scale
@docs scaleSVGX, scaleSVGY, scaleCartesianX, scaleCartesianY

-}



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
  , x : Limits
  , y : Limits
  }


{-| These are minimum and maximum values of a dimension.
-}
type alias Limits =
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
toCartesianX : System -> Float -> Float
toCartesianX system value =
  system.x.min + scaleCartesianX system (value - system.frame.margin.left)


{-| Translate a y-coordinate from SVG to cartesian.
-}
toCartesianY : System -> Float -> Float
toCartesianY system value =
  system.y.max - scaleCartesianY system (value - system.frame.margin.top)



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
scaleCartesianX : System -> Float -> Float
scaleCartesianX system value =
  value * (reachX system) / (lengthX system)


{-| Scale a y-value from SVG to cartesian.
-}
scaleCartesianY : System -> Float -> Float
scaleCartesianY system value =
  value * (reachY system) / (lengthY system)



-- Points


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
toSVGPoint : System -> Point -> Point
toSVGPoint system point =
  { x = toSVGX system point.x
  , y = toSVGY system point.y
  }


{-| -}
toCartesianPoint : System -> Point -> Point
toCartesianPoint system point =
  { x = toCartesianX system point.x
  , y = toCartesianY system point.y
  }



-- INTERNAL


reachX : System -> Float
reachX system =
  let
    diff =
      system.x.max - system.x.min
  in
    if diff > 0 then diff else 1


reachY : System -> Float
reachY system =
  let
    diff =
      system.y.max - system.y.min
  in
    if diff > 0 then diff else 1


lengthX : System -> Float
lengthX system =
  max 1 (system.frame.size.width - system.frame.margin.left - system.frame.margin.right)


lengthY : System -> Float
lengthY system =
  max 1 (system.frame.size.height - system.frame.margin.bottom - system.frame.margin.top)
