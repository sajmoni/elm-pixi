module Main exposing (init)

import Browser.Events
import Encode exposing (..)
import Json.Encode exposing (..)
import Juice exposing (..)
import Pixi exposing (..)
import Platform
import Port
import Shared exposing (Delta, InteractionData)
import Time


type alias Behavior =
    Delta -> Int -> BasicData -> BasicData


type alias InteractionAlias =
    { id : String
    , event : String
    , msg : Msg
    }


type AppState
    = MainMenu
    | Game


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    , interactions : List InteractionAlias
    , appState : AppState
    }


type Msg
    = Interaction InteractionData
    | RemoveEntity String
    | AddEntity Entity
    | SetTextColor Id String
    | Noop
    | ChangeAppState AppState
    | Tick Delta


initialSceneEntities : List Entity
initialSceneEntities =
    [ animatedSprite
        { id = "monster1", x = 45, y = 45, scale = Just 3 }
        { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    , text
        { id = "text1", x = 280, y = 145, scale = Just 4 }
        { textString = "ElmQuest", textStyle = { fill = "white", fontSize = 72 } }
    , text
        { id = "startButton", x = 145, y = 300, scale = Just 1 }
        { textString = "Touch to Start", textStyle = { fill = "white", fontSize = 42 } }
    ]


init : flags -> ( Model, Cmd msg )
init _ =
    let
        entities =
            initialSceneEntities

        behaviors =
            [ moveRight "monster1"
            , updateScale sine "text1" 4
            ]

        interactions =
            [ changeAppState "startButton" "click"
            , InteractionAlias "startButton" "click" (RemoveEntity "monster1")
            , makeSetTextColor "red" "startButton" "mouseover"
            , makeSetTextColor "yellow" "startButton" "mouseout"
            , createEntity "startButton" "click"
            , makeSetTextColor "red" "startButton" "click"
            ]

        initialModel =
            { updates = 0
            , entities = entities
            , behaviors = behaviors
            , interactions = interactions
            , appState = MainMenu
            }
    in
    ( initialModel, Port.init (encodeEntities initialModel.entities) )


updateEntities : Delta -> Int -> List Entity -> List Behavior -> List Entity
updateEntities delta updates entities behaviors =
    behaviors
        |> List.foldl (runUpdates delta updates) entities


runUpdates : Delta -> Int -> Behavior -> List Entity -> List Entity
runUpdates delta updates behavior entities =
    List.map (updateEntity delta updates behavior) entities


sine : Juicer
sine =
    Juice.sine { start = 1, end = 1.2, duration = 120 }


updateScale : Juicer -> String -> Float -> Behavior
updateScale getScale entityId originalScale delta updates data =
    if entityId == data.id then
        { data | scale = Just (getScale updates * originalScale) }

    else
        data


moveRight : String -> Behavior
moveRight entityId delta updates data =
    if entityId == data.id then
        { data | x = data.x + 10 / delta }

    else
        data


updateEntity : Delta -> Int -> Behavior -> Entity -> Entity
updateEntity delta updates behavior entity =
    case entity of
        AnimatedSprite basicData animatedSpriteData ->
            Pixi.animatedSprite (behavior delta updates basicData) (AnimatedSpriteData animatedSpriteData.textures animatedSpriteData.animationSpeed)

        Text basicData textData ->
            Pixi.text (behavior delta updates basicData) (TextData textData.textString textData.textStyle)

        _ ->
            Debug.todo "Blah!"


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
    InteractionAlias id event (ChangeAppState Game)



-- makeSetTextColor : String -> String -> String -> Interaction
-- makeSetTextColor color idToCheck eventToCheck id event data =
--     if eventToCheck == event && idToCheck == id && data.id == idToCheck then
--         ( data, SetTextColor idToCheck color )
--     else
--         ( data, Noop )


makeSetTextColor : String -> String -> String -> InteractionAlias
makeSetTextColor color id event =
    InteractionAlias id event (SetTextColor id color)


interactionOrNoop : String -> String -> InteractionAlias -> Msg
interactionOrNoop idToCheck eventToCheck { id, event, msg } =
    if eventToCheck == event && idToCheck == id then
        msg

    else
        Noop


isNoop : Msg -> Bool
isNoop msg =
    case msg of
        Noop ->
            True

        _ ->
            False


removeEntity : String -> Entity -> Bool
removeEntity id entity =
    let
        basicData =
            getBasicData entity
    in
    if basicData.id == id then
        False

    else
        True



-- Why is this even needed?? Must be a simpler way


callUpdate : (Msg -> Model -> ( Model, Cmd Msg )) -> Msg -> Model -> Model
callUpdate updateFn msg prevModel =
    let
        ( model, _ ) =
            updateFn msg prevModel
    in
    model


setTextColor : Id -> String -> Entity -> Entity
setTextColor id color entity =
    case entity of
        Text basicData textData ->
            let
                textStyle =
                    textData.textStyle
            in
            if id == basicData.id then
                Pixi.text basicData { textData | textStyle = { textStyle | fill = color } }

            else
                entity

        _ ->
            entity


processInteraction : String -> String -> List InteractionAlias -> List Msg
processInteraction id event interactions =
    interactions |> List.map (interactionOrNoop id event) |> List.filter (isNoop >> not)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg lastModel =
    let
        newModel =
            case msg of
                Interaction { id, event } ->
                    let
                        messages =
                            lastModel.interactions |> processInteraction id event
                    in
                    messages |> List.foldl (callUpdate update) lastModel

                RemoveEntity id ->
                    { lastModel | entities = List.filter (removeEntity id) lastModel.entities }

                AddEntity entity ->
                    { lastModel | entities = entity :: lastModel.entities }

                Noop ->
                    lastModel

                ChangeAppState appState ->
                    { lastModel
                        | appState = appState
                    }

                SetTextColor id color ->
                    { lastModel
                        | entities = List.map (setTextColor id color) lastModel.entities
                    }

                Tick delta ->
                    { lastModel
                        | updates = lastModel.updates + 1
                        , entities = updateEntities delta lastModel.updates lastModel.entities lastModel.behaviors
                    }
    in
    ( newModel
    , Port.update (encodeEntities newModel.entities)
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Port.incoming Interaction, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
