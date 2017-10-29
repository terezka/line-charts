module Lines.Attributes exposing (..)

import Svg
import Svg.Attributes
import Svg.Events
import DOM
import Json.Decode as Json
import Lines.Coordinate as Coordinate exposing (Orientation(..))
import Internal.Attributes exposing (Attribute(..))


{-| -}
type alias Attribute msg =
  Internal.Attributes.Attribute msg


{-| -}
background : String -> Attribute msg
background =
  custom << Svg.Attributes.fill


{-| -}
id : String -> Attribute msg
id =
  custom << Svg.Attributes.id


{-| -}
custom : Svg.Attribute msg -> Attribute msg
custom attribute =
  Attribute (\_ -> attribute)


{-| -}
type alias Point =
  { x : Float, y : Float }


{-| -}
onClick : (Point -> msg) -> Attribute msg
onClick msg =
  Attribute <| \system -> Svg.Events.on "click" (decoder system msg)


{-| -}
onMouseMove : (Point -> msg) -> Attribute msg
onMouseMove msg =
  Attribute <| \system -> Svg.Events.on "mousemove" (decoder system msg)


{-| -}
onMouseLeave : msg -> Attribute msg
onMouseLeave msg =
  Attribute <| \_ -> Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> (Point -> msg) -> Attribute msg
on event msg =
  Attribute <| \system -> Svg.Events.on event (decoder system msg)



-- INTERNAL


decoder : Coordinate.System -> (Point -> msg) -> Json.Decoder msg
decoder system msg =
  Json.map5
    translate
    (Json.succeed system)
    (Json.succeed msg)
    (Json.field "clientX" Json.float)
    (Json.field "clientY" Json.float)
    (DOM.target position)


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]


translate : Coordinate.System -> (Point -> msg) -> Float -> Float -> DOM.Rectangle -> msg
translate system msg mouseX mouseY { left, top } =
  msg <|
    { x = clamp system.x.min system.x.max <| Coordinate.toCartesian X system (mouseX - left)
    , y = clamp system.y.min system.y.max <| Coordinate.toCartesian Y system (mouseY - top)
    }
