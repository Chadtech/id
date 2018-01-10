module Id
    exposing
        ( Id
        , Origin(Local, Remote)
        , fromString
        , generator
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Random.Pcg as Random exposing (Generator)


type Id
    = Id String


type Origin
    = Remote Id
    | Local


fromString : String -> Id
fromString =
    Id


encode : Id -> Value
encode (Id str) =
    Encode.string str


decoder : Decoder Id
decoder =
    Decode.map Id Decode.string


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
