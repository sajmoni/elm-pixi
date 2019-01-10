port module Main exposing (init)

import Platform


type alias Model =
    String


port setModel : (Model -> msg) -> Sub msg


port getModel : Model -> Cmd msg


type Msg
    = SetModel Model


init _ =
    ( "test", Cmd.none )


update msg _ =
    let
        newModel =
            case msg of
                SetModel model ->
                    model
    in
    ( newModel, getModel newModel )


subscriptions model =
    setModel SetModel


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
