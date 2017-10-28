module ElmHtml.Constants exposing (..)

{-|
Constants for representing internal keys for Elm's vdom implementation

@docs styleKey, eventKey, attributeKey, attributeNamespaceKey, knownKeys

-}


{-| Internal key for style
-}
styleKey : String
styleKey =
    "STYLE"


{-| Internal key for style
-}
eventKey : String
eventKey =
    "EVENT"


{-| Internal key for style
-}
attributeKey : String
attributeKey =
    "ATTR"


{-| Internal key for style
-}
attributeNamespaceKey : String
attributeNamespaceKey =
    "ATTR_NS"


{-| Keys that we are aware of and should pay attention to
-}
knownKeys : List String
knownKeys =
    [ styleKey, eventKey, attributeKey, attributeNamespaceKey ]
