module Shared exposing (AppState(..), Behavior, Delta, EventData, GameState, Model, QuestType, Room, Turn(..))

import Pixi exposing (..)


type AppState
    = Title
    | Town
    | Quest


type alias Model =
    { updates : Int
    , behaviors : List Behavior
    , appState : AppState
    , gameState : GameState
    }


type alias Delta =
    Float


type alias Behavior =
    Delta -> Int -> GameState -> GameState


type alias EventData =
    { msg : String
    , value : String
    }


type Turn
    = Player
    | Enemy


type alias Room =
    { index : Int
    , maxHp : Int
    , currentHp : Int
    , turn : Turn
    , textures : List String
    }


type alias QuestType =
    { rooms : Room
    }


type alias GameState =
    { quest : QuestType
    , monsterX : Float
    , textColor : String
    }
