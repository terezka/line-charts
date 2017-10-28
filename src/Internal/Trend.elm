module Internal.Trend exposing (Trend, trend, trendQuality, view, correlation)

{-|

# Trend

## Trend (Line of best fit)
@docs Trend, trend, trendQuality, view

## Pearson correlation coefficient
@docs correlation

_Thanks for doing the math, Brian!_

-}

import Svg exposing (Svg)
import Svg.Attributes as A
import Plot.Coordinate as Coordinate exposing (..)



{-| Pearson correlation coefficient
-}
correlation : List Point -> Maybe Float
correlation values =
  case values of
    [] ->
        Nothing

    _ :: [] ->
        Nothing

    _ ->
      let
        ( xs, ys ) =
          unzip values

        standardize maybeMean maybeStddev series =
          Maybe.map2
            (\mean stddev -> List.map (\point -> (point - mean) / stddev) series)
            maybeMean
            maybeStddev

        summedProduct =
          Maybe.map2
            (\stdX stdY -> List.map2 (*) stdX stdY)
            (standardize (mean xs) (stddev xs) xs)
            (standardize (mean ys) (stddev ys) ys)
            |> Maybe.map List.sum

        validate val =
          if isNaN val then
              Nothing
          else
              Just val
      in
      summedProduct
        |> Maybe.map (\sum -> sum / toFloat (List.length values))
        |> Maybe.andThen validate



-- TREND


{-| -}
type alias Trend =
  { slope : Float
  , intercept : Float
  }


{-| -}
trend : List Point -> Maybe Trend
trend values =
  case values of
    [] ->
      Nothing

    _ :: [] ->
      Nothing

    _ ->
      let
        ( xs, ys ) =
          unzip values

        slope =
          Maybe.map3 (\correl stddevY stddevX -> correl * stddevY / stddevX)
            (correlation values)
            (stddev ys)
            (stddev xs)

        intercept =
          Maybe.map3 (\meanY slope meanX -> meanY - slope * meanX)
            (mean ys)
            slope
            (mean xs)
      in
      Maybe.map2 Trend slope intercept


{-| -}
trendQuality : Trend -> List Point -> Maybe Float
trendQuality fit values =
  case values of
    [] ->
        Nothing

    _ ->
        let
          ( xs, ys ) =
            unzip values

          predictions =
            List.map (predictY fit) xs

          meanY =
            mean ys

          sumSquareTotal =
            meanY
              |> Maybe.map (\localMean -> List.map (\y -> (y - localMean) ^ 2) ys)
              |> Maybe.map List.sum

          sumSquareResiduals =
            List.map2 (\actual prediction -> (actual - prediction) ^ 2) ys predictions
              |> List.sum
        in
        sumSquareTotal
          |> Maybe.map (\ssT -> 1 - sumSquareResiduals / ssT)


{-| -}
view : Coordinate.System -> List (Svg.Attribute msg) -> Limits -> Maybe Trend -> Svg msg
view system attributes { max, min } trend =
  case trend of
    Nothing ->
      Svg.text ""

    Just trend ->
      let
        y1 =
          predictY trend min

        y2 =
          predictY trend max
      in
      Svg.line
          (attributes ++
            [ A.x1 <| toString (toSVG X system min)
            , A.y1 <| toString (toSVG Y system y1)
            , A.x2 <| toString (toSVG X system max)
            , A.y2 <| toString (toSVG Y system y2)
            ]
          )
          []



-- HELP


mean : List Float -> Maybe Float
mean numbers =
  case numbers of
    [] ->
      Nothing

    _ ->
      Just <| List.sum numbers / toFloat (List.length numbers)


stddev : List Float -> Maybe Float
stddev numbers =
  let
    helper seriesMean =
      Maybe.map sqrt <| mean <| List.map (\n -> (n - seriesMean) ^ 2) numbers
  in
  mean numbers |> Maybe.andThen helper


predictY : Trend -> Float -> Float
predictY fit x =
  fit.slope * x + fit.intercept


unzip : List Point -> ( List Float, List Float )
unzip points =
  let
    step { x, y } ( xs, ys ) =
      (x :: xs, y :: ys)
  in
    List.foldr step ([], []) points
