module Quest exposing (behaviors, combat, dealDamage, healthBars, inventory, inventoryStartPositionY, monster, render, shouldExecuteUpdate, skillStartPositionX, skillStartPositionY, skillWidth, skills)

import Data exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


render : Model -> Room -> List (Entity Msg)
render model currentRoom =
    monster currentRoom :: inventory model ++ skills model ++ healthBars currentRoom


getHealthBar : Room -> Entity Msg
getHealthBar currentRoom =
    Pixi.graphics [ id "healthBarEnemy", x 250, y 280, color "#ff0000", shape (Rectangle (2.5 * toFloat currentRoom.currentHp) 25) ]
        []


healthBars : Room -> List (Entity Msg)
healthBars currentRoom =
    [ getHealthBar currentRoom
    , Pixi.text
        [ id "hpEnemy", x 500, y 280, textString (String.fromInt currentRoom.currentHp), textStyle [ fill "white", fontSize 12 ] ]
        []
    ]


monster : Room -> Entity Msg
monster currentRoom =
    Pixi.animatedSprite [ id "enemy", x 400, y 100, scale 6, textures currentRoom.textures, animationSpeed 0.02 ] []


inventory : Model -> List (Entity Msg)
inventory model =
    [ Pixi.sprite [ id "helmetSlot", x skillStartPositionX, y inventoryStartPositionY, scale 4, texture "equipment_29" ] []
    , Pixi.sprite [ id "bodySlot", x (skillStartPositionX + skillWidth), y inventoryStartPositionY, scale 4, texture "equipment_25" ] []
    , Pixi.sprite [ id "accessorySlot", x (skillStartPositionX + skillWidth * 2), y inventoryStartPositionY, scale 4, texture "equipment_29" ] []
    , Pixi.sprite [ id "gloveSlot", x (skillStartPositionX + skillWidth * 3), y inventoryStartPositionY, scale 4, texture "equipment_28" ] []
    , Pixi.sprite [ id "weaponSlot", x (skillStartPositionX + skillWidth * 4), y inventoryStartPositionY, scale 4, texture "equipment_33" ] []
    ]


skills : Model -> List (Entity Msg)
skills model =
    [ Pixi.sprite [ id "skill1", x skillStartPositionX, y skillStartPositionY, scale 4, texture "skill_001", on "click" DealDamage ] []
    , Pixi.sprite [ id "skill2", x (skillStartPositionX + skillWidth), y skillStartPositionY, scale 4, texture "skill_002" ] []
    , Pixi.sprite [ id "skill3", x (skillStartPositionX + skillWidth * 2), y skillStartPositionY, scale 4, texture "skill_003" ] []
    , Pixi.sprite [ id "skill4", x (skillStartPositionX + skillWidth * 3), y skillStartPositionY, scale 4, texture "skill_004" ] []
    , Pixi.sprite [ id "skill5", x (skillStartPositionX + skillWidth * 4), y skillStartPositionY, scale 4, texture "skill_005" ] []
    ]


behaviors : Int -> List Behavior
behaviors currentUpdate =
    [ combat currentUpdate 60
    ]


skillWidth =
    120


skillStartPositionX =
    40


skillStartPositionY =
    800


inventoryStartPositionY =
    500



-- setTurn : Turn -> GameState -> GameState
-- setTurn turn gameState =
--     let
--         rooms =
--             gameState.quest.rooms
--     in
--     gameState
--         |> setQuest
--             (gameState.quest
--                 |> setRoom
--                     { rooms | turn = turn }
--             )
-- setQuest : QuestType -> GameState -> GameState
-- setQuest quest gameState =
--     { gameState | quest = quest }
-- setRoom : Room -> QuestType -> QuestType
-- setRoom room quest =
--     { quest | rooms = room }
-- setHp : Int -> Room -> Room
-- setHp hp room =
--     { room | currentHp = hp }


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate (currentUpdate - firstUpdate) == 0



-- setEnemyHp : Int -> GameState -> GameState
-- setEnemyHp newHp gameState =
--     gameState
--         |> setQuest
--             (gameState.quest
--                 |> setRoom
--                     (gameState.quest.rooms
--                         |> setHp newHp
--                     )
--             )


dealDamage : GameState -> GameState
dealDamage gameState =
    let
        quest =
            getQuest gameState

        currentRoom =
            quest.currentRoom

        newHp =
            quest.currentRoom.currentHp - 10
    in
    { gameState
        | appState = Quest (QuestData quest.rooms { currentRoom | currentHp = newHp })
    }


getQuest : GameState -> QuestData
getQuest gameState =
    case gameState.appState of
        Quest questData ->
            questData

        _ ->
            Debug.todo "getQuest crashed"


combat : Int -> Int -> Behavior
combat firstUpdate everyNthUpdate delta updates gameState =
    let
        shouldUpdate =
            shouldExecuteUpdate firstUpdate everyNthUpdate updates
    in
    if shouldUpdate then
        let
            quest =
                getQuest gameState

            newTurn =
                if quest.currentRoom.turn == Player then
                    Enemy

                else
                    Player

            newHp =
                quest.currentRoom.currentHp - 1

            currentRoom =
                quest.currentRoom
        in
        { gameState
            | appState = Quest (QuestData quest.rooms { currentRoom | currentHp = newHp, turn = newTurn })
        }

    else
        gameState
