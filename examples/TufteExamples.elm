module TufteExamples exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes
import Svg exposing (Svg, Attribute, text_, tspan, g)
import Lines exposing (..)
import Lines.Junk as Junk exposing (..)
import Lines.Color as Color
import Lines.Dot as Dot
import Lines.Axis as Axis exposing (defaultLook)
import Lines.Container as Container
import Lines.Legends as Legends


main : Html msg
main =
    view



-- VIEW


view : Svg msg
view =
  Html.div
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ exampleSimple
    , exampleCustomizeLines
    , exampleInterpolation
    ]


exampleSimple : Html msg
exampleSimple =
  Lines.viewSimple .x .y [ data1, data2, data3 ]


exampleCustomizeLines : Html msg
exampleCustomizeLines =
  Lines.view .x .y
    [ Lines.dash "#7c4dff" 1 square "First" "1 2" data1
    , Lines.dash "#f27c21" 2 Dot.none "Second" "4 2 2 2" data2
    , Lines.line "#00848f" 3 plus "Third" data3
    ]


plus : Dot.Dot msg
plus =
  Dot.plus [] 10 (Dot.disconnected 2)


square : Dot.Dot msg
square =
  Dot.square [] 7 (Dot.disconnected 2)


circle : Dot.Dot msg
circle =
  Dot.circle [] 3 (Dot.disconnected 2)


exampleInterpolation : Html msg
exampleInterpolation =
  Lines.viewCustom
    { container = Container.default
    , junk = Junk.none
    , x = Axis.defaultAxis .x
    , y = Axis.defaultAxis .y
    , interpolation = Lines.Monotone
    , legends = Legends.byEnding Legends.defaultLabel
    }
    [ Lines.line Color.blue 1 plus "Women" data1
    , Lines.line Color.orange 1 circle "Non-binary" data3
    , Lines.line Color.pink 1 square "Men" data2
    ]


-- DATA


type alias Data =
  { x : Float
  , y : Float
  }


data1 : List Data
data1 =
  [ Data 1 3
  , Data 2 4
  , Data 3 4.5
  , Data 4 5
  , Data 5 4.3
  , Data 6 5
  , Data 7 6.4
  , Data 8 6.7
  , Data 9 6.9
  , Data 10 9
  ]


data2 : List Data
data2 =
  [ Data 1 1
  , Data 2 2
  , Data 3 4
  , Data 4 7
  , Data 5 8
  , Data 6 8.2
  , Data 7 7
  , Data 8 4
  , Data 9 3
  , Data 10 6
  ]


data3 : List Data
data3 =
  [ Data 1 5
  , Data 2 5.7
  , Data 3 5.2
  , Data 4 6
  , Data 5 5.8
  , Data 6 5.2
  , Data 7 4
  , Data 8 3.6
  , Data 9 6
  , Data 10 7
  ]
