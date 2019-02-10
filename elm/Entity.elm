module Entity exposing (Entity, getById)


type alias Entity =
    { id : String, x : Float, y : Float, pixiType : String, scale : Float }


getById : String -> List Entity -> Entity
getById id =
    List.filter (\e -> e.id == id) >> List.head >> Maybe.withDefault emptyEntity


emptyEntity =
    Entity "incorrectId" 0 0 "NoPixiType" 1
