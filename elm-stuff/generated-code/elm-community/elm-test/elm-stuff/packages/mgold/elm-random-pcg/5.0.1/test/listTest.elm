module ListTest exposing (..)

{-| The central limit theorem states that if you sample any distribution and take the mean, and do that many times,
those means will be on a standard distribution.

That's exactly what this test does, using an independent seed. Judging how "good" the distribution is versus how good it
"should" be is beyond the scope of this example. This test is really to show that independent seeds aren't *trivially*
wrong.
-}

import Dict exposing (Dict)
import Random.Pcg as Random
import Html
import Html.App


seed0 : Random.Seed
seed0 =
    Random.initialSeed 628318530 |> Random.step Random.independentSeed |> snd


gen =
    Random.int 1 6
        |> Random.list 15
        |> Random.map mean
        |> Random.map (\x -> round (10 * x))
        |> Random.list 800
        |> Random.map toMultiSet


mean : List Int -> Float
mean xs =
    toFloat (List.sum xs) / toFloat (List.length xs)


toMultiSet : List Int -> Dict Int Int
toMultiSet list =
    let
        helper xs d =
            case xs of
                [] ->
                    d

                x :: xs ->
                    helper xs <| Dict.insert x (Dict.get x d |> Maybe.withDefault 0 |> (+) 1) d
    in
        helper list Dict.empty


generated =
    Random.step gen seed0 |> fst


main : Program Never
main =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \() -> Html.text <| toString <| generated
        }
