module Internal.Coordinate exposing (..)

{-| -}


{-| -}
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
type alias System =
  { frame : Frame
  , x : Limits
  , y : Limits
  }


{-| -}
type alias Limits =
  { min : Float
  , max : Float
  }


{-| -}
type alias DataPoint data =
  { data : data
  , point : Point
  }


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
type alias Limitations =
  { min : Float -> Float
  , max : Float -> Float
  }


{-| -}
limits : (a -> Float) -> List a -> Limits
limits toValue data =
  let
    limits =
      { min = minimum toValue data
      , max = maximum toValue data
      }
  in
  if limits.min == limits.max then
    { limits | max = limits.max + 1 }
  else
    limits


{-| -}
applyLimitations : Limitations -> Limits -> Limits
applyLimitations limitation limits =
  { min = limitation.min limits.min
  , max = limitation.max limits.max
  }


{-| -}
minimum : (a -> Float) -> List a -> Float
minimum toValue =
  List.map toValue
    >> List.minimum
    >> Maybe.withDefault 0


{-| -}
minimumOrZero : (a -> Float) -> List a -> Float
minimumOrZero toValue =
  minimum toValue >> Basics.min 0


{-| -}
maximum : (a -> Float) -> List a -> Float
maximum toValue =
  List.map toValue
    >> List.maximum
    >> Maybe.withDefault 1


{-| -}
ground : Limits -> Limits
ground limits =
  { limits | min = Basics.min limits.min 0 }


{-| -}
reachX : System -> Float
reachX system =
  let
    diff =
      system.x.max - system.x.min
  in
    if diff > 0 then diff else 1


{-| -}
reachY : System -> Float
reachY system =
  let
    diff =
      system.y.max - system.y.min
  in
    if diff > 0 then diff else 1


{-| -}
lengthX : System -> Float
lengthX system =
  max 1 (system.frame.size.width - system.frame.margin.left - system.frame.margin.right)


{-| -}
lengthY : System -> Float
lengthY system =
  max 1 (system.frame.size.height - system.frame.margin.bottom - system.frame.margin.top)
