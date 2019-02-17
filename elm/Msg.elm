module Msg exposing (AppState(..), InteractionAlias, Msg(..))

import Pixi exposing (..)
import Shared exposing (..)


type AppState
    = Title
    | Town
    | Quest


type Msg
    = Interaction InteractionData
    | RemoveEntity String
    | AddEntity Entity
    | SetTextColor Id String
    | Noop
    | ChangeAppState AppState
    | Tick Delta


type alias InteractionAlias =
    { id : String
    , event : String
    , msg : Msg
    }
