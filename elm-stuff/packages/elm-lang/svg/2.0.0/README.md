# SVG in Elm

Use SVG in Elm.

This library is built on [elm-lang/virtual-dom](http://package.elm-lang.org/packages/elm-lang/virtual-dom/latest/) which handles the dirty details of rendering things quickly.

The best way to learn how to use this library is to read [guide.elm-lang.org](http://guide.elm-lang.org/), particularly the section on [The Elm Architecture](http://guide.elm-lang.org/architecture/index.html). Using SVG is just like using HTML, you just have different tags.

*Note:* This library aims to be the most basic API. In some cases it is possible to use union types to build nicer abstractions, but this starts bringing personal taste into things and has some additional maintainance cost if the underlying spec changes. I think it is best to build such abstractions on top of this library as a separate package.