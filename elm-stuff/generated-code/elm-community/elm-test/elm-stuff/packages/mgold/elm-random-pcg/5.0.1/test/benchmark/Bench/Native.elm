module Bench.Native exposing (..)

import Native.Benchmark


type Benchmark
    = Benchmark


type BenchmarkSuite
    = BenchmarkSuite


bench : String -> (() -> a) -> Benchmark
bench =
    Native.Benchmark.bench


suite : String -> List (Benchmark) -> BenchmarkSuite
suite =
    Native.Benchmark.suite


run : List (BenchmarkSuite) -> b -> b
run =
    Native.Benchmark.run
