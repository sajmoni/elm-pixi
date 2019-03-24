module Msg exposing (Msg(..))

import Model exposing (..)
import Pixi exposing (..)


type Msg
    = Noop
    | ChangeAppState AppState
    | SetTextColor String
    | DealDamage
    | NewQuestGenerated (List Int)
    | GenerateNewQuest
    | Tick Delta
