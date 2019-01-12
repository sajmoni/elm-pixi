port module Main exposing (init)

import Browser.Events
import Platform
import Time


type alias Entity =
    { id : String, x : Float, y : Float }


type alias Model =
    List Entity



-- Incoming actions


port updateSquare : (String -> msg) -> Sub msg



-- Outgoing subscriptions


port updatePort : Model -> Cmd msg


port initPort : Model -> Cmd msg


type alias Delta =
    Float


type Msg
    = UpdateSquare String
    | Tick Delta


init _ =
    let
        initialModel =
            [ Entity "square1" 50 50
            , Entity "square2" 150 150
            , Entity "square3" 250 250
            ]
    in
    ( initialModel, initPort initialModel )


updateEntity delta entity =
    { entity | x = entity.x + delta / 10 }


resetEntity entity =
    { entity | x = 50 }


update msg lastModel =
    let
        newModel =
            case msg of
                UpdateSquare idToUpdate ->
                    List.map
                        (\entity ->
                            if entity.id == idToUpdate then
                                resetEntity entity

                            else
                                entity
                        )
                        lastModel

                Tick delta ->
                    List.map (updateEntity delta) lastModel
    in
    ( newModel, updatePort newModel )


subscriptions model =
    Sub.batch [ updateSquare UpdateSquare, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
