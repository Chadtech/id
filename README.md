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
-- Ok (Id 19) : Result String Id

```

# Origin Type

I am going to describe an app that sounds like something you might have made before. It revolves around a specific data type (say a `Car`), and it has one page where you can create a new `Car` and another where you can edit existing `Car`s. A `Car` is what is it, but if its being updated it already exists and therefore has an id, while if its new it necessarily doesnt exist and doesnt have an id. How do you represent that? Heres an idea..


```elm

type Origin
    = Local
    | Remote Id

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

```