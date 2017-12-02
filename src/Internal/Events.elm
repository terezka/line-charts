module Internal.Events exposing
    ( Event, toEvent, toAttributes, decoder
    , Searcher, findNearest, findNearestX, findWithin, findWithinX, cartesian, svg, searcher
    )

{-| -}

import DOM
import Svg
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate exposing (DataPoint)
import Internal.Utils exposing (withFirst)
import Json.Decode as Json



{-| -}
type Event data msg
    = Event (List (DataPoint data) -> System -> Svg.Attribute msg)


{-| -}
toEvent : (List (DataPoint data) -> System -> Svg.Attribute msg) -> Event data msg
toEvent =
  Event


{-| -}
toAttributes : List (DataPoint data) -> System -> List (Event data msg) -> List (Svg.Attribute msg)
toAttributes dataPoints system =
    List.map (\(Event attribute) -> attribute dataPoints system)



-- DECODER


{-| -}
decoder : List (DataPoint data) -> System -> Searcher data hint -> (hint -> msg) -> Json.Decoder msg
decoder points system searcher msg =
  Json.map7
    toCoordinate
    (Json.succeed points)
    (Json.succeed system)
    (Json.succeed searcher)
    (Json.succeed msg)
    (Json.field "clientX" Json.float)
    (Json.field "clientY" Json.float)
    (DOM.target position)


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]


toCoordinate : List (DataPoint data) -> System -> Searcher data hint -> (hint -> msg) -> Float -> Float -> DOM.Rectangle -> msg
toCoordinate points system searcher msg mouseX mouseY { left, top } =
  Point (mouseX - left) (mouseY - top)
    |> applySearcher searcher points system
    |> msg


applySearcher : Searcher data hint -> List (DataPoint data) -> System -> Point -> hint
applySearcher (Searcher searcher) dataPoints system searched =
  searcher dataPoints system searched



-- SEARCHERS


{-| -}
type Searcher data hint =
  Searcher (List (DataPoint data) -> System -> Point -> hint)


{-| -}
svg : Searcher data Point
svg =
  Searcher <| \points system searched ->
    searched


{-| -}
cartesian : Searcher data Point
cartesian =
  Searcher <| \points system searched ->
    toCartesianSafe system searched


{-| -}
findNearest : Searcher data (Maybe data)
findNearest =
  Searcher <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    findNearestHelp points system searched |> Maybe.map .data


{-| -}
findWithin : Float -> Searcher data (Maybe data)
findWithin radius =
  Searcher <| \points system searchedSvg ->
    let
        searched =
          toCartesianSafe system searchedSvg

        keepIfEligible closest =
            if withinRadius system radius searched closest.point
              then Just closest.data
              else Nothing
    in
    findNearestHelp points system searched
        |> Maybe.andThen keepIfEligible


{-| -}
findNearestX : Searcher data (List data)
findNearestX =
  Searcher <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    findNearestXHelp points system searched |> List.map .data


{-| -}
findWithinX : Float -> Searcher data (List data)
findWithinX radius =
  Searcher <| \points system searchedSvg ->
    let
        searched =
          toCartesianSafe system searchedSvg

        keepIfEligible =
            withinRadiusX system radius searched << .point
    in
    findNearestXHelp points system searched
      |> List.filter keepIfEligible
      |> List.map .data


{-| -}
searcher : (System -> Point -> hint) -> Searcher data hint
searcher toHint =
  Searcher (\_ -> toHint)



-- HELPERS


findNearestHelp : List (DataPoint data) -> System -> Point -> Maybe (DataPoint data)
findNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest.point < distance_ point.point
            then closest
            else point
  in
  withFirst points (List.foldl getClosest)


findNearestXHelp : List (DataPoint data) -> System -> Point -> List (DataPoint data)
findNearestXHelp points system searched =
  let
      distanceX_ =
          distanceX system searched

      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
              if closest.point.x == point.point.x then point :: allClosest
              else if distanceX_ closest.point > distanceX_ point.point then [ point ]
              else allClosest

          Nothing ->
            [ point ]
  in
  List.foldl getClosest [] points



-- COORDINATE HELPERS


{-| -}
toCartesianSafe : System -> Point -> Point
toCartesianSafe system point =
  { x = clamp system.x.min system.x.max <| Coordinate.toDataX system point.x
  , y = clamp system.y.min system.y.max <| Coordinate.toDataY system point.y
  }


{-| -}
distanceX : System -> Point -> Point -> Float
distanceX system position dot =
    abs <| toSVGX system dot.x - toSVGX system position.x


{-| -}
distanceY : System -> Point -> Point -> Float
distanceY system position dot =
    abs <| toSVGY system dot.y - toSVGY system position.y


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
