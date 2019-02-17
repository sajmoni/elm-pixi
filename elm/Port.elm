port module Port exposing (incoming, init, update)

import Json.Decode
import Json.Encode
import Msg exposing (EventData)
import Pixi exposing (..)



-- Incoming actions


port incoming : (EventData -> msg) -> Sub msg



-- Outgoing subscriptions


port update : Json.Encode.Value -> Cmd msg


port init : Json.Encode.Value -> Cmd msg
