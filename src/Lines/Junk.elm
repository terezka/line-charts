module Lines.Junk exposing
  ( Junk, Layers, none, custom
  , translate, translateWithOffset, translateFree, transform, place, placeWithOffset
  )


{-|

## Placing
@docs translate, translateWithOffset, translateFree, transform, place, placeWithOffset

-}

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes
import Html exposing (Html)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Junk


{-| -}
type alias Junk msg =
  Internal.Junk.Junk msg


{-| -}
type alias Layers msg =
  { above : List (Svg msg)
  , below : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
none : Junk msg
none =
  Internal.Junk.Junk (\_ _ -> Layers [] [] [])


{-| -}
custom : (Coordinate.System -> Layers msg) -> Junk msg
custom toJunk =
  Internal.Junk.Junk (\_ -> toJunk)



-- PLACING


{-| -}
translate : Coordinate.System -> Float -> Float -> String
translate system x y =
  "translate(" ++ (toString <| toSVG X system x) ++ ", " ++ (toString <| toSVG Y system y) ++ ")"


{-| -}
translateWithOffset : System -> Float -> Float -> Float -> Float -> String
translateWithOffset system x y offsetX offsetY =
  "translate("
    ++ (toString <| toSVG X system x + offsetX)
    ++ ", "
    ++ (toString <| toSVG Y system y + offsetY)
    ++ ")"


{-| TODO -}
translateFree : Float -> Float -> String
translateFree offsetX offsetY =
  "translate("
    ++ (toString offsetX)
    ++ ", "
    ++ (toString offsetY)
    ++ ")"


{-| -}
transform : List String -> Attribute msg
transform transformers =
  Attributes.transform <|
    String.join ", " transformers


{-| -}
place : System -> Float -> Float -> Attribute msg
place system x y =
  transform [ translate system x y ]


{-| -}
placeWithOffset : System -> Float -> Float -> Float -> Float -> Attribute msg
placeWithOffset system x y offsetX offsetY =
  transform [ translateWithOffset system x y offsetX offsetY ]
