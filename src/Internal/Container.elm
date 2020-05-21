module Internal.Container exposing
  ( Config, Properties, Size, Margin
  , default, spaced, styled, responsive, custom
  , relative, static
  , properties, sizeStyles
  )

{-| -}

import Svg
import Html
import Html.Attributes



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { attributesHtml : List (Html.Attribute msg)
  , attributesSvg : List (Svg.Attribute msg)
  , size : Size
  , margin : Margin
  , id : String
  }


{-| -}
type Size
  = Static
  | Relative


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }


{-| -}
default : String -> Config msg
default id =
  styled id []


{-| -}
spaced : String -> Float -> Float -> Float -> Float -> Config msg
spaced id top right bottom left =
  custom
    { attributesHtml = []
    , attributesSvg = []
    , size = static
    , margin = Margin top right bottom left
    , id = id
    }


{-| -}
styled : String -> List ( String, String ) -> Config msg
styled id styles =
  custom
    { attributesHtml = List.map (\(p, v) -> Html.Attributes.style p v) styles
    , attributesSvg = []
    , size = static
    , margin = Margin 60 140 60 80
    , id = id
    }


{-| -}
responsive : String -> Config msg
responsive id =
  custom
    { attributesHtml = []
    , attributesSvg = []
    , size = relative
    , margin = Margin 60 140 60 80
    , id = id
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config


{-| -}
relative : Size
relative =
  Relative


{-| -}
static : Size
static =
  Static



-- INTERNAL


{-| -}
properties : (Properties msg -> a) -> Config msg -> a
properties f (Config properties_) =
  f properties_


{-| -}
sizeStyles : Config msg -> Float -> Float -> List (Html.Attribute msg)
sizeStyles (Config properties_) width height =
  case properties_.size of
    Static ->
      [ Html.Attributes.style "height" (String.fromFloat height ++ "px")
      , Html.Attributes.style "width" (String.fromFloat width ++ "px")
      ]

    Relative ->
      []
