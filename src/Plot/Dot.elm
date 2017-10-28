module Plot.Dot exposing (Dot(..), Config, Shape(..), Outline(..), none, dot)

{-| -}

import Svg
import Plot.Color as Color


{-| TODO: Make opaque -- also.. None? -}
type Dot msg
  = Dot (Config msg)
  | None


{-| -}
type Shape
  = Triangle
  | Diamond
  | Square
  | Circle Outline
  | Cross
  | Plus
  | Star


{-| -}
type Outline
  = NoOutline
  | Outline OutlineConfig


type alias OutlineConfig =
  { color : Color.Color
  , width : Int
  }


{-| -}
type alias Config msg =
  { shape : Shape
  , events : List (Svg.Attribute msg)
  , size : Int
  , color : Color.Color
  }


{-| -}
none : Dot msg
none =
  None


{-| -}
dot : Config msg -> Dot msg
dot =
  Dot
