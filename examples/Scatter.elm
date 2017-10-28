module ScatterExample exposing (main)

import Svg exposing (Svg)
import Html exposing (Html)
import Scatter as Scatter exposing (..)
import Plot.Coordinate as Coordinate exposing (..)
import Plot.Axis as Axis
import Plot.Junk as Junk
import Plot.Color as Color
import Plot.Container as Container
import Plot.Dot as Dot


main : Html msg
main =
  Html.div [] [ viewSimple, view ]


viewSimple : Svg msg
viewSimple =
  Scatter.viewSimple .lineOfCode .debuggingTime [ elm, javascript ]


view : Svg msg
view =
  Scatter.view .lineOfCode .debuggingTime
    [ group (circle Color.orange) elm
    , group (circle Color.green) javascript
    ]


viewCustom : Svg msg
viewCustom =
  Scatter.viewCustom
    { container = Container.default
    , x = Scatter.Axis Axis.defaultLook .lineOfCode
    , y = Scatter.Axis Axis.defaultLook .debuggingTime
    , junk = Junk.none
    }
    [ group (circle Color.orange) elm
    , group (circle Color.green) javascript
    ]


circle : Color.Color -> Dot.Config msg
circle =
  Dot.Config Dot.Circle [] 5


type alias Data2 =
  { lineOfCode : Float
  , debuggingTime : Float
  }


elm : List Data2
elm =
  [ Data2 1 4
  , Data2 5 7
  , Data2 3 6
  , Data2 9 3
  ]


javascript : List Data2
javascript =
  [ Data2 2 2
  , Data2 3 4
  , Data2 4 6
  , Data2 5 8
  ]
