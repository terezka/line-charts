module LineChart.Junk exposing
  ( Config, Layers, default, custom
  , Transfrom, transform, move, offset
  , vertical, horizontal, verticalCustom, horizontalCustom
  , rectangle, label
  , withinChartArea
  )

{-|

# Quick start
@docs default

# Custom
@docs Config, custom, Layers

# Common junk

## Lines
@docs vertical, horizontal, verticalCustom, horizontalCustom

## Other
@docs rectangle, label, withinChartArea

# Placing helpers
@docs Transfrom, transform, move, offset


-}

import Html
import Svg
import Svg.Attributes as Attributes
import LineChart.Coordinate as Coordinate
import Internal.Junk as Junk
import Internal.Svg as Svg
import Internal.Utils as Utils
import Color
import Color.Convert



-- QUICK START


{-| The default is no junk!
-}
default : Config msg
default =
  Junk.none



-- CUSTOMIZE


{-| Junk for all the stuff which I don't let you do in the library, so for
example if you want a picture of a kitten in the corner of your chart,
you can use junk to add that. To be used in the `LineChart.Config` passed to
`viewCustom` like this:

    chartConfig : LineChart.Config data msg
    chartConfig =
      { ...
      , junk = theJunk -- Use here!
      , ...
      }

-}
type alias Config msg =
  Junk.Config msg


{-| The layers where you can put your junk. Junk in the `below` property will
be placed below your lines, Junk in the `above` property will
be placed above your lines, and the `html` junk will be placed on top on the
chart entirely.

-}
type alias Layers msg =
  { below : List (Svg.Svg msg)
  , above : List (Svg.Svg msg)
  , html : List (Html.Html msg)
  }


{-| Here is where you start producing your junk. You have the `System`
available, meaning you can translate your charts coordinates into SVG
coordinates and move things around easily. You add your elements to the "layer"
you want in the resulting `Layers` type. Here's an example of adding grid LineChart.

    theJunk : Info -> Junk.Junk msg
    theJunk info =
      Junk.custom <| \system ->
        { below = gridLines
        , above = []
        , html = []
        }

    gridLines : Coordinate.System -> List (Svg msg)
    gridLines system =
      List.map (Junk.horizontal system []) (Axis.defaultInterval system.y)

-}
custom : (Coordinate.System -> Layers msg) -> Config msg
custom =
  Junk.Config



-- PLACING HELPERS


{-| -}
type alias Transfrom =
  Svg.Transfrom


{-| Moves in chart space.
-}
move : Coordinate.System -> Float -> Float -> Transfrom
move =
  Svg.move


{-| Moves in SVG space.
-}
offset : Float -> Float -> Transfrom
offset =
  Svg.offset


{-| Produces a SVG transform attributes. Useful to move elements around in
your junk.

    movedStuff : Coordinate.System -> Info -> Svg msg
    movedStuff system hovered =
      Svg.g
        [ Junk.transform
            [ Junk.move system hovered.age hovered.weight
            , Junk.offset 20 10
            ]
        ]
        [ theStuff ]

-}
transform : List Transfrom -> Svg.Attribute msg
transform =
  Svg.transform



-- COMMON


{-| -}
vertical : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
vertical system attributes at =
  Svg.vertical system (withinChartArea system :: attributes) at system.y.min system.y.max


{-| -}
horizontal : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
horizontal system attributes at =
  Svg.horizontal system (withinChartArea system :: attributes) at system.x.min system.x.max


{-| -}
verticalCustom : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float -> Float -> Svg.Svg msg
verticalCustom system attributes =
  Svg.vertical system (withinChartArea system :: attributes)


{-| -}
horizontalCustom : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float ->  Float -> Svg.Svg msg
horizontalCustom system attributes =
  Svg.horizontal system (withinChartArea system :: attributes)


{-| A rectangle within the plot area. This can be used for grid bands
and highlighting a range e.g. for selection.

    xSelectionArea : Coordinate.System -> (Float, Float) -> Svg msg
    xSelectionArea system (startX, endX) =
        Junk.rectangle system [ Attributes.fill "rgba(255,0,0,0.1)" ] startX endX system.y.min system.y.max

-}
rectangle : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Float -> Float -> Float -> Svg.Svg msg
rectangle system attributes =
  Svg.rectangle system (withinChartArea system :: attributes)



-- HELPERS


{-| -}
label : Color.Color -> String -> Svg.Svg msg
label color =
  Svg.label (Color.Convert.colorToHex color)


{-| -}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea { id } =
  Attributes.clipPath <| "url(#" ++ Utils.toChartAreaId id ++ ")"
