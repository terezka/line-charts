port module Test.Generated.Main54488546e57a876028ec01c9ead49ed5 exposing (main)

import Coordinates

import Test.Runner.Node
import Test
import Json.Encode

port emit : ( String, Json.Encode.Value ) -> Cmd msg

main : Test.Runner.Node.TestProgram
main =
    [     Test.describe "Coordinates" [Coordinates.coordinates,
    Coordinates.horizontal,
    Coordinates.vertical] ]
        |> Test.concat
        |> Test.Runner.Node.runWithOptions { runs = Nothing, reporter = Nothing, seed = Nothing, paths = []} emit