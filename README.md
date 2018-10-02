# Id

This package exposes a really simple type called `Id` (and a lot of other stuff too).

```elm
type Id x
    = Id String
```

Its for when your data has an id. Such as..

```elm
import Id exposing (Id)

type alias User =
    { id : Id ()
    , email : String
    }
```

# Why an `Id` and not a `String`?

The Elm compiler is totally okay with the following code snippets..

```elm
type alias User =
    { id : String
    , email : String
    }


type Msg
    -- The type signature of this `Msg` is
    -- unclear about what each `String` is
    -- supposed to be
    = EmailUpdated String String

-- In your view the first parameter may be `id`..
view user =
    input
        [ onInput (EmailUpdated user.id)
        , value user.email
        ]
        []

-- .. while in your update you might treat the first
-- parameter as 'newEmail'
update msg user =
    case msg of
        EmailUpdated newEmail userId ->
            { user | email = newEmail }
```

and

```elm
viewUser : String -> String -> Html Msg
viewUser email id =
    -- first parameter is email
    -- second parameter is id


view : Model -> Html Msg
view model =
    div
        []
        [ viewUser
            -- woops! The parameters are mixed up
            model.user.id
            model.user.email
        ]
```

These mistakes are really easy to make and they cause real problems, but if you just use an `Id` you can make them impossible.

# Whats the `x` in `Id x` for?

You understand the problem in the previous example right? Here is a very similar problem..

```elm
type Id
    = Id String

updateUsersCatsFavoriteFood : Id -> Id -> Id -> Cmd Msg
updateUsersCatsFavoriteFood userId catId foodId =
    -- ..
```

Theres absolutely nothing stopping a developer from mixing up a `catId` with a `userId` or a `foodId` with a `catId`.

Instead we can do..

```elm
type Id x
    = Id String

updateUsersCatsFavoriteFood : Id User -> Id Cat -> Id Food -> Cmd Msg
updateUsersCatsFavoriteFood userId catId foodId =
    -- ..
```

Now with `Id x`, it is impossible (again) to mix up a `Id User` with a `Id Cat`. They have different types. And the compiler will point out if you try and use a `Id User` where only a `Id Cat` works.

# Okay there is one drawback

The following code is not possible due to a circular definition of `User`.

```elm
type alias User =
    { id : Id User }
```

Easy work arounds include..

```elm
type UserId
    = UserId

type alias User =
    { id : Id UserId }
```

and

```elm
type alias User =
    { id : Id () }
```

..but I would encourage you to build your architecture such that data _does not_ contain its own `Id x` to begin with. Instead, you can pair your data with its `Id`, much like a key-value in a database.

```elm
    (Id User, User)
```

# Speaking of Databases

What if you are dealing with a lot of remote data? All the data has ids, and you have no idea what it will be until runtime. One approach is to consolidate everything into a little database on the front end side of your application that acts like a single source of truth for remote data, much like how backend applications manage a database.

This package provides a module called `Db` exposing a type `Db item`. for the most part, a `Db item` is just a wrapper around a `Dict String a`. The primary difference is that `Db item`s use `Id`s as keys, and the type signatures of its helper functions were designed assuming the use case of managing a lot of remote data.

# Message Board Example

```elm
type alias Thread =
    { title : String
    , posts : List (Id Post)
    }


type alias Post =
    { author : String
    , content : String
    }


threadView : Db Post -> (Id Thread, Thread) -> Html Msg
threadView postsDb (threadId, thread) =
    thread.posts
        |> Db.getManyWithId postsDb
        |> List.map postView
        |> (::) (p [] [ Html.text thread.title ])
        |> div [ css [ threadStyle ] ]


postView : (Id Post, Maybe Post) -> Html Msg
postView post =
    div
        [ css [ postStyle ] ]
        (postBody post)


postBody : (Id Post, Maybe Post) -> List (Html Msg)
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
