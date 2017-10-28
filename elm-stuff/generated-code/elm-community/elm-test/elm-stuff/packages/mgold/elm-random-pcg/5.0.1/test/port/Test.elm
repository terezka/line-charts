module Test where

import Graphics.Element exposing (show)
import Random.Pcg as Random

port randomSeed : (Int, Int)

seed0 : Random.Seed
seed0 = (uncurry Random.initialSeed2) randomSeed

gen = Random.list 32 (Random.int 1 6)

main = show <| fst <| Random.generate gen seed0
