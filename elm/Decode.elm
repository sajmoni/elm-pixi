module Decode exposing (decodePixiEvent)

import Json.Decode as D
import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


stringDecoder : String -> D.Decoder String
stringDecoder field =
    D.field field (D.oneOf [ D.string, D.null "" ])


decodePixiEvent : D.Value -> Msg
decodePixiEvent value =
    let
        decoder =
            D.map2 EventData msgDecoder valueDecoder

        decodedValue =
            D.decodeValue decoder value
    in
    case decodedValue of
        Ok event ->
            case event.msg of
                "ChangeAppState" ->
                    case event.value of
                        -- "Quest" ->
                        --     ChangeAppState Quest
                        "Title" ->
                            ChangeAppState Town

                        "Town" ->
                            ChangeAppState Title

                        _ ->
                            Debug.todo "crash 456"

                "SetTextColor" ->
                    SetTextColor event.value

                "DealDamage" ->
                    DealDamage

                "GenerateNewQuest" ->
                    GenerateNewQuest

                _ ->
                    Debug.todo "crash 123"

        Err stuff ->
            Debug.todo "Handle errors"


msgDecoder =
    stringDecoder "msg"


valueDecoder =
    stringDecoder "value"
