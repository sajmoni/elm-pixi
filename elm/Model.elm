module Model exposing (Accessory, AppState(..), Armor, Damage, Delta, Enemy, EventData, GameState, Glove, Helmet, Inventory, Model, Player, QuestData, Room, Turn(..), Weapon)

import Behavior exposing (..)
import Pixi exposing (..)


type alias Model =
    { updates : Int
    , gameState : GameState
    , behaviors : List (Behavior GameState)
    }


type alias GameState =
    { monsterX : Float
    , textColor : String
    , mana : Int
    , inventory : Inventory
    , appState : AppState
    }


type AppState
    = Title
    | Town
    | Quest QuestData


type alias QuestData =
    { rooms : List Room
    , currentRoom : Room
    , player : Player
    }


type alias Player =
    { maxHp : Int
    , currentHp : Int
    , textures : List String
    , attacking : Bool
    }


type alias Delta =
    Float


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
