port module Port exposing (incoming, init, update)

import Json.Decode
import Json.Encode
import Model exposing (..)
import Pixi exposing (..)



-- Incoming actions


port incoming : (Json.Decode.Value -> msg) -> Sub msg



-- Outgoing subscriptions


port update : Json.Encode.Value -> Cmd msg


port init : Json.Encode.Value -> Cmd msg
