module Model exposing (Accessory, AppState(..), Armor, Behavior, Damage, Delta, Enemy, EventData, GameState, Glove, Helmet, Inventory, Model, Player, QuestData, Room, Turn(..), Weapon)

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
    , damage : Int
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


type alias Weapon =
    { texture : String
    , damage : Int
    }


type alias Armor =
    { texture : String
    }


type alias Glove =
    { texture : String
    }


type alias Accessory =
    { texture : String
    }


type alias Helmet =
    { texture : String
    }


type alias Inventory =
    { helmet : Maybe Helmet
    , armor : Maybe Armor
    , weapon : Maybe Weapon
    , accessory : Maybe Accessory
    , glove : Maybe Glove
    }


type alias GameState =
    { monsterX : Float
    , textColor : String
    , mana : Int
    , inventory : Inventory
    , appState : AppState
    }
