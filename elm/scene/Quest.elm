module Quest exposing (accessoryPosition, armorPosition, behaviors, checkIfPlayerDead, combat, dealDamage, enemyHealth, enemyHealthBar, getQuest, glovePosition, helmetPosition, inventory, inventorySlots, inventoryStartPosition, manaBar, monster, nextRoom, playerHealth, playerHealthBar, render, renderAccessory, renderArmor, renderGlove, renderHelmet, renderPlayer, renderWeapon, shouldExecuteUpdate, skillStartPositionX, skillStartPositionY, skillWidth, skills, spendMana, updateHp, weaponPosition)

import Bar
import Behavior as B
import Data exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Weapon exposing (..)


skillWidth =
    120


skillStartPositionX =
    40


skillStartPositionY =
    800


inventoryStartPosition =
    { x = 60
    , y = 350
    }


helmetPosition =
    { x = inventoryStartPosition.x + 90
    , y = inventoryStartPosition.y
    }


armorPosition =
    { x = inventoryStartPosition.x + 80
    , y = inventoryStartPosition.y + 90
    }


accessoryPosition =
    { x = inventoryStartPosition.x
    , y = inventoryStartPosition.y + 90
    }


weaponPosition =
    { x = inventoryStartPosition.x + 210
    , y = inventoryStartPosition.y + 90
    }


glovePosition =
    { x = inventoryStartPosition.x + 210
    , y = inventoryStartPosition.y + 190
    }


render : Model -> QuestData -> List (Entity Msg)
render model quest =
    manaBar model.gameState.mana
        :: (monster quest.currentRoom
                :: renderPlayer quest.player
                :: slash quest.player.attacking
                :: inventorySlots model
                ++ skills model
                ++ enemyHealth quest.currentRoom
                ++ playerHealth quest.player
                ++ inventory model.gameState.inventory
           )


renderEffect : Entity Msg
renderEffect =
    Pixi.animatedSprite
        [ id "effect"
        , x 370
        , y 70
        , scale 7
        , animationSpeed 0.1
        , textures
            [ "ExplodeA00"
            , "ExplodeA01"
            , "ExplodeA02"
            , "ExplodeA03"
            , "ExplodeA04"
            , "ExplodeA05"
            , "ExplodeA06"
            , "ExplodeA07"
            , "ExplodeA08"
            , "ExplodeA09"
            , "ExplodeA10"
            , "ExplodeA11"
            ]
        ]
        []


slash : Bool -> Entity Msg
slash show =
    if show then
        Pixi.animatedSprite
            [ id "effect"
            , x 370
            , y 70
            , scale 7
            , animationSpeed 0.2
            , textures
                [ "Slash16"
                , "Slash15"
                , "Slash14"
                , "Slash13"
                , "Slash12"
                , "Slash11"
                , "Slash10"
                ]
            ]
            []

    else
        Pixi.empty


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
    Pixi.animatedSprite [ id "enemy", x 370, y 70, scale 8, textures currentRoom.enemy.textures, animationSpeed 0.015 ] []


renderPlayer : Player -> Entity Msg
renderPlayer p =
    Pixi.animatedSprite [ id "player", x 70, y 70, scale 8, textures p.textures, animationSpeed 0.015 ] []


inventorySlots : Model -> List (Entity Msg)
inventorySlots model =
    [ Pixi.sprite [ id "helmetSlot", x helmetPosition.x, y helmetPosition.y, scale 4, alpha 0.7, texture "equipment_29" ] []
    , Pixi.sprite [ id "armorSlot", x armorPosition.x, y armorPosition.y, scale 6, alpha 0.7, texture "equipment_25" ] []
    , Pixi.sprite [ id "accessorySlot", x accessoryPosition.x, y accessoryPosition.y, scale 4, alpha 0.7, texture "equipment_29" ] []
    , Pixi.sprite [ id "gloveSlot", x glovePosition.x, y glovePosition.y, scale 4, alpha 0.7, texture "equipment_28" ] []
    , Pixi.sprite [ id "weaponSlot", x weaponPosition.x, y weaponPosition.y, scale 4, alpha 0.7, texture "equipment_33" ] []
    ]


inventory : Inventory -> List (Entity Msg)
inventory i =
    []
        |> renderWeapon i.weapon
        |> renderArmor i.armor
        |> renderHelmet i.helmet
        |> renderAccessory i.accessory
        |> renderGlove i.glove


renderWeapon : Maybe Weapon -> List (Entity Msg) -> List (Entity Msg)
renderWeapon weapon list =
    case weapon of
        Just w ->
            Pixi.sprite [ id "weapon", x weaponPosition.x, y weaponPosition.y, scale 5, texture w.texture ] [] :: list

        Nothing ->
            list


renderArmor : Maybe Armor -> List (Entity Msg) -> List (Entity Msg)
renderArmor armor list =
    case armor of
        Just a ->
            Pixi.sprite [ id "armor", x armorPosition.x, y armorPosition.y, scale 7, texture a.texture ] [] :: list

        Nothing ->
            list


renderHelmet : Maybe Helmet -> List (Entity Msg) -> List (Entity Msg)
renderHelmet helmet list =
    case helmet of
        Just h ->
            Pixi.sprite [ id "helmet", x helmetPosition.x, y helmetPosition.y, scale 5, texture h.texture ] [] :: list

        Nothing ->
            list


renderAccessory : Maybe Accessory -> List (Entity Msg) -> List (Entity Msg)
renderAccessory accessory list =
    case accessory of
        Just a ->
            Pixi.sprite [ id "accessory", x accessoryPosition.x, y accessoryPosition.y, scale 5, texture a.texture ] [] :: list

        Nothing ->
            list


renderGlove : Maybe Glove -> List (Entity Msg) -> List (Entity Msg)
renderGlove glove list =
    case glove of
        Just g ->
            Pixi.sprite [ id "glove", x glovePosition.x, y glovePosition.y, scale 5, texture g.texture ] [] :: list

        Nothing ->
            list


skills : Model -> List (Entity Msg)
skills model =
    [ Pixi.sprite [ id "skill1", x skillStartPositionX, y skillStartPositionY, scale 4, texture "skill_001", on "click" DealDamage ] []
    , Pixi.sprite [ id "skill2", x (skillStartPositionX + skillWidth), y skillStartPositionY, scale 4, texture "skill_002" ] []
    , Pixi.sprite [ id "skill3", x (skillStartPositionX + skillWidth * 2), y skillStartPositionY, scale 4, texture "skill_003" ] []
    , Pixi.sprite [ id "skill4", x (skillStartPositionX + skillWidth * 3), y skillStartPositionY, scale 4, texture "skill_004" ] []
    , Pixi.sprite [ id "skill5", x (skillStartPositionX + skillWidth * 4), y skillStartPositionY, scale 4, texture "skill_005" ] []
    ]


behaviors : Int -> List (B.Behavior GameState)
behaviors currentUpdate =
    [ B.repeat combat 60 currentUpdate
    , B.repeat checkIfPlayerDead 1 currentUpdate
    ]


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


updateHp : Turn -> GameState -> QuestData -> QuestData
updateHp turn gameState quest =
    let
        currentRoom =
            quest.currentRoom

        enemy =
            currentRoom.enemy

        player =
            quest.player
    in
    case turn of
        PlayerTurn ->
            { quest
                | currentRoom =
                    { currentRoom
                        | enemy =
                            { enemy
                                | currentHp = enemy.currentHp - (Maybe.withDefault sword1 gameState.inventory.weapon).damage
                            }
                    }
                , player =
                    { player
                        | attacking = True
                    }
            }

        EnemyTurn ->
            { quest
                | player =
                    { player
                        | currentHp = player.currentHp - enemy.damage
                    }
            }



-- endSlash : Int -> Int -> Behavior GameState
-- endSlash firstUpdate everyNthUpdate delta updates gameState =
--     let
--         shouldUpdate =
--             shouldExecuteUpdate firstUpdate everyNthUpdate updates
--     in
--     if shouldUpdate then
--         let
--             quest =
--                 getQuest gameState
--         in
--         gameState
--     else
--         gameState
-- addEndSlashBehavior: Int -> Turn -> Behavior
-- addEndSlashBehavior currentUpdate turn =
--     if turn == PlayerTurn then
--         endSlash currentUpdate 12


combat : B.UpdateFunction GameState
combat delta currentUpdate gameState =
    let
        quest =
            getQuest gameState

        newTurn =
            if quest.currentRoom.turn == PlayerTurn then
                EnemyTurn

            else
                PlayerTurn

        questWithUpdatedHp =
            updateHp newTurn gameState quest

        currentRoom =
            questWithUpdatedHp.currentRoom
    in
    { gameState
        | appState =
            Quest
                { rooms = questWithUpdatedHp.rooms
                , player = questWithUpdatedHp.player
                , currentRoom =
                    { currentRoom
                        | turn = newTurn
                    }
                }
    }


checkIfPlayerDead : B.UpdateFunction GameState
checkIfPlayerDead delta currentUpdate gameState =
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
