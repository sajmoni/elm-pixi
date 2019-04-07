module Behavior exposing (Behavior, BehaviorType(..), Loop, UpdateFunction, once, repeat, shouldExecuteUpdate, updateGameState, updater)


type alias Loop =
    Bool


type BehaviorType
    = Repeat
    | Once


type alias UpdateFunction gameState =
    Float -> Int -> gameState -> gameState


type alias Behavior gameState =
    { updateFunction : UpdateFunction gameState
    , firstUpdate : Int
    , timer : Int
    , behaviorType : BehaviorType
    }


repeat : UpdateFunction gameState -> Int -> Int -> Behavior gameState
repeat updateFunction timer currentUpdate =
    { updateFunction = updateFunction
    , timer = timer
    , firstUpdate = currentUpdate
    , behaviorType = Repeat
    }


once : UpdateFunction gameState -> Int -> Int -> Behavior gameState
once updateFunction timer currentUpdate =
    { updateFunction = updateFunction
    , timer = timer
    , firstUpdate = currentUpdate
    , behaviorType = Once
    }


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate (currentUpdate - firstUpdate) == 0


updateGameState : Float -> Int -> gameState -> List (Behavior gameState) -> gameState
updateGameState delta currentUpdate gameState behaviors =
    behaviors |> List.foldl (updater delta currentUpdate) gameState


updater : Float -> Int -> Behavior gameState -> gameState -> gameState
updater delta currentUpdate behavior gameState =
    let
        shouldUpdate =
            shouldExecuteUpdate behavior.firstUpdate behavior.timer currentUpdate
    in
    if shouldUpdate then
        behavior.updateFunction delta currentUpdate gameState

    else
        gameState
