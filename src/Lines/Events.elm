module Lines.Events exposing
  ( default
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Searcher, findNearest, findNearestX, findWithin, findWithinX, cartesian, searcher
  )

{-|

# Events

## Quick start
@docs default

## Events
@docs Event, onClick, onMouseMove, onMouseLeave, on

## Searchers
@docs Searcher, findNearest, findNearestX, findWithin, findWithinX, cartesian, searcher

-}

import DOM
import Svg.Events
import Json.Decode as Json
import Internal.Events as Events
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate as Coordinate exposing (..)



-- QUICK START


{-| -}
default : (Maybe data -> msg) -> List (Event data msg)
default msg =
    [ onMouseMove findNearest msg
    , onMouseLeave (msg Nothing)
    ]



-- EVENTS


{-| -}
type alias Event data msg =
  Events.Event data msg


{-| -}
onClick : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onClick searcher msg =
  Events.Event <| \points system -> Svg.Events.on "click" (decoder points system searcher msg)


{-| -}
onMouseMove : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onMouseMove searcher msg =
  Events.Event <| \points system -> Svg.Events.on "mousemove" (decoder points system searcher msg)


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Events.Event <| \_ _ -> Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> Events.Searcher data hint -> (hint -> msg) -> Event data msg
on event searcher msg =
  Events.Event <| \points system -> Svg.Events.on event (decoder points system searcher msg)



-- SEARCHERS


{-| -}
type alias Searcher data hint =
  Events.Searcher data hint



{-| TODO: Make this -}
cartesian : Searcher data (Maybe data)
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
searcher : (System -> Point -> hint) -> Searcher data hint
searcher =
  Events.custom



-- INTERNAL


decoder : List (DataPoint data) -> Coordinate.System -> Events.Searcher data hint -> (hint -> msg) -> Json.Decoder msg
decoder points system searcher msg =
  Json.map7
    translate
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


translate : List (DataPoint data) -> Coordinate.System -> Events.Searcher data hint -> (hint -> msg) -> Float -> Float -> DOM.Rectangle -> msg
translate points system searcher msg mouseX mouseY { left, top } =
    { x = clamp system.x.min system.x.max <| Coordinate.toCartesian X system (mouseX - left)
    , y = clamp system.y.min system.y.max <| Coordinate.toCartesian Y system (mouseY - top)
    }
    |> Events.applySearcher searcher points system
    |> msg
