module Test exposing (..)


import Html exposing (Html)
import Svg.Attributes as Attributes
import Lines
import Lines.Dot as Dot
import Lines.Axis as Axis
import Lines.Coordinate as Coordinate exposing (..)
import Lines.Dot as Dot
import Lines.Events as Events
import Lines.Junk as Junk exposing (..)
import Lines.Legends as Legends
import Lines.Line as Line


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
  , Info 25 75 1.87 28000
  , Info 43 77 1.87 52000
  ]

chuck : List Info
chuck =
  [ Info 4 21 0.98 0
  , Info 25 89 1.83 85000
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
  Lines.view .age .income
    [ Lines.line "darkslateblue" Dot.plus "Alice" alice
    , Lines.line "darkturquoise" Dot.diamond "Bob" bob
    , Lines.line "darkgoldenrod" Dot.triangle "Chuck" chuck
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


calcAverage : List (List Info) -> List Info -> List Info
calcAverage people avaragesOfPeople =
  if List.head (List.head people |> Maybe.withDefault []) == Nothing then
    avaragesOfPeople
  else
    let
      amount =
        toFloat (List.length people)

      aggregate info total =
        { age = total.age + info.age
        , weight = total.weight + info.weight
        , height = total.height + info.height
        , income = total.income + info.income
        }

      divide total =
        { age = total.age / amount
        , weight = total.weight / amount
        , height = total.height / amount
        , income = total.income / amount
        }

      averageOfInfo infos =
        List.foldl aggregate (Info 0 0 0 0) infos |> divide

      avarageOfPeople =
        List.filterMap List.head people |> averageOfInfo

      newAvaragesOfPeople =
         avarageOfPeople :: avaragesOfPeople

      nextPeople =
        List.map (List.tail >> Maybe.withDefault []) people
    in
      calcAverage nextPeople newAvaragesOfPeople


bmi : Info -> Float
bmi person =
  person.weight / person.height ^ 2
