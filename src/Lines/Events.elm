module Lines.Events exposing
  ( Events, default, none, hover, hoverCustom, click, custom
  , Event, on
  , Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX
  )

{-|

# Quick start
@docs Events, default, none, hover, hoverCustom, click, custom

# Events
@docs Event, on

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
hoverCustom :
  { onMouseMove : Handler data msg
  , onMouseLeave : msg
  }
  -> Events.Events data msg
hoverCustom =
  Events.hoverCustom


{-| -}
click : (Maybe data -> msg) -> Events.Events data msg
click =
  Events.click


{-| -}
custom : List (Event data msg) -> Events data msg
custom =
  Events.custom


{-| -}
type alias Event data msg =
  Events.Event data msg


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
type alias Handler data hint =
  Events.Handler data hint


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
