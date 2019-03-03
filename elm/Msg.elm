module Msg exposing (Msg(..))

import Pixi exposing (..)
import Shared exposing (..)


type Msg
    = Noop
    | ChangeAppState AppState
    | SetTextColor String
    | DealDamage
    | Tick Delta
