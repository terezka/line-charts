module Internal.Events exposing (..)

import Svg
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Utils as Utils exposing (withFirst)


{-| -}
type Event msg
    = Event (List Coordinate.Point -> Coordinate.System -> Svg.Attribute msg)


{-| -}
toSvgAttributes : List Coordinate.Point -> Coordinate.System -> List (Event msg) -> List (Svg.Attribute msg)
toSvgAttributes points system =
    List.map (\(Event attribute) -> attribute points system)


{-| -}
applySearcher : Searcher hint -> List Point -> System -> Point -> hint
applySearcher (Searcher searcher) points system searched =
  searcher points system searched


{-| -}
type Searcher hint =
  Searcher (List Point -> System -> Point -> hint)


{-| TODO: Make this -}
svg : Searcher (Maybe Point)
svg =
  Searcher findNearestHelp


{-| TODO: Make this -}
cartesian : Searcher (Maybe Point)
cartesian =
  Searcher findNearestHelp


{-| -}
findNearest : Searcher (Maybe Point)
findNearest =
  Searcher findNearestHelp


{-| -}
findWithin : Float -> Searcher (Maybe Point)
findWithin radius =
  Searcher <| \points system searched ->
    let
        keepIfEligible closest =
            if withinRadius system radius searched closest then
                Just closest
            else
                Nothing
    in
    findNearestHelp points system searched
        |> Maybe.andThen keepIfEligible


{-| -}
findNearestX : Searcher (List Point)
findNearestX =
  Searcher findNearestXHelp


{-| -}
findWithinX : Float -> Searcher (List Point)
findWithinX radius =
  Searcher <| \points system searched ->
    let
        keepIfEligible =
            withinRadiusX system radius searched
    in
    findNearestXHelp points system searched
      |> List.filter keepIfEligible


{-| TODO: Should it exist -}
custom : (System -> Point -> hint) -> Searcher hint
custom toHint =
  Searcher (\_ -> toHint)



-- INTERNAL


findNearestHelp : List Point -> System -> Point -> Maybe Point
findNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest < distance_ point then
              closest
          else
              point
  in
  withFirst points (List.foldl getClosest)


findNearestXHelp : List Point -> System -> Point -> List Point
findNearestXHelp points system searched =
  let
      distanceX_ =
          distanceX system searched

      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
              if closest.x == point.x then
                point :: allClosest
              else if distanceX_ closest > distanceX_ point then
                [ point ]
              else
                allClosest

          Nothing ->
            [ point ]
  in
  List.foldl getClosest [] points



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
