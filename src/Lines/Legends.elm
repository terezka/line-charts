module Lines.Legends exposing
  ( none, default
  , Legends, Legend
  , byEnding, byBeginning
  , bucketed, bucketedCustom
  )

{-|

# Quick start
@docs none, default

# Customizations
@docs Legends

## Free legends
The ones hanging by the line.
@docs byEnding, byBeginning

## Bucketed legends
The ones gathered in one spot.
@docs bucketed, bucketedCustom, Legend

-}

import Svg
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Legends as Legends



-- QUICK START


{-| To be used in the `Lines.Config` passed to `viewCustom` like this:

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , legends = Legends.none -- Use here!
      , ...
      }

-}
none : Legends msg
none =
  Legends.None


{-| Produces your lines legends in the top right corner. Use like `none`.
-}
default : Legends msg
default =
  Legends.default



-- CONFIG


{-| -}
type alias Legends msg
  = Legends.Legends msg



-- FREE


{-| Places the label of your line by its end.

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , legends = Legends.byEnding (Junk.text "black")
      , ...
      }

-}
byEnding : (String -> Svg.Svg msg) -> Legends msg
byEnding =
  Legends.Free Legends.Ending


{-| Same as `byEnding`, except by the beginning!
-}
byBeginning : (String -> Svg.Svg msg) -> Legends msg
byBeginning =
  Legends.Free Legends.Beginning



-- BUCKETED


{-| The two arguments constitute the position of the legend given the range of
the respective axes.

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , legends = Legends.bucketed .max .min -- Bottom right corner
      , ...
      }

-}
bucketed : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Legends msg
bucketed =
  Legends.bucketed


{-| Everything you need to view a legend. A sample of your line as well your
line's label.
-}
type alias Legend msg =
  { sample : Svg.Svg msg
  , label : String
  }


{-| Customize your own bucketed legends. The first argument is the width of the
samples you'd like from your lines (the little snippet of your line) and the
second is a fuction which gives you the `Coordinate.System` as well as a list
of your lines samples and labels (`List (Legend msg)`), so that you can put it
in a SVG container of your liking.

    legends : Legends msg
    legends =
      Legends.bucketedCustom 10 <| \system legends ->
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
bucketedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Legends msg
bucketedCustom =
  Legends.Bucketed
