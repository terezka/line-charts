module Util exposing (..)

{-| This is where I'm sticking Random helper functions I don't want to add to Pcg.
-}

import Array exposing (Array)
import Random.Pcg exposing (..)
import String


rangeLengthList : Int -> Int -> Generator a -> Generator (List a)
rangeLengthList minLength maxLength generator =
    int minLength maxLength
        |> andThen (\len -> list len generator)


rangeLengthArray : Int -> Int -> Generator a -> Generator (Array a)
rangeLengthArray minLength maxLength generator =
    rangeLengthList minLength maxLength generator
        |> map Array.fromList


rangeLengthString : Int -> Int -> Generator Char -> Generator String
rangeLengthString minLength maxLength charGenerator =
    int minLength maxLength
        |> andThen (lengthString charGenerator)


lengthString : Generator Char -> Int -> Generator String
lengthString charGenerator stringLength =
    list stringLength charGenerator
        |> map String.fromList
