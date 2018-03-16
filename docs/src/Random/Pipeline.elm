module Random.Pipeline exposing (generate, with, send)


{-| Random pipeline helpers -}


import Random


{-| -}
generate : a -> Random.Generator a
generate f =
  Random.map (\_ -> f) Random.bool


{-| -}
with : Random.Generator a -> Random.Generator (a -> b) -> Random.Generator b
with =
  Random.map2 (|>)


{-| -}
send : (a -> msg) -> (Random.Generator a) -> Cmd msg
send =
  Random.generate
