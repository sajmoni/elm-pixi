module Behavior exposing (Behavior, BehaviorType(..), Cmd(..), Loop, UpdateFunction, add, append, batch, none, once, processCmdList, remove, repeat, shouldExecuteUpdate, updateGameState, updater)


type alias Loop =
    Bool


type BehaviorType
    = Repeat
    | Once


type Cmd gameState
    = Add (Behavior gameState)
    | Remove String
    | None
    | Batch (List (Cmd gameState))


add : Behavior gameState -> Cmd gameState
add behavior =
    Add behavior


remove : String -> Cmd gameState
remove id =
    Remove id


none : Cmd gameState
none =
    None


batch : List (Cmd gameState) -> Cmd gameState
batch list =
    Batch list


append : Cmd gameState -> Cmd gameState -> Cmd gameState
append cmd1 cmd2 =
    case cmd1 of
        Batch list1 ->
            case cmd2 of
                Batch list2 ->
                    batch (List.append list1 list2)

                None ->
                    batch (None :: list1)

                Add behavior ->
                    batch (Add behavior :: list1)

                Remove id ->
                    batch (Remove id :: list1)

        None ->
            case cmd2 of
                Batch list2 ->
                    batch (None :: list2)

                None ->
                    None

                Add behavior ->
                    batch [ None, Add behavior ]

                Remove id ->
                    batch [ None, Remove id ]

        Add behavior ->
            case cmd2 of
                Batch list ->
                    batch (Add behavior :: list)

                None ->
                    batch [ Add behavior, None ]

                Add behavior2 ->
                    batch [ Add behavior, Add behavior2 ]

                Remove id ->
                    batch [ Add behavior, Remove id ]

        Remove id ->
            case cmd2 of
                Batch list ->
                    batch (Remove id :: list)

                None ->
                    batch [ Remove id, None ]

                Add behavior ->
                    batch [ Remove id, Add behavior ]

                Remove id2 ->
                    batch [ Remove id, Remove id2 ]


type alias UpdateFunction gameState =
    Float -> Int -> gameState -> ( gameState, Cmd gameState )


type alias Behavior gameState =
    { updateFunction : UpdateFunction gameState
    , firstUpdate : Int
    , timer : Int
    , id : String
    , behaviorType : BehaviorType
    }


repeat : String -> UpdateFunction gameState -> Int -> Int -> Behavior gameState
repeat id updateFunction timer currentUpdate =
    { updateFunction = updateFunction
    , timer = timer
    , id = id
    , firstUpdate = currentUpdate
    , behaviorType = Repeat
    }


once : String -> UpdateFunction gameState -> Int -> Int -> Behavior gameState
once id updateFunction timer currentUpdate =
    { updateFunction = updateFunction
    , timer = timer
    , id = id
    , firstUpdate = currentUpdate
    , behaviorType = Once
    }


shouldExecuteUpdate : Int -> Int -> Int -> Bool
shouldExecuteUpdate firstUpdate everyNthUpdate currentUpdate =
    modBy everyNthUpdate (currentUpdate - firstUpdate) == 0


processCmdList : List (Behavior gameState) -> Cmd gameState -> List (Behavior gameState)
processCmdList behaviors cmdList =
    let
        _ =
            Debug.log "cmdList" cmdList
    in
    case cmdList of
        -- Batch list ->
        --     let
        --         result =
        --             List.concatMap (processCmdList behaviors) list
        --         _ =
        --             Debug.log "BATCH result" result
        --     in
        --     result
        Add behavior ->
            let
                _ =
                    Debug.log "ADDING" behavior

                alreadyExists =
                    behaviors |> List.map .id |> List.member behavior.id
            in
            if alreadyExists then
                let
                    _ =
                        Debug.log "Error: behavior with id already exists, id: " behavior.id
                in
                behaviors

            else
                behavior :: behaviors

        Remove id ->
            let
                _ =
                    Debug.log "REMOVING" id
            in
            List.filter (\b -> b.id /= id) behaviors

        None ->
            behaviors

        _ ->
            Debug.todo "batched commands"


updateGameState : Float -> Int -> gameState -> List (Behavior gameState) -> ( gameState, List (Behavior gameState) )
updateGameState delta currentUpdate gameState behaviors =
    let
        ( newGameState, cmdList ) =
            behaviors |> List.foldl (updater delta currentUpdate) ( gameState, none )

        newBehaviors =
            processCmdList behaviors cmdList
    in
    ( newGameState, newBehaviors )


updater : Float -> Int -> Behavior gameState -> ( gameState, Cmd gameState ) -> ( gameState, Cmd gameState )
updater delta currentUpdate behavior ( gameState, cmdList ) =
    let
        shouldUpdate =
            shouldExecuteUpdate behavior.firstUpdate behavior.timer currentUpdate
    in
    if shouldUpdate then
        let
            ( newGameState, newCmdList ) =
                behavior.updateFunction delta currentUpdate gameState
        in
        ( newGameState, append newCmdList cmdList )

    else
        ( gameState, cmdList )
