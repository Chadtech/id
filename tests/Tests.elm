module Tests exposing (all)

import Expect
import Fuzz exposing (int, list, tuple3)
import Id exposing (Id)
import Random.Pcg as Random exposing (Seed)
import Test exposing (..)


seed : Seed
seed =
    Random.initialSeed 6771


all : Test
all =
    [ test "Generator works" <|
        \() ->
            Expect.false
                "arent same"
                (useSeed Id.generator (Random.initialSeed 6771))
                (useSeed Id.generator (Random.initialSeed 81))
    ]
        |> describe "Id"
