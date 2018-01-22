module LineChart.Axis.Title exposing (Config, default, atDataMax, at, custom, Properties)

{-|

# Quick start
@docs Title, default

# Configurations
@docs atDataMax, at

# Customiztion
@docs custom, Properties

-}

import Svg exposing (Svg)
import Internal.Axis.Title as Title
import LineChart.Coordinate as Coordinate



{-| -}
type alias Config msg =
  Title.Config msg


{-| Place a given string title by the maximum of your axis.
-}
default : String -> Config msg
default =
  Title.default


{-| -}
atDataMax : String -> Config msg
atDataMax =
  Title.atDataMax


{-| Place your string title in a spot along your axis.

  Arguments:
  1. Given the data range and axis range, provide a position.
  2. The x offset in SVG space.
  3. The y offset in SVG space.


    title : Title.Title Msg
    title =
      Title.at .max 10 20 "BMI"

-}
at : (Coordinate.Range -> Coordinate.Range -> Float) -> ( Float, Float ) -> String -> Config msg
at =
  Title.at



{-| -}
type alias Properties msg =
  { view : Svg msg
  , position : Coordinate.Range -> Coordinate.Range -> Float
  , offset : ( Float, Float )
  }


{-| Same as `at` except instead of a string title, you pass a SVG title.


    title : Title.Title Msg
    title =
      Title.custom .max 10 20 (Junk.text Color.pink "BMI")
-}
custom : Properties msg -> Config msg
custom =
  Title.custom
