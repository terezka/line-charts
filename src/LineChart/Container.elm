module LineChart.Container exposing
  ( Config, Properties, Size, Margin
  , default, responsive, custom
  , relative, static
  )

{-| -}

import Html
import Svg
import Internal.Container as Container



{-| -}
type alias Config msg =
  Container.Config msg


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }


{-| -}
default : String -> Config msg
default =
  Container.default


{-| -}
responsive : String -> Config msg
responsive =
  Container.responsive


{-| -}
type alias Properties msg =
  { attributesHtml : List (Html.Attribute msg)
  , attributesSVG : List (Svg.Attribute msg)
  , size : Container.Size
  , margin : Margin
  , id : String
  }


{-| -}
custom : Properties msg -> Config msg
custom =
  Container.custom



-- SIZE


{-| -}
type alias Size =
  Container.Size


{-| -}
relative : Size
relative =
  Container.relative


{-| -}
static : Size
static =
  Container.static
