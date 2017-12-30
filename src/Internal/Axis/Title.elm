module Internal.Axis.Title exposing (Title, Config, default, at, custom, config)

import Svg exposing (Svg)
import Lines.Coordinate as Coordinate


{-| -}
type Title msg =
  Title (Config msg)


{-| -}
type alias Config msg =
  { view : Svg msg
  , position : Coordinate.Range -> Float
  , xOffset : Float
  , yOffset : Float
  }


{-| -}
default : String -> Title msg
default title =
  Title
    { view = viewText title
    , position = .max
    , xOffset = 0
    , yOffset = 0
    }


{-| -}
at : (Coordinate.Range -> Float) -> Float -> Float -> String -> Title msg
at position xOffset yOffset title =
  Title
    { view = viewText title
    , position = position
    , xOffset = xOffset
    , yOffset = yOffset
    }


{-| -}
custom : (Coordinate.Range -> Float) -> Float -> Float -> Svg msg -> Title msg
custom position xOffset yOffset view =
  Title
    { view = view
    , position = .max
    , xOffset = xOffset
    , yOffset = yOffset
    }



-- HELPERS


viewText : String -> Svg msg
viewText string =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text string ] ]



-- INTERNAL


{-| -}
config : Title msg -> Config msg
config (Title title) =
  title
