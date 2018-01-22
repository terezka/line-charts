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
default : String -> Config msg
default =
  at (\data range -> range.max) ( 0, 0 )


{-| -}
atDataMax : String -> Config msg
atDataMax =
  at (\data range -> Basics.min data.max range.max) ( 0, 0 )


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
