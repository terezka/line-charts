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
    Normal opacity_     -> opacity_
    Stacked opacity_    -> opacity_
    Percentage opacity_ -> opacity_


{-| -}
opacitySingle : Config -> Float
opacitySingle config =
  case config of
    None               -> 0
    Normal opacity_     -> opacity_
    Stacked opacity_    -> 1
    Percentage opacity_ -> 1


{-| -}
opacityContainer : Config -> Float
opacityContainer config =
  case config of
    None               -> 1
    Normal opacity_     -> 1
    Stacked opacity_    -> opacity_
    Percentage opacity_ -> opacity_
