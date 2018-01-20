module Internal.Events exposing
    ( Events, default, none, hover, hoverX, click, custom
    , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on
    , Decoder, getSVG, getData, getNearest, getNearestX, getWithin, getWithinX
    , map, map2, map3
    -- INTERNAL
    , toChartAttributes
    , toContainerAttributes
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
    [ onMouseMove msg (getWithin 30)
    , onMouseLeave (msg Nothing)
    ]


{-| -}
hoverX : (List data -> msg) -> Events data msg
hoverX msg =
  custom
    [ onMouseMove msg getNearestX
    , onMouseLeave (msg [])
    ]


{-| -}
click : (Maybe data -> msg) -> Events data msg
click msg =
  custom
    [ onClick msg (getWithin 30) ]


{-| -}
custom : List (Event data msg) -> Events data msg
custom =
  Events



-- EVENT


{-| -}
type Event data msg
  = Event Bool (List (Data.Data data) -> System -> Svg.Attribute msg)


onClick : (a -> msg) -> Decoder data a -> Event data msg
onClick =
  on False "click"


{-| -}
onMouseMove : (a -> msg) -> Decoder data a -> Event data msg
onMouseMove =
  on False "mousemove"


{-| -}
onMouseDown : (a -> msg) -> Decoder data a -> Event data msg
onMouseDown =
  on False "mousedown"


{-| -}
onMouseUp : (a -> msg) -> Decoder data a -> Event data msg
onMouseUp =
  on False "mouseup"


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Event False <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : Bool -> String -> (a -> msg) -> Decoder data a -> Event data msg
on catchOutsideChart event toMsg decoder =
  Event catchOutsideChart <| \data system ->
    Svg.Events.on event (toJsonDecoder data system (map toMsg decoder))



-- INTERNAL


{-| -}
toChartAttributes : List (Data.Data data) -> System -> Events data msg -> List (Svg.Attribute msg)
toChartAttributes data system (Events events) =
  let
    order (Event outside event) =
      if outside then Nothing else Just (event data system)
  in
  List.filterMap order events


{-| -}
toContainerAttributes : List (Data.Data data) -> System -> Events data msg -> List (Svg.Attribute msg)
toContainerAttributes data system (Events events) =
  let
    order (Event outside event) =
      if outside then Just (event data system) else Nothing
  in
  List.filterMap order events



-- SEARCHERS


{-| -}
type Decoder data msg =
  Decoder (List (Data.Data data) -> System  -> Point -> msg)


{-| -}
getSVG : Decoder data Point
getSVG =
  Decoder <| \points system searched ->
    searched


{-| -}
getData : Decoder data Point
getData =
  Decoder <| \points system searchedSvg ->
    Coordinate.toData system searchedSvg


{-| -}
getNearest : Decoder data (Maybe data)
getNearest =
  Decoder <| \points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg
    in
    getNearestHelp points system searched
      |> Maybe.map .data


{-| TODO get _nearest_ within? -}
getWithin : Float -> Decoder data (Maybe data)
getWithin radius =
  Decoder <| \points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg

      keepIfEligible closest =
          if withinRadius system radius searched closest.point
            then Just closest.data
            else Nothing
    in
    getNearestHelp points system searched
      |> Maybe.andThen keepIfEligible


{-| -}
getNearestX : Decoder data (List data)
getNearestX =
  Decoder <| \points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg
    in
    getNearestXHelp points system searched
      |> List.map .data


{-| -}
getWithinX : Float -> Decoder data (List data)
getWithinX radius =
  Decoder <| \points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg

      keepIfEligible =
          withinRadiusX system radius searched << .point
    in
    getNearestXHelp points system searched
      |> List.filter keepIfEligible
      |> List.map .data



-- MAPS


{-| -}
map : (a -> msg) -> Decoder data a -> Decoder data msg
map f (Decoder a) =
  Decoder <| \ps s p -> f (a ps s p)


{-| -}
map2 : (a -> b -> msg) -> Decoder data a -> Decoder data b -> Decoder data msg
map2 f (Decoder a) (Decoder b) =
  Decoder <| \ps s p -> f (a ps s p) (b ps s p)


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder data a -> Decoder data b -> Decoder data c -> Decoder data msg
map3 f (Decoder a) (Decoder b) (Decoder c) =
  Decoder <| \ps s p -> f (a ps s p) (b ps s p) (c ps s p)



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


distanceX : System -> Point -> Point -> Float
distanceX system searched dot =
    abs <| toSVGX system dot.x - toSVGX system searched.x


distanceY : System -> Point -> Point -> Float
distanceY system searched dot =
    abs <| toSVGY system dot.y - toSVGY system searched.y


distance : System -> Point -> Point -> Float
distance system searched dot =
    sqrt <| distanceX system searched dot ^ 2 + distanceY system searched dot ^ 2


withinRadius : System -> Float -> Point -> Point -> Bool
withinRadius system radius searched dot =
    distance system searched dot <= radius


withinRadiusX : System -> Float -> Point -> Point -> Bool
withinRadiusX system radius searched dot =
    distanceX system searched dot <= radius



-- DECODER


{-| -}
toJsonDecoder : List (Data.Data data) -> System -> Decoder data msg -> Json.Decoder msg
toJsonDecoder data system (Decoder decoder) =
  let
    handle mouseX mouseY { left, top } =
      decoder data system <| Point (mouseX - left) (mouseY - top)
  in
  Json.map3 handle
    (Json.field "clientX" Json.float)
    (Json.field "clientY" Json.float)
    (DOM.target position)


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]
