# Benchmarks for Random.Pcg

These benchmarks are possible thanks to Robin Heggelund Hansen's work benchmarking [collections-ng](https://github.com/Skinney/collections-ng).

To run them yourself, first download the vendor files (you only need to do this once):
```
mkdir vendor
cd vendor
wget https://cdn.jsdelivr.net/lodash/4.13.1/lodash.min.js
wget https://cdn.jsdelivr.net/benchmarkjs/2.1.0/benchmark.js
```

Then adjust the import of `Random` in `Bencher.elm` to control which library is being benchmarked. Finally run `sh prep-bench.sh` then
`elm-reactor` in this directory and open `run-benchmarks.html`.
