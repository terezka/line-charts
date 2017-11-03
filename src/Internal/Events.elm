module Internal.Events exposing (..)

import Svg
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Utils exposing (withFirst)


{-| -}
type Event data msg
    = Event (List (DataPoint data) -> Coordinate.System -> Svg.Attribute msg)


{-| -}
toSvgAttributes : List (DataPoint data) -> Coordinate.System -> List (Event data msg) -> List (Svg.Attribute msg)
toSvgAttributes dataPoints system =
    List.map (\(Event attribute) -> attribute dataPoints system)


{-| -}
applySearcher : Searcher data hint -> List (DataPoint data) -> System -> Point -> hint
applySearcher (Searcher searcher) dataPoints system searched =
  searcher dataPoints system searched


{-| -}
type Searcher data hint =
  Searcher (List (DataPoint data) -> System -> Point -> hint)


{-| TODO: Make this -}
svg : Searcher data (Maybe data)
svg =
  Searcher findNearestHelp


{-| TODO: Make this -}
cartesian : Searcher data (Maybe data)
cartesian =
  Searcher findNearestHelp


{-| -}
findNearest : Searcher data (Maybe data)
findNearest =
  Searcher findNearestHelp



{-| TODO: Should it exist -}
custom : (System -> Point -> hint) -> Searcher data hint
custom toHint =
  Searcher (\_ -> toHint)



-- INTERNAL


findNearestHelp : List (DataPoint data) -> System -> Point -> Maybe data
findNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest.point < distance_ point.point then
              closest
          else
              point
  in
  withFirst points (List.foldl getClosest) |> Maybe.map .data


findNearestXHelp : List (DataPoint data) -> System -> Point -> List data
findNearestXHelp points system searched =
  []



-- POSITION STUFF


{-| -}
distanceX : System -> Point -> Point -> Float
distanceX system position dot =
    abs <| toSVG X system dot.x - toSVG X system position.x


{-| -}
distanceY : System -> Point -> Point -> Float
distanceY system position dot =
    abs <| toSVG Y system dot.y - toSVG Y system position.y


{-| -}
distance : System -> Point -> Point -> Float
distance system position dot =
    sqrt <| distanceX system position dot ^ 2 + distanceY system position dot ^ 2


{-| -}
withinRadius : System -> Float -> Point -> Point -> Bool
withinRadius system radius position dot =
    distance system position dot <= radius


{-| -}
withinRadiusX : System -> Float -> Point -> Point -> Bool
withinRadiusX system radius position dot =
    distanceX system position dot <= radius
