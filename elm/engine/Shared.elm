module Shared exposing (AppState(..), Behavior, Delta, EventData, GameState, Model, QuestData, Room, Turn(..))

import Pixi exposing (..)


type AppState
    = Title
    | Town
    | Quest QuestData


type alias Model =
    { updates : Int
    , behaviors : List Behavior
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


type alias QuestData =
    { rooms : List Room
    , currentRoom : Room
    }


type alias GameState =
    { monsterX : Float
    , textColor : String
    , mana : Int
    , appState : AppState
    }
