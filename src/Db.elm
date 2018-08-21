module Db
    exposing
        ( Db
        , empty
        , fromList
        , get
        , getMany
        , getWithId
        , getManyWithId
        , insert
        , insertMany
        , remove
        , toList
        , update
        , map
        , mapItem
        )

{-| A way of storing your data by `Id`


# Db

@docs Db, empty

# List

@docs fromList, toList

# Helpers

@docs insert, insertMany, get, getWithId, getMany, getManyWithId, remove, update, map, mapItem


-}

import Dict
import Id exposing (Id)


{-| Short for "Database", it stores data by unique identifiers
-}
type Db item
    = Db (Dict.Dict String item)


{-| Insert an item into the `Db` under the given `Id`
-}
insert : Id -> item -> Db item -> Db item
insert thisId item (Db dict) =
    Dict.insert (Id.toString thisId) item dict
        |> Db


{-| Insert many items into the `Db` under their given `Id`s
-}
insertMany : List ( Id, item ) -> Db item -> Db item
insertMany elements db =
    List.foldr insertManyHelper db elements


insertManyHelper : ( Id, item ) -> Db item -> Db item
insertManyHelper ( id, item ) db =
    insert id item db


{-| Update an item in a `Db`, using an update function. If the item doesnt exist in the `Db`, it comes into the update as `Nothing`. If a `Nothing` comes out of the update function, the value under that id will be removed.
-}
update : Id -> (Maybe item -> Maybe item) -> Db item -> Db item
update id f db =
    Dict.update (Id.toString id) f dict
        |> Db

{-| Remove the item at the given `Id`, if it exists
-}
remove : Id -> Db item -> Db item
remove thisId (Db dict) =
    Db (Dict.remove (Id.toString thisId) dict)


{-| Get the item under the provided `Id`
-}
get : Db item -> Id -> Maybe item
get (Db dict) thisId =
    Dict.get (Id.toString thisId) dict


{-| Just like `get`, except it comes with the `Id`, for those cases where you dont want the item separated from its `Id` -}
getWithId : Db item -> Id -> (Id, Maybe item)
getWithId db thisId =
    (thisId, get db thisId)




{-| Get many items from a `Db` from a list of `Ids`. Elements not in the `Db` simply wont appear in the return result.
-}
getMany : Db item -> List Id -> List item 
getMany db ids =
    ids
        |> List.map (get db)
        |> List.filterMap identity

{-| Get many items from a `Db`, but dont filter out missing results, and pair results with their `Id`-}
getManyWithId : Db item -> List Id -> List (Id, Maybe item)
getManyWithId db =
    List.map (getWithId db)


{-| Turn your `Db` into a list
-}
toList : Db item -> List ( Id, item )
toList (Db dict) =
    Dict.toList dict
        |> List.map
            (Tuple.mapFirst Id.fromString)


{-| Initialize a `Db` from a list of id-value pairs
-}
fromList : List ( Id, item ) -> Db item
fromList items =
    items
        |> List.map 
            (Tuple.mapFirst Id.toString)
        |> Dict.fromList
        |> Db


{-| An empty `Db` with no entries
-}
empty : Db item
empty =
    Db Dict.empty


{-| Map a `Db` to a different data type.
-}
map : (a -> b) -> Db a -> Db b
map f (Db dict) =
    Dict.map (always f) dict
        |> Db


{-| Apply a change to just one item in the `Db`, assuming the item is in the `Db` in the first place. This function is just like `update` except deleting the item is not possible.-}
mapItem : Id -> (item -> item) -> Db item -> Db item
mapItem id f (Db dict) =
    Dict.update (Id.toString id) (Maybe.map f) dict
        |> Db