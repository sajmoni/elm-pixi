module Quest exposing (behaviors, entities, interactions)

import Msg exposing (..)
import Pixi
import Shared exposing (..)


entities : GameState -> List Pixi.Entity
entities gameState =
    gameState.quest.rooms.render
        :: List.append skillBar
            [ Pixi.text
                { id = "questTitle", x = 280, y = 80, scale = Nothing }
                { textString = "Quest", textStyle = { fill = "white", fontSize = 12 } }
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
        { id = "skill1", x = skillStartPositionX, y = skillStartPositionY, scale = Just 4 }
        { texture = "skill_001" }
    , Pixi.sprite
        { id = "skill2", x = skillStartPositionX + skillWidth, y = skillStartPositionY, scale = Just 4 }
        { texture = "skill_002" }
    , Pixi.sprite
        { id = "skill3", x = skillStartPositionX + skillWidth * 2, y = skillStartPositionY, scale = Just 4 }
        { texture = "skill_003" }
    , Pixi.sprite
        { id = "skill4", x = skillStartPositionX + skillWidth * 3, y = skillStartPositionY, scale = Just 4 }
        { texture = "skill_004" }
    , Pixi.sprite
        { id = "skill5", x = skillStartPositionX + skillWidth * 4, y = skillStartPositionY, scale = Just 4 }
        { texture = "skill_005" }
    ]
