module Internal.Coordinate exposing (DataPoint, limits, minimum, minimumOrZero, maximum)

{-| -}

import Lines.Coordinate as Coordinate exposing (..)



{-| -}
type alias DataPoint data =
  { data : data
  , point : Coordinate.Point
  }


{-| -}
limits : (a -> Float) -> List a -> Coordinate.Limits
limits toValue data =
  { min = minimum toValue data
  , max = maximum toValue data
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
