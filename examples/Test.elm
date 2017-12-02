module Test exposing (..)

import Html exposing (Html)
import Lines
import Lines.Axis as Axis
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Dot as Dot
import Lines.Events as Events
import Lines.Junk as Junk exposing (..)
import Lines.Legends as Legends
import Lines.Line as Line
import Svg.Attributes as Attributes


main : Html msg
main =
    humanChart


type alias Info =
    { age : Float
    , weight : Float
    , height : Float
    , income : Float
    }


alice : List Info
alice =
    [ Info 4 24 0.94 0
    , Info 25 75 1.73 25000
    , Info 43 83 1.75 40000
    ]


bob : List Info
bob =
    [ Info 4 22 1.01 0
    , Info 25 75 1.87 -98000
    , Info 43 77 1.87 52000
    ]


chuck : List Info
chuck =
    [ Info 4 21 0.98 20000
    , Info 25 89 1.83 -85000
    , Info 43 95 1.84 120000
    ]


average : List Info
average =
    [ Info 4 22.3 1.0 0
    , Info 25 79.7 1.8 46000
    , Info 43 85 1.82 70667
    ]


humanChart : Html msg
humanChart =
    Lines.view .age
        .income
        [ Lines.area "darkgoldenrod" Dot.none "Chuck" 0.25 chuck
        , Lines.area "darkslateblue" Dot.none "Alice" 0.25 alice
        , Lines.area "darkturquoise" Dot.none "Bob" 0.25 bob
        , Lines.dash "rebeccapurple" Dot.none "Average" [ 2, 4 ] average
        ]


chartConfig : (data -> Float) -> (data -> Float) -> Lines.Config data msg
chartConfig toXValue toYValue =
    { frame = Coordinate.Frame (Coordinate.Margin 40 150 90 150) (Coordinate.Size 650 400)
    , attributes = [ Attributes.style "font-family: monospace;" ] -- Changed from the default!
    , events = Events.none
    , junk = Junk.none
    , x = Axis.default (Axis.defaultTitle "" 0 0) toXValue
    , y = Axis.default (Axis.defaultTitle "" 0 0) toYValue
    , interpolation = Lines.linear
    , legends = Legends.default
    , line = Line.default
    , dot = Dot.default
    }


bmi : Info -> Float
bmi person =
    person.weight / person.height ^ 2
