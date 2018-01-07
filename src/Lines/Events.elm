module Lines.Events exposing
  ( Events, default, none, hover, click, custom
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX
  , map, map2, map3
  )

{-|

# Quick start
@docs default, none

# Events
@docs Events, hover, click, custom

## Singles
@docs Event, onClick, onMouseMove, onMouseLeave, on

## Handlers
@docs Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX
### Maps
@docs map, map2, map3

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
onClick : (a -> msg) -> Handler data a -> Event data msg
onClick =
  Events.onClick


{-| -}
onMouseMove : (a -> msg) -> Handler data a -> Event data msg
onMouseMove =
  Events.onMouseMove


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave =
  Events.onMouseLeave


{-| -}
on : String -> (a -> msg) -> Handler data a -> Event data msg
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
getSvg : Handler data Coordinate.Point
getSvg =
  Events.getSvg


{-| Produces the data point of the event.
-}
getCartesian : Handler data Coordinate.Point
getCartesian =
  Events.getCartesian


{-| Finds the data point nearest to the event.
-}
getNearest : Handler data (Maybe data)
getNearest =
  Events.getNearest


{-| Finds the data point nearest to the event, within the radius (px) you
provide in the first argument.
-}
getWithin : Float -> Handler data (Maybe data)
getWithin =
  Events.getWithin


{-| Finds the data point nearest horizontally to the event.
-}
getNearestX : Handler data (List data)
getNearestX =
  Events.getNearestX


{-| Finds the data point nearest horizontally to the event, within the
distance (px) you provide in the first argument.
-}
getWithinX : Float -> Handler data (List data)
getWithinX =
  Events.getWithinX


{-| -}
map : (a -> msg) -> Handler data a -> Handler data msg
map =
  Events.map


{-| -}
map2 : (a -> b -> msg) -> Handler data a -> Handler data b -> Handler data msg
map2 =
  Events.map2


{-| -}
map3 : (a -> b -> c -> msg) -> Handler data a -> Handler data b -> Handler data c -> Handler data msg
map3 =
  Events.map3
