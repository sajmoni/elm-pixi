module Quest exposing (behaviors, combat, dealDamage, getQuest, inventory, inventoryStartPositionY, manaBar, monster, render, shouldExecuteUpdate, skillStartPositionX, skillStartPositionY, skillWidth, skills, spendMana)

import Bar
import Data exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


render : Model -> QuestData -> List (Entity Msg)
render model quest =
    manaBar model.gameState.mana
        :: (monster quest.currentRoom
                :: player quest.player
                :: inventorySlots model
                ++ skills model
                ++ enemyHealth quest.currentRoom
                ++ playerHealth quest.player
                ++ inventory model.gameState.inventory
           )


enemyHealthBar : Room -> Entity Msg
enemyHealthBar currentRoom =
    Bar.view "healthBarEnemy"
        300
        280
        "#ff0000"
        (toFloat currentRoom.enemy.currentHp)
        (toFloat currentRoom.enemy.maxHp)


playerHealthBar : Player -> Entity Msg
playerHealthBar p =
    Bar.view "healthBarPlayer"
        20
        280
        "#ff0000"
        (toFloat p.currentHp)
        (toFloat p.maxHp)


enemyHealth : Room -> List (Entity Msg)
enemyHealth currentRoom =
    [ enemyHealthBar currentRoom
    , Pixi.text
        [ id "hpEnemy"
        , x 400
        , y 295
        , textString (String.fromInt currentRoom.enemy.currentHp ++ " / " ++ String.fromInt currentRoom.enemy.maxHp)
        , textStyle [ fill "white", fontSize 24 ]
        ]
        []
    ]


playerHealth : Player -> List (Entity Msg)
playerHealth p =
    [ playerHealthBar p
    , Pixi.text
        [ id "hpPlayer"
        , x 100
        , y 295
        , textString (String.fromInt p.currentHp ++ " / " ++ String.fromInt p.maxHp)
        , textStyle [ fill "white", fontSize 24 ]
        ]
        []
    ]


manaBar : Int -> Entity Msg
manaBar mana =
    Pixi.graphics [ id "manaBar", x 50, y 700, color "#0000ff", shape (Rectangle (4 * toFloat mana) 25) ] []


monster : Room -> Entity Msg
monster currentRoom =
    Pixi.animatedSprite [ id "enemy", x 400, y 100, scale 6, textures currentRoom.enemy.textures, animationSpeed 0.015 ] []


player : Player -> Entity Msg
player p =
    Pixi.animatedSprite [ id "player", x 100, y 100, scale 6, textures p.textures, animationSpeed 0.015 ] []


inventorySlots : Model -> List (Entity Msg)
inventorySlots model =
    [ Pixi.sprite [ id "helmetSlot", x skillStartPositionX, y inventoryStartPositionY, scale 4, alpha 0.7, texture "equipment_29" ] []
    , Pixi.sprite [ id "bodySlot", x (skillStartPositionX + skillWidth), y inventoryStartPositionY, scale 4, alpha 0.7, texture "equipment_25" ] []
    , Pixi.sprite [ id "accessorySlot", x (skillStartPositionX + skillWidth * 2), y inventoryStartPositionY, scale 4, alpha 0.7, texture "equipment_29" ] []
    , Pixi.sprite [ id "gloveSlot", x (skillStartPositionX + skillWidth * 3), y inventoryStartPositionY, scale 4, alpha 0.7, texture "equipment_28" ] []
    , Pixi.sprite [ id "weaponSlot", x (skillStartPositionX + skillWidth * 4), y inventoryStartPositionY, scale 4, alpha 0.7, texture "equipment_33" ] []
    ]


inventory : Inventory -> List (Entity Msg)
inventory i =
    let
        inventoryToRender =
            []
    in
    []
        |> renderEquipment i.weapon
        |> renderEquipment i.helmet
        |> renderEquipment i.accessory
        |> renderEquipment i.glove
        |> renderEquipment i.armor
        |> List.filterMap identity


renderEquipment : Equipment -> List (Maybe (Entity Msg)) -> List (Maybe (Entity Msg))
renderEquipment eq list =
    case eq of
        Weapon data ->
            Just (Pixi.sprite [ id "weapon", x (skillStartPositionX + skillWidth * 4), y inventoryStartPositionY, scale 5, texture data.texture ] []) :: list

        Helmet image ->
            Just (Pixi.sprite [ id "helmet", x skillStartPositionX, y inventoryStartPositionY, scale 5, texture image ] []) :: list

        Accessory image ->
            Just (Pixi.sprite [ id "accessory", x (skillStartPositionX + skillWidth * 2), y inventoryStartPositionY, scale 5, texture image ] []) :: list

        Armor image ->
            Just (Pixi.sprite [ id "body", x (skillStartPositionX + skillWidth), y inventoryStartPositionY, scale 5, texture image ] []) :: list

        Glove image ->
            Just (Pixi.sprite [ id "glove", x (skillStartPositionX + skillWidth * 3), y inventoryStartPositionY, scale 5, texture image ] []) :: list

        _ ->
            Nothing :: list


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
    , checkIfPlayerDead
    ]


skillWidth =
    120


skillStartPositionX =
    40


skillStartPositionY =
    800


inventoryStartPositionY =
    500


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate (currentUpdate - firstUpdate) == 0


spendMana : GameState -> GameState
spendMana gameState =
    { gameState | mana = gameState.mana - 10 }


dealDamage : GameState -> GameState
dealDamage gameState =
    let
        quest =
            getQuest gameState

        currentRoom =
            quest.currentRoom

        enemy =
            currentRoom.enemy

        newHp =
            quest.currentRoom.enemy.currentHp - 10
    in
    { gameState
        | appState =
            Quest
                { rooms = quest.rooms
                , player = quest.player
                , currentRoom = { currentRoom | enemy = { enemy | currentHp = newHp } }
                }
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
                if quest.currentRoom.turn == PlayerTurn then
                    EnemyTurn

                else
                    PlayerTurn

            newHp =
                quest.currentRoom.enemy.currentHp - 1

            currentRoom =
                quest.currentRoom

            enemy =
                currentRoom.enemy
        in
        { gameState
            | appState =
                Quest
                    { rooms = quest.rooms
                    , player = quest.player
                    , currentRoom =
                        { currentRoom
                            | turn = newTurn
                            , enemy =
                                { enemy
                                    | currentHp = newHp
                                }
                        }
                    }
        }

    else
        gameState


checkIfPlayerDead : Behavior
checkIfPlayerDead delta updates gameState =
    case gameState.appState of
        Quest questData ->
            if questData.currentRoom.enemy.currentHp > 0 then
                gameState

            else
                { gameState | appState = mapQuest nextRoom gameState.appState }

        _ ->
            Debug.todo "Should never happen"


nextRoom : QuestData -> QuestData
nextRoom questData =
    let
        newRoom =
            getCurrentRoom (questData.currentRoom.index + 1) questData.rooms

        _ =
            Debug.log "newROom" newRoom
    in
    case newRoom of
        Just room ->
            { questData
                | currentRoom = room
            }

        Nothing ->
            Debug.todo "handle no next room"
