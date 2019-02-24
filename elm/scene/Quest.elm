module Quest exposing (behaviors, combat, entities, gameStateUpdates, interactions, inventory, setEnemyHp, setHp, setQuest, setRoom, setTurn, shouldExecuteUpdate, skillBar, skillStartPositionX, skillStartPositionY, skillWidth)

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
            , Pixi.text
                { id = "hp", x = 400, y = 400, scale = Nothing, alpha = Nothing }
                { textString = String.fromInt gameState.quest.rooms.currentHp, textStyle = { fill = "white", fontSize = 12 } }
            ]



-- GameStateUpdates


gameStateUpdates : Int -> List (Int -> GameState -> List Msg)
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


setTurn : Turn -> GameState -> GameState
setTurn turn gameState =
    let
        rooms =
            gameState.quest.rooms
    in
    gameState
        |> setQuest
            (gameState.quest
                |> setRoom
                    { rooms | turn = turn }
            )


setQuest : QuestType -> GameState -> GameState
setQuest quest gameState =
    { gameState | quest = quest }


setRoom : Room -> QuestType -> QuestType
setRoom room quest =
    { quest | rooms = room }


setHp : Int -> Room -> Room
setHp hp room =
    { room | currentHp = hp }


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate (currentUpdate - firstUpdate) == 0


setEnemyHp : Int -> GameState -> GameState
setEnemyHp newHp gameState =
    gameState
        |> setQuest
            (gameState.quest
                |> setRoom
                    (gameState.quest.rooms
                        |> setHp newHp
                    )
            )


combat : Int -> Int -> Int -> GameState -> List Msg
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

            newHp =
                gameState.quest.rooms.currentHp - 1
        in
        [ SetEnemyHp newHp
        , SetText "hp" (String.fromInt newHp)
        , SetTurn newTurn
        ]

    else
        []
