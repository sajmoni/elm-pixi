module Quest exposing (behaviors, combat, dealDamage, healthBars, inventory, inventoryStartPositionY, monster, render, shouldExecuteUpdate, skillStartPositionX, skillStartPositionY, skillWidth, skills)

import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


render : Model -> List (Entity Msg)
render model =
    monster model :: inventory model ++ skills model ++ healthBars model


healthBars : Model -> List (Entity Msg)
healthBars model =
    [ Pixi.graphics [ id "healthBarEnemy", x 250, y 280, color "red", shape (Rectangle 250 25) ]
        []
    , Pixi.text
        [ id "hpEnemy", x 500, y 280, textString (String.fromInt model.gameState.quest.rooms.currentHp), textStyle [ fill "white", fontSize 12 ] ]
        []
    ]


monster : Model -> Entity Msg
monster model =
    Pixi.animatedSprite [ id "enemy", x 400, y 100, scale 6, textures model.gameState.quest.rooms.textures, animationSpeed 0.02 ] []


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
            gameState.quest

        rooms =
            quest.rooms

        newHp =
            gameState.quest.rooms.currentHp - 10
    in
    { gameState
        | quest = { quest | rooms = { rooms | currentHp = newHp } }
    }


combat : Int -> Int -> Behavior
combat firstUpdate everyNthUpdate delta updates gameState =
    let
        shouldUpdate =
            shouldExecuteUpdate firstUpdate everyNthUpdate updates
    in
    if shouldUpdate then
        let
            newTurn =
                if gameState.quest.rooms.turn == Player then
                    Enemy

                else
                    Player

            newHp =
                gameState.quest.rooms.currentHp - 1

            quest =
                gameState.quest

            rooms =
                quest.rooms
        in
        { gameState
            | quest = { quest | rooms = { rooms | currentHp = newHp, turn = newTurn } }
        }

    else
        gameState
