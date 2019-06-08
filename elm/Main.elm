module Main exposing (init)

import Accessory exposing (..)
import Armor exposing (..)
import Behavior as B
import Browser.Events
import Data exposing (..)
import Decode exposing (..)
import Encode exposing (..)
import Glove exposing (..)
import Helmet exposing (..)
import Json.Encode exposing (..)
import Juice exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Platform
import Port
import Quest as QuestModule
import Random
import Time
import Title as TitleModule
import Town as TownModule
import Weapon exposing (..)


init : flags -> ( Model, Cmd msg )
init _ =
    let
        behaviors =
            TitleModule.behaviors 0

        gameState =
            { monsterX = 10
            , textColor = "#ff0000"
            , mana = 100
            , appState = Title
            , inventory =
                { weapon = Just sword2
                , helmet = Just helmet1
                , armor = Just armor1
                , glove = Just glove1
                , accessory = Just accessory1
                }
            }

        initialModel =
            { updates = 0
            , behaviors = behaviors
            , gameState = gameState
            }
    in
    ( initialModel, Port.init (encodeEntities (view initialModel)) )


initScene : Int -> AppState -> Model -> ( Model, Cmd Msg )
initScene updates appState model =
    let
        gameState =
            model.gameState
    in
    case appState of
        Town ->
            ( { model
                | behaviors = TownModule.behaviors
                , gameState = { gameState | appState = appState }
              }
            , Cmd.none
            )

        Quest _ ->
            ( { model
                | behaviors = QuestModule.behaviors model.updates
                , gameState = { gameState | appState = appState }
              }
            , Cmd.none
            )

        _ ->
            Debug.todo "initScene" appState


setTextColor : String -> GameState -> GameState
setTextColor color gameState =
    { gameState
        | textColor = color
    }


generateNewQuest : Model -> ( Model, Cmd Msg )
generateNewQuest model =
    ( model
    , Random.generate NewQuestGenerated (Random.list 10 (Random.int 0 2))
    )


newQuestGenerated : List Int -> Model -> ( Model, Cmd Msg )
newQuestGenerated list model =
    let
        gameState =
            model.gameState

        rooms =
            getQuest list

        currentRoom =
            getCurrentRoom 0 rooms

        player =
            { maxHp = 100
            , currentHp = 100
            , textures = [ "player_01", "player_02", "player_03", "player_04" ]
            , attacking = False
            }
    in
    case currentRoom of
        Just room ->
            initScene model.updates (Quest { player = player, rooms = rooms, currentRoom = room }) model

        Nothing ->
            Debug.todo "Handle reaching the last room"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg lastModel =
    let
        ( newModel, commands ) =
            case msg of
                Noop ->
                    ( lastModel, Cmd.none )

                ChangeAppState appState ->
                    lastModel |> initScene lastModel.updates appState

                SetTextColor color ->
                    ( { lastModel
                        | gameState = setTextColor color lastModel.gameState
                      }
                    , Cmd.none
                    )

                DealDamage ->
                    ( { lastModel
                        | gameState = lastModel.gameState |> QuestModule.dealDamage |> QuestModule.spendMana
                      }
                    , Cmd.none
                    )

                GenerateNewQuest ->
                    generateNewQuest lastModel

                NewQuestGenerated list ->
                    newQuestGenerated list lastModel

                Tick delta ->
                    let
                        ( newGameState, newBehaviors ) =
                            lastModel.behaviors |> B.updateGameState delta lastModel.updates lastModel.gameState
                    in
                    ( { lastModel
                        | updates = lastModel.updates + 1
                        , gameState = newGameState
                        , behaviors = newBehaviors
                      }
                    , Cmd.none
                    )
    in
    ( newModel
    , Cmd.batch [ Port.update (encodeEntities (view newModel)), commands ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Port.incoming decodePixiEvent, Browser.Events.onAnimationFrameDelta Tick ]


view : Model -> List (Entity Msg)
view model =
    case model.gameState.appState of
        Title ->
            TitleModule.render model

        Quest questData ->
            QuestModule.render model questData

        _ ->
            Debug.todo "More views"


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
