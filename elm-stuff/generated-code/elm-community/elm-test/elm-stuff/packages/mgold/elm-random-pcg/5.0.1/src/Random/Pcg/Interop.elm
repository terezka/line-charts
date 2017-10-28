module Random.Pcg.Interop exposing (fission)

{-| Provides a function to create a PCG seed from a seed in the core library.
This is useful for library writers who need a splittable or most robust PRNG but
don't want to require client code to use the PCG implementation.

```elm
import Random
import Random.Pcg
import Random.Pcg.Interop as Random.Pcg
```

@docs fission
-}

import Random
import Random.Pcg


{-| Use the core library's random seed to produce a PCG random seed.

It seems that the package website doesn't show modules in type annotations, so here it is in full:

    fission : Random.Generator (Random.Pcg.Seed)

-}
fission : Random.Generator Random.Pcg.Seed
fission =
    Random.int 0 0xFFFFFFFF |> Random.map Random.Pcg.initialSeed
