module LineChart.Container exposing (Config, Margin, default)

{-| -}

import Html
import Svg


{-| -}
type alias Config msg =
  { attributes : List (Html.Attribute msg)
  , attributesSVG : List (Svg.Attribute msg)
  , margin : Margin
  , id : String
  }


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
  { attributes = []
  , attributesSVG = []
  , margin = Margin 150 150 150 150
  , id = id
  }
