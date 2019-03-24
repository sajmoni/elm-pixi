module Data exposing (getCurrentRoom, getQuest, getRoom, mapQuest)

import Monster exposing (..)
import Shared exposing (..)


getMonster random =
    case random of
        0 ->
            monster0

        1 ->
            monster1

        2 ->
            monster2

        _ ->
            Debug.todo "Add more monsters!"


getRoom : Int -> Int -> Room
getRoom index random =
    let
        monster =
            getMonster random
    in
    { index = index
    , turn = PlayerTurn
    , enemy =
        { currentHp = monster.currentHp
        , maxHp = monster.maxHp
        , textures = monster.textures
        }
    }


getQuest : List Int -> List Room
getQuest list =
    List.indexedMap getRoom list


getCurrentRoom : Int -> List Room -> Maybe Room
getCurrentRoom currentRoom rooms =
    rooms |> List.filter (isCurrentRoom currentRoom) |> List.head


isCurrentRoom : Int -> Room -> Bool
isCurrentRoom currentRoom room =
    if currentRoom == room.index then
        True

    else
        False


mapQuest : (QuestData -> QuestData) -> AppState -> AppState
mapQuest f appState =
    case appState of
        Quest questData ->
            Quest (f questData)

        _ ->
            appState
