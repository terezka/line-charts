module Fuzz.Internal exposing (Fuzzer, Valid, ValidFuzzer, andThen, combineValid, invalidReason, map)

import Lazy
import Lazy.List exposing ((:::), LazyList)
import Random.Pcg as Random exposing (Generator)
import RoseTree exposing (RoseTree(Rose))


type alias Fuzzer a =
    Valid (ValidFuzzer a)


type alias Valid a =
    Result String a


type alias ValidFuzzer a =
    Generator (RoseTree a)


combineValid : List (Valid a) -> Valid (List a)
combineValid valids =
    case valids of
        [] ->
            Ok []

        (Ok x) :: rest ->
            Result.map ((::) x) (combineValid rest)

        (Err reason) :: _ ->
            Err reason


map : (a -> b) -> Fuzzer a -> Fuzzer b
map fn fuzzer =
    (Result.map << Random.map << RoseTree.map) fn fuzzer


andThen : (a -> Fuzzer b) -> Fuzzer a -> Fuzzer b
andThen fn fuzzer =
    let
        helper : (a -> Fuzzer b) -> RoseTree a -> ValidFuzzer b
        helper fn xs =
            RoseTree.map fn xs
                |> removeInvalid
                |> sequenceRoseTree
                |> Random.map RoseTree.flatten
    in
    Result.map (Random.andThen (helper fn)) fuzzer


removeInvalid : RoseTree (Valid a) -> RoseTree a
removeInvalid tree =
    case RoseTree.filterMap getValid tree of
        Just newTree ->
            newTree

        Nothing ->
            Debug.crash "Returning an invalid fuzzer from `andThen` is currently unsupported"


sequenceRoseTree : RoseTree (Generator a) -> Generator (RoseTree a)
sequenceRoseTree (Rose root branches) =
    Random.map2
        Rose
        root
        (Lazy.List.map sequenceRoseTree branches |> sequenceLazyList)


sequenceLazyList : LazyList (Generator a) -> Generator (LazyList a)
sequenceLazyList xs =
    Random.independentSeed
        |> Random.map (runAll xs)


runAll : LazyList (Generator a) -> Random.Seed -> LazyList a
runAll xs seed =
    Lazy.lazy <|
        \_ ->
            case Lazy.force xs of
                Lazy.List.Nil ->
                    Lazy.List.Nil

                Lazy.List.Cons firstGenerator rest ->
                    let
                        ( x, newSeed ) =
                            Random.step firstGenerator seed
                    in
                    Lazy.List.Cons x (runAll rest newSeed)


getValid : Valid a -> Maybe a
getValid valid =
    case valid of
        Ok x ->
            Just x

        Err _ ->
            Nothing


invalidReason : Valid a -> Maybe String
invalidReason valid =
    case valid of
        Ok _ ->
            Nothing

        Err reason ->
            Just reason
