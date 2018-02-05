module LineChart.Legends exposing
  ( Config, none, default
  , byEnding, byBeginning
  , grouped, groupedCustom, Legend
  )

{-|

@docs Config, default, none

## Free legends
Where the title is hanging by its respective line.

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/legends2.png?raw=true"></src>

@docs byEnding, byBeginning

## Grouped legends
Where the titles are gathered in one spot.

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/legends5.png?raw=true"></src>

@docs grouped, groupedCustom, Legend

-}

import Svg
import LineChart.Coordinate as Coordinate exposing (..)
import Internal.Legends as Legends



-- QUICK START


{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , legends = Legends.default
      , ...
      }

-}
type alias Config data msg
  = Legends.Config data msg


{-| Produces legends in the top right corner.
-}
default : Config data msg
default =
  Legends.default



-- OPTIONS


{-| Removes the legends.
-}
none : Config data msg
none =
  Legends.none



-- FREE


{-| Places the legend by the end of its line.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , legends = Legends.byEnding (Junk.label Colors.black)
      , ...
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Legends/Example1.elm)._

-}
byEnding : (String -> Svg.Svg msg) -> Config data msg
byEnding =
  Legends.byEnding


{-| Same as `byEnding`, except by the beginning of the line!
-}
byBeginning : (String -> Svg.Svg msg) -> Config data msg
byBeginning =
  Legends.byBeginning



-- GROUPED


{-| Draws some legends. You desicde where. Arguments:

  1. Given the x-axis range, you produce the x-coordinate in data-space of the legends.
  2. Given the y-axis range, you produce the y-coordinate of data-space the legends.
  3. Move the legends horizontally in SVG-space.
  4. Move the legends vertically in SVG-space.


    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , legends = Legends.grouped .max .min 0 -60 -- Bottom right corner
      , ...
      }


Makes this:

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/legends3.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Legends/Example2.elm)._

-}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config data msg
grouped =
  Legends.grouped


{-| Stuff that's helpful when you're drawing your legends.
A sample of your line as well your line's label.
-}
type alias Legend msg =
  { sample : Svg.Svg msg
  , label : String
  }


{-| Customize your grouped legends. Arguments:

  1. The width of the line samples.
  2. Your view function for the legends.


    legends : Legends data msg
    legends =
      Legends.groupedCustom 30 viewLegends


    viewLegends : Coordinate.System -> List (Legends.Legend msg) -> Svg.Svg msg
    viewLegends system legends =
      Svg.g
        [ Junk.transform
            [ Junk.move system system.x.min system.y.min
            , Junk.offset 20 20
            ]
        ]
        (List.indexedMap viewLegend legends)


    viewLegend : Int -> Legends.Legend msg -> Svg.Svg msg
    viewLegend index { sample, label } =
       Svg.g
        [ Junk.transform [ Junk.offset (toFloat index * 100) 20 ] ]
        [ sample, viewLabel label ]


    viewLabel : String -> Svg.Svg msg
    viewLabel label =
      Svg.g
        [ Junk.transform [ Junk.offset 40 4 ] ]
        [ Junk.label Colors.black label ]


Makes this:

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/legends4.png?raw=true"></src>


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Legends/Example3.elm)._


-}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config data msg
groupedCustom =
  Legends.groupedCustom
