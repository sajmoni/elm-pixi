module Title exposing (behaviors, entities, interactions)

import Juice exposing (..)
import Msg exposing (..)
import Pixi
import Shared exposing (..)


entities : List Pixi.Entity
entities =
    [ Pixi.animatedSprite
        { id = "monster1", x = 45, y = 45, scale = Just 3, alpha = Nothing }
        { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    , Pixi.text
        { id = "text1", x = 280, y = 145, scale = Just 4, alpha = Nothing }
        { textString = "ElmQuest", textStyle = { fill = "white", fontSize = 72 } }
    , Pixi.text
        { id = "startButton", x = 145, y = 300, scale = Just 1, alpha = Nothing }
        { textString = "Touch to Start", textStyle = { fill = "white", fontSize = 42 } }
    ]



-- Behaviors


behaviors =
    [ moveRight "monster1"
    , updateScale sine "text1" 4
    ]


moveRight : String -> Behavior
moveRight entityId delta updates data =
    if entityId == data.id then
        { data | x = data.x + 10 / delta }

    else
        data


sine : Juicer
sine =
    Juice.sine { start = 1, end = 1.2, duration = 120 }


updateScale : Juicer -> String -> Float -> Behavior
updateScale getScale entityId originalScale delta updates data =
    if entityId == data.id then
        { data | scale = Just (getScale updates * originalScale) }

    else
        data



-- Interactions


interactions : List Interaction
interactions =
    [ changeAppState "startButton" "click"
    , Interaction "startButton" "click" (RemoveEntity "monster1")
    , makeSetTextColor "red" "startButton" "mouseover"
    , makeSetTextColor "yellow" "startButton" "mouseout"

    -- , createEntity "startButton" "click"
    , makeSetTextColor "red" "startButton" "click"
    ]


deleteEntity : String -> String -> Interaction
deleteEntity id event =
    Interaction id event (RemoveEntity id)


createEntity : String -> String -> Interaction
createEntity id event =
    let
        newEntity =
            Pixi.animatedSprite
                { id = "monster2", x = 105, y = 145, scale = Just 3, alpha = Nothing }
                { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    in
    Interaction id event (AddEntity newEntity)


changeAppState : String -> String -> Interaction
changeAppState id event =
    Interaction id event (ChangeAppState Quest)


makeSetTextColor : String -> String -> String -> Interaction
makeSetTextColor color id event =
    Interaction id event (SetTextColor id color)
