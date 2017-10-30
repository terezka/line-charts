module Internal.Legends exposing (..)

import Svg exposing (Svg)
import Lines.Coordinate as Coordinate exposing (..)


{-| -}
type Legends msg
  = None
  | Free Placement (String -> Svg msg)
  | Bucketed Float (Coordinate.System -> List (Pieces msg) -> Svg msg)


{-| -}
type Placement
  = Beginning
  | Ending


{-| -}
type alias Pieces msg =
  { sample : Svg msg
  , label : String
  }
