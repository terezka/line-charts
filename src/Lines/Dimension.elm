module Lines.Dimension exposing (Dimension, default)

{-|

@docs Dimension, default

-}


import Lines.Axis.Title as Title
import Lines.Axis.Range as Range
import Lines.Axis as Axis


{-| Customize your dimension.

    - `title`: Adds a title on your axis.
      See `Lines.Axis.Title` for more information and examples.

    - `variable`: Determines what data is drawn in the chart!

    - `pixels`: The length of the dimension.

    - `range`: Determines the range of your dimension.
      See `Lines.Axis.Range` for more information and examples.

    - `axis`: Customizes your axis line and ticks.
      See `Lines.Axis` for more information and examples.

-}
type alias Dimension data msg =
  { title : Title.Title msg
  , variable : data -> Float
  , pixels : Int
  , range : Range.Range
  , axis : Axis.Axis data msg
  }


{-| -}
default : Int -> String -> (data -> Float) -> Dimension data msg
default pixels title variable =
  { title = Title.default title
  , variable = variable
  , pixels = pixels
  , range = Range.default
  , axis = Axis.float (pixels // 70)
  }
