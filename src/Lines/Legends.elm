module Lines.Legends exposing
  ( none, default
  , Legends, Legend
  , byEnding, byBeginning, defaultLabel
  , bucketed, bucketedCustom
  )

{-|

# Quick start
@docs none, default

# Customizations
@docs Legends

## Free legends
The ones hanging by the line.
@docs byEnding, byBeginning, defaultLabel

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
      , legends = Legends.byEnding Legends.defaultLabel
      , ...
      }

You can of course making your own label SVG elements to replace `defaultLabel`!

-}
byEnding : (String -> Svg.Svg msg) -> Legends msg
byEnding =
  Legends.Free Legends.Ending


{-| Same as `byEnding`, except by the beginning!
-}
byBeginning : (String -> Svg.Svg msg) -> Legends msg
byBeginning =
  Legends.Free Legends.Beginning


{-| The default label.

    defaultLabel : String -> Svg msg
    defaultLabel label =
      text_ [] [ tspan [] [ text label ] ]
-}
defaultLabel : String -> Svg.Svg msg
defaultLabel =
  Legends.defaultLabel


-- BUCKETED


{-| The two arguments constitute the position of the legend given the limits of
the respective axes.

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , legends = Legends.bucketed .max .min -- Bottom right corner
      , ...
      }

-}
bucketed : (Coordinate.Limits -> Float) -> (Coordinate.Limits -> Float) -> Legends msg
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
      Legends.bucketedCustom \system legends ->
        Svg.g
          [ Svg.transform [ Svg.move system 100 120 ] ]
          (List.indexedMap viewLegend legends)

    viewLegend : Int -> Legend msg -> Svg msg
    viewLegend index { sample, label } =
       Svg.g
        [ Svg.transform [ Svg.offset 20 (toFloat index * 20) ] ]
        [ sample
        , Svg.g
            [ Svg.transform [ Svg.offset 40 4 ] ]
            [ defaultLabel label ]
        ]

-}
bucketedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Legends msg
bucketedCustom =
  Legends.Bucketed
