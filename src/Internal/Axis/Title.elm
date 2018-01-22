module Internal.Axis.Title exposing (Config, Properties, default, atDataMax, at, custom, config)

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
default : ( Float, Float ) -> String -> Config msg
default =
  at (\_ range -> range.max)


{-| -}
atDataMax : ( Float, Float ) -> String -> Config msg
atDataMax =
  at (\data range -> Basics.min data.max range.max)


{-| -}
at : (Coordinate.Range -> Coordinate.Range -> Float) -> ( Float, Float ) -> String -> Config msg
at position offset title =
  custom
    { view = Svg.label "inherit" title
    , position = position
    , offset = offset
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
config : Config msg -> Properties msg
config (Config title) =
  title
