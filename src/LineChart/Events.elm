module LineChart.Events exposing
  ( Config, default, hoverOne, hoverMany, click, custom
  , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options
  , Decoder, getSvg, getData, getNearest, getNearestX, getWithin, getWithinX
  , map, map2, map3
  )

{-|

@docs Config, default, hoverOne, hoverMany, click

# Customization
@docs custom

## Events
@docs Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options

## Decoders
@docs Decoder, getSvg, getData, getNearest, getNearestX, getWithin, getWithinX

### Maps

    type Msg =
      Hover ( Maybe Data, Coordinate.Point )

    events : Events.Config Data Msg
    events =
      Events.custom
        [ Events.onMouseMove Hover decoder ]

    decoder : Events.Decoder
    decoder =
      Events.map2 (,) Events.getNearest Events.getSvg

@docs map, map2, map3

-}

import Internal.Events as Events
import LineChart.Coordinate as Coordinate



-- QUICK START


{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , events = Events.default
      , ...
      }

-}
type alias Config data msg =
  Events.Config data msg


{-| Adds no events.
-}
default : Config data msg
default =
  Events.default


{-| Sends a message when the mouse is within a 30 pixel radius of a dot.
Sends a `Nothing` when the mouse is not hovering a dot.

Pass a message taking the data of the data point hovered.

    eventsConfig : Events.Config Data Msg
    eventsConfig =
      Events.hoverOne Hover


_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Events/Example1.elm)._

-}
hoverOne : (Maybe data -> msg) -> Config data msg
hoverOne =
  Events.hoverOne


{-| Sends a message when the mouse is within a 30 pixel distance of a
x-coordinate with one or several dots on. Sends a `[]` when the mouse
is not hovering an dots.

Pass a message taking the data of the data points hovered.

    eventsConfig : Events.Config Data Msg
    eventsConfig =
      Events.hoverMany OnHoverMany


_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Events/Example2.elm)._

-}
hoverMany : (List data -> msg) -> Config data msg
hoverMany =
  Events.hoverMany


{-| Sends a given message when clicking on a dot.

Pass a message taking the data of the data points clicked.

    eventsConfig : Events.Config Data Msg
    eventsConfig =
      Events.click Click


_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Events/Example3.elm)._

-}
click : (Maybe data -> msg) -> Config data msg
click =
  Events.click


{-| Add your own combination of events. The cool thing here is that you can pick
another `Events.Decoder` or use `Events.on` for events without shortcuts.

    eventsConfig : Events.Config Data Msg
    eventsConfig =
      Events.custom
        [ Events.onMouseMove Hover Events.getNearest
        , Events.onMouseLeave (Hover Nothing)
        ]


_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Events/Example4.elm)._

This example sends the `Hover` message with the data of the _nearest_ dot when
hovering the chart area and `Hover Nothing` when your leave the chart area.

-}
custom : List (Event data msg) -> Config data msg
custom =
  Events.custom



-- SINGLES


{-| -}
type alias Event data msg =
  Events.Event data msg


{-| -}
onClick : (a -> msg) -> Decoder data a -> Event data msg
onClick =
  Events.onClick


{-| -}
onMouseMove : (a -> msg) -> Decoder data a -> Event data msg
onMouseMove =
  Events.onMouseMove


{-| -}
onMouseDown : (a -> msg) -> Decoder data a -> Event data msg
onMouseDown =
  Events.onMouseDown


{-| -}
onMouseUp : (a -> msg) -> Decoder data a -> Event data msg
onMouseUp =
  Events.onMouseUp


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave =
  Events.onMouseLeave


{-| Add any event to your chart.

Arguments:

  1. The JavaScript event name.
  2. The message.
  3. The `Events.Decoder` to determine what data you want from the event.

-}
on : String -> (a -> msg) -> Decoder data a -> Event data msg
on =
  Events.on


{-| Same as `on`, but you can add some options too!

    1. The JavaScript event name.
    2. The `Options`.
    2. The message.
    3. The `Events.Decoder` to determine what data you want from the event.
-}
onWithOptions : String -> Options -> (a -> msg) -> Decoder data a -> Event data msg
onWithOptions =
  Events.onWithOptions


{-| -}
type alias Options =
  { stopPropagation : Bool
  , preventDefault : Bool
  , catchOutsideChart : Bool
  }



-- DECODERS


{-| Gets you information about where your event happened on your chart.
This example gets you the data of the nearest dot to where you are hovering.

    events : Config Data Msg
    events =
      Events.custom
        [ Events.onMouseMove Hover Events.getNearest ]

-}
type alias Decoder data msg =
  Events.Decoder data msg


{-| Get the SVG-space coordinates of the event.
-}
getSvg : Decoder data Coordinate.Point
getSvg =
  Events.getSvg


{-| Get the data-space coordinates of the event.
-}
getData : Decoder data Coordinate.Point
getData =
  Events.getData


{-| Get the data coordinates nearest to the event.
Returns `Nothing` if you have no data showing.
-}
getNearest : Decoder data (Maybe data)
getNearest =
  Events.getNearest


{-| Get the data coordinates nearest of the event within the radius
you provide in the first argument. Returns `Nothing` if you have no data showing.
-}
getWithin : Float -> Decoder data (Maybe data)
getWithin =
  Events.getWithin


{-| Get the data coordinates horizontally nearest to the event.
-}
getNearestX : Decoder data (List data)
getNearestX =
  Events.getNearestX


{-| Finds the data coordinates horizontally nearest to the event, within the
distance you provide in the first argument.
-}
getWithinX : Float -> Decoder data (List data)
getWithinX =
  Events.getWithinX



-- MAPS


{-| -}
map : (a -> msg) -> Decoder data a -> Decoder data msg
map =
  Events.map


{-| -}
map2 : (a -> b -> msg) -> Decoder data a -> Decoder data b -> Decoder data msg
map2 =
  Events.map2


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data msg
map3 =
  Events.map3
