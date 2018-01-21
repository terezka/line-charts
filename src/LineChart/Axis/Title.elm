module LineChart.Axis.Title exposing (Title, default, at, custom)

{-|

# Quick start
@docs Title, default

# Configurations
@docs at

# Customiztion
@docs custom

-}

import Svg exposing (Svg)
import Internal.Axis.Title as Title
import LineChart.Coordinate as Coordinate


{-| -}
type alias Title msg =
  Title.Title msg


{-| Place a given string title by the maximum of your axis.
-}
default : String -> Title msg
default =
  Title.default


{-| Place your string title in a spot along your axis.

  Arguments:
  1. Given the data range and axis range, provide a position.
  2. The x offset in SVG space.
  3. The y offset in SVG space.


    title : Title.Title Msg
    title =
      Title.at .max 10 20 "BMI"

-}
at : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Title msg
at =
  Title.at


{-| Same as `at` except instead of a string title, you pass a SVG title.


    title : Title.Title Msg
    title =
      Title.custom .max 10 20 (Junk.text Color.pink "BMI")
-}
custom : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> Svg msg -> Title msg
custom =
  Title.custom
