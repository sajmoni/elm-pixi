module Title exposing (behaviors, render)

import Behavior as B
import Juice exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Pixi exposing (..)


behaviors : Int -> List (B.Behavior GameState)
behaviors currentUpdate =
    [ B.repeat moveRight 1 currentUpdate
    ]


moveRight : B.UpdateFunction GameState
moveRight delta _ gameState =
    { gameState | monsterX = gameState.monsterX + (10 / delta) }



-- moveRight : Behavior
-- moveRight delta updates gameState =
--     { gameState | monsterX = gameState.monsterX + (10 / delta) }


getScale : Juicer
getScale =
    Juice.sine { start = 1, end = 1.1, duration = 120 }


render : Model -> List (Pixi.Entity Msg)
render model =
    [ Pixi.text
        [ id "text1", x 320, y 400, textString "ElmQuest", scale (getScale model.updates), textStyle [ fontSize 140 ] ]
        []
    , Pixi.sprite
        [ id "sprite1", x model.gameState.monsterX, y 100, texture "monster_01", scale 2 ]
        []
    , Pixi.text
        [ id "startButton"
        , x 300
        , y 600
        , scale 1
        , textString "Touch to start!"
        , on "click" GenerateNewQuest
        , on "mouseover" (SetTextColor "yellow")
        , textStyle [ fill model.gameState.textColor, fontSize 60 ]
        ]
        []
    ]
