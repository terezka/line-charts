var compiler = require("node-elm-compiler")

testFile = "Main.elm"

compiler.compileToString([testFile], {}).then(function(str) {
  try {
    eval(str);

    process.exit(0)
  } catch (err) {
    console.error(err);

    process.exit(1)
  }
}).catch(function(err) {
  console.error(err);

  process.exit(1)
});
