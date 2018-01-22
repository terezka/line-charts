module Internal.Area
  exposing
    ( Config(..), default, none, percentage, normal, stacked
    , hasArea, opacity, opacitySingle, opacityContainer
    )

{-| -}



{-| -}
type Config
  = None
  | Normal Float
  | Stacked Float
  | Percentage Float


{-| -}
default : Config
default =
  none


{-| -}
none : Config
none =
  None


{-| -}
normal : Float -> Config
normal =
  Normal


{-| -}
stacked : Float -> Config
stacked =
  Stacked


{-| -}
percentage : Float -> Config
percentage =
  Percentage



-- INTERNAL


{-| -}
hasArea : Config -> Bool
hasArea config =
  case config of
    None         -> False
    Normal _     -> True
    Stacked _    -> True
    Percentage _ -> True


{-| -}
opacity : Config -> Float
opacity config =
  case config of
    None               -> 0
    Normal opacity     -> opacity
    Stacked opacity    -> opacity
    Percentage opacity -> opacity


{-| -}
opacitySingle : Config -> Float
opacitySingle config =
  case config of
    None               -> 0
    Normal opacity     -> opacity
    Stacked opacity    -> 1
    Percentage opacity -> 1


{-| -}
opacityContainer : Config -> Float
opacityContainer config =
  case config of
    None               -> 1
    Normal opacity     -> 1
    Stacked opacity    -> opacity
    Percentage opacity -> opacity
