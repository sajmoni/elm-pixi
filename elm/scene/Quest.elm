module Quest exposing (behaviors, combat, entities, gameStateUpdates, interactions, inventory, setQuest, setRoom, setTurn, skillBar, skillStartPositionX, skillStartPositionY, skillWidth)

import Msg exposing (..)
import Pixi
import Shared exposing (..)


entities : GameState -> List Pixi.Entity
entities gameState =
    gameState.quest.rooms.render
        :: List.append inventory
            [ Pixi.text
                { id = "questTitle", x = 280, y = 80, scale = Nothing, alpha = Nothing }
                { textString = "Quest", textStyle = { fill = "white", fontSize = 12 } }
            , Pixi.graphics
                { id = "healthBar1", x = 50, y = 280, scale = Nothing, alpha = Nothing }
                { color = "red", shape = Pixi.Rectangle 250 25 }
            ]



-- GameStateUpdates


gameStateUpdates : Int -> List (Int -> GameState -> GameState)
gameStateUpdates currentUpdate =
    [ combat currentUpdate 60
    ]



-- Behaviors


behaviors : List Behavior
behaviors =
    []



-- Interactions


interactions : List Interaction
interactions =
    []


skillWidth =
    120


skillStartPositionX =
    40


skillStartPositionY =
    800


skillBar : List Pixi.Entity
skillBar =
    [ Pixi.sprite
        { id = "skill1", x = skillStartPositionX, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "skill_001" }
    , Pixi.sprite
        { id = "skill2", x = skillStartPositionX + skillWidth, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "skill_002" }
    , Pixi.sprite
        { id = "skill3", x = skillStartPositionX + skillWidth * 2, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "skill_003" }
    , Pixi.sprite
        { id = "skill4", x = skillStartPositionX + skillWidth * 3, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "skill_004" }
    , Pixi.sprite
        { id = "skill5", x = skillStartPositionX + skillWidth * 4, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "skill_005" }
    ]


inventory : List Pixi.Entity
inventory =
    [ Pixi.sprite
        { id = "helmetSlot", x = skillStartPositionX, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "equipment_29" }
    , Pixi.sprite
        { id = "bodySlot", x = skillStartPositionX + skillWidth, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "equipment_24" }
    , Pixi.sprite
        { id = "accessorySlot", x = skillStartPositionX + skillWidth * 2, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "equipment_25" }
    , Pixi.sprite
        { id = "gloveSlot", x = skillStartPositionX + skillWidth * 3, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "equipment_28" }
    , Pixi.sprite
        { id = "weaponSlot", x = skillStartPositionX + skillWidth * 4, y = skillStartPositionY, scale = Just 4, alpha = Nothing }
        { texture = "equipment_33" }
    ]


setTurn : Turn -> Room -> Room
setTurn turn room =
    { room | turn = turn }


setQuest : QuestType -> GameState -> GameState
setQuest quest gameState =
    { gameState | quest = quest }


setRoom : Room -> QuestType -> QuestType
setRoom room quest =
    { quest | rooms = room }


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate currentUpdate == 0


combat : Int -> Int -> Int -> GameState -> GameState
combat firstUpdate everyNthUpdate updates gameState =
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

            _ =
                Debug.log "newTurn" newTurn
        in
        gameState |> setQuest (gameState.quest |> setRoom (gameState.quest.rooms |> setTurn newTurn))

    else
        gameState
