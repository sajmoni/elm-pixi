module Main exposing (init)

import Browser.Events
import Decode exposing (..)
import Encode exposing (..)
import Json.Encode exposing (..)
import Juice exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Platform
import Port
import Quest as QuestModule
import Shared exposing (..)
import Time
import Title as TitleModule
import Town as TownModule


init : flags -> ( Model, Cmd msg )
init _ =
    let
        behaviors =
            TitleModule.behaviors

        gameState =
            { monsterX = 10
            , textColor = "red"
            , quest =
                QuestType
                    { index = 1
                    , turn = Player
                    , currentHp = 100
                    , maxHp = 100

                    -- , render =
                    --     Pixi.animatedSprite
                    --         { id = "test", x = 400, y = 140, scale = Just 8, alpha = Nothing }
                    --         { textures = [ "monster_17", "monster_18" ], animationSpeed = Just 0.02 }
                    }
            }

        initialModel =
            { updates = 0
            , behaviors = behaviors
            , appState = Title
            , gameState = gameState
            }
    in
    ( initialModel, Port.init (encodeEntities (view initialModel)) )



-- updateEntities : Delta -> Int -> List Entity -> List Behavior -> List Entity
-- updateEntities delta updates entities behaviors =
--     behaviors
--         |> List.foldl (runUpdates delta updates) entities
-- runUpdates : Delta -> Int -> Behavior -> List Entity -> List Entity
-- runUpdates delta updates behavior entities =
--     List.map (updateEntity delta updates behavior) entities
-- updateEntity : Delta -> Int -> Behavior -> Entity -> Entity
-- updateEntity delta updates behavior entity =
--     case entity of
--         AnimatedSprite basicData animatedSpriteData ->
--             Pixi.animatedSprite (behavior delta updates basicData) (AnimatedSpriteData animatedSpriteData.textures animatedSpriteData.animationSpeed)
--         Text basicData textData ->
--             Pixi.text (behavior delta updates basicData) (TextData textData.textString textData.textStyle)
--         _ ->
--             Debug.todo "Blah!"
-- interactionOrNoop : String -> String -> Interaction -> Msg
-- interactionOrNoop idToCheck eventToCheck { id, event, msg } =
--     if eventToCheck == event && idToCheck == id then
--         msg
--     else
--         Noop
-- isNoop : Msg -> Bool
-- isNoop msg =
--     case msg of
--         Noop ->
--             True
--         _ ->
--             False
-- removeEntity : String -> Entity -> Bool
-- removeEntity id entity =
--     let
--         basicData =
--             getBasicData entity
--     in
--     if basicData.id == id then
--         False
--     else
--         True
-- Why is this even needed?? Must be a simpler way


callUpdate : (Msg -> Model -> ( Model, Cmd Msg )) -> Msg -> Model -> Model
callUpdate updateFn msg prevModel =
    let
        ( model, _ ) =
            updateFn msg prevModel
    in
    model



-- setTextColor : Id -> String -> Entity -> Entity
-- setTextColor id color entity =
--     case entity of
--         Text basicData textData ->
--             let
--                 textStyle =
--                     textData.textStyle
--             in
--             if id == basicData.id then
--                 Pixi.text basicData { textData | textStyle = { textStyle | fill = color } }
--             else
--                 entity
--         _ ->
--             entity
-- setText : Id -> String -> Entity -> Entity
-- setText id text entity =
--     case entity of
--         Text basicData textData ->
--             if id == basicData.id then
--                 Pixi.text basicData { textData | textString = text }
--             else
--                 entity
--         _ ->
--             entity
-- processInteraction : String -> String -> List Interaction -> List Msg
-- processInteraction id event interactions =
--     interactions |> List.map (interactionOrNoop id event) |> List.filter (isNoop >> not)


initScene : Int -> AppState -> GameState -> Model -> Model
initScene updates appState gameState model =
    case appState of
        Town ->
            { model
                | behaviors = TownModule.behaviors
            }

        Quest ->
            { model
                | behaviors = QuestModule.behaviors
            }

        _ ->
            Debug.todo "initScene" appState



-- updateGameState : Int -> GameState -> (Int -> GameState -> List Msg) -> List Msg -> List Msg
-- updateGameState updates gameState gameStateUpdate messages =
--     messages |> List.append (gameStateUpdate updates gameState)


updateGameState : Delta -> Int -> GameState -> List Behavior -> GameState
updateGameState delta updates gameState behaviors =
    behaviors |> List.foldl (updater delta updates) gameState


updater : Delta -> Int -> Behavior -> GameState -> GameState
updater delta updates behavior gameState =
    behavior delta updates gameState


setTextColor : String -> GameState -> GameState
setTextColor color gameState =
    { gameState
        | textColor = color
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg lastModel =
    let
        newModel =
            case msg of
                Noop ->
                    lastModel

                ChangeAppState appState ->
                    { lastModel
                        | appState = appState
                    }
                        |> initScene lastModel.updates appState lastModel.gameState

                SetEnemyHp hp ->
                    { lastModel
                        | gameState = QuestModule.setEnemyHp hp lastModel.gameState
                    }

                SetTurn turn ->
                    { lastModel
                        | gameState = QuestModule.setTurn turn lastModel.gameState
                    }

                SetTextColor color ->
                    { lastModel
                        | gameState = setTextColor color lastModel.gameState
                    }

                DealDamage ->
                    { lastModel
                        | gameState = QuestModule.dealDamage lastModel.gameState
                    }

                Tick delta ->
                    -- let
                    -- messages =
                    --     lastModel.gameStateUpdates
                    -- |> List.foldl (updateGameState lastModel.updates lastModel.gameState) []
                    -- updatedModel =
                    --     messages |> List.foldl (callUpdate update) lastModel
                    -- in
                    { lastModel
                        | updates = lastModel.updates + 1
                        , gameState = lastModel.behaviors |> updateGameState delta lastModel.updates lastModel.gameState
                    }
    in
    ( newModel
    , Port.update (encodeEntities (view newModel))
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Port.incoming decodePixiEvent, Browser.Events.onAnimationFrameDelta Tick ]


view : Model -> List (Entity Msg)
view model =
    case model.appState of
        Title ->
            TitleModule.render model

        Quest ->
            QuestModule.render model

        _ ->
            Debug.todo "More views"


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
