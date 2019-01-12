port module Main exposing (init)

import Browser.Events
import Platform
import Time


type alias Entity =
    { id : String, x : Float, y : Float }


type alias Model =
    List Entity



-- Incoming actions


port setModel : (Model -> msg) -> Sub msg



-- Outgoing subscriptions


port updatePort : Model -> Cmd msg


port initPort : Model -> Cmd msg


type alias Delta =
    Float


type Msg
    = SetModel Model
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


update msg lastModel =
    let
        newModel =
            case msg of
                SetModel model ->
                    model

                Tick delta ->
                    List.map (updateEntity delta) lastModel
    in
    ( newModel, updatePort newModel )


subscriptions model =
    Sub.batch [ setModel SetModel, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
