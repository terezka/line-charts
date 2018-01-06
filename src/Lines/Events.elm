module Lines.Events exposing
  ( Events, default, none, hover, click, custom
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX
  )

{-|

# Quick start
@docs default, none

# Effects
@docs Events, hover, click

# Events
@docs custom, Event, onClick, onMouseMove, onMouseLeave, on

# Handlers
@docs Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX

-}

import Internal.Events as Events
import Lines.Coordinate as Coordinate



-- QUICK START


{-| -}
type alias Events data msg =
  Events.Events data msg


{-| -}
default : Events.Events data msg
default =
  Events.default


{-| -}
none : Events.Events data msg
none =
  Events.none


{-| -}
hover : (Maybe data -> msg) -> Events.Events data msg
hover =
  Events.hover


{-| -}
click : (Maybe data -> msg) -> Events.Events data msg
click =
  Events.click


{-| -}
custom : List (Event data msg) -> Events data msg
custom =
  Events.custom



-- SINGLES


{-| -}
type alias Event data msg =
  Events.Event data msg


{-| -}
onClick : Handler data msg -> Event data msg
onClick =
  Events.onClick


{-| -}
onMouseMove : Handler data msg -> Event data msg
onMouseMove =
  Events.onMouseMove


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave =
  Events.onMouseLeave


{-| -}
on : String -> Handler data msg -> Event data msg
on =
  Events.on



-- SEARCHERS


{-| A searcher passes specific information about your event to your message, when
used in an `Event`.

    type Msg = Hover (Maybe Info)

    events : List (Event Msg)
    events =
      [ Events.onMouseMove Events.findNearest Hover ]
-}
type alias Handler data msg =
  Events.Handler data msg


{-| Produces the SVG of the event.
-}
getSvg : (Coordinate.Point -> msg) -> Handler data msg
getSvg =
  Events.getSvg


{-| Produces the data point of the event.
-}
getCartesian : (Coordinate.Point -> msg) -> Handler data msg
getCartesian =
  Events.getCartesian


{-| Finds the data point nearest to the event.
-}
getNearest : (Maybe data -> msg) -> Handler data msg
getNearest =
  Events.getNearest


{-| Finds the data point nearest to the event, within the radius (px) you
provide in the first argument.
-}
getWithin : Float -> (Maybe data -> msg) -> Handler data msg
getWithin =
  Events.getWithin


{-| Finds the data point nearest horizontally to the event.
-}
getNearestX : (List data -> msg) -> Handler data msg
getNearestX =
  Events.getNearestX


{-| Finds the data point nearest horizontally to the event, within the
distance (px) you provide in the first argument.
-}
getWithinX : Float -> (List data -> msg) -> Handler data msg
getWithinX =
  Events.getWithinX
