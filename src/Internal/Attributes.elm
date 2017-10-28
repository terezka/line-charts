module Internal.Attributes exposing (Attribute(..), toSvgAttributes)

{-| -}

import Svg
import Plot.Coordinate as Coordinate


{-| -}
type Attribute msg
    = Attribute (Coordinate.System -> Svg.Attribute msg)


{-| -}
toSvgAttributes : Coordinate.System -> List (Attribute msg) -> List (Svg.Attribute msg)
toSvgAttributes system =
    List.map (\(Attribute attribute) -> attribute system)
