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
@docs Limits, limits

# System
@docs System, system

# Translation
@docs Orientation

## Single value
@docs toSVG, toCartesian

## Point
@docs Point, toSVGPoint, toCartesianPoint

## Scale
@docs scaleSVG, scaleCartesian

-}



{-| Specifies the size and margins of your graphic.
-}
type alias Frame =
  { margin : Margin
  , size : Size
  }


{-| -}
type alias Size =
  { width : Float
  , height : Float
  }


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }


{-| -}
type alias Limits =
  { min : Float
  , max : Float
  }



-- SYSTEM


{-| -}
type alias System =
  { frame : Frame
  , x : Limits
  , y : Limits
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
