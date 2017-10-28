module TufteExamples exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes
import Svg exposing (Svg, Attribute, text_, tspan, g)
import Scatter exposing (..)
import Plot.Junk as Junk exposing (..)
import Plot.Color as Color
import Plot.Dot as Dot
import Plot.Axis as Axis exposing (defaultLook)
import Plot.Container as Container

main : Html msg
main =
    view



-- VIEW


view : Svg msg
view =
  Html.div
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ viewScatter ]


viewScatter : Html msg
viewScatter =
  Scatter.viewCustom
    { container = Container.default
    , junk = Junk.none
    , x = Scatter.Axis { defaultLook | offset = 20 } .x
    , y = Scatter.Axis { defaultLook | offset = 20 } .y
    }
    [ Scatter.groupCustom full (trend { defaultTrendConfig | space = 0 }) data1
    , Scatter.groupCustom empty (trend defaultTrendConfig) data2
    ]



-- DOTS


full : Dot.Config msg
full =
  Dot.Config (Dot.Circle Dot.NoOutline) [] 3 Color.black


empty : Dot.Config msg
empty =
  Dot.Config (Dot.Circle outline) [] 3 Color.transparent


outline : Dot.Outline
outline =
  Dot.Outline
    { color = Color.black
    , width = 1
    }



-- DATA


type alias Data =
  { x : Float
  , y : Float
  }


data1 : List Data
data1 =
  [ Data 1 3
  , Data 2 4
  , Data 2.4 4.5
  , Data 3 5
  , Data 3.5 4.3
  , Data 4 4.5
  ]


data2 : List Data
data2 =
  [ Data 4 5
  , Data 5 5.7
  , Data 5.5 5.2
  , Data 6 6
  , Data 6.5 5.8
  , Data 7 5.2
  ]


data3 : List Data
data3 =
  [ Data 2 5
  , Data 3 2
  , Data 4 8
  , Data 5 4
  ]
