import String
import Task exposing (Task)
import Random.Pcg as Random

import Console exposing (IO)

name = "elm-random-pcg"

n = 2e6 |> round
seed0 = 42
bound = {lo = 0, hi = 0xFFFFFFFF}

header : IO ()
header =
  Console.putStr <| "# " ++ name ++ "\n# seed: " ++ toString seed0 ++ "\ntype: d\ncount: " ++
      toString (12*n) ++ "\nnumbit: 32"

body : List Int -> IO ()
body ints =
  Console.putStr "\n"
    `Console.seq`
  Console.putStr (List.map (toString >> String.padLeft 10 ' ') ints |> String.join "\n")

core : Random.Seed -> (List Int, Random.Seed)
core seed =
  let gen = Random.list n (Random.int bound.lo bound.hi)
  in Random.step gen seed

run1 : Random.Seed -> IO Random.Seed
run1 seed =
  let (ints, seed2) = core seed
  in body ints |> Console.map (\_ -> seed2)

job : IO ()
job =
  header
    `Console.seq`
  run1 (Random.initialSeed seed0)
    `Console.andThen` run1
    `Console.andThen` run1
    `Console.andThen` run1

    `Console.andThen` run1
    `Console.andThen` run1
    `Console.andThen` run1

    `Console.andThen` run1
    `Console.andThen` run1
    `Console.andThen` run1

    `Console.andThen` run1
    `Console.andThen` run1
    `Console.seq`
  Console.exit 0


port io : Signal (Task x ())
port io = Console.run job
