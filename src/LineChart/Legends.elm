module LineChart.Legends exposing
  ( Config, none, default
  , byEnding, byBeginning
  , grouped, groupedCustom, Legend
  )

{-|

# Quick start
@docs Config, default, none

# Options

## Free legends
Where the title is hanging by its respective line.
@docs byEnding, byBeginning

## Grouped legends
Where the titles are gathered in one spot.
@docs grouped, groupedCustom, Legend

-}

import Svg
import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Legends as Legends



-- QUICK START


{-| To be used in the `LineChart.Config` passed to `viewCustom` like this:

    chartConfig : LineChart.Config data msg
    chartConfig =
      { ...
      , legends = Legends.none -- Use here!
      , ...
      }

-}
none : Config data msg
none =
  Legends.none


{-| Produces your lines legends in the top right corner. Use like `none`.
-}
default : Config data msg
default =
  Legends.default



-- CONFIG


{-| -}
type alias Config data msg
  = Legends.Config data msg



-- FREE


{-| Places the label of your line by its end.

    chartConfig : LineChart.Config data msg
    chartConfig =
      { ...
      , legends = Legends.byEnding (Junk.text "black")
      , ...
      }

-}
byEnding : (String -> Svg.Svg msg) -> Config data msg
byEnding =
  Legends.byEnding


{-| Same as `byEnding`, except by the beginning!
-}
byBeginning : (String -> Svg.Svg msg) -> Config data msg
byBeginning =
  Legends.byBeginning



-- BUCKETED


{-| The two arguments constitute the position of the legend given the range of
the respective axes.

    chartConfig : LineChart.Config data msg
    chartConfig =
      { ...
      , legends = Legends.grouped .max .min -- Bottom right corner
      , ...
      }

-}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config data msg
grouped =
  Legends.grouped


{-| Everything you need to view a legend. A sample of your line as well your
line's label.
-}
type alias Legend msg =
  { sample : Svg.Svg msg
  , label : String
  }


{-| Customize your own grouped legends. The first argument is the width of the
samples you'd like from your lines (the little snippet of your line) and the
second is a fuction which gives you the `Coordinate.System` as well as a list
of your lines samples and labels (`List (Legend msg)`), so that you can put it
in a SVG container of your liking.

    legends : Legends data msg
    legends =
      Legends.groupedCustom 10 <| \system legends ->
        Svg.g
          [ Junk.transform [ Junk.move system 100 120 ] ]
          (List.indexedMap viewLegend legends)

    viewLegend : Int -> Legend msg -> Svg msg
    viewLegend index { sample, label } =
       Svg.g
        [ Junk.transform [ Junk.offset 20 (toFloat index * 20) ] ]
        [ sample
        , Svg.g
            [ Junk.transform [ Junk.offset 40 4 ] ]
            [ Junk.text Color.black label ]
        ]

-}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config data msg
groupedCustom =
  Legends.groupedCustom
