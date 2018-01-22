module Internal.Axis.Title exposing (Title, Config, default, byDataMax, at, custom, config)

import Svg exposing (Svg)
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg



{-| -}
type Title msg =
  Title (Config msg)


{-| -}
type alias Config msg =
  { view : Svg msg
  , position : Coordinate.Range -> Coordinate.Range -> Float
  , xOffset : Float
  , yOffset : Float
  }


{-| -}
default : String -> Title msg
default title =
  Title
    { view = Svg.label "inherit" title
    , position = \data range -> range.max
    , xOffset = 0
    , yOffset = 0
    }


{-| -}
byDataMax : String -> Title msg
byDataMax title =
  Title
    { view = Svg.label "inherit" title
    , position = \data range -> Coordinate.smallestRange data range |> .max
    , xOffset = 0
    , yOffset = 0
    }


{-| -}
at : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Title msg
at position xOffset yOffset title =
  Title
    { view = Svg.label "inherit" title
    , position = position
    , xOffset = xOffset
    , yOffset = yOffset
    }


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> Svg msg -> Title msg
custom position xOffset yOffset view =
  Title
    { view = view
    , position = position
    , xOffset = xOffset
    , yOffset = yOffset
    }



-- INTERNAL


{-| -}
config : Title msg -> Config msg
config (Title title) =
  title
