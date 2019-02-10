port module Main exposing (init)

import Browser.Events
import Platform
import Time


type alias Entity =
    { id : String, x : Float, y : Float }


type alias Model =
    { entities : List Entity
    }



-- Incoming actions


port incomingPort : (String -> msg) -> Sub msg



-- Outgoing subscriptions


port updatePort : Model -> Cmd msg


port initPort : Model -> Cmd msg


type alias Delta =
    Float


type Msg
    = UpdateSquare String
    | Tick Delta


getInitialEntities : Int -> List Entity
getInitialEntities times =
    List.range 1 times |> List.map (\n -> Entity ("square" ++ String.fromInt n) (toFloat n / 2) (toFloat (n + modBy n 5)))


init : flags -> ( Model, Cmd msg )
init _ =
    let
        initialModel =
            { entities = getInitialEntities 10 }
    in
    ( initialModel, initPort initialModel )


updateEntity : Delta -> Entity -> Entity
updateEntity delta entity =
    { entity | x = entity.x + delta / 10 }


resetEntity : Entity -> Entity
resetEntity entity =
    { entity | x = 50 }


update : Msg -> Model -> ( Model, Cmd msg )
update msg lastModel =
    let
        newModel =
            case msg of
                UpdateSquare idToUpdate ->
                    { lastModel
                        | entities =
                            List.map
                                (\entity ->
                                    if entity.id == idToUpdate then
                                        resetEntity entity

                                    else
                                        entity
                                )
                                lastModel.entities
                    }

                Tick delta ->
                    { lastModel | entities = List.map (updateEntity delta) lastModel.entities }
    in
    ( newModel, updatePort newModel )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ incomingPort UpdateSquare, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
