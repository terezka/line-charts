module Internal.Events exposing
    ( Config, default, hoverMany, hoverOne, click, custom
    , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options
    , Decoder, getSvg, getData, getNearest, getNearestX, getWithin, getWithinX
    , map, map2, map3
    -- INTERNAL
    , toChartAttributes
    , toContainerAttributes
    )

{-| -}

import DOM
import Svg
import Svg.Events
import Html.Events
import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Data as Data
import Internal.Utils exposing (withFirst)
import Json.Decode as Json



{-| -}
type Config data msg
  = Config (List (Event data msg))


{-| -}
default : Config data msg
default =
  custom []


{-| -}
hoverMany : (List data -> msg) -> Config data msg
hoverMany msg =
  custom
    [ onMouseMove msg getNearestX
    , onMouseLeave (msg [])
    ]


{-| -}
hoverOne : (Maybe data -> msg) -> Config data msg
hoverOne msg =
  custom
    [ onMouseMove msg (getWithin 30)
    , on "touchstart" msg (getWithin 100)
    , on "touchmove" msg (getWithin 100)
    , onMouseLeave (msg Nothing)
    ]


{-| -}
click : (Maybe data -> msg) -> Config data msg
click msg =
  custom
    [ onClick msg (getWithin 30) ]


{-| -}
custom : List (Event data msg) -> Config data msg
custom =
  Config



-- EVENT


{-| -}
type Event data msg
  = Event Bool (List (Data.Data data) -> System -> Svg.Attribute msg)


onClick : (a -> msg) -> Decoder data a -> Event data msg
onClick =
  on "click"


{-| -}
onMouseMove : (a -> msg) -> Decoder data a -> Event data msg
onMouseMove =
  on "mousemove"


{-| -}
onMouseDown : (a -> msg) -> Decoder data a -> Event data msg
onMouseDown =
  on "mousedown"


{-| -}
onMouseUp : (a -> msg) -> Decoder data a -> Event data msg
onMouseUp =
  on "mouseup"


{-| -}
onMouseLeave : msg -> Event data msg
onMouseLeave msg =
  Event False <| \_ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> (a -> msg) -> Decoder data a -> Event data msg
on event toMsg decoder =
  Event False <| \data system ->
    let defaultOptions = Options False False False in
    Svg.Events.custom event (toJsonDecoder defaultOptions data system (map toMsg decoder))


{-| -}
onWithOptions : String -> Options -> (a -> msg) -> Decoder data a -> Event data msg
onWithOptions event options toMsg decoder =
  Event options.catchOutsideChart <| \data system ->
    Html.Events.custom event (toJsonDecoder options data system (map toMsg decoder))


{-| -}
type alias Options =
  { stopPropagation : Bool
  , preventDefault : Bool
  , catchOutsideChart : Bool
  }


-- INTERNAL


{-| -}
toChartAttributes : List (Data.Data data) -> System -> Config data msg -> List (Svg.Attribute msg)
toChartAttributes data system (Config events) =
  let
    order (Event outside event) =
      if outside then Nothing else Just (event data system)
  in
  List.filterMap order events


{-| -}
toContainerAttributes : List (Data.Data data) -> System -> Config data msg -> List (Svg.Attribute msg)
toContainerAttributes data system (Config events) =
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
getSvg : Decoder data Point
getSvg =
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
      |> Maybe.map .user


{-| -}
getWithin : Float -> Decoder data (Maybe data)
getWithin radius =
  Decoder <| \points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg

      keepIfEligible closest =
          if withinRadius system radius searched closest.point
            then Just closest.user
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
      |> List.map .user


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
      |> List.map .user



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
    abs <| toSvgX system dot.x - toSvgX system searched.x


distanceY : System -> Point -> Point -> Float
distanceY system searched dot =
    abs <| toSvgY system dot.y - toSvgY system searched.y


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
toJsonDecoder : Options -> List (Data.Data data) -> System -> Decoder data msg -> Json.Decoder { message : msg, stopPropagation : Bool, preventDefault : Bool}
toJsonDecoder options data system (Decoder decoder) =
  let
    handle mouseX mouseY { left, top, height, width } =
      let
        widthPercent = width / system.frame.size.width
        heightPercent = height / system.frame.size.height

        newSize =
          { width = width
          , height = height
          }

        newMargin =
          { top = system.frame.margin.top * heightPercent
          , right = system.frame.margin.right * widthPercent
          , bottom = system.frame.margin.bottom * heightPercent
          , left = system.frame.margin.left * widthPercent
          }

        newSystem =
          { system | frame = { size = newSize, margin = newMargin } }

        x = (mouseX - left)
        y = (mouseY - top)
      in
      decoder data newSystem (Point x y)

    withOptions msg =
      { message = msg
      , stopPropagation = options.stopPropagation
      , preventDefault = options.preventDefault
      }
  in
  Json.map3 handle
    (Json.field "pageX" Json.float) -- TODO
    (Json.field "pageY" Json.float)
    (DOM.target position)
    |> Json.map withOptions


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]
