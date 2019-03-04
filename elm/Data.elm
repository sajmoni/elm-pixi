module Data exposing (getCurrentRoom, getMonster, getQuest, getRoom, isCurrentRoom, monster0, monster1, monster2)

import Shared exposing (..)


monster0 =
    { maxHp = 60
    , currentHp = 60
    , textures = [ "monster_17", "monster_18" ]
    }


monster1 =
    { maxHp = 80
    , currentHp = 80
    , textures = [ "monster_19", "monster_20" ]
    }


monster2 =
    { maxHp = 100
    , currentHp = 100
    , textures = [ "monster_21", "monster_22" ]
    }


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


getRoom index random =
    let
        monster =
            getMonster random
    in
    { index = index
    , turn = Player
    , currentHp = monster.currentHp
    , maxHp = monster.maxHp
    , textures = monster.textures
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
