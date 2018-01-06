module Internal.Events exposing
    ( Events, default, none, hover, hoverCustom, click, custom
    , Event, onClick, onMouseMove, onMouseLeave, on
    , Handler, getSvg, getCartesian, getNearest, getNearestX, getWithin, getWithinX
    -- INTERNAL
    , toAttributes
    )

{-| -}

import DOM
import Svg
import Svg.Events
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Coordinate exposing (DataPoint)
import Internal.Utils exposing (withFirst)
import Json.Decode as Json


{-| -}
type Events data msg
  = Events (List (Event data msg))


{-| -}
default : Events data msg
default =
  none


{-| -}
none : Events data msg
none =
  custom []


{-| -}
hover : (Maybe data -> msg) -> Events data msg
hover msg =
  custom
    [ onMouseMove (getNearest msg)
    , onMouseLeave (msg Nothing)
    ]


{-| -}
hoverCustom :
  { onMouseMove : Handler data msg
  , onMouseLeave : msg
  }
  -> Events data msg
hoverCustom config =
  custom
    [ onMouseMove config.onMouseMove
    , onMouseLeave config.onMouseLeave
    ]


{-| -}
click : (Maybe data -> msg) -> Events data msg
click msg =
  custom
    [ onClick (getNearest msg) ]


{-| -}
custom : List (Event data msg) -> Events data msg
custom =
  Events



-- EVENT


{-| -}
type Event data msg =
  Event (List (DataPoint data) -> System -> Svg.Attribute msg)


{-| -}
onClick : Handler data msg -> Event data msg
onClick handler =
  Event <| \points system ->
    Svg.Events.on "click" (decoder points system handler)


{-| -}
onMouseMove : Handler data msg -> Event data msg
onMouseMove handler =
  Event <| \points system ->
    Svg.Events.on "mousemove" (decoder points system handler)


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Event <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> Handler data msg -> Event data msg
on event handler =
  Event <| \points system ->
    Svg.Events.on event (decoder points system handler)



-- INTERNAL


{-| -}
toAttributes : List (DataPoint data) -> System -> Events data msg -> List (Svg.Attribute msg)
toAttributes dataPoints system (Events events) =
    List.map (\(Event event) -> event dataPoints system) events



-- DECODER


{-| -}
decoder : List (DataPoint data) -> System -> Handler data msg -> Json.Decoder msg
decoder points system handler =
  Json.map6
    toCoordinate
    (Json.succeed points)
    (Json.succeed system)
    (Json.succeed handler)
    (Json.field "clientX" Json.float)
    (Json.field "clientY" Json.float)
    (DOM.target position)


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]


toCoordinate : List (DataPoint data) -> System -> Handler data msg -> Float -> Float -> DOM.Rectangle -> msg
toCoordinate points system handler mouseX mouseY { left, top } =
  Point (mouseX - left) (mouseY - top)
    |> applyHandler handler points system


applyHandler : Handler data msg -> List (DataPoint data) -> System -> Point -> msg
applyHandler (Handler handler) dataPoints system coordinate =
  handler dataPoints system coordinate



-- SEARCHERS


{-| -}
type Handler data msg =
  Handler (List (DataPoint data) -> System -> Point -> msg)


{-| -}
getSvg : (Point -> msg) -> Handler data msg
getSvg msg =
  Handler <| \points system searched ->
    msg searched


{-| -}
getCartesian : (Point -> msg) -> Handler data msg
getCartesian msg =
  Handler <| \points system searched ->
    msg (toCartesianSafe system searched)


{-| -}
getNearest : (Maybe data -> msg) -> Handler data msg
getNearest msg =
  Handler <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    getNearestHelp points system searched
      |> Maybe.map .data
      |> msg


{-| -}
getWithin : Float -> (Maybe data -> msg) -> Handler data msg
getWithin radius msg =
  Handler <| \points system searchedSvg ->
    let
        searched =
          toCartesianSafe system searchedSvg

        keepIfEligible closest =
            if withinRadius system radius searched closest.point
              then Just closest.data
              else Nothing
    in
    getNearestHelp points system searched
        |> Maybe.andThen keepIfEligible
        |> msg


{-| -}
getNearestX : (List data -> msg) -> Handler data msg
getNearestX msg =
  Handler <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    getNearestXHelp points system searched
      |> List.map .data
      |> msg


{-| -}
getWithinX : Float ->  (List data -> msg) -> Handler data msg
getWithinX radius msg =
  Handler <| \points system searchedSvg ->
    let
        searched =
          toCartesianSafe system searchedSvg

        keepIfEligible =
            withinRadiusX system radius searched << .point
    in
    getNearestXHelp points system searched
      |> List.filter keepIfEligible
      |> List.map .data
      |> msg


{-| -}
handler : (System -> Point -> msg) -> Handler data msg
handler toHint =
  Handler (\_ -> toHint)



-- HELPERS


getNearestHelp : List (DataPoint data) -> System -> Point -> Maybe (DataPoint data)
getNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest.point < distance_ point.point
            then closest
            else point
  in
  withFirst points (List.foldl getClosest)


getNearestXHelp : List (DataPoint data) -> System -> Point -> List (DataPoint data)
getNearestXHelp points system searched =
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
