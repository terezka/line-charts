module LineChart.Axis.Title exposing (Config, default, atAxisMax, atDataMax, atPosition, custom)

{-|

@docs Config, default, atAxisMax, atDataMax, atPosition, custom

-}

import Svg exposing (Svg)
import Internal.Axis.Title as Title
import LineChart.Coordinate as Coordinate



{-| Part of the configuration in `Axis.custom`.

    axisConfig : Axis.Config Data msg
    axisConfig =
      Axis.custom
        { title = Title.default
        , ...
        }

-}
type alias Config msg =
  Title.Config msg


{-| Place the title at the maxima of your axis range.
-}
default : String -> Config msg
default =
  Title.default


{-| Place the title at the maxima of your data range. Arguments:

  1. The x offset in SVG-space.
  2. The y offset in SVG-space.
  3. The title.


    titleConfig : Title.Config msg
    titleConfig =
      Title.atDataMax 0 10 "Age"


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Title/Example1.elm)._

-}
atDataMax : Float -> Float -> String -> Config msg
atDataMax =
  Title.atDataMax


{-| Place the title at the maxima of your axis range. Arguments:

  1. The x offset in SVG-space.
  2. The y offset in SVG-space.
  3. The title.


    titleConfig : Title.Config msg
    titleConfig =
      Title.atAxisMax 0 10 "Age"


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Title/Example1.elm)._

-}
atAxisMax : Float -> Float -> String -> Config msg
atAxisMax =
  Title.atAxisMax


{-| Place your title in any spot along your axis. Arguments:

  1. Given the data range and axis range, provide a position.
  2. The x offset in SVG-space.
  3. The y offset in SVG-space.
  4. The title.


    titleConfig : Title.Config msg
    titleConfig =
      let position dataRange axisRange = 80 in
      Title.atPosition position -15 30 "Weight"


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Title/Example1.elm)._

-}
atPosition : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Config msg
atPosition =
  Title.atPosition


{-| Almost the same as `atPosition` except instead of a string title, you pass a
SVG title. Arguments:

  1. Given the data range and axis range, provide a position.
  2. The x offset in SVG-space.
  3. The y offset in SVG-space.
  4. The title view.


    titleConfig : Title.Config msg
    titleConfig =
      let position dataRange axisRange = middle axisRange in
      Title.custom position -10 35 <|
        Svg.g
          [ Svg.Attributes.style "text-anchor: middle;" ]
          [ Junk.label Colors.pink "Weight" ]

    middle : Coordinate.Range -> Float
    middle { min, max } =
      min + (max - min) / 2


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Title/Example1.elm)._

-}
custom : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> (Svg msg) -> Config msg
custom =
  Title.custom
