module Lines.Legends exposing
  ( none, default
  , Legends, Pieces
  , byEnding, byBeginning
  , bucketed, bucketedCustom
  )

{-| # Legends

## Quick start
@docs none, default

## What are my options?
@docs Legends, Pieces

## Free legends
The ones hanging my the line.
@docs byEnding, byBeginning, defaultLabel

## Bucketed legends
The ones gathered in one spot.
@docs bucketed, bucketedCustom

-}

import Svg
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Legends as Legends



-- CONFIG


{-| -}
type alias Legends msg
  = Legends.Legends msg


{-| -}
type alias Pieces msg =
  { sample : Svg.Svg msg
  , label : String
  }



-- NONE


{-| -}
none : Legends msg
none =
  Legends.None



-- DEFAULT


{-| -}
default : Legends msg
default =
  bucketed .max .max



-- FREE


{-| -}
byEnding : (String -> Svg.Svg msg) -> Legends msg
byEnding =
  Legends.Free Legends.Ending


{-| -}
byBeginning : (String -> Svg.Svg msg) -> Legends msg
byBeginning =
  Legends.Free Legends.Beginning



-- BUCKETED


{-| -}
bucketed : (Coordinate.Limits -> Float) -> (Coordinate.Limits -> Float) -> Legends msg
bucketed =
  Legends.bucketed


{-| -}
bucketedCustom : Float -> (Coordinate.System -> List (Pieces msg) -> Svg.Svg msg) -> Legends msg
bucketedCustom =
  Legends.Bucketed
