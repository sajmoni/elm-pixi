module Shared exposing (AppState(..), Behavior, Damage, Delta, Enemy, Equipment(..), EventData, GameState, Inventory, Model, Player, QuestData, Room, Turn(..), WeaponData)

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
    = PlayerTurn
    | EnemyTurn


type alias Room =
    { index : Int
    , turn : Turn
    , enemy : Enemy
    }


type alias Enemy =
    { maxHp : Int
    , currentHp : Int
    , textures : List String
    }


type alias Player =
    { maxHp : Int
    , currentHp : Int
    , textures : List String
    }


type alias QuestData =
    { rooms : List Room
    , currentRoom : Room
    , player : Player
    }


type alias Damage =
    Int


type alias WeaponData =
    { texture : String
    , damage : Int
    }


type Equipment
    = Weapon WeaponData
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
