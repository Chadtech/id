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

But with an `Id` type, they arent. Using a separate `Id` type eliminates them entirely. `Id`s also cant be changed or modified, which is a good thing because `Id`s need to be static in order to properly identify their value. Using this `Id` type ensures the expectations you already had about identifiers.

And then of course you can decode and encode `Id`s too..

```elm

Encode.encode 0 (Id.encode id)
-- "\"hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh\""

Decode.decodeString (Decode.field "id" Id.decoder) "{\"id\":\"19\"}"
-- Ok (fromString "19") : Result String Id

```

# Db

You may be dealing with an unknown amount of unknown data at runtime. Its a little tricky dealing with this data because theres always the chance it doesnt exist. Since the range of possible data available is extremely wide and you dont want random data distributed all over your application, one approach is to consolidate everything into a little database in the front end side of your application, much like how backend applications manage a database.

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
        |> Db.getManyWithId postsDb
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