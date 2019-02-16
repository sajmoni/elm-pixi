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


type alias Interaction =
    String -> String -> BasicData -> ( BasicData, Msg )


type AppState
    = MainMenu
    | Game


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    , interactions : List Interaction
    , appState : AppState
    }


type Msg
    = Interaction InteractionData
    | RemoveEntity String
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
            , resetX "monster1" "click"
            , makeSetTextColor "red" "startButton" "mouseover"
            , makeSetTextColor "yellow" "startButton" "mouseout"
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


applyInteractionToEntity : String -> String -> Interaction -> Entity -> ( Entity, Msg )
applyInteractionToEntity id event interaction entity =
    case entity of
        AnimatedSprite basicData animatedSpriteData ->
            let
                ( newBasicData, msg ) =
                    interaction id event basicData
            in
            ( Pixi.animatedSprite newBasicData (AnimatedSpriteData animatedSpriteData.textures animatedSpriteData.animationSpeed), msg )

        Text basicData textData ->
            let
                ( newBasicData, msg ) =
                    interaction id event basicData
            in
            ( Pixi.text newBasicData (TextData textData.textString textData.textStyle), msg )

        _ ->
            Debug.todo "Blah!"


type alias InteractionResult =
    { entities : List Entity
    , messages : List Msg
    }


resetX : String -> String -> Interaction
resetX idToCheck eventToCheck id event data =
    if eventToCheck == event && idToCheck == id && data.id == idToCheck then
        ( data, RemoveEntity idToCheck )

    else
        ( data, Noop )


changeAppState : String -> String -> Interaction
changeAppState idToCheck eventToCheck id event data =
    if eventToCheck == event && idToCheck == id && data.id == idToCheck then
        ( data, ChangeAppState Game )

    else
        ( data, Noop )


makeSetTextColor : String -> String -> String -> Interaction
makeSetTextColor color idToCheck eventToCheck id event data =
    if eventToCheck == event && idToCheck == id && data.id == idToCheck then
        ( data, SetTextColor idToCheck color )

    else
        ( data, Noop )



-- highlightText : String -> String -> Interaction
-- highlightText idToCheck eventToCheck id event data =


handleInteraction : String -> String -> Interaction -> InteractionResult -> InteractionResult
handleInteraction id event interaction result =
    let
        tuples =
            List.map (applyInteractionToEntity id event interaction) result.entities
    in
    { entities = List.map Tuple.first tuples
    , messages = List.append result.messages (List.map Tuple.second tuples)
    }


isNoop : Msg -> Bool
isNoop msg =
    case msg of
        Noop ->
            True

        _ ->
            False


handleInteractions : String -> String -> List Entity -> List Interaction -> InteractionResult
handleInteractions id event entities interactions =
    let
        result =
            interactions |> List.foldl (handleInteraction id event) (InteractionResult entities [])
    in
    { result
        | messages = List.filter (isNoop >> not) result.messages
    }


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg lastModel =
    let
        newModel =
            case msg of
                Interaction { id, event } ->
                    let
                        list =
                            handleInteractions id event lastModel.entities lastModel.interactions

                        updatedModel =
                            { lastModel | entities = list.entities }
                    in
                    list.messages |> List.foldl (callUpdate update) updatedModel

                RemoveEntity id ->
                    { lastModel | entities = List.filter (removeEntity id) lastModel.entities }

                Noop ->
                    lastModel

                ChangeAppState appState ->
                    let
                        _ =
                            Debug.log "appstate" appState
                    in
                    { lastModel
                        | appState = appState
                    }

                SetTextColor id color ->
                    let
                        _ =
                            Debug.log "color" color
                    in
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
