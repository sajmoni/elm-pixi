module Msg exposing (AppState(..), EventData, Interaction, Msg(..))

import Pixi exposing (..)
import Shared exposing (..)


type AppState
    = Title
    | Town
    | Quest


type alias EventData =
    { id : String
    , event : String
    }


type Msg
    = PixiEvent EventData
    | RemoveEntity String
    | AddEntity Entity
    | SetTextColor Id String
    | Noop
    | ChangeAppState AppState
    | Tick Delta


type alias Interaction =
    { id : String
    , event : String
    , msg : Msg
    }
