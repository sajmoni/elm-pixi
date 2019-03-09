module Shared exposing (AppState(..), Behavior, Damage, Delta, Equipment(..), EventData, GameState, Inventory, Model, QuestData, Room, Turn(..))

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


type alias Damage =
    Int


type Equipment
    = Weapon String Damage
    | Armor String
    | Glove String
    | Accessory String
    | Helmet String
    | None


type alias Inventory =
    { helmet : Equipment
    , armor : Equipment
    , weapon : Equipment
    , accessory : Equipment
    , glove : Equipment
    }


type alias GameState =
    { monsterX : Float
    , textColor : String
    , mana : Int
    , inventory : Inventory
    , appState : AppState
    }
