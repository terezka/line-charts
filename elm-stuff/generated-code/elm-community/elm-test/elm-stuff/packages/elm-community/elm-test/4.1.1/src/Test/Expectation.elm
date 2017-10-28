module Test.Expectation exposing (Expectation(..), InvalidReason(..), Reason(..), fail, withGiven)


type Expectation
    = Pass
    | Fail { given : Maybe String, description : String, reason : Reason }


type Reason
    = Custom
    | Equals String String
    | Comparison String String
      -- Expected, actual, (index of problem, expected element, actual element)
    | ListDiff String String ( Int, String, String )
      {- I don't think we need to show the diff twice with + and - reversed. Just show it after the main vertical bar.
         "Extra" and "missing" are relative to the actual value.
      -}
    | CollectionDiff
        { expected : String
        , actual : String
        , extra : List String
        , missing : List String
        }
    | TODO
    | Invalid InvalidReason


type InvalidReason
    = EmptyList
    | NonpositiveFuzzCount
    | InvalidFuzzer
    | BadDescription
    | DuplicatedName


{-| Create a failure without specifying the given.
-}
fail : { description : String, reason : Reason } -> Expectation
fail { description, reason } =
    Fail { given = Nothing, description = description, reason = reason }


{-| Set the given (fuzz test input) of an expectation.
-}
withGiven : String -> Expectation -> Expectation
withGiven newGiven expectation =
    case expectation of
        Fail failure ->
            Fail { failure | given = Just newGiven }

        Pass ->
            expectation
