# Line Charts

This library is deprecated in favor of [elm-charts](https://github.com/terezka/elm-charts).

An library for plotting line charts in SVG. Written in all Elm. See [demo.](https://terezka.github.io/line-charts/)

## Installation

Run the following command in the root of your project

```shell
$ elm install terezka/line-charts
```

and import the library in an elm file like this 

```elm
import LineChart
```

See the documentation for more information on usage!

## Documentation

Find the documentation on [Elm's package website](http://package.elm-lang.org/packages/terezka/line-charts/latest).

## Development

### Setup

```shell
$ cd examples
$ elm package install
$ elm reactor
```

and open [examples](https://localhost:8000).

### Tests

Tests are written with [elm-test](https://github.com/elm-community/elm-test).
For further information on elm-test check the documentation.
All required dependencies are downloaded and installed when initially running the command.

```shell
$ elm test
```

### Compile the Docs

```shell
$ elm live docs/src/Main.elm --output=docs/assets/main.js
```
