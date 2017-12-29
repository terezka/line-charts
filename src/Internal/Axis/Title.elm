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
at : String -> (Coordinate.Range -> Float) -> (Float, Float) -> Title msg
at title position (xOffset, yOffset) =
  Title
    { view = viewText title
    , position = .max
    , xOffset = xOffset
    , yOffset = yOffset
    }


{-| -}
custom : Svg msg -> (Coordinate.Range -> Float) -> (Float, Float) -> Title msg
custom view position (xOffset, yOffset) =
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


--


{-| -}
config : Title msg -> Config msg
config (Title title) =
  title
