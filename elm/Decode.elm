module Decode exposing (decodePixiEvent)

import Json.Decode as D
import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


stringDecoder : String -> D.Decoder String
stringDecoder field =
    D.field field D.string


decodePixiEvent : D.Value -> Msg
decodePixiEvent value =
    let
        decoder =
            D.map2 EventData msgDecoder valueDecoder

        foo =
            D.decodeValue decoder value

        _ =
            Debug.log "foo" foo
    in
    case foo of
        Ok event ->
            case event.msg of
                "ChangeAppState" ->
                    case event.value of
                        "Quest" ->
                            ChangeAppState Quest

                        _ ->
                            Debug.todo "crash 456"

                "SetTextColor" ->
                    SetTextColor event.value

                _ ->
                    Debug.todo "crash 123"

        Err stuff ->
            Debug.todo "Handle errors"


msgDecoder =
    stringDecoder "msg"


valueDecoder =
    stringDecoder "value"
