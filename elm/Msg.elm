module Msg exposing (Msg(..))

import Pixi exposing (..)
import Shared exposing (..)


type Msg
    = SetEnemyHp Int
    | SetTurn Turn
    | Noop
    | ChangeAppState AppState
    | SetTextColor String
    | DealDamage
    | Tick Delta
