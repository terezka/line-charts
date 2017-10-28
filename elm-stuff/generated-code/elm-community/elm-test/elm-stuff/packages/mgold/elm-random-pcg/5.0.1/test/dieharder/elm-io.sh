#!/usr/bin/env bash

# Script for use with the Console library to allow Elm to run on Node.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <generated-js-file> <output-file>"
    exit 1
fi

read -d '' handler <<- EOF
(function(){
    if (typeof Elm === "undefined") { throw "elm-io config error: Elm is not defined. Make sure you call elm-io with a real Elm output file"}
    if (typeof Elm.Main === "undefined" ) { throw "Elm.Main is not defined, make sure your module is named Main." };
    var worker = Elm.worker(Elm.Main);
})();
EOF

cat $1 > $2
echo "$handler" >> $2
