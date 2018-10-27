module Internal.Coordinate exposing
  ( System, Frame, Size, Margin, Range
  , range, minimum, minimumOrZero, maximum
  , ground, reachX, reachY, lengthX, lengthY
  , smallestRange, largestRange
  )


{-| -}



{-| -}
type alias System =
  { frame : Frame
  , x : Range
  , y : Range
  , xData : Range
  , yData : Range
  , id : String
  }


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
type alias Range =
  { min : Float
  , max : Float
  }



-- HELPERS


{-| -}
range : (a -> Float) -> List a -> Range
range toValue data =
  let
    range_ =
      { min = minimum toValue data
      , max = maximum toValue data
      }
  in
  if range_.min == range_.max then
    { range_ | max = range_.max + 1 }
  else
    range_


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
ground : Range -> Range
ground range_ =
  { range_ | min = Basics.min range_.min 0 }


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


{-| -}
smallestRange : Range -> Range -> Range
smallestRange data range_ =
  { min = Basics.max data.min range_.min
  , max = Basics.min data.max range_.max
  }


{-| -}
largestRange : Range -> Range -> Range
largestRange data range_ =
  { min = Basics.min data.min range_.min
  , max = Basics.max data.max range_.max
  }
