module Internal.Interpolation exposing (Interpolation(..), toCommands)

{-| -}

import Internal.Path as Path exposing (..)
import Lines.Coordinate as Coordinate  exposing (..)



{-| -}
type Interpolation
  = Linear
  | Monotone


{-| -}
toCommands : Interpolation -> List Point -> List Command
toCommands interpolation =
  case interpolation of
    Linear   -> linear
    Monotone -> monotone



-- INTERNAL / LINEAR


linear : List Point -> List Command
linear =
  List.map Line



-- INTERNAL / MONOTONE


monotone : List Point -> List Command
monotone points =
  case points of
    p0 :: p1 :: p2 :: rest ->
      let
        nextTangent =
          slope3 p0 p1 p2

        previousTangent =
          slope2 p0 p1 nextTangent
      in
        monotoneCurve p0 p1 previousTangent nextTangent ++
        monotoneNext (p1 :: p2 :: rest) nextTangent

    [ p0, p1 ] ->
      linear [ p0, p1 ]

    _ ->
      []


monotoneNext : List Point -> Float -> List Command
monotoneNext points previousTangent =
  case points of
    p0 :: p1 :: p2 :: rest ->
      let
        nextTangent =
          slope3 p0 p1 p2
      in
        monotoneCurve p0 p1 previousTangent nextTangent ++
        monotoneNext (p1 :: p2 :: rest) nextTangent

    [ p0, p1 ] ->
      monotoneCurve p0 p1 previousTangent (slope3 p0 p1 p1)

    _ ->
        []


monotoneCurve : Point -> Point -> Float -> Float -> List Command
monotoneCurve point0 point1 tangent0 tangent1 =
  let
    dx =
      (point1.x - point0.x) / 3
  in
    [ CubicBeziers
        { x = point0.x + dx, y = point0.y + dx * tangent0 }
        { x = point1.x - dx, y = point1.y - dx * tangent1 }
        point1
    ]


{-| Calculate the slopes of the tangents (Hermite-type interpolation) based on
 the following paper: Steffen, M. 1990. A Simple Method for Monotonic
 Interpolation in One Dimension
-}
slope3 : Point -> Point -> Point -> Float
slope3 point0 point1 point2 =
  let
    h0 = point1.x - point0.x
    h1 = point2.x - point1.x
    s0h = toH h0 h1
    s1h = toH h1 h0
    s0 = (point1.y - point0.y) / s0h
    s1 = (point2.y - point1.y) / s1h
    p = (s0 * h1 + s1 * h0) / (h0 + h1)
    slope = (sign s0 + sign s1) * (min (min (abs s0) (abs s1)) (0.5 * abs p))
  in
    if isNaN slope then 0 else slope


toH : Float -> Float -> Float
toH h0 h1 =
  if h0 == 0
    then if h1 < 0 then 0 * -1 else h1
    else h0


{-| Calculate a one-sided slope.
-}
slope2 : Point -> Point -> Float -> Float
slope2 point0 point1 t =
  let h = point1.x - point0.x in
    if h /= 0
      then (3 * (point1.y - point0.y) / h - t) / 2
      else t


sign : Float -> Float
sign x =
  if x < 0
    then -1
    else 1
