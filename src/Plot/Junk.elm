module Plot.Junk exposing (Junk, Layers, none, withoutHint, withHint, Searcher, findNearest, findWithin, findNearestX, findWithinX)


import Svg exposing (Svg)
import Html exposing (Html)
import Plot.Coordinate as Coordinate exposing (Point)
import Internal.Junk
import Internal.Utils as Utils exposing (withFirst)


{-| -}
type alias Junk msg =
  Internal.Junk.Junk msg


{-| -}
type alias Layers msg =
  { above : List (Svg msg)
  , below : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
none : Junk msg
none =
  withoutHint (\_ -> Layers [] [] [])


{-| -}
withoutHint : (Coordinate.System -> Layers msg) -> Junk msg
withoutHint toLayers =
  Internal.Junk.Junk (always toLayers)


{-| -}
withHint : Searcher hint -> (Coordinate.System -> hint -> Layers msg) -> Junk msg
withHint (Searcher searcher) toLayers =
  Internal.Junk.Junk <| \points system ->
    let
      hint =
        searcher points system
    in
      toLayers system hint



-- SEARCHERS


{-| -}
type Searcher hint =
  Searcher (List Point -> Coordinate.System -> hint)


{-| -}
findNearest : Point -> Searcher (Maybe Point)
findNearest searched =
  Searcher (findNearestHelp searched)


{-| -}
findWithin : Float -> Point -> Searcher (Maybe Point)
findWithin radius searched =
  Searcher <| \points system ->
    let
        keepIfEligible closest =
            if Utils.withinRadius system radius searched closest then
                Just closest
            else
                Nothing
    in
    findNearestHelp searched points system
        |> Maybe.andThen keepIfEligible


{-| -}
findNearestX : Point -> Searcher (List Point)
findNearestX searched =
  Searcher (findNearestXHelp searched)


{-| -}
findWithinX : Float -> Point -> Searcher (List Point)
findWithinX radius searched =
  Searcher <| \points system ->
    let
        keepIfEligible =
            Utils.withinRadiusX system radius searched
    in
    findNearestXHelp searched points system
      |> List.filter keepIfEligible



-- INTERNAL


findNearestHelp : Point -> List Point -> Coordinate.System ->  Maybe Point
findNearestHelp searched points system =
  let
      distance =
          Utils.distance system searched

      getClosest point closest =
          if distance closest < distance point then
              closest
          else
              point
  in
  withFirst points (List.foldl getClosest)


findNearestXHelp : Point -> List Point -> Coordinate.System -> List Point
findNearestXHelp searched points system =
  let
      distanceX =
          Utils.distanceX system searched

      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
              if closest.x == point.x then
                point :: allClosest
              else if distanceX closest > distanceX point then
                [ point ]
              else
                allClosest

          Nothing ->
            [ point ]
  in
  List.foldl getClosest [] points
