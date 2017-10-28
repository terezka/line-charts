module Lines.Dot exposing (Dot, Config, Shape(..),default, none, dot, view, bordered, filled)

{-| -}

import Svg exposing (Svg)
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Internal.Primitives as Primitives


{-| -}
type Dot msg
  = Dot (Maybe (Config msg))


{-| -}
type Shape
  = Triangle
  | Diamond
  | Square
  | Circle
  | Cross
  | Plus
  | Star


{-| -}
type alias Config msg =
  { shape : Shape
  , events : List (Svg.Attribute msg)
  , size : Int
  , coloring : Coloring
  }


{-| -}
type alias Coloring
  = Primitives.Coloring


{-| -}
none : Dot msg
none =
  Dot Nothing


{-| -}
dot : Config msg -> Dot msg
dot config =
  Dot (Just config)


{-| -}
default : Color.Color -> Config msg
default color =
  Config Circle [] 5 filled


{-| -}
filled : Coloring
filled =
  Primitives.Filled


{-| -}
bordered : Int -> Coloring
bordered =
  Primitives.Bordered


{-| -}
view : Coordinate.System -> Color.Color -> Dot msg -> Coordinate.Point -> Svg msg
view system color (Dot config) point =
  Maybe.map (viewConfig system color point) config
    |> Maybe.withDefault (Svg.text "")



-- INTERNAL


viewConfig : Coordinate.System -> Color.Color -> Coordinate.Point -> Config msg -> Svg msg
viewConfig system color point config =
  case config.shape of
    Circle ->
      Primitives.viewCircle color config.coloring config.size system point -- TODO: Add event attributes

    _ ->
      Svg.text "" -- TODO
