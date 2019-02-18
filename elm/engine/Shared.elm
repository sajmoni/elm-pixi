module Shared exposing (Behavior, Delta, GameState, GameStateUpdate, QuestType, Room, Turn(..))

import Pixi exposing (BasicData, Entity)


type alias Delta =
    Float


type alias Behavior =
    Delta -> Int -> BasicData -> BasicData


type alias GameStateUpdate =
    Int -> GameState -> GameState


type Turn
    = Player
    | Enemy


type alias Room =
    { index : Int
    , render : Entity
    , maxHp : Int
    , currentHp : Int
    , turn : Turn
    }


type alias QuestType =
    { rooms : Room
    }


type alias GameState =
    { quest : QuestType
    }
