module Lines.Events exposing
  ( none, default
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Searcher, findNearest, findNearestX, findWithin, findWithinX, cartesian, searcher
  )

{-|

# Events

## Quick start
@docs none, default

## Events
@docs Event, onClick, onMouseMove, onMouseLeave, on

## Searchers
@docs Searcher, findNearest, findNearestX, findWithin, findWithinX, cartesian, searcher

-}

import Svg.Events
import Json.Decode as Json
import Internal.Events as Events
import Lines.Coordinate as Coordinate



-- QUICK START


{-| -}
default : (Maybe data -> msg) -> List (Event data msg)
default msg =
    [ onMouseMove findNearest msg
    , onMouseLeave (msg Nothing)
    ]


{-| -}
none : List (Event data msg)
none =
  []


-- EVENTS


{-| -}
type alias Event data msg =
  Events.Event data msg


{-| -}
onClick : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onClick searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on "click" (Events.decoder points system searcher msg)


{-| -}
onMouseMove : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onMouseMove searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on "mousemove" (Events.decoder points system searcher msg)


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Events.toEvent <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> Events.Searcher data hint -> (hint -> msg) -> Event data msg
on event searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on event (Events.decoder points system searcher msg)



-- SEARCHERS


{-| -}
type alias Searcher data hint =
  Events.Searcher data hint


{-| -}
svg : Searcher data Coordinate.Point
svg =
  Events.svg


{-| -}
cartesian : Searcher data Coordinate.Point
cartesian =
  Events.cartesian


{-| -}
findNearest : Searcher data (Maybe data)
findNearest =
  Events.findNearest


{-| -}
findWithin : Float -> Searcher data (Maybe data)
findWithin =
  Events.findWithin


{-| -}
findNearestX : Searcher data (List data)
findNearestX =
  Events.findNearestX


{-| -}
findWithinX : Float -> Searcher data (List data)
findWithinX =
  Events.findWithinX


{-| -}
searcher : (Coordinate.System -> Coordinate.Point -> hint) -> Searcher data hint
searcher =
  Events.searcher
