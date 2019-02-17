module Shared exposing (Behavior, Delta, GameState, QuestType, Room)

import Pixi exposing (BasicData, Entity)


type alias Delta =
    Float


type alias Behavior =
    Delta -> Int -> BasicData -> BasicData


type alias Room =
    { index : Int
    , render : Entity
    }


type alias QuestType =
    { rooms : Room
    }


type alias GameState =
    { quest : QuestType
    }
