module Internal.Events exposing
    ( Events, default, none, hover, click, custom
    , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on
    , Handler, getSVG, getData, getNearest, getNearestX, getWithin, getWithinX
    , map, map2, map3
    -- INTERNAL
    , toAttributes
    )

{-| -}

import DOM
import Svg
import Svg.Events
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Data as Data
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
    [ onMouseMove msg getNearest
    , onMouseLeave (msg Nothing)
    ]


{-| -}
click : (Maybe data -> msg) -> Events data msg
click msg =
  custom
    [ onClick msg getNearest ]


{-| -}
custom : List (Event data msg) -> Events data msg
custom =
  Events



-- EVENT


{-| -}
type Event data msg =
  Event (List (Data.Data data) -> System -> Svg.Attribute msg)


{-| -}
onClick : (a -> msg) -> Handler data a -> Event data msg
onClick =
  on "click"


{-| -}
onMouseMove : (a -> msg) -> Handler data a -> Event data msg
onMouseMove =
  on "mousemove"


{-| -}
onMouseDown : (a -> msg) -> Handler data a -> Event data msg
onMouseDown =
  on "mousedown"


{-| -}
onMouseUp : (a -> msg) -> Handler data a -> Event data msg
onMouseUp =
  on "mouseup"


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Event <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> (a -> msg) -> Handler data a -> Event data msg
on event f handler =
  Event <| \points system ->
    Svg.Events.on event (decoder points system (map f handler))



-- INTERNAL


{-| -}
toAttributes : List (Data.Data data) -> System -> Events data msg -> List (Svg.Attribute msg)
toAttributes dataPoints system (Events events) =
    List.map (\(Event event) -> event dataPoints system) events



-- DECODER


{-| -}
decoder : List (Data.Data data) -> System -> Handler data msg -> Json.Decoder msg
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


toCoordinate : List (Data.Data data) -> System -> Handler data msg -> Float -> Float -> DOM.Rectangle -> msg
toCoordinate points system handler mouseX mouseY { left, top } =
  Point (mouseX - left) (mouseY - top)
    |> applyHandler handler points system


applyHandler : Handler data msg -> List (Data.Data data) -> System -> Point -> msg
applyHandler (Handler handler) dataPoints system coordinate =
  handler dataPoints system coordinate



-- SEARCHERS


{-| -}
type Handler data msg =
  Handler (List (Data.Data data) -> System -> Point -> msg)


{-| -}
getSVG : Handler data Point
getSVG =
  Handler <| \points system searched ->
    searched


{-| -}
getData : Handler data Point
getData =
  Handler <| \points system searched ->
    toCartesianSafe system searched


{-| -}
getNearest : Handler data (Maybe data)
getNearest =
  Handler <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    getNearestHelp points system searched
      |> Maybe.map .data


{-| -}
getWithin : Float -> Handler data (Maybe data)
getWithin radius =
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


{-| -}
getNearestX : Handler data (List data)
getNearestX =
  Handler <| \points system searchedSvg ->
    let
      searched =
        toCartesianSafe system searchedSvg
    in
    getNearestXHelp points system searched
      |> List.map .data


{-| -}
getWithinX : Float -> Handler data (List data)
getWithinX radius =
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


{-| -}
handler : (System -> Point -> a) -> Handler data a
handler toHint =
  Handler (\_ -> toHint)


{-| -}
map : (a -> msg) -> Handler data a -> Handler data msg
map f (Handler a) =
  Handler <| \ps s p -> f (a ps s p)


{-| -}
map2 : (a -> b -> msg) -> Handler data a -> Handler data b -> Handler data msg
map2 f (Handler a) (Handler b) =
  Handler <| \ps s p -> f (a ps s p) (b ps s p)


{-| -}
map3 : (a -> b -> c -> msg) -> Handler data a -> Handler data b -> Handler data c -> Handler data msg
map3 f (Handler a) (Handler b) (Handler c) =
  Handler <| \ps s p -> f (a ps s p) (b ps s p) (c ps s p)



-- HELPERS


getNearestHelp : List (Data.Data data) -> System -> Point -> Maybe (Data.Data data)
getNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest.point < distance_ point.point
            then closest
            else point
  in
  withFirst (List.filter .isReal points) (List.foldl getClosest)


getNearestXHelp : List (Data.Data data) -> System -> Point -> List (Data.Data data)
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
