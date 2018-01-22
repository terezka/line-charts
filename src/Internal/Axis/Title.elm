module Internal.Axis.Title exposing (Config, Properties, default, byDataMax, at, custom, config)

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
  , xOffset : Float
  , yOffset : Float
  }


{-| -}
default : String -> Config msg
default title =
  custom
    { view = Svg.label "inherit" title
    , position = \data range -> range.max
    , xOffset = 0
    , yOffset = 0
    }


{-| -}
byDataMax : String -> Config msg
byDataMax title =
  custom
    { view = Svg.label "inherit" title
    , position = \data range -> Coordinate.smallestRange data range |> .max
    , xOffset = 0
    , yOffset = 0
    }


{-| -}
at : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Config msg
at position xOffset yOffset title =
  custom
    { view = Svg.label "inherit" title
    , position = position
    , xOffset = xOffset
    , yOffset = yOffset
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
