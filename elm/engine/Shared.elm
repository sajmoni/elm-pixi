module Shared exposing (Behavior, Delta, InteractionData)

import Pixi exposing (BasicData)


type alias Delta =
    Float


type alias InteractionData =
    { id : String
    , event : String
    }


type alias Behavior =
    Delta -> Int -> BasicData -> BasicData
