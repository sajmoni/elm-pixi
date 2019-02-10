module Behavior exposing (Behavior, run)

import Entity exposing (..)
import Shared exposing (Delta)



-- create


type alias Behavior =
    { id : String
    , entityId : String
    , transformation : Int -> Float
    , onUpdate : (Int -> Float) -> Int -> Delta -> Entity -> Entity
    }


run : Int -> Float -> List Entity -> Behavior -> Entity
run updates delta entities behavior =
    behavior.onUpdate behavior.transformation updates delta (getById behavior.entityId entities)
