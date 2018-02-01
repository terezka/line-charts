module Internal.Axis.Title exposing (Config, Properties, default, atAxisMax, atDataMax, atPosition, custom, config)

import Svg exposing (Svg)
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { view : Svg msg
  , position : Coordinate.Range -> Coordinate.Range -> Float
  , offset : ( Float, Float )
  }


{-| -}
default : String -> Config msg
default =
  atAxisMax 0 0


{-| -}
atAxisMax : Float -> Float -> String -> Config msg
atAxisMax =
  let position data range = range.max in
  atPosition position


{-| -}
atDataMax : Float -> Float -> String -> Config msg
atDataMax =
  let position data range = Basics.min data.max range.max in
  atPosition position


{-| -}
atPosition : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Config msg
atPosition position x y =
  custom position x y << Svg.label "inherit"


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> Svg msg -> Config msg
custom position x y title =
  Config
    { view = title
    , position = position
    , offset = ( x, y )
    }



-- INTERNAL


{-| -}
config : Config msg -> Properties msg
config (Config title) =
  title
