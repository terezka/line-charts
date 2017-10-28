module Test.Internal exposing (Test(..), blankDescriptionFailure, duplicatedName, failNow)

import Random.Pcg as Random exposing (Generator)
import Set exposing (Set)
import Test.Expectation exposing (Expectation(..))


type Test
    = Test (Random.Seed -> Int -> List Expectation)
    | Labeled String Test
    | Skipped Test
    | Only Test
    | Batch (List Test)


{-| Create a test that always fails for the given reason and description.
-}
failNow : { description : String, reason : Test.Expectation.Reason } -> Test
failNow record =
    Test
        (\_ _ -> [ Test.Expectation.fail record ])


blankDescriptionFailure : Test
blankDescriptionFailure =
    failNow
        { description = "This test has a blank description. Let's give it a useful one!"
        , reason = Test.Expectation.Invalid Test.Expectation.BadDescription
        }


duplicatedName : List Test -> Result String (Set String)
duplicatedName =
    let
        names : Test -> List String
        names test =
            case test of
                Labeled str _ ->
                    [ str ]

                Batch subtests ->
                    List.concatMap names subtests

                Test _ ->
                    []

                Skipped subTest ->
                    names subTest

                Only subTest ->
                    names subTest

        insertOrFail : String -> Result String (Set String) -> Result String (Set String)
        insertOrFail newName =
            Result.andThen
                (\oldNames ->
                    if Set.member newName oldNames then
                        Err newName
                    else
                        Ok <| Set.insert newName oldNames
                )
    in
    List.concatMap names
        >> List.foldl insertOrFail (Ok Set.empty)
