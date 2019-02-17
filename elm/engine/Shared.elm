module Shared exposing (Behavior, Delta)

import Pixi exposing (BasicData)


type alias Delta =
    Float


type alias Behavior =
    Delta -> Int -> BasicData -> BasicData
