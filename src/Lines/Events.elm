module Lines.Events exposing (..)

{-| -}


import Svg.Events
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Events as Events
import DOM
import Json.Decode as Json



{-| -}
simple : (Maybe Point -> msg) -> List (Event msg)
simple msg =
    [ onMouseMove Events.findNearest msg
    , onMouseLeave (msg Nothing)
    ]



-- EVENTS


{-| -}
type alias Event msg =
  Events.Event msg


{-| -}
onClick : Events.Searcher hint -> (hint -> msg) -> Event msg
onClick searcher msg =
  Events.Event <| \points system -> Svg.Events.on "click" (decoder points system searcher msg)


{-| -}
onMouseMove : Events.Searcher hint -> (hint -> msg) -> Event msg
onMouseMove searcher msg =
  Events.Event <| \points system -> Svg.Events.on "mousemove" (decoder points system searcher msg)


{-| -}
onMouseLeave : msg -> Event msg
onMouseLeave msg =
  Events.Event <| \_ _ -> Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> Events.Searcher hint -> (hint -> msg) -> Event msg
on event searcher msg =
  Events.Event <| \points system -> Svg.Events.on event (decoder points system searcher msg)



-- SEARCHERS


{-| -}
type alias Searcher hint =
  Events.Searcher hint


{-| TODO: Make this -}
svg : Searcher (Maybe Point)
svg =
  Events.svg


{-| TODO: Make this -}
cartesian : Searcher (Maybe Point)
cartesian =
  Events.cartesian


{-| -}
findNearest : Searcher (Maybe Point)
findNearest =
  Events.findNearest


{-| -}
findWithin : Float -> Searcher (Maybe Point)
findWithin =
    Events.findWithin


{-| -}
findNearestX : Searcher (List Point)
findNearestX =
  Events.findNearestX


{-| -}
findWithinX : Float -> Searcher (List Point)
findWithinX =
  Events.findWithinX


{-| -}
searcher : (System -> Point -> hint) -> Searcher hint
searcher =
  Events.custom



-- INTERNAL


decoder : List Point -> Coordinate.System -> Events.Searcher hint -> (hint -> msg) -> Json.Decoder msg
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


translate : List Point ->Coordinate.System -> Events.Searcher hint -> (hint -> msg) -> Float -> Float -> DOM.Rectangle -> msg
translate points system searcher msg mouseX mouseY { left, top } =
    { x = clamp system.x.min system.x.max <| Coordinate.toCartesian X system (mouseX - left)
    , y = clamp system.y.min system.y.max <| Coordinate.toCartesian Y system (mouseY - top)
    }
    |> Events.applySearcher searcher points system
    |> msg
