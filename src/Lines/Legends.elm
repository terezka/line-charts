module Lines.Legends exposing (..)

import Svg exposing (Svg)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Legends as Legends



{-| -}
type alias Legends msg
  = Legends.Legends msg



{-| -}
type alias Pieces msg =
  { sample : Svg msg
  , label : String
  }


-- NONE


{-| -}
none : Legends msg
none =
  Legends.None



-- DEFAULT


{-| -}
default : Legends msg
default =
  bucketed .max .max



-- FREE


{-| -}
byEnding : (String -> Svg msg) -> Legends msg
byEnding =
  Legends.Free Legends.Ending


{-| -}
byBeginning : (String -> Svg msg) -> Legends msg
byBeginning =
  Legends.Free Legends.Beginning


{-| -}
defaultLabel : String -> Svg msg
defaultLabel label =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text label ] ]



-- BUCKETED


{-| -}
bucketedCustom : (Coordinate.System -> List (Pieces msg) -> Svg msg) -> Legends msg
bucketedCustom =
  Legends.Bucketed


{-| -}
bucketed : (Coordinate.Limits -> Float) -> (Coordinate.Limits -> Float) -> Legends msg
bucketed toX toY =
  Legends.Bucketed <| \system legends ->
    Svg.g
      [ place system (toX system.x) (toY system.y) ]
      (List.indexedMap viewLegend legends)



-- INTERNAL


viewLegend : Int -> Pieces msg -> Svg msg
viewLegend index { sample, label } =
   Svg.g
    [ transform [ translateFree 20 (toFloat index * 15) ] ]
    [ sample
    , Svg.g
        [ transform [ translateFree 40 4 ] ]
        [ defaultLabel label ]
    ]
