module Lines.Events exposing
  ( none, default
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Searcher, svg, cartesian, findNearest, findNearestX, findWithin, findWithinX
  )

{-|

# Events

## Quick start
@docs none, default

## Events
@docs Event, onClick, onMouseMove, onMouseLeave, on

## Searchers
@docs Searcher, svg, cartesian, findNearest, findNearestX, findWithin, findWithinX

-}

import Svg.Events
import Json.Decode as Json
import Internal.Events as Events
import Lines.Coordinate as Coordinate



-- QUICK START


{-| The default events for hovering a data point. Defined like this:

    default : (Maybe data -> msg) -> List (Event data msg)
    default toMsg =
        [ Events.onMouseMove Events.findNearest msg
        , Events.onMouseLeave (toMsg Nothing)
        ]


To be used like this:

    type alias Model =
      Maybe Info

    type Msg =
      Hover (Maybe Info)

    update : Msg -> Model -> Model
    update (Hover hovered) =
      Model hovered

    view : Model -> Html Msg
    view model =
      div [] [ chart, text <| "Hovered point: " ++ toString model ]

    chart : Html msg
    chart =
      Lines.viewCustom chartConfig
        [ Lines.line "darkslateblue" Dot.cross "Alice" alice ]

    chartConfig : Config Info msg
    chartConfig =
      { ...
      , events = Events.default Hover
      , ...
      }

Want the dots to change when hovering? See `Dot.emphasizable`! TODO link

-}
default : (Maybe data -> msg) -> List (Event data msg)
default msg =
    [ onMouseMove findNearest msg
    , onMouseLeave (msg Nothing)
    ]


{-| Literally an empty list, just here for consistency. -- TODO should it just be removed then??
-}
none : List (Event data msg)
none =
  []


-- EVENTS


{-| A chart event!
-}
type alias Event data msg =
  Events.Event data msg


{-| Produces a click event listener. The first argument is a `Searcher` which
can find the nearest data point for you, give you the SVG coordinates, or other
information. This information will be passed to your message provided in the
second argument. To learn more about searchers, see the `Searcher` type!
-}
onClick : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onClick searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on "click" (Events.decoder points system searcher msg)


{-| Like `onClick`, except it reacts to the `mousemove` event.
-}
onMouseMove : Events.Searcher data hint -> (hint -> msg) -> Event data msg
onMouseMove searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on "mousemove" (Events.decoder points system searcher msg)


{-| Sends your message on `mouseleave`.
-}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Events.toEvent <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| Like `onClick`, except it reacts to whatever event you pass as
the first argument.
-}
on : String -> Events.Searcher data hint -> (hint -> msg) -> Event data msg
on event searcher msg =
  Events.toEvent <| \points system ->
    Svg.Events.on event (Events.decoder points system searcher msg)



-- SEARCHERS


{-| A searcher passes specific information about your event to your message, when
used in an `Event`.

    type Msg = Hover (Maybe Info)

    events : List (Event Msg)
    events =
      [ Events.onMouseMove Events.findNearest Hover ]
-}
type alias Searcher data hint =
  Events.Searcher data hint


{-| Produces the SVG of the event.
-}
svg : Searcher data Coordinate.Point
svg =
  Events.svg


{-| Produces the data point of the event.
-}
cartesian : Searcher data Coordinate.Point
cartesian =
  Events.cartesian


{-| Finds the data point nearest to the event.
-}
findNearest : Searcher data (Maybe data)
findNearest =
  Events.findNearest


{-| Finds the data point nearest to the event, within the radius (px) you
provide in the first argument.
-}
findWithin : Float -> Searcher data (Maybe data)
findWithin =
  Events.findWithin


{-| Finds the data point nearest horizontally to the event.
-}
findNearestX : Searcher data (List data)
findNearestX =
  Events.findNearestX


{-| Finds the data point nearest horizontally to the event, within the
distance (px) you provide in the first argument.
-}
findWithinX : Float -> Searcher data (List data)
findWithinX =
  Events.findWithinX
