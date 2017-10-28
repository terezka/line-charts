module Lines.Dot exposing (Dot, Config, Shape(..),default, none, dot, view, defaultBorder)

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
  , color : Color.Color
  , border : Maybe Border
  }


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
  Config Circle [] 5 color Nothing


{-| -}
type alias Border =
  { color : Color.Color
  , width : Int
  }


{-| -}
defaultBorder : Border
defaultBorder =
  { color = Color.black
  , width = 1
  }



{-| -}
view : Coordinate.System -> Dot msg -> Coordinate.Point -> Svg msg
view system (Dot config) point =
  Maybe.map (viewConfig system point) config
    |> Maybe.withDefault (Svg.text "")



-- INTERNAL


viewConfig : Coordinate.System -> Coordinate.Point -> Config msg -> Svg msg
viewConfig system point config =
  case config.shape of
    Circle ->
      Primitives.viewCircle config.color config.size config.border system point -- TODO: Add event attributes

    _ ->
      Svg.text "" -- TODO
