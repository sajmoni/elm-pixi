port module Main exposing (init)

import Browser.Events
import Juice
import Platform
import Time



-- type PixiDisplayObject
--     = Graphics
--     | Text


type alias Entity =
    { id : String, x : Float, y : Float, pixiType : String, scale : Float }


type alias Model =
    { entities : List Entity
    , animateText : Int -> Float
    , updates : Int
    }



-- Incoming actions


port incomingPort : (String -> msg) -> Sub msg



-- Outgoing subscriptions


port updatePort : List Entity -> Cmd msg


port initPort : List Entity -> Cmd msg


type alias Delta =
    Float


type Msg
    = UpdateSquare String
    | Tick Delta


getInitialEntities : Int -> List Entity
getInitialEntities times =
    List.range 1 times |> List.map (\n -> Entity ("square" ++ String.fromInt n) (toFloat n / 2) (toFloat (n + modBy n 5)) "Graphics" 1)


init : flags -> ( Model, Cmd msg )
init _ =
    let
        initialModel =
            { entities = Entity "titleText" 200 300 "Text" 1 :: getInitialEntities 10
            , animateText = Juice.sine { start = 1, end = 1.2, duration = 120 }
            , updates = 0
            }
    in
    ( initialModel, initPort initialModel.entities )


updateEntity : Delta -> (Int -> Float) -> Int -> Entity -> Entity
updateEntity delta getScale updates entity =
    if isGraphicsEntity entity then
        { entity | x = entity.x + delta / 10 }

    else
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
                    { lastModel
                        | entities = lastModel.entities |> List.map (updateEntity delta lastModel.animateText lastModel.updates)
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
