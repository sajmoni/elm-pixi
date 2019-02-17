module Title exposing (behaviors, entities, interactions)

import Juice exposing (..)
import Msg exposing (..)
import Pixi
import Shared exposing (..)


entities : List Pixi.Entity
entities =
    [ Pixi.animatedSprite
        { id = "monster1", x = 45, y = 45, scale = Just 3 }
        { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    , Pixi.text
        { id = "text1", x = 280, y = 145, scale = Just 4 }
        { textString = "ElmQuest", textStyle = { fill = "white", fontSize = 72 } }
    , Pixi.text
        { id = "startButton", x = 145, y = 300, scale = Just 1 }
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


interactions : List InteractionAlias
interactions =
    [ changeAppState "startButton" "click"
    , InteractionAlias "startButton" "click" (RemoveEntity "monster1")
    , makeSetTextColor "red" "startButton" "mouseover"
    , makeSetTextColor "yellow" "startButton" "mouseout"
    , createEntity "startButton" "click"
    , makeSetTextColor "red" "startButton" "click"
    ]


deleteEntity : String -> String -> InteractionAlias
deleteEntity id event =
    InteractionAlias id event (RemoveEntity id)


createEntity : String -> String -> InteractionAlias
createEntity id event =
    let
        newEntity =
            Pixi.animatedSprite { id = "monster2", x = 105, y = 145, scale = Just 3 } { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    in
    InteractionAlias id event (AddEntity newEntity)


changeAppState : String -> String -> InteractionAlias
changeAppState id event =
    InteractionAlias id event (ChangeAppState Town)


makeSetTextColor : String -> String -> String -> InteractionAlias
makeSetTextColor color id event =
    InteractionAlias id event (SetTextColor id color)
