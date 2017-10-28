#!/usr/bin/env bash

set -e

if [ ! -f elm-core-random.txt ]; then
  sed -i.bak 's/import Random.Pcg as Random/import Random/g' Dieharder.elm
  sed -i.bak 's/elm-random-pcg/elm-core-random/g' Dieharder.elm
  elm make Dieharder.elm --output=raw_out.js
  sh elm-io.sh raw_out.js generate_files.js
  echo "Generating elm-core-random.txt..."
  node generate_files.js > elm-core-random.txt
  dieharder -g 202 -f elm-core-random.txt -a | tee dieharder-core.log
fi

if [ ! -f elm-random-pcg.txt ]; then
  sed -i.bak 's/import Random$/import Random.Pcg as Random/g' Dieharder.elm
  sed -i.bak 's/elm-core-random/elm-random-pcg/g' Dieharder.elm
  elm make Dieharder.elm --output=raw_out.js
  sh elm-io.sh raw_out.js generate_files.js
  echo "Generating elm-random-pcg.txt..."
  node generate_files.js > elm-random-pcg.txt
  dieharder -g 202 -f elm-random-pcg.txt  -a | tee dieharder-pcg.log
fi

