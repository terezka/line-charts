module Lines.Axis.Time exposing
  ( default
  , defaultLook
  , defaultMark
  )

{-|

# Quick start
@docs default, defaultLook, defaultMark

-}

import Svg exposing (..)
import Svg.Attributes as Attributes
import Date
import Lines.Color as Color
import Lines.Axis as Axis
import Internal.DateTime.Unit as Unit


-- DEFAULTS


{-| The default axis configuration.

  - First argument is a `Title`, which you don't have to bother too
    much to figure out if you just use `defaultTitle`.
  - Second argument is the axis variable. This is a fuction to extract
    a value from your data.


    axis : Axis data msg
    axis =
      Axis.axisTime <| Axis.Time.default (Axis.Time.defaultTitle "Age" 0 0) .age
-}
default : Float -> Axis.Title msg -> (data -> Float) -> Axis.Axis data msg
default length title variable =
  { variable = variable
  , limitations = Axis.Limitations identity identity
  , look = defaultLook length title
  , length = length
  }


{-| The default look configuration is the following.

    defaultLook : Title msg -> Look msg
    defaultLook title =
      { title = title
      , offset = 20
      , position = Axis.towardsZero
      , line = Just (Axis.defaultLine [ Attributes.stroke Color.gray ])
      , marks = (\info -> List.map (defaultMark info.unit) info.positions) << Unit.positions 4
      , direction = Negative
      }

I recommend you copy the snippet into your code and mess around with it for a
but or check out the examples [here](TODO)

-}
defaultLook : Float -> Axis.Title msg -> Axis.Look msg
defaultLook length title =
  let
    numOfTicks =
      round (length / 170)
  in
  { title = title
  , offset = 20
  , position = Axis.towardsZero
  , line = Just (Axis.defaultLine [ Attributes.stroke Color.gray ])
  , marks = (\info -> List.map (defaultMark info.unit) info.positions) << Unit.positions numOfTicks
  , direction = Axis.Negative
  }


{-| The default mark configuration is the following.

    defaultMark : Unit.Unit -> Float -> Mark msg
    defaultMark unit position =
      { position = position
      , label = Just (defaultLabel position)
      , tick = Just defaultTick
      }
-}
defaultMark : Unit.Unit -> Float -> Axis.Mark msg
defaultMark unit position =
  let
    date =
      Date.fromTime position

    label =
      Unit.defaultFormatting unit date -- TODO how to format

    viewLabel =
      text_ [] [ tspan [] [ text label ] ]
  in
  { position = position
  , label = Just viewLabel
  , tick = Just Axis.defaultTick
  }
