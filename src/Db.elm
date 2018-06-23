module Db
    exposing
        ( Db
        , empty
        , fromList
        , get
        , getMany
        , insert
        , insertMany
        , remove
        , toList
        , update
        )

{-| A way of storing your data by `Id`


# Db

@docs Db, empty


# Helpers

@docs insert, insertMany, get, getMany, remove, update


# List

@docs fromList, toList

-}

import Dict
import Id exposing (Id)


{-| Short for "Database", it stores data by unique identifiers
-}
type Db item
    = Db (Dict.Dict String item)


{-| Insert an item into the Db under the given id
-}
insert : Id -> item -> Db item -> Db item
insert thisId item (Db dict) =
    Dict.insert (Id.toString thisId) item dict
        |> Db


{-| Insert many items into the Db under their given ids
-}
insertMany : List ( Id, item ) -> Db item -> Db item
insertMany elements db =
    List.foldr insertManyHelper db elements


insertManyHelper : ( Id, item ) -> Db item -> Db item
insertManyHelper ( id, item ) db =
    insert id item db


{-| Update an item in a Db, using an update function. If the item doesnt exist in the Db, it comes into the update as `Nothing`. If a `Nothing` comes out of the update function, it means the value under that id will be remove
-}
update : Id -> (Maybe item -> Maybe item) -> Db item -> Db item
update id f db =
    case Tuple.second <| Tuple.mapSecond f (get db id) of
        Just i ->
            insert id i db

        Nothing ->
            remove id db


{-| Remove the item at the given id, if it exists
-}
remove : Id -> Db item -> Db item
remove thisId (Db dict) =
    Db (Dict.remove (Id.toString thisId) dict)


{-| Get the item under the provided id, if it exists

The result of `get` is a `(Id, Maybe item)` instead of just a `Maybe item`, because presumably the data and its id will be used together in your software. They are grouped together by default so your software doesnt have to manually group them together.

-}
get : Db item -> Id -> ( Id, Maybe item )
get (Db dict) thisId =
    ( thisId, Dict.get (Id.toString thisId) dict )


{-| Get many items from a Db from a list of Ids.
-}
getMany : Db item -> List Id -> List ( Id, Maybe item )
getMany db =
    List.map (get db)


{-| Turn your Db into a list
-}
toList : Db item -> List ( Id, item )
toList (Db dict) =
    Dict.toList dict
        |> List.map
            (Tuple.mapFirst Id.fromString)


{-| Initialize a Db from a list of id-value pairs
-}
fromList : List ( Id, item ) -> Db item
fromList items =
    items
        |> List.map (Tuple.mapFirst Id.toString)
        |> Dict.fromList
        |> Db


{-| An empty Db with no entries
-}
empty : Db item
empty =
    Db Dict.empty
