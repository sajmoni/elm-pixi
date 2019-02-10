port module Main exposing (init)

import Browser.Events
import Juice
import Platform
import Time



-- type PixiDisplayObject
--     = Graphics
--     | Text


type alias Entity =
    { id : String, x : Float, y : Float, pixiType : String }


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
    List.range 1 times |> List.map (\n -> Entity ("square" ++ String.fromInt n) (toFloat n / 2) (toFloat (n + modBy n 5)) "Graphics")


init : flags -> ( Model, Cmd msg )
init _ =
    let
        initialModel =
            { entities = Entity "titleText" 10 100 "Text" :: getInitialEntities 10 }
    in
    ( initialModel, initPort initialModel )


updateEntity : Delta -> Entity -> Entity
updateEntity delta entity =
    { entity | x = entity.x + delta / 10 }


resetEntity : Entity -> Entity
resetEntity entity =
    { entity | x = 50 }


isGraphicsEntity entity =
    entity.pixiType == "Graphics"


update : Msg -> Model -> ( Model, Cmd msg )
update msg lastModel =
    let
        newModel =
            case msg of
                UpdateSquare idToUpdate ->
                    { lastModel
                        | entities =
                            lastModel.entities
                                |> List.filter isGraphicsEntity
                                |> List.map
                                    (\entity ->
                                        if entity.id == idToUpdate then
                                            resetEntity entity

                                        else
                                            entity
                                    )
                    }

                Tick delta ->
                    { lastModel | entities = lastModel.entities |> List.filter isGraphicsEntity |> List.map (updateEntity delta) }
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
