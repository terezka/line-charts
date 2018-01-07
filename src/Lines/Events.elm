module Lines.Events exposing
  ( Events, default, none, hover, click, custom
  , Event, onClick, onMouseMove, onMouseLeave, on
  , Handler, getSVG, getData, getNearest, getNearestX, getWithin, getWithinX
  , map, map2, map3
  )

{-|

# Quick start
@docs default, none

# Configurations
@docs Events, hover, click, custom

## Events
@docs Event, onClick, onMouseMove, onMouseLeave, on

## Handlers
@docs Handler, getSVG, getData, getNearest, getNearestX, getWithin, getWithinX

### Maps

    events : Events.Events Data Msg
    events =
      Events.custom
        [ Events.onMouseMove Hover <|
            Events.map2 (,) Events.getNearest Events.getSVG
        ]

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


{-| Gets you information about where your event happened on your chart.
This example gets you the nearest data coordinates to where you are hovering.

    events : Events.Events Data Msg
    events =
      Events.custom
        [ Events.onMouseMove Hover Events.getNearest ]
-}
type alias Handler data msg =
  Events.Handler data msg


{-| Get the SVG coordinates of the event.
-}
getSVG : Handler data Coordinate.Point
getSVG =
  Events.getSVG


{-| Get the data coordinates of the event.
-}
getData : Handler data Coordinate.Point
getData =
  Events.getData


{-| Get the data coordinates nearest to the event.
Returns `Nothing` if you have no data showing.
-}
getNearest : Handler data (Maybe data)
getNearest =
  Events.getNearest


{-| Get the data coordinates nearest of the event within the radius (in pixels)
you provide in the first argument. Returns `Nothing` if you have no data showing.
-}
getWithin : Float -> Handler data (Maybe data)
getWithin =
  Events.getWithin


{-| Get the data coordinates horizontally nearest to the event.
-}
getNearestX : Handler data (List data)
getNearestX =
  Events.getNearestX


{-| Finds the data coordinates horizontally nearest to the event, within the
distance (in pixels) you provide in the first argument.
-}
getWithinX : Float -> Handler data (List data)
getWithinX =
  Events.getWithinX



-- MAPS


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
