port module Main exposing (init)

import Browser.Events
import Platform
import Time


type alias Entity =
    { id : String, x : Float, y : Float }


type alias Model =
    List Entity


port setModel : (Model -> msg) -> Sub msg


port getModel : Model -> Cmd msg


type alias Delta =
    Float


type Msg
    = SetModel Model
    | Tick Delta


init _ =
    let
        initialModel =
            [ { id = "square", x = 50, y = 50 } ]
    in
    ( initialModel, getModel initialModel )


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
    ( newModel, getModel newModel )


subscriptions model =
    Sub.batch [ setModel SetModel, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
