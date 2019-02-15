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


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    , interactions : List Interaction
    }


type Msg
    = Interaction InteractionData
    | RemoveEntity String
    | Noop
    | Tick Delta


initialSceneEntities : List Entity
initialSceneEntities =
    [ animatedSprite
        { id = "monster1", x = 45, y = 45, scale = Just 3 }
        { textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    , text
        { id = "text1", x = 145, y = 145, scale = Just 4 }
        { textString = "ElmQuest", textStyle = { fill = "white", fontSize = 72 } }
    , text
        { id = "startButton", x = 145, y = 300, scale = Just 4 }
        { textString = "Touch to Start", textStyle = { fill = "white", fontSize = 42 } }
    ]


init : flags -> ( Model, Cmd msg )
init _ =
    let
        entities =
            initialSceneEntities

        behaviors =
            [ moveRight "monster1"
            , updateScale sine "text1"
            ]

        interactions =
            [ resetX "monster1" "click"
            ]

        initialModel =
            { updates = 0
            , entities = entities
            , behaviors = behaviors
            , interactions = interactions
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


updateScale : Juicer -> String -> Behavior
updateScale getScale entityId delta updates data =
    if entityId == data.id then
        { data | scale = Just (getScale updates) }

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


resetX : String -> String -> Interaction
resetX idToCheck eventToCheck id event data =
    if eventToCheck == event && idToCheck == id && data.id == idToCheck then
        ( { data | x = 0 }, RemoveEntity idToCheck )

    else
        ( data, Noop )


handleInteraction : String -> String -> Interaction -> List ( Entity, Msg ) -> List ( Entity, Msg )
handleInteraction id event interaction list =
    List.map (applyInteractionToEntity id event interaction) (List.map Tuple.first list)


toTuples entities =
    List.map foo entities


foo entity =
    ( entity, Noop )


handleInteractions : String -> String -> List Entity -> List Interaction -> List ( Entity, Msg )
handleInteractions id event entities interactions =
    interactions |> List.foldl (handleInteraction id event) (toTuples entities)



-- updateEntities : Delta -> Int -> List Entity -> List Behavior -> List Entity
-- updateEntities delta updates entities behaviors =
--     behaviors
--         |> List.foldl (runUpdates delta updates) entities
-- foo id event


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


callUpdate : (Msg -> Model -> ( Model, Cmd Msg )) -> Msg -> Model -> Model
callUpdate updateFn msg prevModel =
    let
        ( model, _ ) =
            updateFn msg prevModel
    in
    model


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
                            { lastModel | entities = List.map Tuple.first list }
                    in
                    -- { lastModel | entities = List.filter (handleInteraction id event) lastModel.entities }
                    list |> List.map Tuple.second |> List.foldl (callUpdate update) updatedModel

                RemoveEntity id ->
                    { lastModel | entities = List.filter (removeEntity id) lastModel.entities }

                Noop ->
                    lastModel

                Tick delta ->
                    { lastModel
                        | updates = lastModel.updates + 1
                        , entities = updateEntities delta lastModel.updates lastModel.entities lastModel.behaviors
                    }
    in
    ( newModel
    , Cmd.batch [ Port.update (encodeEntities newModel.entities) ]
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
