module Id
    exposing
        ( Db
        , Id
        , Origin(Local, Remote)
        , decoder
        , emptyDb
        , encode
        , fromString
        , generator
        , get
        , insert
        , items
        , toDb
        )

{-| A simple `Id` type for your types that have ids.


# Id

@docs Id, fromString, encode, decoder, generator


# Origin

@docs Origin


# Db

@docs Db, get, insert, toDb, items, emptyDb

-}

import Char
import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Random.Pcg as Random exposing (Generator)


{-| A dictionary that uses `Id` as keys
-}
type Db a
    = Db (a -> Id) (Dict.Dict String a)


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


{-| Get the item with a given id, if its in the `Db`
-}
get : Id -> Db a -> Maybe a
get (Id str) (Db _ dict) =
    Dict.get str dict


{-| Get just the items in a `Db`
-}
items : Db item -> List item
items (Db _ dict) =
    Dict.values dict


{-| Insert a new item into a `Db`
-}
insert : item -> Db item -> Db item
insert item (Db toId dict) =
    Dict.insert (toString (toId item)) item dict
        |> Db toId


{-| Remove an item from a `Db`
-}
remove : Id -> Db item -> Db item
remove (Id str) (Db toId dict) =
    Dict.remove str dict
        |> Db toId


{-| Make a `Db` that uses `Id` as keys

    type alias User =
        { id : Id
        , name : String
        }


    toDb .id users : Db User

-}
toDb : (item -> Id) -> List item -> Db item
toDb toId items =
    items
        |> List.map (pairWithId toId)
        |> Dict.fromList
        |> Db toId


{-| An empty `Db`
-}
emptyDb : (item -> Id) -> Db item
emptyDb toId =
    Db toId Dict.empty


pairWithId : (item -> Id) -> item -> ( String, item )
pairWithId toId item =
    ( toString (toId item), item )
