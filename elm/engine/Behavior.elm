module Behavior exposing (Behavior)

import Pixi exposing (..)
import Shared exposing (Delta)



-- create


type alias Behavior =
    { id : String
    , entity : Entity
    , transformation : Int -> Float
    , onUpdate : (Int -> Float) -> Int -> Delta -> Entity -> Entity
    }
