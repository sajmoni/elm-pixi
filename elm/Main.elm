port module Main exposing (init)

import Behavior exposing (Behavior, run)
import Browser.Events
import Entity exposing (Entity)
import Juice
import Platform
import Shared exposing (Delta)
import Time



-- type PixiDisplayObject
--     = Graphics
--     | Text


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    }



-- Incoming actions


port incomingPort : (String -> msg) -> Sub msg



-- Outgoing subscriptions


port updatePort : List Entity -> Cmd msg


port initPort : List Entity -> Cmd msg


type Msg
    = UpdateSquare String
    | Tick Delta


getInitialEntities : Int -> List Entity
getInitialEntities times =
    List.range 1 times |> List.map (\n -> Entity ("square" ++ String.fromInt n) (toFloat n / 2) (toFloat (n + modBy n 5)) "Graphics" 1)


init : flags -> ( Model, Cmd msg )
init _ =
    let
        textEntity =
            Entity "titleText" 300 300 "Text" 1

        squares =
            getInitialEntities 10

        initialModel =
            { entities = textEntity :: squares
            , updates = 0
            , behaviors =
                Behavior "animateText" textEntity.id (Juice.sine { start = 1, end = 1.2, duration = 120 }) updateScale
                    :: List.map (\s -> Behavior "moveSquare" s.id (\_ -> 1) moveRight)
                        squares
            }
    in
    ( initialModel, initPort initialModel.entities )


moveRight : (Int -> Float) -> Int -> Delta -> Entity -> Entity
moveRight getX updates delta entity =
    { entity | x = entity.x + getX updates * delta / 15 }


updateScale : (Int -> Float) -> Int -> Delta -> Entity -> Entity
updateScale getScale updates _ entity =
    { entity | scale = getScale updates }


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
                                |> List.map
                                    (\entity ->
                                        if isGraphicsEntity entity && entity.id == idToUpdate then
                                            resetEntity entity

                                        else
                                            entity
                                    )
                    }

                Tick delta ->
                    { lastModel
                      -- | entities = lastModel.entities |> List.map (updateEntity delta lastModel.animateText lastModel.updates)
                        | entities = lastModel.behaviors |> List.map (run lastModel.updates delta lastModel.entities)
                        , updates = lastModel.updates + 1
                    }
    in
    ( newModel, updatePort newModel.entities )


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
