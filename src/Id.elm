module Id
    exposing
        ( Id
        , Origin(Local, Remote)
        , decoder
        , encode
        , fromString
        , generator
        )

{-| A simple `Id` type for your types that have ids.


# Id

@docs Id, fromString, encode, decoder, generator


# Origin

@docs Origin

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Random.Pcg as Random exposing (Generator)


{-| -}
type Id
    = Id String


{-| -}
type Origin
    = Local
    | Remote Id


{-| The only way to make an Id

    Id.fromString "vq93rUv0A4"

-}
fromString : String -> Id
fromString =
    Id


{-| Encode an `Id`

    Encode.encode 0 (Id.encode id)
    -- ""hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh"" : String

    [ ("id", Id.encode id) ]
        |> Encode.object
        |> Encode.encode 0

    -- {\"id\":\"hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh\"} : String

-}
encode : Id -> Value
encode (Id str) =
    Encode.string str


{-| Decode an `Id`

    Decode.decodeString (Decode.field "id" Id.decoder) "{\"id\":\"19\"}"
    -- Ok (Id 19) : Result String Id

-}
decoder : Decoder Id
decoder =
    Decode.map Id Decode.string


{-| A way to generate `Id`s

    import Id exposing (Id)
    import Random.Pcg as Random

    user : Seed -> ( User, Seed )
    user seed =
        let
            ( id, nextSeed ) =
                Random.step Id.generator seed
        in
        ( { id = id, email = "Bob@sci.org" }
        , nextSeed
        )

-}
generator : Generator Id
generator =
    Random.int 0 61
        |> Random.list 64
        |> Random.map (intsToString >> Id)


intsToString : List Int -> String
intsToString =
    List.map toChar >> String.fromList


toChar : Int -> Char
toChar int =
    if int < 10 then
        Char.fromCode (int + 48)
    else if int < 36 then
        Char.fromCode (int + 55)
    else
        Char.fromCode (int + 61)
