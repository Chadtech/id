module Id
    exposing
        ( Dict
        , Id
        , Origin(Local, Remote)
        , decoder
        , encode
        , fromString
        , generator
        , insert
        , merge
        , toDict
        , values
        )

{-| A simple `Id` type for your types that have ids.


# Id

@docs Id, fromString, encode, decoder, generator


# Origin

@docs Origin


# Dict

@docs Dict, insert, toDict, values, merge

-}

import Char
import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Random.Pcg as Random exposing (Generator)


{-| A dictionary that uses `Id` as keys
-}
type Dict a
    = Dict (a -> Id) (Dict.Dict String a)


{-| -}
type Id
    = Id String


{-| Data that comes from a remote source usually has an id, while data that is made locally doesnt. If thats your situation, using this `Origin` type might be a better way of representing your datas id.

    type alias Car =
        { origin : Origin
        , make : String
        }

    saveCar : Car -> Http.Request (Result Err ())
    saveCar car =
        case car.origin of
            Id id ->
                Car.update id car

            New ->
                Car.create car

-}
type Origin
    = Local
    | Remote Id


{-| The only way to make an Id

    Id.fromString "vq93rUv0A4"

-}
fromString : String -> Id
fromString =
    Id


toString : Id -> String
toString (Id str) =
    str


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


{-| A way to generate random `Id`s

    import Id exposing (Id)
    import Random.Pcg as Random exposing (Seed)

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


{-| Get just the values of a `Id.Dict`
-}
values : Dict a -> List a
values (Dict _ dict) =
    Dict.values dict


{-| Insert a new value into an `Id.Dict`
-}
insert : a -> Dict a -> Dict a
insert x (Dict toId dict) =
    Dict.insert (toString (toId x)) x dict
        |> Dict toId


{-| Combine two `Id.Dict`. In case of a collision, the values in the first parameter are overwritten. `Id.Dict` are initialized with a function `: a -> Id`, if the functions of the two `Id.Dict` are not the same, the function the first Id.dict` is the one that is used.
-}
merge : Dict a -> Dict a -> Dict a
merge targetDict (Dict _ sourceDict) =
    sourceDict
        |> Dict.values
        |> List.foldr insert targetDict


{-| Make a special `Dict` that uses `Id` as keys

    type alias User =
        { id : Id
        , name : String
        }


    Id.toDict .id users : Dict User

-}
toDict : (a -> Id) -> List a -> Dict a
toDict toId xs =
    xs
        |> List.map (pairWithId toId)
        |> Dict.fromList
        |> Dict toId


emptyDict : (a -> Id) -> Dict a
emptyDict toId =
    Dict toId Dict.empty


pairWithId : (a -> Id) -> a -> ( String, a )
pairWithId toId x =
    ( toString (toId x), x )
