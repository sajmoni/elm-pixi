port module Port exposing (incoming, init, update)

import Json.Encode
import Pixi exposing (..)



-- Incoming actions


port incoming : (String -> msg) -> Sub msg



-- Outgoing subscriptions


port update : Json.Encode.Value -> Cmd msg


port init : Json.Encode.Value -> Cmd msg
