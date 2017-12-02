module Lines.Coordinate exposing
  ( Frame, Size, Margin
  , Orientation(..), Limits, System
  , toSVG, toCartesian
  , Point, toSVGPoint, toCartesianPoint
  , scaleSVG, scaleCartesian
  )

{-|

# Frame
@docs Frame, Size, Margin

# Limits
@docs Limits

# System
@docs System

# Translation
@docs Orientation

## Single value
@docs toSVG, toCartesian

## Point
@docs Point, toSVGPoint, toCartesianPoint

## Scale
@docs scaleSVG, scaleCartesian

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


{-| -}
type Orientation = X | Y


{-| Translate a value from cartesian to SVG.

    toSVG X system point.x
-}
toSVG : Orientation -> System -> Float -> Float
toSVG orientation system value =
  case orientation of
    X ->
      scaleSVG orientation system (value - system.x.min) + system.frame.margin.left

    Y ->
      scaleSVG orientation system (system.y.max - value) + system.frame.margin.top


{-| Translate a value from SVG to cartesian.
-}
toCartesian : Orientation -> System -> Float -> Float
toCartesian orientation system value =
  case orientation of
    X ->
      system.x.min + scaleCartesian orientation system (value - system.frame.margin.left)

    Y ->
      system.y.max - scaleCartesian orientation system (value - system.frame.margin.top)



-- Scaling


{-| Scale a value from cartesian to SVG.
-}
scaleSVG : Orientation -> System -> Float -> Float
scaleSVG orientation system value =
  value * (length orientation system) / (reach orientation system)


{-| Scale a value from SVG to cartesian.
-}
scaleCartesian : Orientation -> System -> Float -> Float
scaleCartesian orientation system value =
  value * (reach orientation system) / (length orientation system)



-- Points


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
toSVGPoint : System -> Point -> Point
toSVGPoint system point =
  { x = toSVG X system point.x
  , y = toSVG Y system point.y
  }


{-| -}
toCartesianPoint : System -> Point -> Point
toCartesianPoint system point =
  { x = toCartesian X system point.x
  , y = toCartesian Y system point.y
  }



-- INTERNAL


reach : Orientation -> System -> Float
reach orientation system =
  let
    limits =
      case orientation of
        X ->
          system.x

        Y ->
          system.y

    diff =
      limits.max - limits.min
  in
    if diff > 0 then diff else 1


length : Orientation -> System -> Float
length orientation system =
  case orientation of
    X ->
      max 1 (system.frame.size.width - system.frame.margin.left - system.frame.margin.right)

    Y ->
      max 1 (system.frame.size.height - system.frame.margin.bottom - system.frame.margin.top)
