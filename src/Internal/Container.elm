module Internal.Container exposing
  ( Config, Properties, Size, Margin
  , default, spaced, responsive, custom
  , relative, static
  , properties, sizeStyles
  )

{-| -}

import Svg
import Html



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
  custom
    { attributesHtml = []
    , attributesSvg = []
    , size = static
    , margin = Margin 60 140 60 80
    , id = id
    }


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
properties : Config msg -> Properties msg
properties (Config properties) =
  properties


{-| -}
sizeStyles : Config msg -> Float -> Float -> List ( String, String )
sizeStyles (Config properties) width height =
  case properties.size of
    Static ->
      [ ( "height", toString height ++ "px" )
      , ( "width", toString width ++ "px" )
      ]

    Relative ->
      []
