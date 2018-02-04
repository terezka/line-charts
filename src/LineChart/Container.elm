module LineChart.Container exposing
  ( Config, Properties, Size, Margin
  , default, responsive, custom
  , relative, static
  )

{-|

@docs Config, default, responsive

# Customization
@docs custom, Properties, Margin

## Sizing
@docs Size, relative, static

-}

import Html
import Svg
import Internal.Container as Container



{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data Msg
    chartConfig =
      { ...
      , conatiner = Container.default
      , ...
      }

-}
type alias Config msg =
  Container.Config msg


{-| The default container configuration.

Pass the id.

_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Container/Example1.elm)._

-}
default : String -> Config msg
default =
  Container.default


{-| Makes the chart take the size of your container.

Pass the id.

_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Container/Example2.elm)._

-}
responsive : String -> Config msg
responsive =
  Container.responsive


{-| -}
type alias Properties msg =
  { attributesHtml : List (Html.Attribute msg)
  , attributesSvg : List (Svg.Attribute msg)
  , size : Container.Size
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


{-| Properties:

  - **attributesHtml** are attributes which will go on it's internal `div` container.
  - **attributesSvg** are attributes which will go on it's internal `svg` container.
  - **size** controls the size. See the `Size` type for options.
  - **margin** adds margin around the chart.
  - **id** sets the id. It's important for this to be unique for every chart
    on your page.


    containerConfig : Container.Config msg
    containerConfig =
      Container.custom
        { attributesHtml = [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
        , attributesSvg = []
        , size = Container.static
        , margin = Container.Margin 30 100 60 80
        , id = "chart-id"
        }


_See the full example [here](https://github.com/terezka/lines/blob/master/examples/Docs/Container/Example3.elm)._

-}
custom : Properties msg -> Config msg
custom =
  Container.custom



-- SIZE


{-| -}
type alias Size =
  Container.Size


{-| Makes the chart size relative to it's container
-}
relative : Size
relative =
  Container.relative


{-| Makes the chart the exact number of pixels defined in your x and y axis
 configuration.
-}
static : Size
static =
  Container.static
