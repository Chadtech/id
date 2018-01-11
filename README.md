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

```

Why use an `Id` instead of a `String`? Technically, both the following are possible with `String` ids..


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

```

Admittedly these errors seem implausible, but using a separate `Id` type eliminates them entirely. Theres really no functionality lost either, since ids arent meant to change over the life span of the data. Put another way: there really *shouldnt* be any functionality with ids, so using this `Id` type ensures your expectations.

And then of course you can decode and encode `Id`s too..

```elm

Encode.encode 0 (Id.encode id)
-- "\"hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh\"" : String

Decode.decodeString (Decode.field "id" Id.decoder) "{\"id\":\"19\"}"
-- Ok (Id 19) : Result String Id

```
