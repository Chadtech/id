# Id

This package exposes a really simple type called `Id`. Its for when your data has an id. Such as..


```elm

import Id exposing (Id)

type alias User =
    { id : Id 
    , email : String
    }

```

You can make `Id`s from strings..

```elm

import Id exposing (Id)

user : User
user = 
    { id = Id.fromString "400" 
    , email = "Bob@sci.org"
    }

```

Or you can generate random `Id`s..


```elm

import Id exposing (Id)
import Random exposing (Seed)


user : Seed -> ( User, Seed )
user seed =
    let
        ( id, nextSeed ) =
            Random.step Id.generator seed
    in
    ( { id = id, email = "Bob@sci.org" }
    , nextSeed
    )

```

Why use an `Id` instead of a `String`? Technically, all of the following are possible with `String` ids..


```elm

coolString : User -> String
coolString user =
    user.email ++ user.id


screwUpUser : User -> User
screwUpUser user =
    { user
        | id = user.email
        , email = user.id
    }


henry : User
henry =
    User "Henry" henrysId

```

Admittedly these errors seem implausible, but using a separate `Id` type eliminates them entirely. Theres really no functionality lost either; in fact, the whole point is that there *shouldnt* be any functionality with ids. Ids largely just get set and then forgotten about. Using this `Id` type ensures your expectations.

And then of course you can decode and encode `Id`s too..

```elm

Encode.encode 0 (Id.encode id)
-- "\"hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh\""

Decode.decodeString (Decode.field "id" Id.decoder) "{\"id\":\"19\"}"
-- Ok (Id "19") : Result String Id

```

# Db

If you are dealing with data that comes from a remote source, in all likelihood youll be dealing with a lot of it, and you wont know what data with what ids until run time. Since the range of possible data available is extremely wide, one approach is to manage a little database in the front end side of your application, much like how backend applications manage a database.

This package provides a module called `Db` exposing a ype `Db item`. A `Db item` is, for the most part, just a wrapper around a `Dict String a`. The primary difference is that `Db item`s use `Id`s as keys, and the type signatures of its helper functions were designed assuming the use case of managing a `Db`


```elm
type alias Thread =
    { title : String
    , posts : List Id
    }

type alias Post =
    { author : String
    , content : String 
    }

threadView : Db Post -> (Id, Thread) -> Html Msg
threadView postsDb (threadId, thread) =
    thread.posts
        |> Db.getMany postsDb
        |> List.map postView
        |> (::) (p [] [ Html.text thread.title ])
        |> div [ css [ threadStyle ] ]


postView : (Id, Maybe Post) -> Html Msg
postView post =
    div
        [ css [ postStyle ] ]
        (postBody post)


postBody : (Id, Maybe Post) -> List (Html Msg)
postBody (id, maybePost) =
    case maybePost of
        Just post ->
            [ p
                []
                [ Html.text post.author ]
            , p 
                []
                [ Html.text post.content ]
            ]

        Nothing ->
            [ p
                []
                [ Html.text "Post not found" ]
            ]
```