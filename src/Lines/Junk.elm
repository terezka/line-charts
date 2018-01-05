module Lines.Junk exposing
  ( Junk, Layers, none, custom
  , Transfrom, transform, move, offset
  , vertical, horizontal, text
  )

{-|

# Quick start
@docs none

# Custom
@docs Junk, custom, Layers

# Common junk
@docs vertical, horizontal, text

# Placing helpers
@docs Transfrom, transform, move, offset


-}

import Html
import Svg
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate
import Lines.Color as Color
import Internal.Junk
import Internal.Svg as Svg



-- QUICK START


{-| No junk!
-}
none : Junk msg
none =
  Internal.Junk.Junk (\_ -> Layers [] [] [])



-- CUSTOMIZE


{-| Junk for all the stuff which I don't let you do in the library, so for
example if you want a picture of a kitten in the corner of your chart,
you can use junk to add that. To be used in the `Lines.Config` passed to
`viewCustom` like this:

    chartConfig : Lines.Config data msg
    chartConfig =
      { ...
      , junk = theJunk -- Use here!
      , ...
      }


-}
type alias Junk msg =
  Internal.Junk.Junk msg


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
you want in the resulting `Layers` type. Here's an example of adding grid lines.

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
custom : (Coordinate.System -> Layers msg) -> Junk msg
custom =
  Internal.Junk.Junk



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


{-| A grid line that takes up the full length of your vertical axis.

    theJunk : Info -> Junk.Junk msg
    theJunk info =
      Junk.custom <| \system ->
        { below = gridLines
        , above = []
        , html = []
        }

    gridLines : Coordinate.System -> List (Svg msg)
    gridLines system =
      List.map (Junk.vertical system []) (Axis.defaultInterval system.x) -- TODO
-}
vertical : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
vertical system attributes at =
  Svg.vertical system attributes at system.y.min system.y.max


{-| A grid line that takes up the full length of your horizontal axis.
-}
horizontal : Coordinate.System -> List (Svg.Attribute msg) -> Float -> Svg.Svg msg
horizontal system attributes at =
  Svg.horizontal system attributes at system.x.min system.x.max



-- HELPERS


{-| -}
text : Color.Color -> String -> Svg.Svg msg
text color string =
  Svg.text_ [ Attributes.fill color ] [ Svg.tspan [] [ Svg.text string ] ]
