module Internal.Numbers exposing (customInterval, defaultInterval)

import Regex
import Round
import Lines.Coordinate as Coordinate exposing (..)


{-| -}
defaultInterval : Coordinate.Limits -> List Float
defaultInterval limits =
    customInterval limits.min (getDecentInterval limits.min limits.max 10) limits


{-| -}
customInterval : Float -> Float -> Coordinate.Limits -> List Float
customInterval intersection delta limits =
    let
        firstValue =
            getFirstValue delta limits.min intersection

        ticks result index =
            let
                next =
                    position delta firstValue index
            in
            if next <= limits.max then
                ticks (result ++ [ next ]) (index + 1)
            else
                result
    in
    ticks [] 0



-- INTERNAL


position : Float -> Float -> Int -> Float
position delta firstValue index =
    firstValue
        + toFloat index
        * delta
        |> Round.round (deltaPrecision delta)
        |> String.toFloat
        |> Result.withDefault 0


deltaPrecision : Float -> Int
deltaPrecision delta =
    delta
        |> toString
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\.[0-9]*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.length
        |> (-) 1
        |> min 0
        |> abs


getFirstValue : Float -> Float -> Float -> Float
getFirstValue delta min intersection =
    min + (intersection - min - offset delta (intersection - min))


offset : Float -> Float -> Float
offset precision value =
    toFloat (floor (value / precision)) * precision


getDecentInterval : Float -> Float -> Int -> Float
getDecentInterval min max total =
    let
        range =
            abs (max - min)

        -- calculate an initial guess at step size
        delta0 =
            range / toFloat total

        -- get the magnitude of the step size
        mag =
            floor (logBase 10 delta0)

        magPow =
            toFloat (10 ^ mag)

        -- calculate most significant digit of the new step size
        magMsd =
            round (delta0 / magPow)

        -- promote the MSD to either 1, 2, or 5
        magMsdFinal =
            if magMsd > 5 then
                10
            else if magMsd > 2 then
                5
            else if magMsd > 1 then
                1
            else
                magMsd
    in
    toFloat magMsdFinal * magPow
